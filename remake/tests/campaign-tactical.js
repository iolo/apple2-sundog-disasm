import { campaignSaveCodec } from '../js/core/campaign-saves.js';
import { createCharacter } from '../js/core/character.js';
import { createInitialEquipment } from '../js/core/initialization.js';
import { recalculateEquipment } from '../js/core/equipment.js';
import { createSurvival } from '../js/core/survival.js';
import { advanceCampaignMachinery,reduceMachineryControl } from '../js/core/campaign-machinery.js';
import { reduceCampaignSpace,reduceCampaignShipCommunication } from '../js/core/campaign-space.js';
import { reduceCampaignFlight } from '../js/core/campaign-flight.js';

export async function campaignTacticalTests(test,equal) {
  const names=['initial-navigation','initial-economy','initial-location','ship-inventory','ship-walk','maps',
    'city-walk','surface-walk','dialogue','dialogue-text','items','dialogue-systems','ground-chase','ground-combat','exchange-defaults','flight-defaults'];
  const [navigation,economy,location,inventory,walk,maps,cityWalk,surfaceWalk,scripts,text,items,systems,chase,ground,exchange,flight]=
    await Promise.all(names.map(n=>fetch(`../data/${n}.json`).then(r=>r.json())));
  const legacy={navigation,economy,location,inventory,ground:{maps,cityWalk,surfaceWalk},dialogue:{scripts,text,items,systems},
    exchange,flight,regional:true,combat:{chase,ground},space:true};
  const content={...legacy,tactical:true},old=campaignSaveCodec(legacy,walk),codec=campaignSaveCodec(content,walk);
  const fresh=()=>codec.create({...createCharacter(),name:'Tactical host'},12345);
  const tick=(s,ms=50,paused=false)=>advanceCampaignMachinery(s,createSurvival(s.ship.condition),ms,paused,content);
  const run=(s,total,chunk=50)=>{for(let i=0;i<total;i+=chunk)s=tick(s,Math.min(chunk,total-i)).state;return s};
  const reload=s=>codec.parse(JSON.stringify(codec.make(s,0))).state;
  const action=(s,a)=>reduceCampaignSpace(s,a,content);
  const enter=s=>action(s,{type:'view',view:'tactical'});
  const fixture=()=>{
    const s=fresh();s.equipment=createInitialEquipment({next:()=>1}).map(recalculateEquipment);s.resources.fuel=255;
    // Working ordinary sensors, without the targeting computer. Source cache16.
    const g=s.equipment[3];g.units.forEach(u=>u.components[g.requiredSocket]=g.spares[g.requiredSocket]);s.equipment[3]=recalculateEquipment(g);
    s.space.flags[40]=true;s.space.flags[44]=false;s.encounters.randomState=29;s.machinery.phase=0;
    Object.assign(s.space.words,{205:512,206:512,207:-1,208:0,209:0,214:1,215:20,216:200,217:100});return s;
  };
  const gun=s=>action(action(s,{type:'menu',menu:3}),{type:'gun',firing:true,focused:true});
  const comm=s=>reduceCampaignShipCommunication(s,content,{type:'comm'});
  const reply=(s,input)=>reduceCampaignShipCommunication(s,content,{type:'dialogue',input});
  const agree=s=>reply(reply(comm(s),{type:'reply',slot:0}),{type:'cancel'});
  const reject=(f,code='invalidCampaign')=>{let message;try{f()}catch(e){message=e.message}equal(message,code)};

  await test('Tactical28 validates historical26 before migration, preserving RNG/time and the full partial-clock budget',()=>{
    const initial=fresh(),save=codec.make(initial,0);equal([save.version,save.scope],[28,'ship-input-1']);equal(reload(initial),initial);
    const historical=old.make(old.create({...createCharacter(),name:'Tactical host'},12345),0);
    equal(codec.validate(historical).state,initial);
    const active=structuredClone(historical);active.state.space.view='tactical';active.state.space.elapsed=249;active.state.space.words[354]=3;
    const migrated=codec.validate(active).state;equal(migrated.ship,active.state.ship);equal(migrated.encounters,active.state.encounters);
    equal(migrated.resources,active.state.resources);equal(migrated.machinery,active.state.machinery);
    equal([migrated.space.elapsed,migrated.space.tactical.carry],[0,249]);equal(migrated.space.words[354],3);equal(reload(migrated),migrated);
    equal(tick(migrated,60000,true).state,migrated);
    const consumed=tick(migrated,1).state;equal(consumed.space.tactical.carry,0);equal(consumed.space.elapsed,0);
    const forged=structuredClone(active);forged.state.space.tactical=migrated.space.tactical;reject(()=>codec.validate(forged));
    const exited=action(migrated,{type:'view',view:'ship'});equal(exited.space.elapsed,249);equal(exited.space.tactical,null);equal(reload(exited),exited);
  });
  await test('Historical27 validates its exact controller before adding button state without manufacturing a press',()=>{
    let s=gun(enter(fixture()));s=action(s,{type:'aim',control:{x:0,y:0,fire:true}});
    const historical=codec.make(s,0);historical.version=27;historical.scope='ship-tactical-1';delete historical.state.space.tactical.trigger;
    const migrated=codec.validate(historical).state;
    equal(migrated.space.tactical.trigger,{latched:false,previous:true});
    equal(migrated.encounters,s.encounters);equal(migrated.ship,s.ship);equal(migrated.resources,s.resources);equal(reload(migrated),migrated);
    equal(tick(migrated).state.resources.guns.charge,s.resources.guns.charge);
    const extra=structuredClone(historical);extra.state.space.tactical.trigger={latched:false,previous:true};reject(()=>codec.validate(extra));
    const missing=codec.make(s,0);delete missing.state.space.tactical.trigger;reject(()=>codec.validate(missing));
  });
  await test('Held campaign fire shoots once through due recharge, JSON continuation and30/60/144Hz until a new press',()=>{
    let s=gun(enter(fixture()));s.resources.guns.charge=5;s.space.words[217]=20;
    s=action(s,{type:'aim',control:{x:0,y:0,fire:true}});
    const first=tick(s).state;equal(first.space.words[216],104);equal(first.resources.guns.charge,0);
    equal(first.space.tactical.trigger,{latched:false,previous:true});
    const held=run(first,2000);equal(held.space.words[216],104);equal(held.resources.guns.charge>0,true);equal(reload(held),held);
    equal(tick(reload(held),60000,true).state,held);
    for(const hz of [30,60,144]) {
      let state=first,previous=0;
      for(let frame=1;frame<=2*hz;frame++) {const now=Math.floor(frame*1000/hz);state=tick(state,now-previous).state;previous=now;if(frame===hz)state=reload(state)}
      equal(state,held);
    }
    const released=tick(action(held,{type:'aim',control:{x:0,y:0,fire:false}})).state;
    equal(released.space.tactical.trigger,{latched:false,previous:false});
    const again=tick(action(released,{type:'aim',control:{x:0,y:0,fire:true}})).state;
    const noPress=tick(released).state;
    // The target has retreated off center during recharge. The new press is
    // still a shot. This due power phase recharges it immediately for4 fuel;
    // compare the otherwise identical frame without a press.
    equal(again.resources.guns.charge,255);equal(noPress.resources.guns.charge,255);
    equal(again.resources.fuel,noPress.resources.fuel-4);
    equal(again.space.words[216],104);equal(again.space.cooldowns[0],0);
    equal(again.space.tactical.trigger,{latched:false,previous:true});equal(reload(again),again);
  });
  await test('A short press survives partial save/pause, spends empty-space charge and cannot duplicate a cached kill',()=>{
    let s=gun(enter(fixture()));s.space.tactical.record.contact=false;s.space.words[216]=0;s.resources.guns.charge=100;
    s=action(s,{type:'aim',control:{x:0,y:0,fire:true}});
    s=action(s,{type:'aim',control:{x:0,y:0,fire:false}});
    const partial=tick(s,17).state;equal(partial.space.tactical.trigger,{latched:true,previous:false});
    equal(tick(reload(partial),60000,true).state,partial);
    const fired=tick(reload(partial),33).state;
    equal(fired.resources.guns.charge,0);equal(fired.space.words[354],1);equal(fired.space.cooldowns,s.space.cooldowns);
    equal(fired.space.flags[40],true);equal(fired.space.tactical.trigger,{latched:false,previous:false});equal(reload(fired),fired);
    const broken=gun(enter(fixture()));broken.resources.guns.charge=0;
    const pressed=action(broken,{type:'aim',control:{x:0,y:0,fire:true}}),charged=run(pressed,500);
    equal(charged.resources.guns.charge>0,true);equal(charged.space.words[216],200);equal(reload(charged),charged);
  });
  await test('Campaign entry commits three actual ordered machinery calls once, retaining source contact and cached sensor context',()=>{
    const s=fixture();s.space.flags[36]=s.space.flags[47]=true;s.resources.guns.charge=100;const before=JSON.stringify(s),entered=enter(s);
    equal(entered.ship.minutes,s.ship.minutes+1);equal(entered.machinery.phase,3);equal(entered.resources.guns.charge,84);
    equal(entered.encounters.randomState,29);equal([entered.space.words[215],entered.space.words[217],entered.space.words[354]],[20,100,0]);
    equal(entered.space.flags[36],false);equal(entered.space.flags[47],true);
    const t=entered.space.tactical;equal(t.record.reticle,{angle:s.regional.shipLocation.orbit.angle,radius:128});
    equal([t.record.contact,t.record.visible,t.record.sensors,t.record.grace,t.record.frameLimit],[true,false,16,0,5]);
    equal(t.control,{x:0,y:0,fire:false});equal(t.carry,0);equal(reload(entered),entered);equal(enter(entered),entered);equal(JSON.stringify(s),before);
  });
  await test('Targeting entry draws from the actual campaign RNG before startup without granting resources or replacing cached owners',()=>{
    const s=fixture(),sensors=s.equipment[3];sensors.units[0].components[sensors.requiredSocket]=sensors.requiredComponent;
    s.equipment[3]=recalculateEquipment(sensors);s.encounters.randomState=12345;
    const entered=enter(s);equal(entered.encounters.randomState,202267833);
    equal([entered.space.words[206],entered.space.words[205]],[472,462]);equal(entered.space.tactical.record.reticle,{angle:118,radius:115});
    equal(entered.pod.cargo,s.pod.cargo);equal(entered.economy,s.economy);equal(reload(entered),entered);
  });
  await test('Saved tactical frames follow native odd/even dispatch and pre/post-due movement, resetting354 only at phase1',()=>{
    const s=enter(fixture()),partial=tick(s,49).state;equal(partial.space.elapsed,49);equal(partial.space.words[215],20);
    const first=tick(reload(partial),1);equal(first.frames,1);equal(first.cycles,0);equal([first.state.space.words[354],first.state.space.words[215],first.state.space.words[217]],[1,19,99]);
    const even=tick(first.state);equal([even.state.space.words[354],even.state.space.words[215]],[2,19]);
    const due=tick(s,250);equal([due.frames,due.cycles],[5,1]);equal([due.state.space.words[215],due.state.space.words[217],due.state.space.words[354]],[16,96,5]);
    equal(due.state.machinery.phase,0);equal(due.state.ship.minutes,s.ship.minutes);equal(reload(due.state),due.state);
    const clock=tick(due.state,100);equal(clock.cycles,1);equal(clock.state.machinery.phase,1);equal(clock.state.ship.minutes,s.ship.minutes+1);
    equal([clock.state.space.words[354],clock.state.space.words[215],clock.state.space.words[217]],[0,14,94]);equal(reload(clock.state),clock.state);
  });
  await test('Frame state, held input and RNG continue identically at30/60/144Hz, through partial reload and pause',()=>{
    let s=enter(fixture());s.space.words[215]=0;s.space.words[207]=0;s.space.words[217]=39;
    s.space.words[206]=538;s.space.tactical.record.visible=true;s.space.tactical.record.grace=0;
    const reference=run(s,3000,50);equal(run(s,3000,10),reference);equal(run(s,3000,250),reference);equal(tick(s,3000).state,reference);
    for(const hz of [30,60,144]) {
      let state=s,previous=0;
      for(let frame=1;frame<=3*hz;frame++) {
        const now=Math.floor(frame*1000/hz);state=tick(state,now-previous).state;previous=now;
        if(frame===hz)state=reload(state);
      }
      equal(state,reference);
    }
    const partial=tick(s,17).state;equal(tick(reload(partial),60000,true).state,partial);
    equal(tick(reload(partial),33).state,tick(s,50).state);equal(reload(reference),reference);
  });
  await test('Campaign gun loops spend actual charge before movement, keep kill cooldowns and permit source inoperative-loop power only in28',()=>{
    let s=enter(fixture());s.resources.guns.charge=100;s.space.words[217]=20;
    s=gun(s);s=action(s,{type:'aim',control:{x:8,y:8,fire:true}});equal(reload(s),s);
    const before=JSON.stringify(s),shot=tick(s).state;equal(shot.resources.guns.charge,0);equal(shot.space.words[216],0);equal(shot.space.words[354],2);
    equal(shot.space.cooldowns[0],1);equal(shot.space.tactical.record.contact,false);
    equal(shot.space.tactical.record.reticle,{angle:120,radius:(s.regional.shipLocation.orbit.angle-8<<16)>>16});
    equal(shot.encounters.randomState,s.encounters.randomState);equal(reload(shot),shot);equal(JSON.stringify(s),before);
    const stopped=action(shot,{type:'menu',menu:0});equal(stopped.resources.guns.powered,false);equal(stopped.space.tactical.record.firing,false);
    const broken=enter(fixture());broken.equipment[2].units.forEach(u=>u.components[0]=0);broken.equipment[2]=recalculateEquipment(broken.equipment[2]);broken.resources.guns.charge=0;
    const loop=gun(broken);equal(loop.resources.guns.powered,true);equal(reload(loop),loop);equal(tick(loop).state.space.words[216],200);
    const forged=codec.make(loop,0);forged.version=26;forged.scope='ship-communication-1';delete forged.state.space.tactical;reject(()=>codec.validate(forged));
    const outside=structuredClone(loop);outside.space.tactical.record.firing=false;reject(()=>codec.snapshot(outside));
  });
  await test('Submenus keep main-frame increments after release, and cached sensors gate actual shield/cloak controls',()=>{
    const s=enter(fixture()),menu=action(s,{type:'menu',menu:1}),first=tick(menu).state;
    equal(first.space.words[354],1);equal(first.space.words[215],19);equal(reload(first),first);
    const shield=reduceMachineryControl(first,{type:'shields',delta:64});equal(shield.resources.shields.targetCharge,64);
    const low=structuredClone(first);low.space.tactical.record.sensors=1;
    reject(()=>action(low,{type:'menu',menu:3}),'shipTacticalUnavailable');
    reject(()=>reduceMachineryControl(low,{type:'shields',delta:64}),'shipTacticalUnavailable');
    reject(()=>reduceMachineryControl(low,{type:'cloak',enabled:true}),'shipTacticalUnavailable');
    reject(()=>action(first,{type:'fire',focused:true}),'spaceUnavailable');
  });
  await test('Armed campaign jettison conserves actual losses and purchase costs, excludes stored cryogens and retains the Comm deadline',()=>{
    let s=enter(fixture());const lot={commodityId:'cargo-02',quality:7,originCity:'city-01',pricePaid:100};
    s.economy.accounts[0].balance-=100;s.pod.cargo[0]=lot;
    const archive=s.regional.cities.find(c=>c.warehouse.slots.some(l=>l?.commodityId==='cargo-31'));
    const slot=archive.warehouse.slots.findIndex(l=>l?.commodityId==='cargo-31');s.pod.cargo[1]=archive.warehouse.slots[slot];archive.warehouse.slots[slot]=null;
    s.space.communication.pending=true;s.space.communication.ticks=6;s.space.flags[47]=true;s.encounters.randomState=28;
    reject(()=>action(s,{type:'jettison',selection:1}),'shipCargoUnavailable');
    const armed=action(s,{type:'menu',menu:2});equal(armed.space.tactical.record.jettisonChoices,[true,false]);equal(reload(armed),armed);
    reject(()=>action(armed,{type:'jettison',selection:2}),'shipCargoUnavailable');reject(()=>action(armed,{type:'jettison',selection:3}),'shipCargoUnavailable');
    const lost=action(armed,{type:'jettison',selection:1});equal(lost.pod.cargo[0],null);equal(lost.pod.cargo[1],s.pod.cargo[1]);
    equal(lost.space.losses,[{lot,count:1}]);equal(lost.space.communication,armed.space.communication);equal(lost.space.words[215],128);equal(reload(lost),lost);
    const forged=structuredClone(lost);forged.economy.accounts[0].balance++;reject(()=>codec.snapshot(forged));
    const cancelled=action(armed,{type:'menu',menu:0});equal(cancelled.pod.cargo,armed.pod.cargo);equal(cancelled.encounters.randomState,armed.encounters.randomState);
  });
  await test('Frozen campaign Comm restores a byte-sized reticle without repeating startup calls and counts only actual due deadlines',()=>{
    let s=enter(fixture());s.space.tactical.record.reticle={angle:-1,radius:777};s=tick(s,17).state;
    const opened=comm(s);equal(opened.space.tactical.record.reticle,{angle:255,radius:9});equal(reload(opened),opened);equal(tick(opened,60000).state,opened);
    reject(()=>action(opened,{type:'aim',control:{x:1,y:0,fire:false}}),'spaceUnavailable');
    const agreed=reply(reply(opened,{type:'reply',slot:0}),{type:'cancel'});
    // Native Game13 $2588 advances phase3→4 before Game12 restores255/9.
    // The host stores phase modulo4. There are no three startup calls.
    equal(agreed.ship.minutes,opened.ship.minutes);equal(opened.machinery.phase,3);equal(agreed.machinery.phase,0);equal(agreed.resources,opened.resources);
    equal(agreed.space.elapsed,17);equal(agreed.space.tactical.record.reticle,{angle:255,radius:9});equal(agreed.space.communication.ticks,6);equal(agreed.space.words[354],0);equal(reload(agreed),agreed);
    let state=agreed,due=0;
    for(let frame=0;due<7&&frame<100;frame++) {
      const r=tick(state);state=reload(r.state);
      if(r.cycles){due++;equal(state.space.communication.ticks,Math.max(0,6-due));equal(state.space.flags[44],due===7)}
    }
    equal(due,7);equal(state.space.communication.pending,false);
  });
  await test('Comm return runs exactly one actual dispatcher phase before arming its deadline, including power, clock and forced sleep',()=>{
    for(const phase of [0,1,2,3]) {
      const s=enter(fixture());s.machinery.phase=phase;s.resources.guns.charge=100;
      const returned=agree(s);
      equal(returned.machinery.phase,(phase+1)%4);
      equal(returned.ship.minutes,s.ship.minutes+(phase===0?1:0));
      equal(returned.resources.guns.charge,phase%2===0?92:100);
      equal(returned.space.communication,{conversation:null,pending:true,ticks:6});
      equal(returned.space.flags[35],false);equal(returned.space.flags[47],true);equal(reload(returned),returned);
      equal(tick(reload(returned),60000,true).state,returned);
    }
    const s=enter(fixture());s.machinery.phase=0;s.ship.minutes=59;
    s.ship.condition={vigor:200,rest:1,health:200,nourishment:200};
    const sleeping=agree(s);
    equal(sleeping.ship.minutes,60);equal(sleeping.space.activity.sleeping,true);equal(sleeping.space.activity.forced,true);
    equal(sleeping.space.view,'ship');equal(sleeping.space.tactical,null);equal(sleeping.space.flags[35],false);
    equal(sleeping.space.communication,{conversation:null,pending:false,ticks:0});equal(reload(sleeping),sleeping);
    const escaped=enter(fixture());escaped.space.words[217]=129;
    const returned=agree(escaped);
    equal(returned.space.flags[40],false);equal(returned.space.flags[47],true);equal(returned.space.tactical.record.contact,false);
    equal(returned.space.communication,{conversation:null,pending:true,ticks:6});equal(reload(returned),returned);
  });
  await test('Successful warp commits its counter/call followed by three entry calls, while gravity failure retains the active host',()=>{
    const s=run(reduceCampaignFlight(fixture(),content,{type:'launch'}),4250);
    s.space.flags[40]=s.space.flags[47]=true;s.resources.guns.charge=100;
    let charged=reduceCampaignFlight(s,content,{type:'setWarp',systemId:'system-02'});charged.resources.warp.charge=charged.resources.warp.targetCharge;
    const failed=reduceCampaignFlight(charged,content,{type:'warp'});equal(failed.space.flags[40],true);equal(failed.space.flags[47],true);equal(failed.space.tactical,null);equal(reload(failed),failed);
    charged.regional.shipLocation.worldId=null;charged.regional.podWorldId=null;charged.regional.shipLocation.orbit.radius=43;
    const jumped=reduceCampaignFlight(charged,content,{type:'warp'});
    equal(jumped.regional.shipLocation.systemId,'system-02');equal(jumped.space.flags[40],false);equal(jumped.space.flags[47],false);
    equal(jumped.machinery.phase,charged.machinery.phase);equal(jumped.ship.minutes,charged.ship.minutes+1);equal(jumped.resources.guns.charge,84);
    equal(jumped.space.words[354],0);equal(jumped.space.tactical.record.contact,false);equal(reload(jumped),jumped);
  });
  await test('Voluntary/forced sleep and ship defeat release the saved firing loop and retain durable terminal ownership',()=>{
    const active=gun(enter(fixture())),sleeping=action(active,{type:'sleep'});equal(sleeping.space.tactical,null);equal(sleeping.resources.guns.powered,false);equal(reload(sleeping),sleeping);
    const forced=structuredClone(active);forced.ship.minutes=59;forced.ship.condition={vigor:200,rest:1,health:200,nourishment:200};forced.machinery.phase=0;forced.space.words[354]=4;
    const asleep=tick(forced).state;equal(asleep.space.view,'ship');equal(asleep.space.tactical,null);equal(asleep.space.activity.sleeping,true);equal(asleep.space.activity.forced,true);equal(reload(asleep),asleep);
    const fatal=enter(fixture());fatal.space.flags[45]=true;fatal.resources.hull=1;fatal.space.words[217]=20;fatal.space.words[354]=4;
    const dead=tick(fatal).state;equal(dead.space.words[347],1);equal(dead.space.defeat.reason,'shipDestroyed');equal(dead.space.tactical,null);equal(dead.space.elapsed,0);equal(reload(dead),dead);equal(tick(dead,60000).state,dead);
  });
  await test('Malformed tactical imports and input reject atomically, with historical26 and frozen Comm constraints intact',()=>{
    const s=enter(fixture()),before=JSON.stringify(s);
    for(const change of [v=>v.space.tactical=null,v=>v.space.tactical.extra=1,v=>v.space.tactical.record.extra=1,
      v=>v.space.tactical.record.frameLimit=15,v=>v.space.tactical.record.grace=32768,v=>v.space.tactical.control.x=9,
      v=>v.space.tactical.control.fire=1,v=>v.space.tactical.control.extra=1,v=>v.space.elapsed=50,
      v=>v.space.tactical.trigger=null,v=>v.space.tactical.trigger.extra=1,v=>v.space.tactical.trigger.latched=1,v=>v.space.tactical.trigger.previous=0,
      v=>v.space.tactical.carry=250,v=>{v.space.tactical.carry=1;v.space.elapsed=1},v=>v.space.view='ship']) {
      const bad=structuredClone(s);change(bad);reject(()=>codec.snapshot(bad));
    }
    reject(()=>action(s,{type:'aim',control:{x:0,y:0,fire:false,extra:1}}),'invalidCampaignSpace');equal(JSON.stringify(s),before);
    const opened=comm(s),bad=structuredClone(opened);bad.space.tactical.record.menu=3;reject(()=>codec.snapshot(bad));
    const input=structuredClone(opened);input.space.tactical.trigger.latched=true;reject(()=>codec.snapshot(input));
    reject(()=>campaignSaveCodec({...legacy,tactical:false},walk),'invalidCampaignContent');
  });
}
