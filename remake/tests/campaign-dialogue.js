import { campaignSaveCodec } from '../js/core/campaign-saves.js';
import { createCharacter } from '../js/core/character.js';
import { createRoomGeometries, roomAt } from '../js/core/room-walk.js';
import { createCityMaps } from '../js/core/city-map.js';
import { createCityGeometry, SHIP_REENTRY } from '../js/core/city-walk.js';
import { populateRoom } from '../js/core/room-actors.js';
import { initialRoomTraffic } from '../js/core/room-traffic.js';
import { initialCounter, reduceCampaignCounter, restoreCampaignConversation } from '../js/core/campaign-dialogue.js';

export async function campaignDialogueTests(test,equal) {
  const [layouts,maps,navigation,economy,location,cityData,inventory,ship,scripts,text,items,systems]=await Promise.all([
    'room-walk','maps','initial-navigation','initial-economy','initial-location','city-walk','ship-inventory','ship-walk',
    'dialogue','dialogue-text','items','dialogue-systems',
  ].map(n=>fetch(`../data/${n}.json`).then(r=>r.json())));
  const content={navigation,economy,location,inventory,dialogue:{scripts,text,items,systems}};
  const city=createCityGeometry(createCityMaps(maps,navigation,economy)['city-01'],cityData,{...location,position:location.shipPosition});
  city.rooms=createRoomGeometries(layouts);
  const codec=campaignSaveCodec(content,ship,city),fresh=()=>codec.create({...createCharacter(),name:'Counter pilot'},12345);
  const reject=fn=>{let message;try{fn()}catch(e){message=e.message}equal(message,'invalidCampaign')};
  function inRoom() {
    const state=fresh();state.ship.position={...SHIP_REENTRY};
    state.travel={scene:'room',cityPosition:{x:311,y:267},roomPosition:{x:14,y:71}};
    const room=roomAt(city.rooms,city.map,state.travel.cityPosition),p=populateRoom(room,12345);
    state.encounters={randomState:p.randomState,roomSeed:p.seed,roomState:initialRoomTraffic(p),counter:initialCounter()};
    return state;
  }
  const room=city.rooms[15],act=(state,action)=>reduceCampaignCounter(state,content,room,action).state;
  function talking(initial=inRoom()) {
    let state=act(initial,{type:'request'}),ticks=0;
    while(state.encounters.counter.service!=='talking'&&ticks++<500)state=act(state,{type:'tick'});
    equal(state.encounters.counter.service,'talking');return state;
  }
  await test('Purchases replay multiple transfers, then commit cash and inventory once without changing accounts or cargo',()=>{
    const initial=inRoom();initial.ship.inventory.carried=[0,0,0,0];
    // Withdraw within the existing wealth bound so equipment quotes are affordable.
    const funds=initial.economy.accounts[0].balance;initial.economy.accounts[0].balance=0;initial.dialogue.cash+=funds;
    let state=talking(initial),spent=0;
    const input=(s,input)=>act(s,{type:'dialogue',input});
    for(const slot of [0,1]) {
      state=input(state,{type:'item',item:23});state=input(state,{type:'reply',slot:1});
      const frame=restoreCampaignConversation(state,content,room).conversation;spent+=frame.state.locals[106];
      const quote=codec.make(state,0);equal(codec.parse(JSON.stringify(quote)).state,state);
      state=input(state,{type:'purchase',slot});
      equal(state.dialogue.cash,initial.dialogue.cash);equal(state.ship.inventory.carried,[0,0,0,0]);
      const save=codec.make(state,0);equal(save.version,15);equal(codec.parse(JSON.stringify(save)).state,state);
      const old=structuredClone(save);old.version=13;delete old.state.economy.personalTrade;old.scope='landed-exchange-1';reject(()=>codec.validate(old));
      const bad=structuredClone(save);bad.state.encounters.counter.conversation.inputs.at(-1).slot=4;reject(()=>codec.validate(bad));
      equal(restoreCampaignConversation(codec.parse(JSON.stringify(save)).state,content,room),restoreCampaignConversation(state,content,room));
    }
    const before=JSON.stringify(state),ended=input(state,{type:'cancel'});
    equal(ended.ship.inventory.carried,[23,23,0,0]);equal(ended.dialogue.cash,initial.dialogue.cash-spent);
    equal(ended.economy,initial.economy);equal(ended.start,initial.start);equal(ended.ship.inventory.stores,initial.ship.inventory.stores);
    equal(codec.parse(JSON.stringify(codec.make(ended,0))).state,ended);equal(JSON.stringify(state),before);
    const old=codec.make(talking(),0);old.version=13;delete old.state.economy.personalTrade;old.scope='landed-exchange-1';equal(codec.validate(old).version,15);
  });
  await test('Version10 owns active dialogue fields and migrates version7 without changing actor/RNG progress',()=>{
    const state=inRoom(),save=codec.make(state,0);equal(save.version,15);equal(save.scope,'landed-personal-trade-1');
    const old=structuredClone(save);old.version=7;delete old.state.economy;old.scope='landed-traffic-1';delete old.state.dialogue;delete old.state.encounters.counter;
    const before=JSON.stringify(old),loaded=codec.parse(before);equal(loaded,save);equal(JSON.stringify(old),before);
    old.state.encounters.counter=initialCounter();reject(()=>codec.validate(old));
    const bad=structuredClone(save);bad.version=7;delete bad.state.economy;bad.scope='landed-traffic-1';reject(()=>codec.validate(bad));
  });
  await test('Waiting and speaking saves restore source state and RNG through the replay record',()=>{
    let state=act(inRoom(),{type:'request'});
    const waiting=codec.parse(JSON.stringify(codec.make(state,1))).state;
    equal(act(waiting,{type:'tick'}),act(state,{type:'tick'}));
    state=talking();state=act(state,{type:'dialogue',input:{type:'reply',slot:2}});
    state=act(state,{type:'dialogue',input:{type:'item',item:23}});
    const before=JSON.stringify(state),saved=codec.make(state,2),loaded=codec.parse(JSON.stringify(saved)).state;
    equal(loaded,state);equal(saved.state.encounters.counter.conversation.inputs,[{type:'reply',slot:2},{type:'item',item:23}]);
    const frame=restoreCampaignConversation(loaded,content,room);equal(frame.conversation.view.state,161);
    equal(restoreCampaignConversation(state,content,room),frame);equal(JSON.stringify(state),before);
    equal(act(loaded,{type:'dialogue',input:{type:'cancel'}}),act(state,{type:'dialogue',input:{type:'cancel'}}));
  });
  await test('Version8 mid-conversation saves migrate to active cash without changing replay or RNG',()=>{
    const save=codec.make(talking(),0),old=structuredClone(save);
    old.version=8;delete old.state.economy;old.scope='landed-dialogue-1';delete old.state.dialogue.cash;
    equal(codec.validate(old),save);
    equal(restoreCampaignConversation(codec.validate(old).state,content,room),restoreCampaignConversation(save.state,content,room));
    old.state.dialogue.cash=old.state.start.credits;reject(()=>codec.validate(old));
  });
  await test('Conversation completion atomically persists source flags, staff mood and gate, then removes replay history',()=>{
    const state=talking(),before=JSON.stringify(state);
    const impatient=act(state,{type:'dialogue',input:{type:'timeout'}});
    const ended=act(impatient,{type:'dialogue',input:{type:'reply',slot:2}});
    equal(ended.encounters.counter,{service:'served',conversation:null});
    equal([ended.dialogue.workspace.mood,ended.dialogue.workspace.gate],[2,1]);
    equal(ended.dialogue.flags.slice(48,52),[false,false,false,false]);
    equal(ended.encounters.roomState.actors.at(-1).words[8],2);
    equal(codec.parse(JSON.stringify(codec.make(ended,0))).state,ended);
    equal(ended.start,state.start);equal(ended.ship,state.ship);equal(JSON.stringify(state),before);
  });
  await test('Dialogue imports reject invented internals, extra input fields, invalid sequences and RNG mismatches',()=>{
    const state=talking(),save=codec.make(state,0),before=JSON.stringify(save);
    for(const mutate of [
      s=>s.encounters.randomState++,s=>s.encounters.counter.conversation.seed++,
      s=>s.encounters.counter.conversation.text='invented',s=>s.encounters.counter.conversation.inputs=[{type:'cancel'}],
      s=>s.encounters.counter.conversation.inputs=[{type:'reply',slot:0}],
      s=>s.encounters.counter.conversation.inputs=[{type:'timeout',extra:true}],
      s=>s.encounters.counter.conversation.inputs=Array(1025).fill({type:'timeout'}),
      s=>s.encounters.counter.service='idle',s=>s.encounters.counter.conversation=null,
      s=>s.dialogue.attributes=[1],s=>s.dialogue.flags[65]=true,s=>s.dialogue.flags[1]=1,
      s=>s.dialogue.workspace.quantity=2,s=>s.dialogue.workspace.actor=1,s=>s.dialogue.workspace.extra=1,
      s=>s.dialogue.cash=999,s=>s.encounters.counter.extra=1,
    ]){const bad=structuredClone(save);mutate(bad.state);reject(()=>codec.validate(bad))}
    equal(JSON.stringify(save),before);
  });
  await test('Dialogue fields survive leaving and returning to city/ship without retaining an orphan conversation',()=>{
    const state=act(talking(),{type:'dialogue',input:{type:'cancel'}}),dialogue=structuredClone(state.dialogue);
    state.travel={scene:'city',cityPosition:state.travel.cityPosition};
    state.encounters={...state.encounters,roomSeed:null,roomState:null,counter:null};
    equal(codec.make(state,0).state.dialogue,dialogue);
    state.encounters.counter=initialCounter();reject(()=>codec.make(state,0));
    state.encounters.counter=null;state.travel={scene:'ship',cityPosition:null};
    equal(codec.make(state,0).state.dialogue,dialogue);
  });
}
