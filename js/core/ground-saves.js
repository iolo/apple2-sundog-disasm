import { regionalGroundStart } from './regional-world.js';
import { createGroundWorld,initialGround } from './campaign-ground.js';
import { cityReachability,cityShipAnchor } from './city-walk.js';
import { podReachability,podHeading,podServiceAt } from './city-pod.js';
import { findPodFootExit } from './parked-pod.js';
import { validateCargoSlots } from './cargo.js';
import { canStandSurface,surfaceCityEntryOrigins } from './surface-walk.js';

const keys=(v,n)=>v&&typeof v==='object'&&!Array.isArray(v)&&Object.keys(v).length===n.length&&n.every(k=>Object.hasOwn(v,k));
const integer=(v,a,b)=>Number.isInteger(v)&&v>=a&&v<=b;
const point=(p,w,h)=>keys(p,['x','y'])&&integer(p.x,0,w-1)&&integer(p.y,0,h-1);
const same=(a,b)=>a?.x===b?.x&&a?.y===b?.y;
const fail=()=>{throw new Error('invalidGround')};
const wrap=(n,size)=>(n+size)%size;

export function migratedGround(start,travel) {
  const anchor=cityShipAnchor(start.shipLocation);
  return initialGround(start,travel.cityPosition??{x:anchor.x,y:anchor.y+6});
}

// One validator owns immutable world data and bounded caches across snapshots.
export function groundSaveValidator(content,start,rooms,{regional=false,salvage=false,completedPhase=start.economy.colony.completedPhase}={}) {
  const world=createGroundWorld(content,start,{completedPhase}),cityChecks=new Map(),surfaceChecks=new Map();
  function surfaceCheck(colony) {
    const key=colony?`${colony.x}/${colony.y}`:'none';
    if(surfaceChecks.has(key))return surfaceChecks.get(key);
    const g=world.surface(colony),seen=new Uint8Array(1120*576),queue=new Int32Array(seen.length),arrivals=new Set();
    let head=0,tail=0;
    // Every source side/corner city exit is a legitimate transition anchor.
    // Regional worlds seed all city exits; historical scopes seed the starting city.
    for(const c of g.map.cities)for(const [x,y] of [[0,16],[21,16],[11,7],[11,23],[0,7],[0,23],[21,7],[21,23]]) {
      const index=(c.position.y*24+y)*1120+c.position.x*28+x;arrivals.add(index);
      if((regional||c.cityId===start.shipLocation.cityId)&&!seen[index]){seen[index]=1;queue[tail++]=index}
    }
    while(head<tail) {
      const index=queue[head++],x=index%1120,y=Math.floor(index/1120);
      for(let dy=-2;dy<=2;dy++)for(let dx=-2;dx<=2;dx++)if(dx||dy) {
        const p={x:wrap(x+dx,1120),y:wrap(y+dy,576)},i=p.y*1120+p.x;
        if(!seen[i]&&canStandSurface(g,p)){seen[i]=1;queue[tail++]=i}
      }
    }
    const cities=new Set([start.shipLocation.cityId]);
    for(const c of g.map.cities)for(let y=0;y<24;y++)for(let x=0;x<28;x++) {
      const px=wrap(c.position.x*28+x-3,1120),py=wrap(c.position.y*24+y+3,576);
      if(seen[py*1120+px])cities.add(c.cityId);
    }
    const reached=p=>point(p,1120,576)&&(!!seen[p.y*1120+p.x]||
      (arrivals.has(p.y*1120+p.x)&&g.map.cities.some(c=>cities.has(c.cityId)&&Math.floor(p.x/28)===c.position.x&&Math.floor(p.y/24)===c.position.y)));
    const result={geometry:g,reached,cities};
    // Imports cannot grow an unbounded cache by varying colony positions.
    if(surfaceChecks.size>=2)surfaceChecks.clear();surfaceChecks.set(key,result);return result;
  }
  function metadata(value,travel,pod) {
    if(!keys(value,['worldId','cityId','podCityId','colonyPosition','camera'])||value.worldId!==world.worldId||
      ![null,...world.cityIds].includes(value.cityId)||!(regional?[null,...content.economy.cities.map(c=>c.id),'city-60']:[null,...world.cityIds]).includes(value.podCityId)||
      !point(value.camera,40,24)||(travel.scene==='surface')!==(value.cityId===null)&&!(regional&&travel.scene==='ship')||
      (!['city','surface','ship','room','bank','exchange','depot','transstation','colony'].includes(travel.scene))||
      (!regional&&!['city','surface'].includes(travel.scene)&&value.cityId!==start.shipLocation.cityId)||
      (pod.attached&&value.podCityId!==start.shipLocation.cityId))fail();
    if(value.colonyPosition!==null) {
      if(world.worldId!=='world-01'||!point(value.colonyPosition,40,24)||world.surfaceBase.tiles[value.colonyPosition.y][value.colonyPosition.x]<14)fail();
    } else if(!regional&&(value.cityId!==start.shipLocation.cityId||value.podCityId!==start.shipLocation.cityId))fail();
    if(value.colonyPosition!==null&&!regional) {
      const reached=surfaceCheck(value.colonyPosition).cities;
      if((value.cityId!==null&&!reached.has(value.cityId))||(value.podCityId!==null&&!reached.has(value.podCityId)))fail();
    }
    if(travel.scene!=='ship') {
      const h=travel.scene==='surface'?24:32,p=travel.cityPosition;
      if(!point(p,1120,h*24))fail();
      const x=wrap(p.x-value.camera.x*28,1120),y=wrap(p.y-value.camera.y*h,h*24);
      if(x>273||y<7||y>191)fail();
    }
    return {worldId:value.worldId,cityId:value.cityId,podCityId:value.podCityId,
      colonyPosition:value.colonyPosition?{x:value.colonyPosition.x,y:value.colonyPosition.y}:null,
      camera:{x:value.camera.x,y:value.camera.y}};
  }
  function cityCheck(state,cityId,driving) {
    const p=state.pod,local=!p.attached&&state.ground.podCityId===cityId&&(!regional||state.regional.podWorldId===world.worldId);
    const key=`${cityId}/${driving}/${p.attached}/${!driving&&local?`${p.position.x}/${p.position.y}/${p.heading}`:''}`;
    if(cityChecks.has(key))return cityChecks.get(key);
    const city=world.city(cityId,p.attached),g=driving?city.pod:local?world.foot({...state,ground:{...state.ground,cityId}}):city;
    const entries=new Map();
    for(const e of surfaceCityEntryOrigins(world.size(cityId))) {
      const heading=podHeading(Math.floor((e.direction-1)/3)-1,(e.direction-1)%3-1);
      entries.set(`${e.position.x}/${e.position.y}/${heading}`,{position:e.position,heading});
    }
    let reached;
    if(driving)reached=podReachability({...g,podOrigins:[...entries.values(),...(g.spawn?[{position:g.spawn,heading:16}]:[])]});
    else reached=cityReachability({...g,footOrigins:[...entries.values()].map(e=>e.position).concat(g.spawn?[g.spawn]:[],local?[findPodFootExit(g,p.position)].filter(Boolean):[])});
    const result={geometry:g,reached};if(cityChecks.size>=8)cityChecks.clear();cityChecks.set(key,result);return result;
  }
  function pod(value,state) {
    if(!keys(value,['attached','position','heading','cargo','occupied'])||typeof value.attached!=='boolean'||typeof value.occupied!=='boolean')fail();
    const cargo=validateCargoSlots(value.cargo,'pod',{auxiliaryFuel:true,salvage});
    if(value.attached) {if(value.position!==null||value.heading!==16||value.occupied)fail()}
    else {
      if(regional&&state.regional.podWorldId!==world.worldId) {
        if(value.occupied)fail();
        const remote={...state,ground:{...state.ground,worldId:state.regional.podWorldId,cityId:state.ground.podCityId,colonyPosition:state.regional.podWorldId==='world-01'?state.regional.colonyPosition:null},travel:{scene:'ship',cityPosition:null}};
        return groundSaveValidator(content,regionalGroundStart(remote),rooms,{regional:true,salvage,completedPhase}).pod(value,remote);
      }
      if(value.occupied&&(!['city','surface','exchange','depot','colony'].includes(state.travel.scene)||state.ground.podCityId!==state.ground.cityId||!same(value.position,state.travel.cityPosition)))fail();
      if(state.ground.podCityId===null) {if(value.heading!==26||!surfaceCheck(state.ground.colonyPosition).reached(value.position))fail()}
      else {
        const c=cityCheck(state,state.ground.podCityId,true);
        if(!point(value.position,1120,768)||!c.reached(value.position,value.heading))fail();
        if(value.occupied&&['exchange','depot','colony'].includes(state.travel.scene)&&podServiceAt(c.geometry,value.position,value.heading)!==state.travel.scene)fail();
      }
    }
    return {attached:value.attached,position:value.position&&{x:value.position.x,y:value.position.y},heading:value.heading,cargo,occupied:value.occupied};
  }
  function player(state) {
    const {travel,ground}=state;
    if(travel.scene==='ship')return;
    if(travel.scene==='surface') {if(!surfaceCheck(ground.colonyPosition).reached(travel.cityPosition))fail()}
    else if(!state.pod.occupied&&!cityCheck(state,ground.cityId,false).reached(travel.cityPosition))fail();
  }
  function city(state) {
    if(state.ground.cityId===null)return null;
    return {...world.city(state.ground.cityId,state.pod.attached),rooms};
  }
  return {metadata,pod,player,city,world};
}
