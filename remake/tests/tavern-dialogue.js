import { createRoomGeometries, roomAt } from '../js/core/room-walk.js';
import { populateRoom } from '../js/core/room-actors.js';
import { initialRoomTraffic, validateRoomTraffic } from '../js/core/room-traffic.js';
import { createRoomCounter, requestRoomCounter, tickRoomCounter, openRoomCounter, advanceRoomCounter } from '../js/core/room-counter.js';
import { setupCounterDialogue } from '../js/core/dialogue-state.js';
import { campaignSaveCodec } from '../js/core/campaign-saves.js';
import { createCharacter } from '../js/core/character.js';
import { createCityMaps } from '../js/core/city-map.js';
import { createCityGeometry, cityReachability, SHIP_REENTRY } from '../js/core/city-walk.js';
import { cityDoorAt } from '../js/core/city-doors.js';
import { initialCounter, reduceCampaignCounter, restoreCampaignConversation } from '../js/core/campaign-dialogue.js';
import { dialogueMessage } from '../js/ui/dialogue.js';
import { translator } from '../js/ui/i18n.js';
import { reduceCampaignBank } from '../js/core/banking.js';
import { initialPersonalTrade } from '../js/core/personal-trade.js';

export async function tavernDialogueTests(test,equal) {
  const [layouts,maps,navigation,economy,location,cityData,inventory,ship,scripts,text,items,systems,en,ko]=await Promise.all([
    ...['room-walk','maps','initial-navigation','initial-economy','initial-location','city-walk','ship-inventory','ship-walk',
      'dialogue','dialogue-text','items','dialogue-systems'].map(n=>fetch(`../data/${n}.json`).then(r=>r.json())),
    ...['en','ko'].map(n=>fetch(`../locales/${n}.json`).then(r=>r.json())),
  ]);
  const rooms=createRoomGeometries(layouts),dialogue={scripts,text,items,systems};
  const context={system:systems.systems[0],attributes:[30,40,50,30,81],carried:[12,141,139,140],
    flags:Array(128).fill(false),workspace:{lastCity:0,mood:3,quantity:1,gate:0,item:0,actor:0},city:1,hour:7,
    surface:{x:10,y:6},cash:500};
  const places={systems:navigation.systems.map(s=>s.name),worlds:navigation.worlds.map(w=>w.name),system:1,world:1};
  const city=createCityGeometry(createCityMaps(maps,navigation,economy)['city-01'],cityData,{...location,position:location.shipPosition});city.rooms=rooms;
  const reached=cityReachability(city);let street;
  outer:for(let y=7;y<city.height;y++)for(let x=3;x<city.width-7;x++)
    if(cityDoorAt(city.map,{x,y})?.type===8&&reached({x,y})){street={x,y};break outer}
  const room=roomAt(rooms,city.map,street),content={navigation,economy,location,inventory,dialogue};
  const codec=campaignSaveCodec(content,ship,city),t=translator({en,ko},'ko');
  const reject=(fn,message='invalidCampaign')=>{let error;try{fn()}catch(e){error=e.message}equal(error,message)};
  const traffic=(room,arriving=false)=>{
    const p=populateRoom(room,12345),s=initialRoomTraffic(p,room),w=s.actors[0].words;
    s.actors=[s.actors[0],s.actors.at(-1)];w.splice(0,6,86,43,86,43,86,43);w[7]=arriving ? 5*256+33 : 4;w[9]=0;
    if(arriving){s.active=2;s.tavern.playerSeat=4;w[8]=4}
    return s;
  };
  const state=()=>{
    const s=codec.create({...createCharacter(),name:'Tavern pilot'},12345);s.ship.position={...SHIP_REENTRY};s.ship.minutes=420;
    s.dialogue.attributes=[...context.attributes];s.travel={scene:'room',cityPosition:street,roomPosition:{x:16,y:86}};
    s.encounters={randomState:2,roomSeed:12345,roomState:traffic(room),counter:initialCounter()};return s;
  };
  const act=(s,a)=>reduceCampaignCounter(s,content,room,a),reply=(s,slot)=>act(s,{type:'dialogue',input:{type:'reply',slot}});
  function tradeOffer() {
    const s=state();s.ship.inventory.carried=[139,235,23,0];
    let result=act(s,{type:'request'});
    for(const input of [{type:'timeout'},{type:'reply',slot:1},{type:'reply',slot:1}])result=act(result.state,{type:'dialogue',input});
    equal(result.conversation.view.state,130);return result;
  }
  function saleOffer() {
    let result=reply(tradeOffer().state,2);equal(result.conversation.view.state,131);
    result=act(result.state,{type:'dialogue',input:{type:'item',item:139}});equal(result.conversation.view.state,35);
    result=reply(result.state,0);equal(result.conversation.view.state,37);return result;
  }
  await test('Visitor sale replay commits carried item, cash and gross proceeds once, preserving speaker and bank ownership',()=>{
    const offer=saleOffer(),before=JSON.stringify(offer.state),price=offer.conversation.state.locals[106];
    let sold=act(offer.state,{type:'dialogue',input:{type:'sale',slot:1}});equal(sold.conversation.view.state,46);
    equal(sold.state.dialogue.cash,offer.state.dialogue.cash);equal(sold.state.ship.inventory,offer.state.ship.inventory);
    equal(sold.state.economy.personalTrade,initialPersonalTrade());equal(JSON.stringify(offer.state),before);
    const saved=codec.make(sold.state,0),loaded=codec.parse(JSON.stringify(saved)).state;
    equal(saved.version,16);equal(saved.scope,'landed-local-cargo-1');equal(restoreCampaignConversation(loaded,content,room).conversation,sold.conversation);
    const done=act(loaded,{type:'dialogue',input:{type:'cancel'}}).state;
    equal(done.ship.inventory.carried,[139,0,23,0]);equal(done.dialogue.cash,offer.state.dialogue.cash+price);
    equal(done.economy.personalTrade.sold[11],1);equal(done.economy.personalTrade.proceeds[11],price);
    equal(done.economy.accounts,offer.state.economy.accounts);equal(done.economy.exchange,offer.state.economy.exchange);
    equal(done.encounters.counter.conversation,null);equal(done.dialogue.workspace.actor,2);
    equal(done.encounters.roomState.actors.at(-1),offer.state.encounters.roomState.actors.at(-1));
    equal(codec.parse(JSON.stringify(codec.make(done,0))).state,done);
    equal(act(sold.state,{type:'dialogue',input:{type:'cancel'}}).state,done);
    const bank=structuredClone(done);bank.travel={scene:'bank',cityPosition:{x:369,y:299}};
    bank.encounters={...bank.encounters,roomSeed:null,roomState:null,counter:null};
    const deposited=reduceCampaignBank(bank,city.map,{type:'deposit',amount:price});
    equal(deposited.economy.personalTrade,done.economy.personalTrade);equal(codec.snapshot(deposited),deposited);
    const missing=structuredClone(done);missing.economy.personalTrade=initialPersonalTrade();reject(()=>codec.snapshot(missing));
  });
  await test('Version14 social progress upgrades with an empty ledger but cannot inject visitor acceptance or sale inputs',()=>{
    const social=codec.make(tradeOffer().state,0),old=structuredClone(social);old.version=14;delete old.state.pod;old.scope='landed-purchases-1';delete old.state.economy.personalTrade;
    equal(codec.validate(old),social);
    const accepted=saleOffer(),taken=act(accepted.state,{type:'dialogue',input:{type:'sale',slot:0}});
    for(const s of [accepted.state,taken.state]) {
      const legacy=codec.make(s,0);legacy.version=14;delete legacy.state.pod;legacy.scope='landed-purchases-1';delete legacy.state.economy.personalTrade;
      reject(()=>codec.validate(legacy));
    }
    old.state.economy.personalTrade=initialPersonalTrade();reject(()=>codec.validate(old));
  });
  await test('Sale saves reject inconsistent income, invalid input fields and pending ledger overflow without changing the source',()=>{
    const accepted=saleOffer(),taken=act(accepted.state,{type:'dialogue',input:{type:'sale',slot:0}}),save=codec.make(taken.state,0),before=JSON.stringify(save);
    for(const mutate of [s=>s.economy.personalTrade.proceeds[11]=100,s=>s.economy.personalTrade.sold[0]=1,
      s=>s.encounters.counter.conversation.inputs.at(-1).slot=2,s=>s.encounters.counter.conversation.inputs.at(-1).price=600,
      s=>{s.economy.personalTrade.sold[11]=1000000000;s.economy.personalTrade.proceeds[11]=100000000000}]) {
      const bad=structuredClone(save);mutate(bad.state);reject(()=>codec.validate(bad));
    }
    equal(JSON.stringify(save),before);
  });
  await test('Tavern setup selects three source entries and consumes the incoming mode flag only for kind22',()=>{
    for(const kind of [12,21,22]) {
      const input={...context,kind,randomState:12345,flags:[...context.flags],workspace:{...context.workspace,item:12,mood:1}};
      input.flags[66]=true;const before=JSON.stringify(input),s=setupCounterDialogue(input);
      equal(s.randomState,12345);equal(s.state.entry,({12:16,21:48,22:33})[kind]);
      equal([s.state.locals[18],s.state.locals[33],s.state.locals[41],s.state.flags[66]],kind===22 ? [true,4,12,false] : [false,1,0,true]);
      equal(JSON.stringify(input),before);
    }
  });
  await test('All four bartenders approach the player and preserve their own mood on return',()=>{
    for(let index=4;index<=7;index++) {
      const r=rooms[index],p=populateRoom(r,0),s=initialRoomTraffic(p,r);
      let frame=createRoomCounter(r,s,p.randomState,{x:30,y:31});frame=requestRoomCounter(r,frame);
      for(let i=0;frame.service!=='talking'&&i<200;i++)frame=tickRoomCounter(r,frame);
      equal(frame.service,'talking');frame=openRoomCounter(dialogue,r,frame,context,{places});
      equal([frame.conversation.state.kind,frame.conversation.view.state],[12,16]);
      const food=advanceRoomCounter(dialogue,r,frame,{type:'item',item:8});
      equal(food.frame.conversation.view.state,18);
      reject(()=>advanceRoomCounter(dialogue,r,frame,{type:'item',item:8},{purchases:false}),'unsupportedRoomTrade');
      const returned=advanceRoomCounter(dialogue,r,frame,{type:'cancel'});
      equal(returned.frame.service,'served');equal(returned.outcome.workspace.actor,0);
      equal(validateRoomTraffic(r,returned.frame.traffic,returned.frame.position,{service:'served'}).state,returned.frame.traffic);
    }
  });
  await test('An arriving visitor opens kind22 and refusal restores the actual speaker, leaving the bartender unchanged',()=>{
    let frame=createRoomCounter(room,traffic(room,true),12345,{x:16,y:86});frame=tickRoomCounter(room,frame);
    equal(frame.traffic.tavern.contact,{actor:2,kind:22});equal(frame.service,'talking');
    const staff=structuredClone(frame.traffic.actors.at(-1));frame=openRoomCounter(dialogue,room,frame,context,{places});
    equal([frame.conversation.state.kind,frame.conversation.state.workspace.actor,frame.conversation.view.state],[22,2,33]);
    const quote=advanceRoomCounter(dialogue,room,frame,{type:'reply',slot:1}).frame;
    const pay=quote.conversation.view.replies.find(r=>r.caption===2);equal(!!pay,true);
    reject(()=>advanceRoomCounter(dialogue,room,quote,{type:'reply',slot:pay.slot},{visitorTrades:false}),'unsupportedRoomTrade');
    const returned=advanceRoomCounter(dialogue,room,frame,{type:'reply',slot:2});
    equal(returned.frame.service,'idle');equal(returned.outcome.workspace.actor,2);
    equal(returned.frame.traffic.actors.at(-1),staff);equal(returned.frame.traffic.tavern.secondary,2);
    equal(returned.frame.traffic.actors[0].words[7]&2,2*returned.outcome.workspace.gate);
    equal(validateRoomTraffic(room,returned.frame.traffic,returned.frame.position,{service:'idle'}).state,returned.frame.traffic);
  });
  await test('A player can chat, hear a matched joke and migrate version10 replay saves without changing the speaker',()=>{
    let result=act(state(),{type:'request'});equal(result.conversation.view.state,128);
    result=reply(result.state,1);equal(result.conversation.view.state,176);
    result=reply(result.state,2);equal(result.conversation.view.state,192);
    const question=result.conversation.view.word,randomIndex=result.conversation.state.locals[14];
    const save=codec.make(result.state,0);equal(save.version,16);equal(save.scope,'landed-local-cargo-1');
    const loaded=codec.parse(JSON.stringify(save)).state;equal(loaded,result.state);
    const legacy=structuredClone(save);legacy.version=10;delete legacy.state.pod;delete legacy.state.economy;legacy.scope='landed-taverns-1';
    equal(codec.parse(JSON.stringify(legacy)),save);
    equal(restoreCampaignConversation(loaded,content,room).conversation,result.conversation);
    equal(/[가-힣]/.test(dialogueMessage(result.conversation,t,'ko')),true);
    result=act(loaded,{type:'dialogue',input:{type:'timeout'}});equal(result.conversation.view.state,193);
    equal(result.conversation.state.locals[14],randomIndex);
    equal([61,93,131,169,204,230].indexOf(question),[81,107,147,182,218,238].indexOf(result.conversation.view.word));
    result=act(result.state,{type:'dialogue',input:{type:'timeout'}});equal(result.conversation.view.state,178);
    result=act(result.state,{type:'dialogue',input:{type:'cancel'}});
    equal(result.conversation,null);equal(result.state.encounters.counter,initialCounter());
    equal(result.state.dialogue.workspace.actor,2);equal(result.state.encounters.roomState.tavern.secondary,2);
    equal(codec.parse(JSON.stringify(codec.make(result.state,0))).state,result.state);
    const moved=act(result.state,{type:'move',position:{x:16,y:84}}).state;
    equal(moved.encounters.roomState.tavern.playerSeat,null);codec.make(moved,0);
  });
  await test('Tavern imports reject missing populations, orphan contacts, invented speakers and version9 extensions',()=>{
    const s=act(state(),{type:'request'}).state,save=codec.make(s,0);
    for(const mutate of [v=>v.state.encounters.roomState.tavern.contact.actor=0,
      v=>v.state.encounters.counter=initialCounter(),v=>v.state.dialogue.workspace.actor=1,
      v=>v.state.dialogue.workspace.actor=9,v=>v.state.encounters.roomSeed=null,
      v=>{v.version=9;delete v.state.pod;delete v.state.economy;v.scope='landed-lodging-1'}]) {
      const bad=structuredClone(save);mutate(bad);reject(()=>codec.validate(bad));
    }
    const old=codec.make(codec.create({...createCharacter(),name:'Legacy tavern'},12345),0);
    const expected=structuredClone(old);old.version=9;delete old.state.pod;delete old.state.economy;old.scope='landed-lodging-1';equal(codec.validate(old),expected);
    old.state.dialogue.workspace.actor=2;reject(()=>codec.validate(old));
  });
  await test('Bartender tips replay an adjustable offer and commit its debit once on return',()=>{
    const s=state(),p=populateRoom(room,0);s.travel.roomPosition={x:30,y:31};
    let frame=createRoomCounter(room,initialRoomTraffic(p,room),13,s.travel.roomPosition);frame.service='talking';
    const local={...context,cash:s.dialogue.cash,carried:s.ship.inventory.carried,
      surface:s.start.playerLocation.surfacePosition};
    frame=openRoomCounter(dialogue,room,frame,local,{places});
    s.encounters={randomState:frame.randomState,roomSeed:0,roomState:frame.traffic,counter:{service:'talking',conversation:{seed:13,inputs:[]}}};
    let result=reply(s,2);equal(result.conversation.view.state,22);
    result=reply(result.state,2);equal(result.conversation.view.state,23);
    result=act(result.state,{type:'dialogue',input:{type:'offer',direction:'increase',step:10}});
    equal(result.conversation.state.locals[100],10);
    const saved=codec.make(result.state,0),loaded=codec.parse(JSON.stringify(saved)).state;
    equal(restoreCampaignConversation(loaded,content,room).conversation,result.conversation);
    result=reply(loaded,2);equal(result.conversation.view.state,26);
    equal(result.conversation.state.locals[104],s.dialogue.cash-10);equal(result.state.dialogue.cash,s.dialogue.cash);
    result=act(result.state,{type:'dialogue',input:{type:'cancel'}});
    equal(result.state.dialogue.cash,s.dialogue.cash-10);equal(result.state.encounters.counter.service,'served');
    equal(codec.parse(JSON.stringify(codec.make(result.state,0))).state,result.state);
  });
  await test('Bartender food purchases survive replay, reject legacy injection and commit both items on return',()=>{
    const s=state(),p=populateRoom(room,0);s.travel.roomPosition={x:30,y:31};s.ship.inventory.carried=[0,0,139,140];
    let frame=createRoomCounter(room,initialRoomTraffic(p,room),13,s.travel.roomPosition);frame.service='talking';
    frame=openRoomCounter(dialogue,room,frame,{...context,cash:s.dialogue.cash,carried:s.ship.inventory.carried,
      surface:s.start.playerLocation.surfacePosition},{places});
    s.encounters={randomState:frame.randomState,roomSeed:0,roomState:frame.traffic,counter:{service:'talking',conversation:{seed:13,inputs:[]}}};
    let current=s,spent=0;
    for(const [slot,item] of [[0,8],[1,9]]) {
      let result=act(current,{type:'dialogue',input:{type:'item',item}});spent+=result.conversation.state.locals[106];
      const accepted=codec.make(result.state,0),legacy=structuredClone(accepted);legacy.version=13;delete legacy.state.pod;delete legacy.state.economy.personalTrade;legacy.scope='landed-exchange-1';
      reject(()=>codec.validate(legacy)); // Food selection itself was blocked in the old scope.
      result=act(codec.parse(JSON.stringify(accepted)).state,{type:'dialogue',input:{type:'purchase',slot}});
      current=codec.parse(JSON.stringify(codec.make(result.state,0))).state;
      equal(restoreCampaignConversation(current,content,room).conversation,result.conversation);
    }
    const ended=act(current,{type:'dialogue',input:{type:'cancel'}}).state;
    equal(ended.ship.inventory.carried,[8,9,139,140]);equal(ended.dialogue.cash,s.dialogue.cash-spent);
    equal(ended.economy,s.economy);equal(ended.ship.condition,s.ship.condition);
    equal(codec.parse(JSON.stringify(codec.make(ended,0))).state,ended);
  });
  await test('Every tavern message has Korean text and chosen place names survive language changes without RNG draws',()=>{
    const frame=act(state(),{type:'request'}).conversation;
    for(const block of [90,91,92,97,100,101,102])for(const word of Object.keys(text.messages[block])) {
      const f=structuredClone(frame);f.block=block;f.view.word=Number(word);f.view.chosenPlaces=['Test destination'];
      const before=JSON.stringify(f),message=dialogueMessage(f,t,'ko');
      equal(/[가-힣]/.test(message),true);equal(/\{\w+\}/.test(message),false);equal(JSON.stringify(f),before);
      if(block===100&&['157','178'].includes(word))equal(message.includes('Test destination'),true);
    }
  });
}
