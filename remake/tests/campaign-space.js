import { campaignSaveCodec } from '../js/core/campaign-saves.js';
import { createCharacter } from '../js/core/character.js';
import { createInitialEquipment } from '../js/core/initialization.js';
import { recalculateEquipment } from '../js/core/equipment.js';
import { createSurvival } from '../js/core/survival.js';
import { reduceCampaignFlight } from '../js/core/campaign-flight.js';
import { advanceCampaignMachinery,reduceMachineryControl,reconcileMachinery } from '../js/core/campaign-machinery.js';
import { reduceCampaignEngineering } from '../js/core/campaign-engineering.js';
import { reduceCampaignSpace,stepCampaignSpaceProducer,reduceCampaignShipCommunication,
  restoreCampaignShipCommunication,validateCampaignSpace } from '../js/core/campaign-space.js';

// Independent byte/carry RNG oracle, with source call counts below.
function stream(seed,count) {
  const bytes=[seed%256,Math.floor(seed/256)%256,Math.floor(seed/65536)%256,Math.floor(seed/16777216)];
  const rolls=[];
  for(let n=0;n<count;n++) {
    for(let shift=0;shift<7;shift++) {
      let carry=(Math.floor(bytes[0]/64)%2+Math.floor(bytes[3]/64)%2)%2;
      for(let i=0;i<4;i++){const next=Math.floor(bytes[i]/128);bytes[i]=(bytes[i]*2+carry)%256;carry=next}
    }
    rolls.push(Math.floor(bytes[0]/2)*256+bytes[2]);
  }
  return {rolls,state:bytes.reduce((sum,b,i)=>sum+b*256**i,0)};
}

export async function campaignSpaceTests(test,equal) {
  const names=['initial-navigation','initial-economy','initial-location','ship-inventory','ship-walk','maps',
    'city-walk','surface-walk','dialogue','dialogue-text','items','dialogue-systems','ground-chase','ground-combat','exchange-defaults','flight-defaults'];
  const [navigation,economy,location,inventory,walk,maps,cityWalk,surfaceWalk,scripts,text,items,systems,chase,ground,exchange,flight]=
    await Promise.all(names.map(n=>fetch(`../data/${n}.json`).then(r=>r.json())));
  const legacy={navigation,economy,location,inventory,ground:{maps,cityWalk,surfaceWalk},
    dialogue:{scripts,text,items,systems},exchange,flight,regional:true,combat:{chase,ground}};
  const content={...legacy,space:true},old=campaignSaveCodec(legacy,walk),codec=campaignSaveCodec(content,walk);
  const fresh=()=>codec.create({...createCharacter(),name:'Space host'},12345);
  const survival=s=>({...createSurvival(s.ship.condition),minutes:s.ship.minutes});
  const tick=(s,ms=250,v=survival(s),paused=false)=>advanceCampaignMachinery(s,v,ms,paused,content);
  const run=(s,total,chunk=250)=>{let v=survival(s);for(let i=0;i<total;i+=chunk){const r=tick(s,Math.min(chunk,total-i),v);s=r.state;v=r.survival}return s};
  const act=(s,a)=>reduceCampaignFlight(s,content,a);
  const launch=s=>run(act(s,{type:'launch'}),4250);
  const reload=s=>codec.parse(JSON.stringify(codec.make(s,0))).state;
  const working=s=>{s.equipment=createInitialEquipment({next:()=>1}).map(recalculateEquipment);return s};
  const orbit=()=>{const s=working(fresh());s.resources.fuel=255;return launch(s)};
  const buyCargo=s=>{
    const lot={commodityId:'cargo-02',quality:7,originCity:'city-01',pricePaid:100};
    s.economy.accounts[0].balance-=100;s.pod.cargo=[lot,null];return s;
  };
  const contact=(seed=29)=>{
    const s=orbit();s.encounters.randomState=seed;s.space.flags[40]=s.space.flags[44]=true;
    Object.assign(s.space.words,{205:512,206:512,207:0,208:0,209:0,214:1,215:20,216:200,217:20});return s;
  };
  const reject=(run,code='invalidCampaign')=>{let message;try{run()}catch(e){message=e.message}equal(message,code)};
  const comm=s=>reduceCampaignShipCommunication(s,content,{type:'comm'});
  const reply=(s,input)=>reduceCampaignShipCommunication(s,content,{type:'dialogue',input});
  const tactical=s=>reduceCampaignSpace(s,{type:'view',view:'tactical'});
  const agree=s=>reply(reply(comm(tactical(s)),{type:'reply',slot:0}),{type:'cancel'});

  await test('Space version26 validates before migration and leaves historical24 hull/failure/cryogen rules strict',()=>{
    const initial=fresh(),save=codec.make(initial,0);equal([save.version,save.scope],[26,'ship-communication-1']);equal(reload(initial),initial);
    const historical=old.make(old.create({...createCharacter(),name:'Space host'},12345),0);
    equal(codec.validate(historical).state,initial);
    const bad=structuredClone(historical);bad.state.resources.hull--;reject(()=>codec.validate(bad));
    bad.state.resources.hull++;bad.state.space=initial.space;reject(()=>codec.validate(bad));
    const scopes=['landed-ship-1','landed-engineering-1','landed-city-1','landed-bank-1','landed-rooms-1','landed-occupants-1','landed-traffic-1','landed-dialogue-1','landed-lodging-1','landed-taverns-1','landed-services-1','landed-banking-1','landed-exchange-1','landed-purchases-1','landed-personal-trade-1','landed-local-cargo-1','landed-trader-matching-1','landed-depot-1','landed-failures-1','landed-power-1','landed-parking-1','landed-ground-1','regional-flight-1'];
    for(let version=1;version<=23;version++) {
      const legacySave=structuredClone(historical),s=legacySave.state;delete s.combat;
      legacySave.version=version;legacySave.scope=scopes[version-1];
      if(version<23){delete s.regional;delete s.flight}
      if(version<22)delete s.ground;
      if(version<20)delete s.machinery;if(version<19)delete s.engineering;if(version<18)delete s.resources;
      if(version<16)delete s.pod;else if(version<21)delete s.pod.occupied;
      if(version<12)delete s.economy;else {if(version<13)delete s.economy.exchange;if(version<15)delete s.economy.personalTrade}
      if(version<8)delete s.dialogue;else if(version===8)delete s.dialogue.cash;
      if(version<6)delete s.encounters;else {if(version<7)delete s.encounters.roomState;if(version<8)delete s.encounters.counter}
      if(version<3)delete s.travel;if(version<2)delete s.equipment;
      equal(codec.validate(legacySave).state,initial);
    }
  });
  await test('Engine-powered production runs before arrival and before power/combat with one campaign RNG',()=>{
    let s=buyCargo(orbit());s=act(s,{type:'sublight',angle:0});s.encounters.randomState=52;s.machinery.phase=0;
    const before=JSON.stringify(s),r=tick(s).state,draws=stream(52,10),rolls=draws.rolls;
    equal(rolls.slice(0,3).map(n=>n&15),[0,13,13]);equal(r.flight.motion.progress,1);
    equal(r.space.flags[40],true);equal(r.space.flags[41],true);equal(r.space.words[214],rolls[4]&3);
    equal([r.space.words[206],r.space.words[205],r.space.words[216]],[rolls[5]&1023,rolls[6]&1023,150+rolls[7]%106]);
    equal([r.space.words[217],r.space.words[215]],[123,36]);equal(r.encounters.randomState,draws.state);
    equal(r.ship.minutes,s.ship.minutes+1);equal(r.pod.cargo,s.pod.cargo);equal(r.start,s.start);equal(JSON.stringify(s),before);equal(reload(r),r);
  });
  await test('Source power follows production and precedes combat, including eager failed even-phase movement',()=>{
    let s=buyCargo(orbit());s=act(s,{type:'sublight',angle:0});s.encounters.randomState=52;s.machinery.phase=3;
    s=act(s,{type:'setWarp',systemId:'system-02'});
    const r=tick(s).state;equal(r.flight.motion.progress,0);equal(r.space.flags[40],true);
    equal(r.encounters.randomState,stream(52,11).state);equal(r.resources.fuel,s.resources.fuel-2);equal(r.resources.warp.charge,8);equal(reload(r),r);
    const shield=contact();shield.space.flags[45]=true;shield.space.words[214]=0;shield.machinery.phase=1;shield.resources.shields.targetCharge=255;
    const powered=tick(shield).state;equal(powered.resources.shields.charge,26);equal(powered.resources.hull,shield.resources.hull);
    equal(powered.resources.fuel,shield.resources.fuel-4);equal(powered.encounters.randomState,stream(29,3).state);equal(reload(powered),powered);
  });
  await test('Suppressed production keeps contact flags, and engine-off ticks do not invent encounters or RNG',()=>{
    const s=buyCargo(orbit());s.encounters.randomState=52;const still=tick(s).state;
    equal(still.encounters.randomState,52);equal(still.space.flags[40],false);
    const active=contact();active.space.flags[44]=false;const next=tick(active).state;
    equal(next.space.flags[40],true);equal(next.space.words[215],16);equal(next.encounters.randomState,29);equal(reload(next),next);
    const cloak=act(s,{type:'sublight',angle:0});cloak.machinery.cloaked=true;
    const suppressed=stepCampaignSpaceProducer(cloak,content,{enabled:true,arrived:false});equal(suppressed.encounters.randomState,52);equal(suppressed.space.flags[40],false);
    const inhibited=act(s,{type:'sublight',angle:0});inhibited.space.flags[36]=true;
    equal(stepCampaignSpaceProducer(inhibited,content,{enabled:true,arrived:false}).encounters.randomState,52);equal(reload(inhibited),inhibited);
  });
  await test('Arrival resets the active contact cooldown before its actual world causes a retreat',()=>{
    let s=contact(28);s.space.flags[44]=false;
    // A one-step return to the already selected world is a real orbital route.
    s.regional.shipLocation.worldId=null;s.regional.podWorldId=null;
    s.regional.shipLocation.orbit={...s.regional.shipLocation.orbit,radius:s.regional.shipLocation.orbit.radius-1};
    s=act(s,{type:'sublight',worldId:'world-01'});equal(s.flight.motion.duration,1);s.machinery.phase=0;
    const arrived=tick(s).state;equal(arrived.flight.motion,null);equal(arrived.regional.shipLocation.worldId,'world-01');
    equal([arrived.space.words[207],arrived.space.words[215]],[2,130]);equal(arrived.space.flags[44],false);equal(reload(arrived),arrived);
  });
  await test('Contact and serialized partial power ticks continue identically across cadence, pause and JSON reload',()=>{
    const s=contact();s.space.flags[44]=false;
    const partial=tick(s,249).state;equal(partial.machinery.phase,s.machinery.phase);equal(partial.space.elapsed,249);
    const resumed=tick(reload(partial),1).state;equal(resumed,tick(s).state);
    equal(tick(reload(partial),1,createSurvival(partial.ship.condition)).state,resumed);
    const paused=tick(partial,60000,survival(partial),true);equal(paused.state,partial);equal(paused.survival.elapsed,249);
    equal(run(s,4000,10),run(s,4000,100));equal(run(s,4000,250),tick(s,4000).state);
    reject(()=>tick(s,1.5),'invalidCampaignSpace');reject(()=>tick(s,60001),'invalidCampaignSpace');
  });
  await test('Actual pending fire commits hull damage and immediate engineering caches, including frame burnout',()=>{
    const hull=contact();hull.space.flags[45]=true;const hit=tick(hull).state;
    equal(hit.resources.hull,hull.resources.hull-2);equal(hit.encounters.randomState,3550957389);equal(reload(hit),hit);
    const s=contact(4);s.space.flags[45]=true;const damaged=tick(s).state;
    equal(damaged.equipment[1].units[1].components,[31,156,30,24]);equal(damaged.equipment[1].performance,12);
    equal(damaged.engineering.pendingFailures[1],6);equal(damaged.space.combatFailures,[false,true,false,false,false,false]);equal(reload(damaged),damaged);
    const forged=structuredClone(damaged);forged.space.combatFailures[1]=false;reject(()=>codec.snapshot(forged));
    const atBay=structuredClone(damaged);atBay.ship.position={x:109,y:60};
    const burned=reduceCampaignEngineering(atBay,{type:'tick',groupIndex:1}).state;
    equal(burned.equipment[1].units[1].components,[31,7,30,24]);equal(burned.engineering.pendingFailures[1],31);equal(burned.space.combatFailures[1],false);equal(reload(burned),burned);
    equal(reconcileMachinery(damaged).space.flags,damaged.space.flags);
  });
  await test('Shunt damage preserves multiple raw high bytes and engineering resolves every owned failure',()=>{
    const s=contact(4);s.space.flags[45]=true;
    s.equipment[1]=recalculateEquipment({...s.equipment[1],units:s.equipment[1].units.map(u=>({components:[31,23,23,23]}))});
    const hit=tick(s).state;equal(hit.encounters.randomState,stream(4,26).state);
    equal(hit.equipment[1].units.flatMap(u=>u.components).filter(b=>b>127).length>1,true);equal(reload(hit),hit);
    hit.ship.position={x:109,y:60};const burned=reduceCampaignEngineering(hit,{type:'tick',groupIndex:1}).state;
    equal(burned.equipment[1].units.flatMap(u=>u.components).some(b=>b>127),false);equal(reload(burned),burned);
  });
  await test('Ship destruction is durable even when the native zero-output pointer leaves hull intact',()=>{
    const s=contact(4);s.space.flags[45]=true;
    s.equipment[1]=recalculateEquipment({...s.equipment[1],units:s.equipment[1].units.map(()=>({components:[0,0,0,0]}))});
    const result=tick(s),dead=result.state;equal(dead.resources.hull,s.resources.hull);equal(dead.ship.condition,s.ship.condition);
    equal(dead.space.defeat,{reason:'shipDestroyed',minutes:dead.ship.minutes});equal(dead.space.words[347],1);equal(dead.space.elapsed,0);equal(reload(dead),dead);
    equal(tick(reload(dead),1000).state,dead);equal(result.survival.dead,true);
    reject(()=>act(dead,{type:'distress'}),'flightUnavailable');reject(()=>reduceMachineryControl(dead,{type:'guns',enabled:true}),'machineryUnavailable');
    reject(()=>reduceCampaignSpace(dead,{type:'view',view:'tactical'}),'spaceUnavailable');
    const forged=structuredClone(dead);forged.space.defeat=null;reject(()=>codec.snapshot(forged));
    const direct=contact();direct.resources.hull=1;direct.space.flags[45]=true;
    const zero=tick(direct).state;equal(zero.resources.hull,0);equal(reload(zero),zero);
    const both=contact();both.resources.hull=1;both.space.flags[45]=true;both.ship.minutes=59;both.machinery.phase=0;
    both.ship.condition={vigor:1,rest:1,health:1,nourishment:1};
    const terminal=tick(both).state;equal(terminal.ship.condition.vigor,0);equal(terminal.resources.hull,0);
    equal(terminal.combat.defeat,{reason:'conditionDeath',minutes:60});equal(terminal.space.defeat,{reason:'shipDestroyed',minutes:60});equal(reload(terminal),terminal);
  });
  await test('Player guns consume actual charge and increment only the visited packed system cooldown on a kill',()=>{
    let s=contact();s=reduceCampaignSpace(s,{type:'view',view:'tactical'});s.resources.guns.charge=255;
    s.space.cooldowns[0]=15;s.space.words[214]=2;
    const before=JSON.stringify(s),shot=reduceCampaignSpace(s,{type:'fire',focused:true});
    equal(shot.resources.guns.charge,0);equal(shot.space.words[216],0);equal(shot.space.words[354],1);
    equal(shot.space.cooldowns,[1,...Array(11).fill(0)]);equal(shot.encounters.randomState,s.encounters.randomState);equal(JSON.stringify(s),before);equal(reload(shot),shot);
    const ended=tick(shot).state;equal(ended.space.flags[40],false);equal(reload(ended),ended);
  });
  await test('Jettison removes actual lots in source order, persists ordinary cost and conserves lost cryogens',()=>{
    let s=buyCargo(orbit());s=reduceCampaignSpace(s,{type:'view',view:'tactical'});
    const archive=s.regional.cities.find(c=>c.warehouse.slots.some(l=>l?.commodityId==='cargo-31'));
    const slot=archive.warehouse.slots.findIndex(l=>l?.commodityId==='cargo-31'),cryogen=archive.warehouse.slots[slot];
    s.pod.cargo[1]=cryogen;archive.warehouse.slots[slot]=null;s.space.cooldowns[0]=7;s.encounters.randomState=28;
    equal(reload(s),s);const before=JSON.stringify(s),lost=reduceCampaignSpace(s,{type:'jettison',selection:3});
    equal(lost.pod.cargo,[null,null]);equal(lost.space.losses,[{lot:cryogen,count:1},{lot:s.pod.cargo[0],count:1}]);
    equal(lost.encounters.randomState,462364);equal(lost.space.cooldowns[0],0);equal(lost.space.flags[46],true);equal(lost.space.flags[47],true);equal(reload(lost),lost);equal(JSON.stringify(s),before);
    const duplicate=structuredClone(lost);duplicate.pod.cargo[1]=cryogen;reject(()=>codec.snapshot(duplicate));
    const missing=structuredClone(lost);missing.space.losses.shift();reject(()=>codec.snapshot(missing));
    const income=structuredClone(lost);income.economy.accounts[0].balance+=101;reject(()=>codec.snapshot(income));
    const repeated=structuredClone(lost);repeated.space.losses.push({...repeated.space.losses[0]});reject(()=>codec.snapshot(repeated));
    const legacySave=old.make(old.create({...createCharacter(),name:'Space host'},12345),0);
    const warehouse=legacySave.state.regional.cities.find(c=>c.warehouse.slots.some(l=>l?.commodityId==='cargo-31'));
    warehouse.warehouse.slots[warehouse.warehouse.slots.findIndex(l=>l?.commodityId==='cargo-31')]=null;reject(()=>codec.validate(legacySave));
  });
  await test('Tactical scene pauses contact drift while power and pending fire still run on actual ticks',()=>{
    const s=reduceCampaignSpace(contact(),{type:'view',view:'tactical'});s.space.flags[45]=true;
    const hit=tick(s).state;equal([hit.space.words[205],hit.space.words[206],hit.space.words[215]],[512,512,20]);
    equal(hit.resources.hull,s.resources.hull-2);equal(reload(hit),hit);
    const empty=reduceCampaignSpace(fresh(),{type:'view',view:'tactical'});
    reject(()=>reduceCampaignSpace(empty,{type:'fire',focused:true}),'shipGunUnavailable');
    const detached=structuredClone(s);detached.pod.attached=false;
    reject(()=>reduceCampaignSpace(detached,{type:'jettison',selection:1}),'spaceCargoUnavailable');
  });
  await test('Successful actual warp clears contact40/47 without an arrival producer; a failed jump retains them',()=>{
    let s=contact();s.space.flags[47]=true;s=act(s,{type:'setWarp',systemId:'system-02'});s.resources.warp.charge=s.resources.warp.targetCharge;
    const failed=act(s,{type:'warp'});equal(failed.space.flags[40],true);equal(failed.space.flags[47],true);equal(reload(failed),failed);
    s.regional.shipLocation.worldId=null;s.regional.podWorldId=null;s.regional.shipLocation.orbit.radius=43;
    const jumped=act(s,{type:'warp'});equal(jumped.regional.shipLocation.systemId,'system-02');equal(jumped.space.flags[40],false);equal(jumped.space.flags[47],false);equal(jumped.space.view,'tactical');equal(reload(jumped),jumped);
  });
  await test('Malformed contact fields, derived cache, hull and loss imports reject atomically',()=>{
    const s=fresh();for(const change of [v=>v.space.words[206]=1024,v=>v.space.words.extra=1,v=>v.space.flags[0]=true,
      v=>delete v.space.flags[40],v=>v.space.cooldowns[0]=16,v=>v.space.elapsed=250,v=>v.space.view='unknown',
      v=>v.space.combatFailures[0]=true,v=>v.space.defeat={reason:'shipDestroyed',minutes:0},v=>v.space.extra=0,
      v=>v.space.losses=[{lot:{commodityId:'cargo-02',quality:7,originCity:'city-01',pricePaid:0},count:1}],v=>v.resources.hull=0]) {
      const bad=structuredClone(s);change(bad);const before=JSON.stringify(bad);reject(()=>codec.snapshot(bad));equal(JSON.stringify(bad),before);
    }
    const atGround=contact();atGround.travel={scene:'city',cityPosition:{x:0,y:0}};reject(()=>codec.snapshot(atGround));
  });
  await test('Historical25 validates its original nine space fields before adding idle communication and activity',()=>{
    const s=contact(4);s.space.flags[45]=true;const damaged=tick(s).state;
    const save=codec.make(damaged,0);save.version=25;save.scope='ship-encounters-1';
    delete save.state.space.communication;delete save.state.space.activity;
    equal(codec.validate(save).state,damaged);
    for(const change of [v=>v.space.communication={conversation:null,pending:false,ticks:0},
      v=>v.space.activity={sleeping:true,forced:false,sleepPhase:0},v=>v.space.flags[35]=true,
      v=>v.space.flags[49]=true,v=>v.space.flags[51]=true]) {
      const bad=structuredClone(save);change(bad.state);reject(()=>codec.validate(bad));
    }
    const wrongScope=structuredClone(save);wrongScope.scope='ship-communication-1';reject(()=>codec.validate(wrongScope));
  });
  await test('Comm freezes actual source inputs and replay while clocks and unrelated ship controls cannot advance',()=>{
    const s=tactical(contact());s.space.words[354]=10;
    const before=JSON.stringify(s),opened=comm(s),frozen=opened.space.communication.conversation;
    equal(JSON.stringify(s),before);equal(frozen.context.kind,19);equal(frozen.context.sceneMiddle,1);
    equal(frozen.context.city,0);equal(frozen.context.workspace,{...s.dialogue.workspace,item:0,mood:0,quantity:2});
    equal(frozen.context.bankBalance,s.economy.accounts[0].balance);equal(frozen.context.cash,s.dialogue.cash);
    equal(frozen.context.attributes,s.dialogue.attributes);equal(frozen.context.carried,s.ship.inventory.carried);
    equal(Object.keys(frozen),['context','record']);equal(Object.keys(frozen.record),['seed','inputs']);equal(opened.space.words[354],0);equal(reload(opened),opened);
    const midway=reply(opened,{type:'reply',slot:0});equal(reload(midway),midway);
    equal(restoreCampaignShipCommunication(reload(midway),content),restoreCampaignShipCommunication(midway,content));
    equal(midway.economy,opened.economy);equal(midway.dialogue,opened.dialogue);equal(midway.ship,opened.ship);
    equal(tick(midway,60000).state,midway);equal(tick(midway,250).cycles,0);
    reject(()=>act(midway,{type:'distress'}),'flightUnavailable');
    reject(()=>reduceMachineryControl(midway,{type:'guns',enabled:true}),'machineryUnavailable');
    const atBay=structuredClone(midway);atBay.ship.position={x:109,y:60};
    reject(()=>reduceCampaignEngineering(atBay,{type:'enter',groupIndex:1}),'equipmentUnavailable');
    for(const action of [{type:'view',view:'ship'},{type:'sleep'},{type:'jettison',selection:3},{type:'fire',focused:true}])
      reject(()=>reduceCampaignSpace(midway,action),'spaceUnavailable');
    reject(()=>comm(midway),'shipCommunicationUnavailable');
  });
  await test('Space Comm uses the visited bank/system and a nullable airborne world rather than the parked ground domain',()=>{
    let s=contact(1);s.regional.shipLocation.worldId=null;s.regional.podWorldId=null;s.regional.shipLocation.orbit.radius=43;
    s=act(s,{type:'setWarp',systemId:'system-02'});s.resources.warp.charge=s.resources.warp.targetCharge;s=act(s,{type:'warp'});
    equal(s.regional.shipLocation.systemId,'system-02');equal(s.ground.worldId,'world-01');equal(s.regional.shipLocation.worldId,null);
    s.space.flags[40]=s.space.flags[44]=true;s.encounters.randomState=1;
    const opened=comm(s),context=opened.space.communication.conversation.context;
    equal(context.system,systems.systems.find(s=>s.id==='system-02'));equal(context.bankBalance,s.economy.accounts[1].balance);
    equal(context.city,0);equal(reload(opened),opened);equal(restoreCampaignShipCommunication(opened,content).view.state,64);
    const returned=reply(reply(reload(opened),{type:'reply',slot:0}),{type:'cancel'});
    equal(returned.economy.accounts,s.economy.accounts);equal(returned.dialogue.cash,s.dialogue.cash);equal(reload(returned),returned);
  });
  await test('Agree commits once without payment or automatic jettison; six ticks then the seventh restore aggression after combat',()=>{
    const initial=buyCargo(contact()),agreed=agree(initial);
    equal(agreed.space.communication,{conversation:null,pending:true,ticks:6});equal(agreed.space.flags[44],false);
    equal(agreed.space.flags[35],false);equal(agreed.space.flags[41],false);equal(agreed.space.flags[47],true);equal(agreed.dialogue.flags[51],false);
    equal(agreed.economy.accounts,initial.economy.accounts);equal(agreed.dialogue.cash,initial.dialogue.cash);equal(agreed.pod.cargo,initial.pod.cargo);
    let s=reload(tick(agreed,249).state);equal(s.space.communication.ticks,6);
    s=tick(s,1).state;equal(s.space.communication.ticks,5);equal(s.space.flags[44],false);
    for(let n=4;n>=0;n--){s=reload(tick(s).state);equal(s.space.communication.ticks,n);equal(s.space.flags[44],false)}
    const rng=s.encounters.randomState,hull=s.resources.hull;
    s=reload(tick(s).state);equal(s.space.communication,{conversation:null,pending:false,ticks:0});equal(s.space.flags[44],true);
    equal(s.encounters.randomState,rng);equal(s.space.flags[45],false);equal(s.resources.hull,hull);
    const next=tick(s).state;equal(next.encounters.randomState,stream(rng,2).state);equal(reload(next),next);
    reject(()=>comm(s),'shipCommunicationUnavailable');reject(()=>reply(s,{type:'cancel'}),'shipCommunicationUnavailable');
  });
  await test('Source Refuse can negotiate retreat; failed refusal or dismissal retains hostility without a cargo demand',()=>{
    const s=tactical(contact(1));s.dialogue.flags[48]=s.dialogue.flags[50]=s.dialogue.flags[51]=true;const opened=comm(s);
    equal(opened.dialogue.flags.slice(48,52),[false,false,false,true]); // Shared globals: source clears48–50, retaining51.
    const refused=reply(opened,{type:'reply',slot:1}),bluffed=reply(reload(refused),{type:'reply',slot:2});
    const fled=reply(reload(bluffed),{type:'cancel'});
    equal([fled.space.words[215],fled.space.words[207]],[128,2]);equal(fled.space.flags[44],false);equal(fled.dialogue.flags[49],false);equal(fled.dialogue.flags[51],true);
    equal(fled.space.communication,{conversation:null,pending:false,ticks:0});equal(fled.encounters.randomState,270844305);equal(reload(fled),fled);
    const failure=reply(reply(comm(tactical(contact(29))),{type:'reply',slot:1}),{type:'cancel'});
    equal(failure.space.flags[44],true);equal(failure.space.communication.pending,false);equal(reload(failure),failure);
    const dismissed=reply(reply(comm(tactical(contact(29))),{type:'cancel'}),{type:'cancel'});
    equal(dismissed.space.flags[44],true);equal(dismissed.space.flags[47],true);equal(reload(dismissed),dismissed);
  });
  await test('Jettison during Agree preserves the source pending deadline; leaving tactical context restores aggression immediately',()=>{
    const agreed=agree(buyCargo(contact(29))),partial=tick(agreed,500).state;
    const lost=reduceCampaignSpace(partial,{type:'jettison',selection:1});
    equal(lost.pod.cargo,[null,null]);equal(lost.space.words[215],128);equal(lost.space.words[207],1);
    equal(lost.space.flags[44],false);equal(lost.space.communication,partial.space.communication);equal(reload(lost),lost);
    const overdue=run(lost,1250);equal(overdue.space.flags[44],true);equal(overdue.space.communication.pending,false);equal(reload(overdue),overdue);
    const left=reduceCampaignSpace(reload(partial),{type:'view',view:'ship'});
    equal(left.space.flags[44],true);equal(left.space.communication,{conversation:null,pending:false,ticks:0});equal(reload(left),left);
    const sleeping=reduceCampaignSpace(partial,{type:'sleep'});equal(sleeping.space.view,'ship');equal(sleeping.space.flags[44],true);
    equal(sleeping.space.communication.pending,false);equal(reload(sleeping),sleeping);
    let warp=structuredClone(partial);warp.regional.shipLocation.worldId=null;warp.regional.podWorldId=null;warp.regional.shipLocation.orbit.radius=43;
    warp=act(warp,{type:'setWarp',systemId:'system-02'});warp.resources.warp.charge=warp.resources.warp.targetCharge;
    const jumped=act(warp,{type:'warp'});equal(jumped.space.flags[40],false);equal(jumped.space.communication.pending,false);equal(reload(jumped),jumped);
  });
  await test('Comm returns and demand clocks continue identically through pauses, JSON reloads and caller display cadences',()=>{
    const s=agree(contact());equal(run(s,2000,10),run(s,2000,100));equal(run(s,2000,250),tick(s,2000).state);
    const partial=tick(s,17).state,paused=tick(reload(partial),60000,createSurvival(partial.ship.condition),true);
    equal(paused.state,partial);equal(paused.survival.elapsed,17);equal(tick(reload(paused.state),233).state,tick(s).state);
    const opened=comm(tactical(contact())),waiting=reply(opened,{type:'reply',slot:0});
    equal(reply(reload(waiting),{type:'cancel'}),reply(waiting,{type:'cancel'}));
  });
  await test('Saved voluntary sleep owns its remainder and rest phase, ignoring reconstructed transient survival defaults',()=>{
    const s=fresh();s.ship.condition.rest=100;
    const sleeping=reduceCampaignSpace(tick(s,249).state,{type:'sleep'});equal(sleeping.space.elapsed,0);
    equal(sleeping.space.activity,{sleeping:true,forced:false,sleepPhase:0});
    const partial=tick(sleeping,49).state;equal(reload(partial),partial);equal(partial.space.elapsed,49);
    const first=tick(reload(partial),1,createSurvival(partial.ship.condition)).state;
    equal(first,tick(sleeping,50).state);equal(first.space.activity.sleepPhase,1);equal(first.ship.condition.rest,100);
    const second=tick(reload(first),50).state;equal(second.space.activity.sleepPhase,0);equal(second.ship.condition.rest,101);
    equal(run(sleeping,4000,10),tick(sleeping,4000).state);equal(tick(partial,60000,survival(partial),true).state,partial);
    const awake=reduceCampaignSpace(first,{type:'wake'});equal(awake.space.activity,{sleeping:false,forced:false,sleepPhase:1});
    equal(awake.space.elapsed,0);equal(reload(awake),awake);equal(tick(awake,249).cycles,0);
    reject(()=>act(first,{type:'distress'}),'flightUnavailable');reject(()=>reduceMachineryControl(first,{type:'guns',enabled:true}),'machineryUnavailable');
    reject(()=>reduceCampaignSpace(first,{type:'view',view:'tactical'}),'spaceUnavailable');reject(()=>reduceCampaignSpace(first,{type:'sleep'}),'spaceUnavailable');
  });
  await test('Forced sleep survives reload and unlocks wake only after source rest recovery; sleep death stays terminal',()=>{
    const s=fresh();s.ship.minutes=59;s.ship.condition={vigor:200,rest:1,health:200,nourishment:200};s.machinery.phase=0;
    const forced=tick(s).state;equal(forced.space.activity,{sleeping:true,forced:true,sleepPhase:0});equal(forced.space.view,'ship');
    equal(forced.ship.condition.rest,0);equal(reload(forced),forced);reject(()=>reduceCampaignSpace(forced,{type:'wake'}),'spaceWakeUnavailable');
    const after=tick(reload(forced),12850,createSurvival(forced.ship.condition)).state;
    equal(after.ship.condition.rest,128);equal(after.space.activity.forced,true);equal(after.space.activity.sleepPhase,1);equal(reload(after),after);
    reject(()=>reduceCampaignSpace(after,{type:'wake'}),'spaceWakeUnavailable');
    const rested=tick(reload(after),50).state;equal(rested.ship.condition.rest,129);equal(rested.space.activity.forced,false);
    equal(reload(reduceCampaignSpace(rested,{type:'wake'})).space.activity.sleeping,false);
    const fatal=reduceCampaignSpace(fresh(),{type:'sleep'});fatal.ship.minutes=59;fatal.machinery.phase=0;
    fatal.ship.condition={vigor:1,rest:0,health:0,nourishment:0};
    const dead=tick(fatal,50).state;equal(dead.combat.defeat,{reason:'conditionDeath',minutes:60});
    equal(dead.space.activity.sleeping,false);equal(dead.space.activity.forced,false);equal(dead.space.elapsed,0);
    equal(tick(reload(dead),60000).state,dead);reject(()=>reduceCampaignSpace(dead,{type:'wake'}),'spaceUnavailable');
    const forged=structuredClone(dead);forged.space.elapsed=1;reject(()=>codec.snapshot(forged));
  });
  await test('Exhaustion exits a pending tactical demand and restores source aggression before subsequent sleeping calls',()=>{
    const s=agree(contact());s.ship.minutes=59;s.machinery.phase=0;s.ship.condition={vigor:200,rest:1,health:200,nourishment:200};
    const forced=tick(s).state;equal(forced.space.view,'ship');equal(forced.space.flags[44],true);equal(forced.space.communication.pending,false);
    equal(forced.space.activity,{sleeping:true,forced:true,sleepPhase:0});equal(reload(forced),forced);
  });
  await test('Forged Comm inputs, frozen owners, deadline and sleep records reject atomically without trusting derived frames',()=>{
    const opened=comm(tactical(contact()));
    for(const change of [s=>s.economy.accounts[0].balance--,s=>s.dialogue.cash--,s=>s.ship.minutes+=60,s=>s.dialogue.attributes[2]++,
      s=>s.ship.inventory.carried[0]=12,s=>s.space.words[214]=2,s=>s.space.words[354]=1,s=>s.space.flags[35]=false,s=>s.space.flags[44]=false,
      s=>s.space.communication.conversation.context.bankBalance--,s=>s.space.communication.conversation.context.system.local32=0,
      s=>s.space.communication.conversation.context.extra=1,s=>s.space.communication.conversation.frame={},
      s=>s.space.communication.conversation.record.inputs=[{type:'reply',slot:0},{type:'cancel'}],
      s=>s.space.communication.conversation.record.inputs=[{type:'cancel',money:100}],s=>s.encounters.randomState++,
      s=>s.space.activity.sleeping=true,s=>s.space.communication.pending=true,s=>s.space.communication.ticks=7]) {
      const bad=structuredClone(opened);change(bad);const before=JSON.stringify(bad);reject(()=>codec.snapshot(bad));equal(JSON.stringify(bad),before);
    }
    const waiting=reply(opened,{type:'reply',slot:0}),before=JSON.stringify(waiting);
    reject(()=>reply(waiting,{type:'cancel',money:100}),'invalidEncounterDialogue');equal(JSON.stringify(waiting),before);
    for(const change of [s=>s.space.communication.ticks=1,s=>s.space.communication.pending=true,s=>s.space.activity.forced=true,
      s=>s.space.activity.sleepPhase=2,s=>s.space.activity.extra=1]) {
      const bad=fresh();change(bad);reject(()=>codec.snapshot(bad));
    }
    const sleeping=reduceCampaignSpace(fresh(),{type:'sleep'});sleeping.space.elapsed=50;reject(()=>codec.snapshot(sleeping));
    sleeping.space.elapsed=0;
    reject(()=>validateCampaignSpace({...sleeping,travel:{scene:'city'}},sleeping.space,{content}),'invalidCampaignSpace');
    const pending=agree(contact());pending.space.view='ship';reject(()=>codec.snapshot(pending));
    const unconsumed=agree(contact());unconsumed.dialogue.flags[51]=true;reject(()=>codec.snapshot(unconsumed));
    const healthy=reduceCampaignSpace(fresh(),{type:'sleep'});healthy.space.activity.forced=true;healthy.ship.condition.rest=129;reject(()=>codec.snapshot(healthy));
  });
}
