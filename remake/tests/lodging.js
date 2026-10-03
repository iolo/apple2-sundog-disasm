import { createRoomGeometries } from '../js/core/room-walk.js';
import { initialLodging, lodgingGeometry, rentLodging } from '../js/core/room-lodging.js';
import { populateRoom, roomActorGeometry } from '../js/core/room-actors.js';
import { initialRoomTraffic } from '../js/core/room-traffic.js';
import { initialCounter, reduceCampaignCounter, restoreCampaignConversation } from '../js/core/campaign-dialogue.js';
import { campaignSaveCodec } from '../js/core/campaign-saves.js';
import { createCharacter } from '../js/core/character.js';
import { createCityMaps } from '../js/core/city-map.js';
import { createCityGeometry, cityReachability, SHIP_REENTRY } from '../js/core/city-walk.js';
import { cityDoorAt } from '../js/core/city-doors.js';
import { setupCounterDialogue } from '../js/core/dialogue-state.js';
import { canStand } from '../js/core/ship-walk.js';
import { sourceRandom } from '../js/core/random.js';
import { translator } from '../js/ui/i18n.js';
import { dialogueMessage } from '../js/ui/dialogue.js';
import { transferBankFunds } from '../js/core/banking.js';

export async function lodgingTests(test,equal) {
  const [layouts,maps,navigation,economy,location,cityData,inventory,ship,scripts,text,items,systems]=await Promise.all([
    'room-walk','maps','initial-navigation','initial-economy','initial-location','city-walk','ship-inventory','ship-walk',
    'dialogue','dialogue-text','items','dialogue-systems'].map(n=>fetch(`../data/${n}.json`).then(r=>r.json())));
  const content={navigation,economy,location,inventory,dialogue:{scripts,text,items,systems}};
  const city=createCityGeometry(createCityMaps(maps,navigation,economy)['city-01'],cityData,{...location,position:location.shipPosition});
  city.rooms=createRoomGeometries(layouts);const room=city.rooms[1],reached=cityReachability(city);
  let street;
  outer:for(let y=7;y<city.height;y++)for(let x=3;x<city.width-7;x++)
    if(cityDoorAt(city.map,{x,y})?.type===11&&reached({x,y})){street={x,y};break outer}
  if(!street)throw Error('No reachable lodging door');
  const codec=campaignSaveCodec(content,ship,city),fee=8*systems.systems[0].local30+3;
  const fresh=()=>codec.create({...createCharacter(),name:'Lodging pilot'},12345);
  const act=(state,action)=>reduceCampaignCounter(state,content,room,action).state;
  const frame=state=>restoreCampaignConversation(state,content,room).conversation;
  const reply=(state,caption)=>act(state,{type:'dialogue',input:{type:'reply',slot:frame(state).view.replies.find(r=>r.caption===caption).slot}});
  const next=state=>act(state,{type:'dialogue',input:{type:'timeout'}});
  const reject=fn=>{let message;try{fn()}catch(e){message=e.message}equal(message,'invalidCampaign')};
  function atCounter(cash) {
    const state=fresh(),p=populateRoom(room,0);state.ship.position={...SHIP_REENTRY};state.ship.minutes=7*60;
    state.travel={scene:'room',cityPosition:street,roomPosition:{x:21,y:71},lodging:initialLodging()};
    state.encounters={randomState:p.randomState,roomSeed:0,roomState:initialRoomTraffic(p),counter:initialCounter()};
    if(cash!==undefined)state.dialogue.cash=cash;
    return state;
  }
  function talking(cash,configure=()=>{}) {
    let state=atCounter(cash),ticks=0;configure(state);state=act(state,{type:'request'});
    while(state.encounters.counter.service!=='talking'&&ticks++<500)state=act(state,{type:'tick'});
    equal(frame(state).view.state,96);return state;
  }
  function rented() {return next(reply(reply(talking(),0),2))}

  await test('Withdrawn cash funds lodging through replay saves without losing active bank balances',()=>{
    const initial=talking(undefined,state=>{
      const funds=transferBankFunds(state.dialogue.cash,state.economy,'system-01',{type:'withdraw',amount:1000});
      state.dialogue.cash=funds.cash;state.economy=funds.economy;
    });
    equal(initial.dialogue.cash,initial.start.credits+1000);
    const paid=reply(reply(initial,0),2),saved=codec.make(paid,0),restored=codec.parse(JSON.stringify(saved)).state;
    const result=next(restored);equal(result.dialogue.cash,initial.dialogue.cash-fee);equal(result.economy,initial.economy);
    equal(codec.snapshot(result),result);equal(result.start,initial.start);
  });

  await test('Every lodging door SVG matches runtime collision, including combinations from repeated rentals',async()=>{
    const canvas=document.createElement('canvas');canvas.width=140;canvas.height=96;const context=canvas.getContext('2d');
    for(let openMask=0;openMask<16;openMask++) {
      const image=new Image();image.src=`../assets/svg/room-01${openMask ? `-doors-${openMask}` : ''}.svg`;await image.decode();
      context.clearRect(0,0,140,96);context.drawImage(image,0,0);const pixels=context.getImageData(0,0,140,96).data;
      const geometry=lodgingGeometry(room,{rented:1,openMask});
      for(let y=0;y<96;y++)for(let x=0;x<140;x++)equal(pixels[(y*140+x)*4+3]>0,!!(geometry.backgrounds.ship[y][Math.floor(x/7)]&(1<<(x%7))));
    }
    const seen=new Set();
    for(const seed of [0,512,1024,1536,12345,0xffffffff]) {
      const rng=sourceRandom(seed),number=1+rng.next()%4,result=rentLodging({rented:1,openMask:1},seed);
      equal(result,{lodging:{rented:number,openMask:1|(1<<(number-1))},randomState:rng.state});seen.add(number);
    }
    equal(seen.size,4);
  });

  await test('Lodging setup quotes each system fee, caps the offered cash and consumes no setup RNG',()=>{
    const base=talking(),context=frame(base).state;
    for(const system of systems.systems)for(const cash of [0,1,8*system.local30+3,500]) {
      const setup=setupCounterDialogue({...context,system,city:1,hour:7,surface:{x:10,y:6},cash,randomState:12345,kind:23});
      const v=setup.state.locals,cost=8*system.local30+3;
      equal([setup.state.entry,setup.randomState,v[100],v[104],v[106],v[108]],[96,12345,Math.min(cash,cost),cash,cost,`${cost} Cr`]);
    }
  });
  await test('Lodging payment replays before return, then atomically debits cash and opens the randomly assigned room',()=>{
    const initial=talking(),before=JSON.stringify(initial),quoted=reply(initial,0),paid=reply(quoted,2);
    equal(frame(quoted).view.state,99);equal(frame(paid).view.state,100);
    equal(paid.dialogue.cash,initial.dialogue.cash);equal(frame(paid).state.locals[104],initial.dialogue.cash-fee);
    const restored=codec.parse(JSON.stringify(codec.make(paid,0))).state;equal(restored,paid);
    const rng=sourceRandom(paid.encounters.randomState),number=1+rng.next()%4,result=next(restored);
    equal(result.dialogue.cash,initial.dialogue.cash-fee);equal(result.travel.lodging,{rented:number,openMask:1<<(number-1)});
    equal(result.encounters.randomState,rng.state);equal(result.encounters.counter,{service:'served',conversation:null});
    equal(result.dialogue.flags[65],false);equal(result.start,initial.start);equal(result.ship,initial.ship);
    equal(next(paid),result);equal(JSON.stringify(initial),before);equal(codec.snapshot(result),result);
  });
  await test('Insufficient funds and declining a room preserve cash and access; Korean quotes retain the full fee',async()=>{
    const [en,ko]=await Promise.all(['en','ko'].map(n=>fetch(`../locales/${n}.json`).then(r=>r.json()))),t=translator({en,ko},'ko');
    for(const cash of [0,fee-1]) {
      const initial=talking(cash),quoted=reply(initial,0),denied=reply(quoted,2),result=next(denied);
      equal(frame(denied).view.state,101);equal(result.dialogue.cash,cash);equal(result.travel.lodging,initialLodging());
      equal(dialogueMessage(frame(quoted),t,'ko').includes(String(fee)),true);
      equal(frame(quoted).view.text.includes(`${fee} Cr`),true);
    }
    const initial=talking(),declined=reply(initial,1);
    equal(declined.dialogue.cash,initial.dialogue.cash);equal(declined.travel.lodging,initialLodging());
    const full=reply(talking(undefined,s=>{s.ship.minutes=4*60;s.dialogue.attributes[3]=0}),0);
    equal(frame(full).view.state,98);equal(next(full).dialogue.cash,initial.dialogue.cash);equal(next(full).travel.lodging,initialLodging());
  });
  await test('Rented doors close behind the player and reopen from inside; closed-bedroom saves remain reachable',()=>{
    let state=rented();const assigned=state.travel.lodging.rented,x=28+28*(assigned-1);
    // Follow a collision-checked path in single-pixel steps. Seed0 keeps this
    // visit staff-only, isolating door access from unrelated visitor traffic.
    for(const target of [{x,y:40},{x,y:22},{x,y:45}]) {
      const start=state.travel.roomPosition,open=lodgingGeometry(room,state.travel.lodging,{access:true});
      const g=roomActorGeometry(open,state.encounters.roomState.actors),queue=[start],prev=new Map([[`${start.x},${start.y}`,null]]);
      for(let i=0;i<queue.length;i++) {
        const p=queue[i];if(p.x===target.x&&p.y===target.y)break;
        for(const [dx,dy] of [[1,0],[-1,0],[0,1],[0,-1]]) {
          const q={x:p.x+dx,y:p.y+dy},key=`${q.x},${q.y}`;
          if(!prev.has(key)&&canStand(g,q)){prev.set(key,p);queue.push(q)}
        }
      }
      equal(prev.has(`${target.x},${target.y}`),true);
      const path=[];for(let p=target;prev.get(`${p.x},${p.y}`);p=prev.get(`${p.x},${p.y}`))path.unshift(p);
      for(const p of path) {
        equal(canStand(roomActorGeometry(lodgingGeometry(room,state.travel.lodging),state.encounters.roomState.actors),p),true);
        state=act(state,{type:'move',position:p});state=act(state,{type:'tick'});
      }
      equal(state.dialogue.flags[57],target.y===22);
      equal(state.travel.lodging.openMask,target.y===40 ? 1<<(assigned-1) : 0);
      equal(codec.parse(JSON.stringify(codec.make(state,1))).state,state);
    }
  });
  await test('Version8 migrates cash from creation and rejects injected cash; lodging saves reject invented access',()=>{
    const current=codec.make(fresh(),0),old=structuredClone(current);old.version=8;delete old.state.pod?.occupied;delete old.state.machinery;delete old.state.engineering;delete old.state.resources;delete old.state.pod;delete old.state.economy;old.scope='landed-dialogue-1';delete old.state.dialogue.cash;
    const before=JSON.stringify(old);equal(codec.validate(old),current);equal(JSON.stringify(old),before);
    old.state.dialogue.cash=1;reject(()=>codec.validate(old));
    const saved=codec.make(rented(),0);
    for(const mutate of [s=>s.dialogue.cash=-1,s=>s.dialogue.cash=s.start.credits+1,
      s=>s.travel.lodging.openMask=16,s=>s.travel.lodging.rented=0,s=>s.travel.lodging.extra=1,
      s=>{s.encounters.roomSeed=null;s.encounters.roomState=null;s.encounters.counter=null},
      s=>s.travel.roomPosition={x:112,y:22}]) {
      const bad=structuredClone(saved);mutate(bad.state);reject(()=>codec.validate(bad));
    }
    const legacy=structuredClone(saved);legacy.version=8;delete legacy.state.pod?.occupied;delete legacy.state.machinery;delete legacy.state.engineering;delete legacy.state.resources;delete legacy.state.pod;delete legacy.state.economy;legacy.scope='landed-dialogue-1';delete legacy.state.dialogue.cash;delete legacy.state.travel.lodging;
    reject(()=>codec.validate(legacy));
  });
}
