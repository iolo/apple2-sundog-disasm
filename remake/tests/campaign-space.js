import { campaignSaveCodec } from '../js/core/campaign-saves.js';
import { createCharacter } from '../js/core/character.js';
import { createInitialEquipment } from '../js/core/initialization.js';
import { recalculateEquipment } from '../js/core/equipment.js';
import { createSurvival } from '../js/core/survival.js';
import { reduceCampaignFlight } from '../js/core/campaign-flight.js';
import { advanceCampaignMachinery,reduceMachineryControl,reconcileMachinery } from '../js/core/campaign-machinery.js';
import { reduceCampaignEngineering } from '../js/core/campaign-engineering.js';
import { reduceCampaignSpace,stepCampaignSpaceProducer } from '../js/core/campaign-space.js';

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

  await test('Space version25 validates before migration and leaves historical24 hull/failure/cryogen rules strict',()=>{
    const initial=fresh(),save=codec.make(initial,0);equal([save.version,save.scope],[25,'ship-encounters-1']);equal(reload(initial),initial);
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
}
