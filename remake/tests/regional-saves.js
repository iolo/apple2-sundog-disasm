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
    for(const mutate of [x=>x.regional.shipLocation.systemId='system-12',x=>x.flight.motion.progress++,x=>x.flight.motion.duration++,x=>x.flight.extra=true,x=>x.regional.cities[1]=x.regional.cities[0],x=>x.regional.cargoProceeds=-1,x=>x.resources.enginesPowered=false,x=>{x.resources.warp={charge:20,targetCharge:21,targetSystemId:'system-02',charging:true}}]){const bad=structuredClone(s);mutate(bad);reject(()=>codec.snapshot(bad))}
    const bad=ready(),owner=bad.regional.cities.find(c=>c.warehouse.slots.some(Boolean));owner.warehouse.slots[0]=null;reject(()=>codec.snapshot(bad));
  });
  await test('Every capital supports regional save/reload and independent destination exchange ownership',()=>{
    for(const w of exchange.worlds) {
      let s=arrive(act(ready(),{type:'launch'}));s.regional.shipLocation.systemId=w.systemId;s.regional.shipLocation.worldId=w.id;
      s=arrive(act(s,{type:'land',cityId:w.capitalCityId}));s=selectRegionalExchange(s,w.capitalCityId);
      equal(codec.parse(JSON.stringify(codec.make(s,0))).state,s);
    }
  });
  await test('A pod left on Jondd remains validated after flight to another world and through a full return',()=>{
    let s=ready();s.pod={...s.pod,attached:false,position:{x:287,y:217},heading:16,occupied:false};
    const parked=structuredClone(s.pod);s=arrive(act(s,{type:'launch'}));s=arrive(act(s,{type:'sublight',worldId:'world-02'}));s=arrive(act(s,{type:'land',cityId:exchange.worlds[1].capitalCityId}));
    equal(codec.snapshot(s).pod,parked);equal(s.regional.podWorldId,'world-01');
    s=arrive(act(s,{type:'launch'}));s=arrive(act(s,{type:'sublight',worldId:'world-01'}));s=arrive(act(s,{type:'land',cityId:'city-01'}));equal(codec.snapshot(s).pod,parked);
  });
}
