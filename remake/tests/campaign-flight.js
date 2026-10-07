import { campaignSaveCodec } from '../js/core/campaign-saves.js';
import { createCharacter } from '../js/core/character.js';
import { initialRegional,warpRequirement,regionalGroundStart } from '../js/core/regional-world.js';
import { initialFlight,reduceCampaignFlight,flightMode,sublightDuration,orbitalDelta,landingLocation } from '../js/core/campaign-flight.js';
import { advanceCampaignMachinery,reconcileMachinery } from '../js/core/campaign-machinery.js';
import { createSurvival } from '../js/core/survival.js';
import { sourceRandom } from '../js/core/random.js';
import { createGroundWorld } from '../js/core/campaign-ground.js';
import { canStand } from '../js/core/ship-walk.js';
import { validateShipResources } from '../js/core/ship-resources.js';

export async function campaignFlightTests(test,equal) {
  const names=['initial-navigation','initial-economy','initial-location','ship-inventory','ship-walk','exchange-defaults','flight-defaults','maps','surface-walk','city-walk'];
  const [navigation,economy,location,inventory,shipWalk,exchange,flight,maps,surfaceWalk,cityWalk]=await Promise.all(names.map(n=>fetch(`../data/${n}.json`).then(r=>r.json())));
  const content={navigation,economy,location,inventory,exchange,flight,ground:{maps,surfaceWalk,cityWalk}},codec=campaignSaveCodec(content,shipWalk);
  const fresh=()=>{
    const state=codec.create({...createCharacter(),name:'Flight pilot'},12345);
    state.regional=initialRegional(state.start);state.flight=initialFlight();state.resources.fuel=255;return state;
  };
  const act=(s,a)=>reduceCampaignFlight(s,content,a),reject=(f,code)=>{let error;try{f()}catch(e){error=e.message}equal(error,code)};
  function ticks(state,n) {
    let survival={...createSurvival(state.ship.condition),minutes:state.ship.minutes};
    for(let i=0;i<n;i++){const result=advanceCampaignMachinery(state,survival,250);state=result.state;survival=result.survival}
    return state;
  }
  function arrive(state) {for(let i=0;state.flight.motion&&i<4096;i++)state=ticks(state,1);if(state.flight.motion)throw Error('Flight did not arrive');return state}
  const launch=state=>arrive(act(state,{type:'launch'}));
  await test('Sublight ETA retains signed shortest-angle interpolation and source truncation',()=>{
    equal(orbitalDelta({angle:250,radius:20},{angle:6,radius:43}),{angle:12,radius:23});
    equal(orbitalDelta({angle:0,radius:43},{angle:128,radius:20}),{angle:128,radius:-23});
    equal(sublightDuration({angle:250,radius:20},{angle:6,radius:43}),3);
    equal(sublightDuration({angle:0,radius:43},{angle:128,radius:20}),10);
  });
  await test('Launch and landing are owned timed transitions that preserve creation, cargo and survival',()=>{
    const base=fresh(),before=JSON.stringify(base),started=act(base,{type:'launch'});
    equal(JSON.stringify(base),before);equal(started.flight.motion.duration,5);equal(started.regional.shipLocation,base.regional.shipLocation);
    const mid=ticks(started,5);equal(mid.flight.motion.progress,2);
    const orbit=arrive(mid);equal(flightMode(orbit),'orbit');equal(orbit.ship.minutes,5);equal(orbit.resources.fuel,255);
    const landed=arrive(act(orbit,{type:'land',cityId:'city-01'}));
    equal(flightMode(landed),'landed');equal(landed.ship.minutes,10);equal(landed.regional.shipLocation.position,{x:150,y:115});
    equal(landed.start,base.start);equal(landed.ship.inventory,base.ship.inventory);equal(landed.pod.cargo,base.pod.cargo);
  });
  await test('Planetary transitions switch shields/cloaker off and reject absent engines, fuel, clearance or pilotage',()=>{
    const state=fresh();state.resources.shields.targetCharge=255;
    equal(act(state,{type:'launch'}).resources.shields.targetCharge,0);
    const poor=structuredClone(state);poor.resources.fuel=0;reject(()=>act(poor,{type:'launch'}),'machineryNoFuel');
    poor.resources.fuel=255;poor.equipment[1].performance=0;reject(()=>act(poor,{type:'launch'}),'flightNoEngines');
    poor.equipment[1].performance=16;poor.economy.accounts[0].balance=1000;reject(()=>act(poor,{type:'launch'}),'flightClearanceDenied');
    reject(()=>act(state,{type:'cityFlight',cityId:'city-02'}),'flightNoPilotage');
    const orbit=launch(state);reject(()=>act(orbit,{type:'land',cityId:'city-09'}),'flightInvalidDestination');
    reject(()=>act(orbit,{type:'land',cityId:'city-02'}),'flightNoPilotage');
  });
  await test('Every source starport on all18 worlds has valid ship/pod ground access',()=>{
    for(const w of exchange.worlds) {
      const state=launch(fresh());state.regional.shipLocation.systemId=w.systemId;state.regional.shipLocation.worldId=w.id;
      const arrived=landingLocation(state,content,w.capitalCityId);state.regional.shipLocation=arrived.location;
      state.ground.worldId=w.id;state.ground.cityId=w.capitalCityId;
      const world=createGroundWorld({...content,...content.ground},regionalGroundStart(state)),g=world.city(w.capitalCityId,true);
      equal(canStand(g,g.spawn),true);equal(g.pod.spawn!==null,true);
    }
  });
  await test('Sublight movement spends fuel only on successful phase3 steps and HALT preserves the current position',()=>{
    let state=launch(fresh());state.equipment[1].performance=16;
    state=act(state,{type:'sublight',angle:0});const from=structuredClone(state.regional.shipLocation.orbit),fuel=state.resources.fuel;
    state.machinery.phase=2;state=ticks(state,1);equal(state.resources.fuel,fuel-1);equal(state.flight.motion.progress,1);
    equal(state.regional.shipLocation.orbit.angle!==from.angle||state.regional.shipLocation.orbit.radius!==from.radius,true);
    const halted=act(state,{type:'halt'});equal(halted.regional.shipLocation,state.regional.shipLocation);equal(halted.flight.motion,null);equal(halted.resources.enginesPowered,false);
    reject(()=>act(state,{type:'sublight',worldId:'world-18'}),'flightBusy');
  });
  await test('Warp charging shares source power phases/RNG and cancellation discharges without refunding fuel',()=>{
    let state=fresh();const target='system-02',required=warpRequirement(state.start.systems,'system-01',target);
    state=act(state,{type:'setWarp',systemId:target});equal(state.resources.warp.targetCharge,required);
    state.equipment[0].performance=16;state=ticks(state,4);equal(state.resources.warp.charge,8);equal(state.resources.fuel,253);
    const cancelled=act(state,{type:'cancelWarp'});equal(cancelled.resources.warp.charge,8);equal(cancelled.resources.warp.targetCharge,0);
    const discharged=ticks(cancelled,4);equal(discharged.resources.warp.charge,4);equal(discharged.resources.fuel,253);
    equal(validateShipResources(discharged.resources,discharged.start,{flight:true}),discharged.resources);
    reject(()=>validateShipResources(discharged.resources,discharged.start),'invalidShipResources');
  });
  await test('Warp at a source radius43 point succeeds, copies attached cargo and clears all charge controls',()=>{
    let state=launch(fresh());state=arrive(act(state,{type:'sublight',angle:16}));
    equal([state.regional.shipLocation.worldId,state.regional.shipLocation.orbit.radius],[null,43]);
    state=act(state,{type:'setWarp',systemId:'system-02'});state.equipment[0].performance=16;
    for(let n=0;state.resources.warp.charge<state.resources.warp.targetCharge&&n<1024;n++)state=ticks(state,1);
    const before=JSON.stringify(state),jumped=act(state,{type:'warp'});
    equal(JSON.stringify(state),before);equal(jumped.regional.shipLocation.systemId,'system-02');equal(jumped.flight.lastEvent,'flightWarpComplete');
    equal(jumped.resources.warp,{charge:0,targetCharge:0,targetSystemId:null,charging:false});equal(jumped.pod.cargo,state.pod.cargo);equal(jumped.start,state.start);
  });
  await test('Gravity-field warp failure leaves the ship in place and consumes its stored charge',()=>{
    let state=launch(fresh());state=act(state,{type:'setWarp',systemId:'system-02'});state.resources.warp.charge=state.resources.warp.targetCharge;
    const rng=sourceRandom(state.encounters.randomState);rng.next();
    const failed=act(state,{type:'warp'});equal(failed.regional.shipLocation,state.regional.shipLocation);equal(failed.flight.lastEvent,'flightGravityFailure');
    equal(failed.resources.warp.charge,0);equal(failed.encounters.randomState,rng.state);
  });
  await test('Distress refueling owns one exact due time, preserves RNG in orbit and refills once',()=>{
    let state=launch(fresh());state.resources.fuel=0;
    const requested=act(state,{type:'distress'});equal(requested.flight.refuelAt,state.ship.minutes+30);equal(requested.encounters.randomState,state.encounters.randomState);
    reject(()=>act(requested,{type:'distress'}),'flightUnavailable');
    state=ticks(requested,116);equal(state.resources.fuel,0);state=ticks(state,4);equal(state.resources.fuel,255);equal(state.flight.refuelAt,null);
    state.resources.fuel=90;state=ticks(state,8);equal(state.resources.fuel,90);
  });
  await test('Engine/warp dependencies shut down active requests, and an unattended pod stays behind',()=>{
    let state=fresh();state.pod={...state.pod,attached:false,position:{x:287,y:217},heading:16,occupied:false};
    const parked=structuredClone(state.pod),orbit=launch(state);equal(orbit.pod,parked);equal(orbit.regional.podWorldId,'world-01');equal(orbit.ground.podCityId,'city-01');
    state=act(orbit,{type:'sublight',angle:0});state.equipment[1].performance=0;
    const shut=reconcileMachinery(state);equal(shut.flight.motion,null);equal(shut.resources.enginesPowered,false);equal(shut.pod,parked);
  });
}
