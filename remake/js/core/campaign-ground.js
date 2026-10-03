import { createCityMaps } from './city-map.js';
import { createCityGeometry } from './city-walk.js';
import { createPodGeometry,tryPodStep,podHeading } from './city-pod.js';
import { tryStep } from './ship-walk.js';
import { parkedPodGeometry,findPodFootExit,canBoardParkedPod } from './parked-pod.js';
import { composeSurfaceMap,placeSurfaceColony } from './surface-map.js';
import { createSurfaceGeometry,trySurfaceStep,surfaceCityAt,citySurfaceExit,surfaceCityEntry } from './surface-walk.js';
import { groundCameraAt,scrollGroundCamera } from './ground-camera.js';

const integer=(n,min,max)=>Number.isInteger(n)&&n>=min&&n<=max;
const same=(a,b)=>a?.x===b?.x&&a?.y===b?.y;

// Geometry/content ownership is separate from campaign state. Only a ship in
// this city contributes its exterior, spawn and docking gates.
export function createGroundWorld({maps,navigation,economy,cityWalk,surfaceWalk},start) {
  const worldId=start.playerLocation.worldId;
  const cityMaps=createCityMaps(maps,navigation,economy,{completedPhase:start.economy.colony.completedPhase});
  const surfaceBase=composeSurfaceMap(maps.worlds.find(m=>m.id===worldId),surfaceWalk.cities);
  const cityIds=new Set(surfaceBase.cities.map(c=>c.cityId));if(worldId==='world-01')cityIds.add('city-60');
  const cities=new Map(),surfaces=new Map();let footCache=null;
  const size=id=>id==='city-60'?Math.min(9,start.economy.colony.completedPhase):9;
  function city(id,attached) {
    if(!cityIds.has(id))throw new Error('groundUnavailable');
    const key=`${id}/${attached}`;
    if(!cities.has(key)) {
      const location=id===start.shipLocation.cityId?start.shipLocation:null,map=cityMaps[id];
      const g=createCityGeometry(map,{...cityWalk,shipRows:attached?cityWalk.shipRows:cityWalk.detachedShipRows},location,{surfaceTravel:true});
      g.pod=createPodGeometry(map,cityWalk,location,{surfaceTravel:true});cities.set(key,g);
    }
    return cities.get(key);
  }
  function surface(colonyPosition) {
    const key=worldId==='world-01'?`${colonyPosition?.x}/${colonyPosition?.y}`:'ordinary';
    if(!surfaces.has(key)) {
      if(worldId==='world-01'&&!colonyPosition)throw new Error('groundUnavailable');
      const map=worldId==='world-01'?placeSurfaceColony(surfaceBase,1,colonyPosition).map:surfaceBase;
      if(surfaces.size>=2)surfaces.clear();
      surfaces.set(key,createSurfaceGeometry(map,surfaceWalk));
    }
    return surfaces.get(key);
  }
  function foot(state) {
    const {ground,pod}=state,g=city(ground.cityId,pod.attached);
    if(pod.attached||ground.podCityId!==ground.cityId)return g;
    const key=`${ground.cityId}/${pod.position.x}/${pod.position.y}/${pod.heading}`;
    if(footCache?.key!==key)footCache={key,geometry:parkedPodGeometry(g,g.pod,pod.position,pod.heading)};
    return footCache.geometry;
  }
  return {worldId,cityIds,size,city,surface,foot,surfaceBase};
}

// Companion to existing travel and pod state: position/cargo are never copied
// into a second owner. A null city means this world's surface, not no location.
export function initialGround(start,position) {
  return {worldId:start.playerLocation.worldId,cityId:start.playerLocation.cityId,
    podCityId:start.shipLocation.cityId,colonyPosition:null,camera:groundCameraAt(position)};
}

export function nearbySurfacePod(player,pod) {
  return Math.abs(player.x-pod.x)<=4&&Math.abs(player.y-pod.y)<=4&&
    Math.abs(Math.floor((player.x+3)/28)-Math.floor(pod.x/28))<=1&&
    Math.abs(Math.floor((player.y-3)/24)-Math.floor(pod.y/24))<=1;
}

export function reduceCampaignGround(previous,world,action) {
  const {ground,travel,pod}=previous;
  if(!ground||ground.worldId!==world.worldId||!['city','surface'].includes(travel.scene)||
      (travel.scene==='surface')!==(ground.cityId===null)||
      (ground.cityId!==null&&!world.cityIds.has(ground.cityId))||
      (pod.occupied&&(pod.attached||ground.podCityId!==ground.cityId||!same(pod.position,travel.cityPosition))))throw new Error('groundUnavailable');
  const surface=travel.scene==='surface',position=travel.cityPosition;
  const next=structuredClone(previous),g=next.ground,p=next.pod;
  const geometry=surface?world.surface(g.colonyPosition):p.occupied?world.city(g.cityId,false).pod:world.foot(next);
  const moveTo=position=>{next.travel.cityPosition={...position};if(p.occupied){p.position={...position};g.podCityId=g.cityId}};
  if(action.type==='move') {
    const {dx,dy}=action,limit=p.occupied?2:1;
    if(!integer(dx,-limit,limit)||!integer(dy,-limit,limit)||(!dx&&!dy))throw new Error('groundUnavailable');
    let moved;
    if(surface)moved=trySurfaceStep(geometry,position,dx,dy);
    else if(p.occupied){const result=tryPodStep(geometry,position,dx,dy);moved=result?.position??position;if(result)p.heading=result.heading}
    else moved=tryStep(geometry,position,dx,dy);
    moveTo(moved);
    const scroll=scrollGroundCamera(g.camera,moved,surface);
    if(!surface&&scroll.scrolled) {
      const marker=g.cityId==='city-60'?{position:g.colonyPosition}:world.surfaceBase.cities.find(c=>c.cityId===g.cityId);
      const exit=citySurfaceExit(scroll.attempted,marker,world.size(g.cityId));
      if(exit) {
        if(g.worldId==='world-01'&&g.colonyPosition===null) {
          const placed=placeSurfaceColony(world.surfaceBase,next.encounters.randomState);
          g.colonyPosition=placed.position;next.encounters.randomState=placed.randomState;
        }
        g.cityId=null;next.travel={scene:'surface',cityPosition:exit};
        if(p.occupied){p.heading=26;p.position={...exit};g.podCityId=null}
        g.camera=groundCameraAt(exit,true);return next;
      }
    }
    g.camera=scroll.camera;
  } else if(action.type==='enterCity') {
    if(!surface)throw new Error('groundUnavailable');
    const marker=surfaceCityAt(geometry.map,position);
    if(!marker)throw new Error('groundUnavailable');
    const entry=surfaceCityEntry(geometry.map,position,world.size(marker.cityId));
    g.cityId=entry.cityId;next.travel={scene:'city',cityPosition:entry.position};
    if(p.occupied) {
      g.podCityId=entry.cityId;p.position={...entry.position};
      p.heading=podHeading(Math.floor((entry.direction-1)/3)-1,(entry.direction-1)%3-1);
    }
    g.camera=groundCameraAt(entry.position);
  } else if(action.type==='park'||action.type==='board') {
    if(p.attached||g.podCityId!==g.cityId)throw new Error('podUnavailable');
    if(action.type==='park') {
      if(!p.occupied)throw new Error('podUnavailable');
      // Game21 proc8 draws unattended pods only in scene3; proc25's surface
      // foot exit retains the pod coordinate without the city exit search.
      const exit=surface?position:findPodFootExit(world.foot(next),p.position);
      if(!exit)throw new Error('podExitBlocked');
      p.occupied=false;next.travel.cityPosition={...exit};
    } else {
      if(p.occupied||!(surface?nearbySurfacePod(position,p.position):canBoardParkedPod(geometry,position,p.position)))throw new Error('podUnavailable');
      p.occupied=true;next.travel.cityPosition={...p.position};
    }
  } else throw new Error('groundUnavailable');
  return next;
}
