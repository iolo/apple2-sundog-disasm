import { campaignSaveCodec } from '../js/core/campaign-saves.js';
import { createCharacter } from '../js/core/character.js';
import { reduceCampaignEngineering, engineeringStatus } from '../js/core/campaign-engineering.js';

export async function campaignEngineeringTests(test,equal) {
  const [navigation,economy,inventory,location,geometry]=await Promise.all(['initial-navigation','initial-economy','ship-inventory','initial-location','ship-walk'].map(n=>fetch(`../data/${n}.json`).then(r=>r.json())));
  const codec=campaignSaveCodec({navigation,economy,inventory,location},geometry);
  const fresh=()=>{const s=codec.create({...createCharacter(),name:'Mechanic'},12345);s.ship.position={x:109,y:60};s.ship.inventory.carried=[156,28,23,0];return s};
  const pocket=index=>({container:'carried',index}),installed=(unit,socket)=>({container:'installed',unit,socket});
  const act=(s,type,rest={})=>reduceCampaignEngineering(s,{type,groupIndex:0,...rest});
  const put=s=>act(s,'exchange',{from:pocket(0),to:installed(0,1)}).state;
  const reject=(f,want='invalidCampaign')=>{let got;try{f()}catch(e){got=e.message}equal(got,want)};
  await test('Live engineering owns pending installation, failed output and repaired replacement across saves',()=>{
    const s=fresh(),before=JSON.stringify(s),pending=put(s);
    equal(pending.engineering.pendingFailures,[1,31,31,31,31,31]);equal(pending.equipment[0].performance,15);
    equal(pending.ship.inventory.carried,[23,28,23,0]);equal(pending.equipment[0].units[0].components[1],156);
    equal(codec.parse(JSON.stringify(codec.make(pending,0))).state,pending);
    const failed=act(pending,'tick').state;equal(failed.equipment[0].units[0].components[1],7);equal(failed.equipment[0].performance,11);
    equal(codec.snapshot(failed),failed);equal(act(failed,'tick').state,failed);
    const repair=act(failed,'exchange',{from:installed(0,1),to:pocket(3)}).state;
    equal(repair.ship.inventory.carried[3],7);equal(repair.equipment[0].units[0].components[1],0);
    const repaired=act(repair,'exchange',{from:pocket(1),to:installed(0,1)}).state;
    equal(repaired.equipment[0].performance,15);equal(codec.snapshot(repaired),repaired);
    equal(repaired.dialogue,s.dialogue);equal(repaired.resources,s.resources);equal(repaired.encounters,s.encounters);equal(repaired.start,s.start);equal(repaired.ship.minutes,s.ship.minutes);equal(JSON.stringify(s),before);
  });
  await test('Pending failures prevent stale-target exchanges and resolve canonically at frame entry',()=>{
    const pending=put(fresh()),before=JSON.stringify(pending);
    const blocked=act(pending,'exchange',{from:pocket(1),to:installed(0,1)});
    equal(blocked.state,pending);equal(blocked.message,'equipmentPending');equal(JSON.stringify(pending),before);
    const opened=act(pending,'enter');equal(opened.message,'equipmentFailed');equal(opened.state,act(pending,'tick').state);
    equal(codec.snapshot(opened.state),opened.state);equal(engineeringStatus(opened.state.equipment,opened.state.resources).unitsOffline,3);
  });
  await test('Failed fits and remote engineering requests leave every owned field untouched',()=>{
    const s=fresh(),before=JSON.stringify(s);
    equal(act(s,'exchange',{from:pocket(0),to:installed(0,0)}),{state:s,message:'equipmentDoesNotFit'});
    equal(act(s,'exchange',{from:pocket(9),to:installed(0,0)}).state,s);
    reject(()=>act(s,'tick',{groupIndex:3}),'equipmentUnavailable');
    const away=structuredClone(s);away.ship.position={x:54,y:118};reject(()=>act(away,'enter'),'equipmentUnavailable');
    const remote=structuredClone(s);remote.travel.scene='city';reject(()=>act(remote,'enter'),'equipmentUnavailable');
    equal(JSON.stringify(s),before);
  });
  await test('Occupied pocket exchanges retain the displaced part and normalize only the installed byte',()=>{
    const s=fresh();s.ship.inventory.carried=[156,235,60,0];
    const result=act(s,'exchange',{from:installed(1,1),to:pocket(0)}).state;
    equal(result.ship.inventory.carried,[28,235,60,0]);equal(result.equipment[0].units[1].components[1],156);equal(result.engineering.pendingFailures[0],6);equal(codec.snapshot(result),result);
    const pockets=act(s,'exchange',{from:pocket(0),to:pocket(1)}).state;equal(pockets.ship.inventory.carried,[235,156,60,0]);equal(pockets.equipment,s.equipment);
    const masked=act(s,'exchange',{from:pocket(2),to:installed(0,1)}).state;equal(masked.equipment[0].units[0].components[1],28);equal(masked.ship.inventory.carried[2],23);equal(codec.snapshot(masked),masked);
  });
  await test('Version18 migration preserves resources and prior equipment but cannot inject pending faults',()=>{
    const s=fresh();s.ship.inventory.carried=[0,28,23,0];s.resources.hull=16;s.resources.fuel=255;
    const save=codec.make(s,0),old=structuredClone(save);old.version=18;old.scope='landed-depot-1';delete old.state.engineering;
    equal(codec.validate(old),save);old.state.engineering=save.state.engineering;reject(()=>codec.validate(old));
    const fault=codec.make(put(fresh()),0);fault.version=18;fault.scope='landed-depot-1';delete fault.state.engineering;reject(()=>codec.validate(fault));
  });
  await test('Pending-save validation rejects unmatched targets, forged caches, extra faults and bad metadata',()=>{
    const pending=put(fresh());
    for(const change of [s=>delete s.engineering,s=>s.engineering.extra=0,s=>s.engineering.pendingFailures.push(31),s=>s.engineering.pendingFailures[0]=31,
      s=>s.engineering.pendingFailures[0]=4,s=>s.engineering.pendingFailures[0]=2,s=>s.equipment[0].units[0].components[1]=28,
      s=>s.equipment[0].units[1].components[1]=156,s=>s.equipment[0].performance=11,s=>s.equipment[0].units[0].performance=0,
      s=>s.equipment[0].spares[1]=25,s=>s.equipment[0].units[0].components.push(0)]) {
      const bad=structuredClone(pending);change(bad);reject(()=>codec.snapshot(bad));
    }
  });
}
