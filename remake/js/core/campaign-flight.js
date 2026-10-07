import { currentShipLocation,warpRequirement } from './regional-world.js';
import { sourceRandom } from './random.js';
import { groundCameraAt } from './ground-camera.js';
import { finishCampaignSpaceWarp } from './campaign-space.js';

export const initialFlight=()=>({motion:null,refuelAt:null,lastEvent:null});
export const flightMode=state=>currentShipLocation(state).cityId?'landed':currentShipLocation(state).worldId?'orbit':'space';
const clear=()=>({x:0,y:0});
const angle=n=>(n+256)%256;
export function orbitalDelta(from,to) {
  let delta=to.angle-from.angle;
  if(delta>128)delta-=256;else if(delta< -128)delta+=256;
  return {angle:delta,radius:to.radius-from.radius};
}
// Game13 proc36 $1BAE–$1BE2: proc31 shifts right8, then proc30 shifts LEFT2.
// Word211 is successful motion steps; displayed ETA is1+(word211>>1).
export function sublightDuration(from,to) {
  const delta=orbitalDelta(from,to);
  return ((Math.trunc(Math.abs(delta.radius)/3)+((Math.abs(delta.angle)*(from.radius+to.radius))>>8))<<2)+1;
}
export function flightOrbit(state,content,worldId) {
  const world=content.navigation.worlds.find(w=>w.id===worldId),generated=state.start.worlds.find(w=>w.id===worldId);
  if(!world||!generated)throw Error('flightInvalidDestination');
  return {angle:generated.orbitalAngle,radius:world.orbitalRadius};
}
function emptyLocation(systemId,worldId,orbit) {
  return {systemId,worldId,cityId:null,orbit:{...orbit},surfacePosition:clear(),cityPosition:clear(),position:clear()};
}
function setShip(state,location) {
  state.regional.shipLocation=structuredClone(location);
  if(state.pod.attached)state.regional.podWorldId=location.worldId;
  if(location.cityId) {
    if(state.ground.worldId==='world-01')state.regional.colonyPosition=state.ground.colonyPosition;
    state.ground={worldId:location.worldId,cityId:location.cityId,
      podCityId:state.pod.attached?location.cityId:state.ground.podCityId,
      colonyPosition:location.worldId==='world-01'?state.regional.colonyPosition:null,
      camera:groundCameraAt({x:location.surfacePosition.x*28+location.position.x%28,y:location.surfacePosition.y*32+location.position.y%32+6})};
  } else {
    if(state.ground.worldId==='world-01')state.regional.colonyPosition=state.ground.colonyPosition;
    state.ground.cityId=null;if(state.pod.attached)state.ground.podCityId=null;
  }
}

// Game13 proc26: capital uses the exported world tile; other cities require
// pilotage special (proc12 local11/flag21). Their four arrival sides draw RNG.
export function landingLocation(state,content,cityId) {
  const worldId=currentShipLocation(state).worldId,w=content.exchange.worlds.find(w=>w.id===worldId);
  const city=content.economy.cities.find(c=>c.id===cityId)??content.economy.colonyCity;
  if(!w||city?.id!==cityId||city.worldId!==worldId)throw Error('flightInvalidDestination');
  const capital=cityId===w.capitalCityId;
  if(!capital&&!state.equipment[5].specialAvailable)throw Error('flightNoPilotage');
  const marker=content.ground.surfaceWalk.cities.find(c=>c.cityId===cityId)?.position??state.regional.colonyPosition;
  if(!marker)throw Error('flightInvalidDestination');
  const rng=sourceRandom(state.encounters.randomState);let tile;
  if(capital)tile=content.flight.worlds.find(w=>w.id===worldId)?.landingPosition;
  else if(cityId==='city-60')tile={x:19,y:12};
  else {
    const side=rng.next()%4;
    const range=(lo,hi)=>lo+rng.next()%(hi-lo+1);
    tile=side===0?{x:range(10,30),y:5}:side===1?{x:31,y:range(6,17)}:side===2?{x:range(10,30),y:18}:{x:9,y:range(6,17)};
  }
  if(!tile)throw Error('flightInvalidDestination');
  return {location:{systemId:currentShipLocation(state).systemId,worldId,cityId,
    orbit:flightOrbit(state,content,worldId),surfacePosition:{...tile},cityPosition:{...marker},position:{...content.flight.shipPosition}},randomState:rng.state};
}

export function reduceCampaignFlight(previous,content,action) {
  if(!previous.regional||!previous.flight||previous.travel.scene!=='ship'||previous.pod.occupied||previous.space?.defeat||previous.combat?.defeat||previous.space?.communication?.conversation||previous.space?.activity?.sleeping)throw Error('flightUnavailable');
  let next=structuredClone(previous);const r=next.resources,f=next.flight,ship=currentShipLocation(next),mode=flightMode(next);
  const busy=()=>{if(f.motion)throw Error('flightBusy')};
  const engine=()=>{if(r.fuel===0)throw Error('machineryNoFuel');if(next.equipment[1].performance===0)throw Error('flightNoEngines')};
  if(action.type==='cancelWarp') {
    r.warp.targetCharge=0;r.warp.targetSystemId=null;r.warp.charging=false;f.lastEvent='flightWarpCancelled';
  } else if(action.type==='setWarp') {
    const target=content.navigation.systems.find(s=>s.id===action.systemId);
    if(!target||target.id===ship.systemId)throw Error('flightInvalidDestination');
    const charge=warpRequirement(next.start.systems,ship.systemId,target.id);
    if(charge>255)throw Error('flightBeyondJump');
    if(r.fuel===0)throw Error('machineryNoFuel');
    if(next.equipment[0].performance===0)throw Error('flightNoWarp');
    r.warp={...r.warp,targetCharge:charge,targetSystemId:target.id,charging:true};f.lastEvent=charge>r.warp.charge+2*r.fuel?'flightFuelLow':null;
  } else if(action.type==='warp') {
    busy();
    if(mode==='landed'||!r.warp.charging||!r.warp.targetSystemId||r.warp.charge<r.warp.targetCharge||next.equipment[0].performance===0)throw Error('flightWarpNotReady');
    const rng=sourceRandom(next.encounters.randomState),radius=ship.orbit.radius;
    const chance=ship.worldId?0:(radius+7)*2,success=chance>rng.next()%100;
    let landingAngle=ship.orbit.angle;
    if(success) {
      if(radius<43) {
        const center=32+((landingAngle+8)>>4),half=((43-radius)>>2)+1;
        landingAngle=(center-half+rng.next()%(2*half+1))&15;
      } else landingAngle=((landingAngle+8)>>4)&15;
      setShip(next,emptyLocation(r.warp.targetSystemId,null,{angle:landingAngle*16,radius:43}));
      f.lastEvent='flightWarpComplete';
    } else f.lastEvent='flightGravityFailure';
    next.encounters.randomState=rng.state;
    r.warp={charge:0,targetCharge:0,targetSystemId:null,charging:false};r.enginesPowered=false;
    if(success)next=finishCampaignSpaceWarp(next,content);
  } else if(action.type==='sublight') {
    busy();engine();if(mode==='landed')throw Error('flightUnavailable');
    let destination;
    if(action.worldId) {
      const system=content.navigation.systems.find(s=>s.id===ship.systemId);
      if(!system.worldIds.includes(action.worldId))throw Error('flightInvalidDestination');
      destination=emptyLocation(ship.systemId,action.worldId,flightOrbit(next,content,action.worldId));
    } else {
      if(!Number.isInteger(action.angle)||action.angle<0||action.angle>255||action.angle%16!==0)throw Error('flightInvalidDestination');
      destination=emptyLocation(ship.systemId,null,{angle:action.angle,radius:43});
    }
    if(ship.worldId===destination.worldId&&ship.orbit.angle===destination.orbit.angle&&ship.orbit.radius===destination.orbit.radius)throw Error('flightCurrentLocation');
    f.motion={type:'sublight',from:structuredClone(ship),to:destination,duration:sublightDuration(ship.orbit,destination.orbit),progress:0};
    r.enginesPowered=true;f.lastEvent=null;
  } else if(action.type==='halt') {
    if(f.motion?.type!=='sublight')throw Error('flightUnavailable');
    f.motion=null;r.enginesPowered=false;f.lastEvent='flightHalted';
  } else if(['launch','land','cityFlight'].includes(action.type)) {
    busy();engine();let to;
    if(action.type==='launch') {
      if(mode!=='landed')throw Error('flightUnavailable');
      const balance=next.economy.accounts.find(a=>a.systemId===ship.systemId).balance;
      // Game13 $1DD2–$1DE6 tests both native account words separately.
      if(Math.trunc(balance/1000)<=0||balance%1000<=0)throw Error('flightClearanceDenied');
      to=emptyLocation(ship.systemId,ship.worldId,flightOrbit(next,content,ship.worldId));
    } else {
      if(!ship.worldId||(action.type==='land'&&mode!=='orbit')||(action.type==='cityFlight'&&mode!=='landed'))throw Error('flightUnavailable');
      if(action.type==='cityFlight'&&!next.equipment[5].specialAvailable)throw Error('flightNoPilotage');
      const landed=landingLocation(next,content,action.cityId);to=landed.location;next.encounters.randomState=landed.randomState;
      if(to.cityId===ship.cityId)throw Error('flightCurrentLocation');
    }
    f.motion={type:action.type,from:structuredClone(ship),to,duration:action.type==='cityFlight'?20:5,progress:0};
    r.shields.targetCharge=0;next.machinery.cloaked=false;r.enginesPowered=false;f.lastEvent=null;
  } else if(action.type==='distress') {
    if(mode==='landed'||f.refuelAt!==null)throw Error('flightUnavailable');
    const rng=sourceRandom(next.encounters.randomState),wait=ship.worldId?30:60+rng.next()%91;
    f.refuelAt=next.ship.minutes+wait;next.encounters.randomState=rng.state;f.lastEvent='flightRescueRequested';
  } else throw Error('flightUnavailable');
  return next;
}

// Source motion before power. Planetary overlays become resumable five/twenty
// minute transitions using the displayed ETA (explicit browser scheduling).
export function stepCampaignFlight(previous,phase) {
  const next=structuredClone(previous),f=next.flight,r=next.resources;
  if(!f)return {state:next,workingFuel:r.fuel,arrived:false,encounterDue:false};
  // $02BC returns before RNG when flag1 is off. LAND at $02D3 retains
  // phase bit0: draw on every powered tick, move only on odd phases.
  const encounterDue=r.enginesPowered;
  const rng=sourceRandom(next.encounters.randomState),roll=encounterDue?rng.next()&15:null;
  let workingFuel=r.fuel,arrived=false;
  if(encounterDue&&phase===3)workingFuel--; // $0416, including failed motion rolls.
  if(f.motion?.type==='sublight'&&encounterDue&&(phase&1)&&roll<next.equipment[1].performance) {
    const m=f.motion;m.progress++;
    const delta=orbitalDelta(m.from.orbit,m.to.orbit);
    next.regional.shipLocation.orbit={angle:angle(m.from.orbit.angle+Math.trunc(m.progress*delta.angle/m.duration)),radius:m.from.orbit.radius+Math.trunc(m.progress*delta.radius/m.duration)};
    if(m.progress===m.duration){setShip(next,m.to);f.motion=null;r.enginesPowered=false;f.lastEvent='flightArrival';arrived=true}
  } else if(f.motion&&f.motion.type!=='sublight'&&phase===1) {
    f.motion.progress++;
    if(f.motion.progress===f.motion.duration){setShip(next,f.motion.to);f.motion=null;f.lastEvent='flightArrival';arrived=true}
  }
  next.encounters.randomState=rng.state;
  return {state:next,workingFuel,arrived,encounterDue};
}

// Library24 proc15 $0DAE–$0DF4, after power: the distress beacon fills255 once.
export function finishCampaignFlight(state) {
  const next=structuredClone(state),f=next.flight;
  if(!f)return next;
  if(f.refuelAt!==null&&next.ship.minutes>=f.refuelAt){next.resources.fuel=255;f.refuelAt=null;f.lastEvent='flightRescueComplete'}
  if(f.motion?.type==='sublight'&&!next.resources.enginesPowered){f.motion=null;f.lastEvent='flightNoEngines'}
  return next;
}
