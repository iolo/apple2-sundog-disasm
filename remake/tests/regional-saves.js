import { createGroundWorld } from '../js/core/campaign-ground.js';
import { regionalGroundStart } from '../js/core/regional-world.js';
import { placeSurfaceColony } from '../js/core/surface-map.js';
import { recalculateEquipment } from '../js/core/equipment.js';
import { canStand } from '../js/core/ship-walk.js';
import { campaignSaveCodec } from '../js/core/campaign-saves.js';
import { createCharacter } from '../js/core/character.js';
import { reduceCampaignFlight } from '../js/core/campaign-flight.js';
import { advanceCampaignMachinery } from '../js/core/campaign-machinery.js';
import { createSurvival } from '../js/core/survival.js';
import { selectRegionalExchange } from '../js/core/regional-world.js';

export async function regionalSaveTests(test,equal) {
  const names=['initial-navigation','initial-economy','initial-location','ship-inventory','ship-walk','exchange-defaults','flight-defaults','maps','surface-walk','city-walk'];
  const [navigation,economy,location,inventory,shipWalk,exchange,flight,maps,surfaceWalk,cityWalk]=await Promise.all(names.map(n=>fetch(`../data/${n}.json`).then(r=>r.json())));
  const content={navigation,economy,location,inventory,exchange,flight,ground:{maps,surfaceWalk,cityWalk}},old=campaignSaveCodec(content,shipWalk),codec=campaignSaveCodec({...content,regional:true},shipWalk);
  const fresh=()=>codec.create({...createCharacter(),name:'Save pilot'},12345);
  const reject=f=>{let error;try{f()}catch(e){error=e.message}equal(error,'invalidCampaign')};
  const act=(s,a)=>reduceCampaignFlight(s,content,a);
  function tick(s,n=1) {let survival={...createSurvival(s.ship.condition),minutes:s.ship.minutes};for(let i=0;i<n;i++){const v=advanceCampaignMachinery(s,survival,250);s=v.state;survival=v.survival}return s}
  function arrive(s) {for(let i=0;s.flight.motion&&i<2048;i++)s=tick(s);return s}
  function ready() {let s=fresh();s.resources.fuel=255;return s}
  await test('Save23 validates historical22 before adding regional ownership; forged progress is rejected',()=>{
    const state=old.create({...createCharacter(),name:'Legacy pilot'},12345),record=old.make(state,0),migrated=codec.validate(record);
    equal([migrated.version,migrated.scope],[23,'regional-flight-1']);equal(migrated.state.start,state.start);equal(migrated.state.ground,state.ground);equal(migrated.state.regional.cities.length,56);
    const forged=structuredClone(record);forged.state.resources.enginesPowered=true;reject(()=>codec.validate(forged));
    forged.state.resources.enginesPowered=false;forged.state.regional=migrated.state.regional;reject(()=>codec.validate(forged));
    equal(codec.parse(JSON.stringify(codec.make(migrated.state,0))).state,migrated.state);
  });
  await test('Mid-launch, sublight, charging, landing and distress reloads preserve exact clock, RNG and resources',()=>{
    let s=act(ready(),{type:'launch'});s=tick(s,5);
    const reload=x=>codec.parse(JSON.stringify(codec.make(x,0))).state;
    equal(arrive(reload(s)),arrive(s));s=arrive(s);s=act(s,{type:'sublight',angle:0});s=tick(s);
    equal(arrive(reload(s)),arrive(s));s=arrive(s);s=act(s,{type:'setWarp',systemId:'system-02'});s=tick(s,8);equal(tick(reload(s),16),tick(s,16));
    while(s.resources.warp.charge<s.resources.warp.targetCharge)s=tick(s);
    s=act(s,{type:'warp'});s=arrive(act(s,{type:'sublight',worldId:'world-03'}));s=tick(act(s,{type:'land',cityId:'city-09'}),5);equal(arrive(reload(s)),arrive(s));
    s=arrive(s);s=arrive(act(s,{type:'launch'}));s=act(s,{type:'distress'});equal(tick(reload(s),120),tick(s,120));
  });
  await test('Regional imports reject impossible membership, interpolation, charge, duplicated stock and extra fields',()=>{
    const s=act(arrive(act(ready(),{type:'launch'})),{type:'sublight',angle:0});
    for(const mutate of [x=>x.regional.shipLocation.systemId='system-12',x=>x.flight.motion.progress=x.flight.motion.duration-1,x=>x.flight.motion.duration++,x=>x.flight.extra=true,x=>x.regional.cities[1]=x.regional.cities[0],x=>x.regional.cargoProceeds=-1,x=>x.resources.enginesPowered=false,x=>{x.resources.warp={charge:20,targetCharge:21,targetSystemId:'system-02',charging:true}}]){const bad=structuredClone(s);mutate(bad);reject(()=>codec.snapshot(bad))}
    const bad=ready(),owner=bad.regional.cities.find(c=>c.warehouse.slots.some(Boolean));owner.warehouse.slots[0]=null;reject(()=>codec.snapshot(bad));
  });
  await test('Every capital supports regional save/reload and independent destination exchange ownership',()=>{
    for(const w of exchange.worlds) {
      let s=arrive(act(ready(),{type:'launch'}));s.regional.shipLocation.systemId=w.systemId;s.regional.shipLocation.worldId=w.id;
      s=arrive(act(s,{type:'land',cityId:w.capitalCityId}));s=selectRegionalExchange(s,w.capitalCityId);
      equal(codec.parse(JSON.stringify(codec.make(s,0))).state,s);
    }
  });
  await test('Regional colony coordinates validate against generated terrain and historical22 placement migrates exactly',()=>{
    const original=old.create({...createCharacter(),name:'Colony pilot'},12345),world=createGroundWorld({...content,...content.ground},original.start),placed=placeSurfaceColony(world.surfaceBase,original.encounters.randomState);
    original.ground.colonyPosition=placed.position;original.encounters.randomState=placed.randomState;
    const migrated=codec.validate(old.make(original,0)).state;equal(migrated.regional.colonyPosition,placed.position);equal(codec.snapshot(migrated),migrated);
    const bad=structuredClone(migrated);bad.regional.colonyPosition={...surfaceWalk.cities[0].position};bad.ground.colonyPosition=bad.regional.colonyPosition;reject(()=>codec.snapshot(bad));
  });
  await test('All57 ordinary city landings and Banville have valid access, canonical regional saves and source arrival geometry',()=>{
    const capital=arrive(act(ready(),{type:'launch'}));
    // Declared working-pilotage/colony fixtures isolate landing and content
    // coverage. The UI acceptance journey uses ordinary capital landings.
    capital.equipment[5].units[0].components=[...capital.equipment[5].spares];capital.equipment[5].units[0].components[capital.equipment[5].requiredSocket]=capital.equipment[5].requiredComponent;capital.equipment[5]=recalculateEquipment(capital.equipment[5]);
    const placed=placeSurfaceColony(createGroundWorld({...content,...content.ground},capital.start).surfaceBase,capital.encounters.randomState);
    capital.ground.colonyPosition=placed.position;capital.regional.colonyPosition=placed.position;
    for(const city of [...economy.cities,economy.colonyCity]) {
      let s=structuredClone(capital);s.regional.shipLocation.worldId=city.worldId;s.regional.shipLocation.systemId=exchange.worlds.find(w=>w.id===city.worldId).systemId;
      s=arrive(act(s,{type:'land',cityId:city.id}));const world=createGroundWorld({...content,...content.ground},regionalGroundStart(s)),g=world.city(city.id,true);
      equal(canStand(g,g.spawn),true);equal(g.pod.spawn!==null,true);equal(codec.snapshot(s),s);
    }
  });
  await test('A pod left on Jondd remains validated after flight to another world and through a full return',()=>{
    let s=ready();s.pod={...s.pod,attached:false,position:{x:287,y:217},heading:16,occupied:false};
    const parked=structuredClone(s.pod);s=arrive(act(s,{type:'launch'}));s=arrive(act(s,{type:'sublight',worldId:'world-02'}));s=arrive(act(s,{type:'land',cityId:exchange.worlds[1].capitalCityId}));
    equal(codec.snapshot(s).pod,parked);equal(s.regional.podWorldId,'world-01');
    s=arrive(act(s,{type:'launch'}));s=arrive(act(s,{type:'sublight',worldId:'world-01'}));s=arrive(act(s,{type:'land',cityId:'city-01'}));equal(codec.snapshot(s).pod,parked);
  });
}
