import { regionalIndex,warpRequirement } from './regional-world.js';
import { flightOrbit,orbitalDelta,sublightDuration } from './campaign-flight.js';
const keys=(v,n)=>v&&typeof v==='object'&&!Array.isArray(v)&&Object.keys(v).length===n.length&&n.every(k=>Object.hasOwn(v,k));
const integer=(n,a,b)=>Number.isInteger(n)&&n>=a&&n<=b;
const point=(p,w,h)=>keys(p,['x','y'])&&integer(p.x,0,w-1)&&integer(p.y,0,h-1);
const same=(a,b)=>a===b||(a&&b&&typeof a==='object'&&typeof b==='object'&&Object.keys(a).length===Object.keys(b).length&&Object.keys(a).every(k=>Object.hasOwn(b,k)&&same(a[k],b[k])));
const fail=()=>{throw Error('invalidRegional')};
const events=[null,'flightWarpCancelled','flightFuelLow','flightWarpComplete','flightGravityFailure','flightHalted','flightRescueRequested','flightArrival','flightRescueComplete','flightNoEngines'];

// Save23 owns actual locations, one journey and the one distress deadline.
// Historical saves are validated by their original codec before migration.
export function validateRegionalFlight(state,content) {
  const {regional:r,flight:f,ground:g,pod,travel,resources,equipment}=state,index=regionalIndex(content);
  function location(v) {
    if(!keys(v,['systemId','worldId','cityId','orbit','surfacePosition','cityPosition','position'])||!state.start.systems.some(s=>s.id===v.systemId)||
      (v.worldId!==null&&index.worlds.get(v.worldId)?.systemId!==v.systemId)||
      !keys(v.orbit,['angle','radius'])||!integer(v.orbit.angle,0,255)||!integer(v.orbit.radius,0,43)||
      !point(v.surfacePosition,40,24)||!point(v.cityPosition,40,24)||!point(v.position,280,192))fail();
    if(v.cityId===null) {
      if([v.surfacePosition,v.cityPosition,v.position].some(p=>p.x!==0||p.y!==0))fail();
    } else {
      const city=index.cities.get(v.cityId),world=index.worlds.get(v.worldId);
      if(!city||city.worldId!==v.worldId||!same(v.orbit,flightOrbit(state,content,v.worldId)))fail();
      const marker=content.ground.surfaceWalk.cities.find(c=>c.cityId===v.cityId)?.position??r.colonyPosition;
      if(!same(v.cityPosition,marker))fail();
      if(same(v,state.start.shipLocation))return;
      if(!same(v.position,content.flight.shipPosition))fail();
      const tile=v.surfacePosition;
      if(v.cityId===world.capitalCityId) {
        if(!same(tile,content.flight.worlds.find(w=>w.id===v.worldId).landingPosition))fail();
      } else if(v.cityId==='city-60') {if(!same(tile,{x:19,y:12}))fail()}
      else if(!((tile.y===5||tile.y===18)&&integer(tile.x,10,30)||(tile.x===9||tile.x===31)&&integer(tile.y,6,17)))fail();
    }
  }
  location(r.shipLocation);
  if(r.colonyPosition!==null&&(!point(r.colonyPosition,40,24)||content.ground.maps.worlds.find(w=>w.id==='world-01').tiles[r.colonyPosition.y][r.colonyPosition.x]<14))fail();
  if(!index.worlds.has(g.worldId)||!same(g.colonyPosition,g.worldId==='world-01'?r.colonyPosition:null))fail();
  if(pod.attached) {
    if(r.podWorldId!==r.shipLocation.worldId||g.podCityId!==r.shipLocation.cityId)fail();
  } else {
    if(!index.worlds.has(r.podWorldId)||(g.podCityId!==null&&index.cities.get(g.podCityId)?.worldId!==r.podWorldId))fail();
  }
  if(r.shipLocation.cityId) {
    if(g.worldId!==r.shipLocation.worldId)fail();
  } else if(travel.scene!=='ship'||g.cityId!==null)fail();
  if(travel.scene!=='ship'&&(!r.shipLocation.cityId||index.worlds.get(g.worldId).systemId!==r.shipLocation.systemId))fail();
  if(!keys(f,['motion','refuelAt','lastEvent'])||!events.includes(f.lastEvent)||
    (f.refuelAt!==null&&!integer(f.refuelAt,state.ship.minutes+1,state.ship.minutes+150)))fail();
  const m=f.motion;
  if(m!==null) {
    if(!keys(m,['type','from','to','duration','progress'])||!['launch','land','cityFlight','sublight'].includes(m.type)||travel.scene!=='ship'||
      !integer(m.duration,1,255)||!integer(m.progress,0,m.duration-1))fail();
    location(m.from);location(m.to);
    if(m.from.systemId!==m.to.systemId||m.from.systemId!==r.shipLocation.systemId)fail();
    if(m.type==='sublight') {
      if(m.from.cityId!==null||m.to.cityId!==null||!resources.enginesPowered||equipment[1].performance===0||m.duration!==sublightDuration(m.from.orbit,m.to.orbit))fail();
      if(m.to.worldId? !same(m.to.orbit,flightOrbit(state,content,m.to.worldId)):m.to.orbit.radius!==43||m.to.orbit.angle%16!==0)fail();
      const d=orbitalDelta(m.from.orbit,m.to.orbit),expected={...m.from,orbit:{angle:(m.from.orbit.angle+Math.trunc(m.progress*d.angle/m.duration)+256)%256,radius:m.from.orbit.radius+Math.trunc(m.progress*d.radius/m.duration)}};
      if(!same(r.shipLocation,expected))fail();
    } else {
      if(!same(r.shipLocation,m.from)||m.from.worldId!==m.to.worldId||resources.enginesPowered||m.duration!==(m.type==='cityFlight'?20:5))fail();
      if(m.type==='launch'? !m.from.cityId||m.to.cityId!==null:m.type==='land'?m.from.cityId!==null||!m.to.cityId:!m.from.cityId||!m.to.cityId||m.from.cityId===m.to.cityId)fail();
    }
  } else if(resources.enginesPowered)fail();
  if(resources.warp.charging&&(equipment[0].performance===0||resources.warp.targetSystemId===r.shipLocation.systemId||
    resources.warp.targetCharge!==warpRequirement(state.start.systems,r.shipLocation.systemId,resources.warp.targetSystemId)))fail();
  if(state.economy.exchange.visit&&state.economy.exchange.market.cityId!==g.cityId)fail();
  return true;
}
