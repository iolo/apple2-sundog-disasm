import { campaignSaveCodec } from '../js/core/campaign-saves.js';
import { createCharacter } from '../js/core/character.js';
import { createSurvival, startSleep } from '../js/core/survival.js';
import { reduceMachineryControl, advanceCampaignMachinery, reconcileMachinery } from '../js/core/campaign-machinery.js';
import { reduceCampaignEngineering } from '../js/core/campaign-engineering.js';
import { recalculateEquipment } from '../js/core/equipment.js';

export async function campaignMachineryTests(test,equal) {
  const [navigation,economy,inventory,location,geometry]=await Promise.all(['initial-navigation','initial-economy','ship-inventory','initial-location','ship-walk'].map(n=>fetch(`../data/${n}.json`).then(r=>r.json())));
  const codec=campaignSaveCodec({navigation,economy,inventory,location},geometry);
  const fresh=()=>{const s=codec.create({...createCharacter(),name:'Power pilot'},12345);s.resources.fuel=16;return s};
  const survival=s=>({...createSurvival(s.ship.condition),minutes:s.ship.minutes});
  const control=(s,type,rest)=>reduceMachineryControl(s,{type,...rest});
  const run=(s,ms,chunk=50,v=survival(s))=>{for(let i=0;i<ms;i+=chunk){const r=advanceCampaignMachinery(s,v,Math.min(chunk,ms-i));s=r.state;v=r.survival}return {state:s,survival:v}};
  const reject=(f,code)=>{let got;try{f()}catch(e){got=e.message}equal(got,code)};
  await test('One aboard clock drives power phases and resource consumption independently of frame cadence',()=>{
    let s=control(fresh(),'guns',{enabled:true});s=control(s,'shields',{delta:256});const before=JSON.stringify(s);
    const a=run(s,1000,20),b=run(s,1000,100);equal(a,b);equal(a.state.machinery.phase,0);equal(a.state.ship.minutes,1);
    equal(a.state.resources.fuel,4);equal(a.state.resources.guns.charge,255);equal(a.state.resources.shields.charge,s.equipment[4].performance*8);
    equal(a.state.encounters,s.encounters);equal(a.state.start,s.start);equal(JSON.stringify(s),before);
    const paused=advanceCampaignMachinery(a.state,{...a.survival,elapsed:249},5000,true);equal(paused.state,a.state);equal(paused.survival.elapsed,0);
    const capped=advanceCampaignMachinery(s,survival(s),60000);equal(capped.cycles,1);equal(capped.state.ship.minutes,1);
  });
  await test('Sleep uses the saved machinery phase and shares hourly condition updates and forced-sleep recovery',()=>{
    const s=fresh();s.machinery.phase=2;s.ship.minutes=59;s.ship.condition.rest=90;
    let v=startSleep(survival(s));let r=run(s,100,50,v);equal(r.state.ship.minutes,59);equal(r.state.ship.condition.rest,91);equal(r.state.machinery.phase,0);
    r=run(r.state,50,50,r.survival);equal(r.state.ship.minutes,60);equal(r.state.ship.condition.nourishment,252);
    const exhausted=fresh();exhausted.ship.minutes=59;exhausted.ship.condition.rest=1;
    const forced=run(exhausted,250);equal(forced.survival.sleeping,true);equal(forced.survival.forced,true);equal(forced.state.ship.condition.rest,0);
    const recovered=run(forced.state,12900,50,forced.survival);equal(recovered.state.ship.condition.rest,129);equal(recovered.survival.forced,false);
    const dying=fresh();dying.ship.minutes=59;dying.ship.condition={vigor:1,rest:1,health:1,nourishment:1};
    const dead=run(dying,250);equal(dead.survival.dead,true);equal(run(dead.state,500,50,dead.survival).state,dead.state);
  });
  await test('Machinery tick consumes only an attached auxiliary lot and persists fuel-exhaustion cleanup',()=>{
    const s=control(fresh(),'shields',{delta:256});s.resources.fuel=1;
    s.pod.cargo=[{commodityId:'cargo-01',quality:7,originWorld:'world-01',pricePaid:0},null];
    const fueled=run(s,500).state;equal(fueled.resources.fuel,252);equal(fueled.pod.cargo,[null,null]);equal(fueled.resources.shields.targetCharge,255);equal(codec.snapshot(fueled),fueled);
    const empty=structuredClone(s);empty.pod.cargo=[null,null];const stopped=run(empty,500).state;
    equal(stopped.resources.fuel,0);equal(stopped.resources.shields.targetCharge,0);equal(codec.snapshot(stopped),stopped);
  });
  await test('Last-unit removal clears dependent controls and faulty special burnout disables the cloaker',()=>{
    const s=control(fresh(),'guns',{enabled:true});s.resources.guns.charge=200;
    s.equipment[2]=recalculateEquipment({...s.equipment[2],units:s.equipment[2].units.map(u=>({components:[0,...u.components.slice(1)]}))});
    const cleared=reconcileMachinery(s);equal(cleared.resources.guns,{charge:0,powered:false});equal(codec.snapshot(cleared),cleared);
    const shield=fresh();shield.ship.position={x:116,y:143};shield.ship.inventory.carried=[149,0,0,0];
    const put=reduceCampaignEngineering(shield,{type:'exchange',groupIndex:4,from:{container:'carried',index:0},to:{container:'installed',unit:0,socket:1}}).state;
    equal(put.equipment[4].specialAvailable,true);const cloaked=control(put,'cloak',{enabled:true});equal(codec.snapshot(cloaked),cloaked);
    const failed=reduceCampaignEngineering(cloaked,{type:'tick',groupIndex:4}).state;equal(failed.machinery.cloaked,false);equal(codec.snapshot(failed),failed);
  });
  await test('Current saves preserve every power phase and historical19 saves reject active machinery before migration',()=>{
    for(const phase of [0,1,2,3]) {
      const s=run(control(fresh(),'guns',{enabled:true}),phase*250).state;
      equal(codec.parse(JSON.stringify(codec.make(s,0))).state,s);
      const resumed=codec.snapshot(s);equal(run(resumed,1000),run(s,1000));
    }
    const current=codec.make(fresh(),0),old=structuredClone(current);old.version=19;old.scope='landed-failures-1';delete old.state.machinery;
    equal(codec.validate(old),current);old.state.resources.fuel=1;reject(()=>codec.validate(old),'invalidCampaign');
    old.state.resources.fuel=16;old.state.resources.guns.powered=true;reject(()=>codec.validate(old),'invalidCampaign');
    old.state.resources.guns.powered=false;old.state.machinery={phase:0,cloaked:false};reject(()=>codec.validate(old),'invalidCampaign');
  });
  await test('Power controls reject remote access and invalid adjustments without changing their input',()=>{
    const s=fresh(),before=JSON.stringify(s);reject(()=>control(s,'shields',{delta:1}),'machineryUnavailable');
    s.resources.fuel=0;reject(()=>control(s,'shields',{delta:64}),'machineryNoFuel');s.resources.fuel=16;
    reject(()=>control(s,'cloak',{enabled:true}),'machineryNoCloaker');equal(JSON.stringify(s),before);
    const outside=structuredClone(s);outside.travel.scene='city';reject(()=>control(outside,'guns',{enabled:true}),'machineryUnavailable');
    for(const mutate of [v=>v.machinery.phase=4,v=>v.machinery.extra=0,v=>v.machinery.cloaked=true,v=>v.resources.shields.targetCharge=1,v=>v.resources.warp.charge=8]) {
      const bad=structuredClone(s);mutate(bad);reject(()=>codec.snapshot(bad),'invalidCampaign');
    }
  });
}
