import { campaignSaveCodec } from '../js/core/campaign-saves.js';
import { createCharacter } from '../js/core/character.js';
import { createInitialEquipment } from '../js/core/initialization.js';
import { recalculateEquipment } from '../js/core/equipment.js';
import { createSurvival } from '../js/core/survival.js';
import { advanceCampaignMachinery,reduceMachineryControl } from '../js/core/campaign-machinery.js';
import { reduceCampaignSpace,reduceCampaignShipCommunication } from '../js/core/campaign-space.js';
import { reduceCampaignFlight } from '../js/core/campaign-flight.js';
import { reduceWarehouseCargo } from '../js/core/cargo.js';
import { reduceCampaignExchange,exchangeSaleQuote } from '../js/core/campaign-exchange.js';
import { createGroundWorld } from '../js/core/campaign-ground.js';
import { regionalGroundStart } from '../js/core/regional-world.js';
import { cityServiceAt } from '../js/core/city-doors.js';
import { cityReachability,SHIP_REENTRY } from '../js/core/city-walk.js';
import { groundCameraAt } from '../js/core/ground-camera.js';

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
  const kill=(seed=29,enemyType=1)=>{
    let s=gun(enter(fixture()));s.resources.guns.charge=100;s.space.words[217]=20;s.space.words[214]=enemyType;s.encounters.randomState=seed;
    return tick(action(s,{type:'aim',control:{x:0,y:0,fire:true}})).state;
  };
  const tractor=s=>action(action(s,{type:'gun',firing:false,focused:true}),{type:'tractor'});

  await test('Actual ship kills credit only their system account, persist bounded bounty/wreck receipts and cannot award twice on held fire',()=>{
    const before=gun(enter(fixture())),s=kill();
    equal(s.economy.accounts[0].balance,before.economy.accounts[0].balance+2000);
    equal(s.economy.accounts.slice(1),before.economy.accounts.slice(1));equal(s.dialogue.cash,before.dialogue.cash);
    equal(s.space.bounties,[{systemId:'system-01',enemyType:1,count:1}]);
    equal(s.space.wrecks,[{lot:{commodityId:'cargo-26',quality:7,originCity:null,pricePaid:0},count:1}]);
    equal(s.space.flags[36],true);equal(s.space.words[217],21);equal(s.encounters.randomState,61296285);equal(reload(s),s);
    const held=run(reload(s),500);equal(held.space.bounties,s.space.bounties);equal(held.space.wrecks,s.space.wrecks);
    equal(held.economy.accounts,s.economy.accounts);equal(held.encounters.randomState,s.encounters.randomState);
    const missing=structuredClone(s);missing.space.bounties=[];reject(()=>codec.snapshot(missing));
    const wrong=structuredClone(s);wrong.space.bounties[0].systemId='system-02';reject(()=>codec.snapshot(wrong));
    const extra=structuredClone(s);extra.space.bounties[0].amount=2000;reject(()=>codec.snapshot(extra));
    const doubled=structuredClone(s);doubled.space.wrecks[0].count=2;reject(()=>codec.snapshot(doubled));
    const unpaid=kill(29,0);equal(unpaid.economy.accounts,before.economy.accounts);
    equal(unpaid.space.bounties,[{systemId:'system-01',enemyType:0,count:1}]);equal(unpaid.space.wrecks[0].count,1);equal(reload(unpaid),unpaid);
    let overflow=gun(enter(fixture()));overflow.resources.guns.charge=100;overflow.space.words[217]=20;overflow.economy.accounts[0].balance=32767999;
    overflow=action(overflow,{type:'aim',control:{x:0,y:0,fire:true}});const capped=structuredClone(overflow);
    reject(()=>tick(overflow),'bankOverflow');equal(overflow,capped);
  });
  await test('Tractor calls every50ms frame, runs actual due power/time and copies into slot2 once through pause, partial reload and display cadences',()=>{
    const start=tractor(kill()),pull=tick(start,100).state;
    equal(start.space.tactical.record.wreck.tractorSlot,1);equal(start.space.words[207],-4);
    equal(pull.space.words[217],13);equal(pull.pod.cargo,[null,null]);equal(reload(pull),pull);
    equal(tick(reload(pull),60000,true).state,pull);
    const done=tick(reload(pull),150);equal(done.frames,3);equal(done.cycles,2);
    equal(done.state.ship.minutes,start.ship.minutes+1);equal(done.state.space.words[217],1);
    equal(done.state.pod.cargo,[null,start.space.tactical.record.wreck.lot]);equal(done.state.space.flags[36],false);
    equal(done.state.space.tactical.record.wreck,null);equal(reload(done.state),done.state);
    const expected=run(start,1000);
    for(const hz of [30,60,144]) {
      let state=start,last=0;
      for(let frame=1;frame<=hz;frame++) {const now=Math.floor(frame*1000/hz);state=tick(state,now-last).state;last=now;if(frame===Math.floor(hz/3))state=reload(state)}
      equal(state,expected);
    }
    const partial=tick(start,17).state;equal(tick(reload(partial),33).state,tick(start).state);
    for(const a of [{type:'aim',control:{x:0,y:0,fire:false}},{type:'view',view:'ship'},{type:'sleep'},{type:'menu',menu:0},{type:'tractor'}])reject(()=>action(start,a),'shipTractorActive');
    reject(()=>reduceMachineryControl(start,{type:'shields',delta:64}),'shipTractorActive');
    reject(()=>reduceCampaignFlight(start,content,{type:'halt'}),'shipTractorActive');
    reject(()=>comm(start),'shipTractorActive');
  });
  await test('Full pods and absent wrecks reject tractor atomically; source detached pods retain the same actual manifest owner',()=>{
    const s=action(kill(),{type:'gun',firing:false,focused:true}),full=structuredClone(s);
    const purchased={commodityId:'cargo-02',quality:7,originCity:'city-01',pricePaid:100};
    full.pod.cargo=[structuredClone(purchased),structuredClone(purchased)];full.economy.accounts[0].balance-=200;
    equal(reload(full),full);const before=structuredClone(full);
    reject(()=>action(full,{type:'tractor'}),'shipTractorNoRoom');equal(full,before);
    const empty=action(enter(fixture()),{type:'menu',menu:3});reject(()=>action(empty,{type:'tractor'}),'shipTractorOutOfRange');
    const detached=structuredClone(s);detached.pod.attached=false;
    // Isolate proc18's source access rule. No second hold or attachment grant.
    const pulling=action(detached,{type:'tractor'});equal(pulling.pod,detached.pod);equal(pulling.space.tactical.record.wreck.tractorSlot,1);
  });
  await test('Newly collected wreck fuel enters cargo after the due machinery call and refuels only on its next actual call',()=>{
    const s=tractor(kill(0));s.space.words[217]=5;s.space.words[354]=4;s.machinery.phase=0;s.resources.fuel=0;
    const before=structuredClone(s),loaded=tick(s).state;
    equal(s,before);equal(loaded.resources.fuel,0);
    equal(loaded.pod.cargo,[null,{commodityId:'cargo-01',quality:4,originCity:null,pricePaid:0}]);
    equal(loaded.machinery.phase,1);equal(reload(loaded),loaded);
    loaded.space.words[354]=4;const consumed=tick(loaded).state;
    equal(consumed.resources.fuel,255);equal(consumed.pod.cargo,[null,null]);equal(consumed.space.wrecks,loaded.space.wrecks);equal(reload(consumed),consumed);
  });
  await test('Historical28 validates its exact old cargo/controller before adding empty salvage owners without retroactive bounty or RNG',()=>{
    let s=gun(enter(fixture()));s.space.flags[36]=true;s.space.words[216]=0;s.space.tactical.record.contact=false;
    s=action(s,{type:'aim',control:{x:0,y:0,fire:true}});const h=codec.make(s,0);
    h.version=28;h.scope='ship-input-1';delete h.state.space.bounties;delete h.state.space.wrecks;delete h.state.space.tactical.record.wreck;
    const migrated=codec.validate(h).state;equal(migrated,s);equal(reload(migrated),migrated);
    const extra=structuredClone(h);extra.state.space.wrecks=[];reject(()=>codec.validate(extra));
    const record=structuredClone(h);record.state.space.tactical.record.wreck=null;reject(()=>codec.validate(record));
    const cargo=structuredClone(h);cargo.state.pod.cargo[0]={commodityId:'cargo-25',quality:6,originCity:null,pricePaid:0};reject(()=>codec.validate(cargo));
    const missing=codec.make(s,0);delete missing.state.space.bounties;reject(()=>codec.validate(missing));
  });
  await test('Salvage has one wreck/pod/warehouse/loss owner, survives regional archives and sells through the actual exchange into its account',()=>{
    const collected=run(tractor(kill()),250),lot=collected.pod.cargo[1];equal(reload(collected),collected);
    const session=reduceWarehouseCargo({warehouse:collected.economy.exchange.warehouse,pod:collected.pod.cargo},
      {cityId:'city-01',transport:'pod'},{type:'store',slot:1},{auxiliaryFuel:true,salvage:true});
    const stored=structuredClone(collected);stored.economy.exchange.warehouse=session.warehouse;stored.pod.cargo=session.pod;equal(reload(stored),stored);
    const archived=structuredClone(stored);archived.economy.exchange.warehouse.slots[0]=null;
    const remote=archived.regional.cities.find(c=>c.market.cityId==='city-09').warehouse;remote.slots[remote.slots.indexOf(null)]=lot;
    equal(reload(archived),archived);const duplicated=structuredClone(archived);duplicated.pod.cargo[0]=lot;reject(()=>codec.snapshot(duplicated));
    const invented=structuredClone(stored);invented.space.wrecks=[];reject(()=>codec.snapshot(invented));
    const armed=action(collected,{type:'menu',menu:2}),lost=action(armed,{type:'jettison',selection:2});
    equal(lost.pod.cargo,[null,null]);equal(lost.space.losses,[{lot,count:1}]);equal(reload(lost),lost);
    let visiting=action(stored,{type:'view',view:'ship'});
    const world=createGroundWorld({...content,...content.ground},regionalGroundStart(visiting)),city=world.city('city-01',true),reached=cityReachability(city);
    let door;for(let y=192;y<576&&!door;y++)for(let x=280;x<840;x++)if(cityServiceAt(city.map,{x,y})==='exchange'&&reached({x,y})){door={x,y};break}
    equal(!!door,true);visiting.ship.position={...SHIP_REENTRY};visiting.travel={scene:'city',cityPosition:door};visiting.ground.camera=groundCameraAt(door);
    visiting=reduceCampaignExchange(visiting,content,city.map,{type:'enter'});equal(reload(visiting),visiting);
    const quote=exchangeSaleQuote(visiting,content,0),bank=visiting.economy.accounts[0].balance;equal(quote>0,true);
    const sold=reduceCampaignExchange(visiting,content,city.map,{type:'sell',slot:0});
    equal(sold.economy.accounts[0].balance,bank+quote);equal(sold.economy.accounts.slice(1),visiting.economy.accounts.slice(1));
    equal(sold.regional.cargoProceeds,quote);equal(sold.economy.exchange.warehouse.slots[0],null);equal(reload(sold),sold);
  });

  await test('Tactical29 validates historical26 before migration, preserving RNG/time and the full partial-clock budget',()=>{
    const initial=fresh(),save=codec.make(initial,0);equal([save.version,save.scope],[29,'ship-salvage-1']);equal(reload(initial),initial);
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
    delete historical.state.space.bounties;delete historical.state.space.wrecks;delete historical.state.space.tactical.record.wreck;
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
    equal(shot.encounters.randomState,61296285);equal(reload(shot),shot);equal(JSON.stringify(s),before);
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
  await test('Native fatal tactical frame finishes movement and one Game13 display call before freezing saved defeat',()=>{
    const s=enter(fixture());s.resources.hull=1;s.resources.fuel=228;s.resources.guns={charge:68,powered:false};
    s.resources.shields={charge:0,targetCharge:0};s.encounters.randomState=28;s.machinery.phase=1;
    s.ship.minutes=1278;s.ship.condition={vigor:237,rest:235,health:255,nourishment:228};
    s.space.rangeMemory=45;s.space.flags[45]=true;
    Object.assign(s.space.words,{205:512,206:512,207:0,208:0,209:0,214:1,215:41,216:200,217:5,354:4});
    const before=structuredClone(s),result=tick(s),dead=result.state;
    // R10p $096A -> Startup7 $04B2: phase2 ->3, gun68 ->60,
    // cooldown40 ->35 (one post-due move then the non-tactical -4).
    equal([result.frames,result.cycles,dead.machinery.phase],[1,2,3]);
    equal([dead.resources.hull,dead.resources.guns.charge,dead.resources.fuel],[0,60,228]);
    equal([dead.space.words[215],dead.space.words[217],dead.space.words[354]],[35,5,5]);
    equal(dead.encounters.randomState,0xc3870fdc);equal(dead.ship.minutes,1278);equal(dead.ship.condition,s.ship.condition);
    equal(dead.equipment,s.equipment);equal(dead.pod.cargo,s.pod.cargo);
    equal(dead.space.defeat,{reason:'shipDestroyed',minutes:1278});equal(dead.space.tactical,null);equal(dead.space.elapsed,0);
    equal(reload(dead),dead);equal(tick(reload(dead),60000).state,dead);equal(result.survival.dead,true);equal(s,before);
  });
  await test('Fatal exit releases gun power and demand before its actual phase1 clock without re-running after reload',()=>{
    const s=gun(enter(fixture()));s.resources.hull=1;s.resources.guns.charge=68;s.resources.shields={charge:0,targetCharge:0};
    s.encounters.randomState=28;s.machinery.phase=3;s.ship.minutes=59;s.ship.condition={vigor:237,rest:235,health:255,nourishment:228};
    s.space.flags[45]=true;s.space.communication.pending=true;s.space.communication.ticks=2;
    Object.assign(s.space.words,{207:0,208:0,209:0,215:41,217:5,354:4});
    const dead=tick(s).state;equal(dead.ship.minutes,60);equal(dead.machinery.phase,1);
    equal(dead.resources.guns,{charge:60,powered:false});equal(dead.space.words[354],0);
    equal(dead.ship.condition,{vigor:237,rest:231,health:255,nourishment:225});
    equal(dead.space.defeat,{reason:'shipDestroyed',minutes:59});equal(dead.space.communication.pending,false);
    equal(dead.space.communication.ticks,0);equal(dead.space.flags[44],true);equal(reload(dead),dead);
    equal(tick(reload(dead),60000).state,dead);
    const forged=structuredClone(dead);forged.space.defeat.minutes=58;reject(()=>codec.snapshot(forged));
    const wrongPhase=structuredClone(dead);wrongPhase.machinery.phase=2;reject(()=>codec.snapshot(wrongPhase));
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
    const wreck=kill(),pulling=tractor(wreck);
    for(const change of [v=>v.space.tactical.record.wreck.extra=1,v=>v.space.tactical.record.wreck.lot.commodityId='cargo-31',
      v=>v.space.tactical.record.wreck.lot.quality=3,v=>v.space.tactical.record.wreck.lot.pricePaid=100,
      v=>v.space.tactical.record.wreck.lot.originCity='city-01',v=>v.space.tactical.record.wreck.present=false,
      v=>v.space.tactical.record.wreck.tractorSlot=2,v=>v.space.flags[36]=false,v=>v.space.words[216]=1,
      v=>v.space.wrecks[0].count=0,v=>v.space.wrecks[0].extra=1,v=>v.space.bounties[0].count=0]) {
      const bad=structuredClone(wreck);change(bad);reject(()=>codec.snapshot(bad));
    }
    for(const change of [v=>v.space.tactical.record.menu=0,v=>v.space.tactical.record.firing=true,
      v=>v.space.tactical.control.x=1,v=>v.space.tactical.trigger.latched=true,
      v=>v.pod.cargo[1]=v.space.tactical.record.wreck.lot]) {
      const bad=structuredClone(pulling);change(bad);reject(()=>codec.snapshot(bad));
    }
    const opened=comm(s),bad=structuredClone(opened);bad.space.tactical.record.menu=3;reject(()=>codec.snapshot(bad));
    const input=structuredClone(opened);input.space.tactical.trigger.latched=true;reject(()=>codec.snapshot(input));
    reject(()=>campaignSaveCodec({...legacy,tactical:false},walk),'invalidCampaignContent');
  });
}
