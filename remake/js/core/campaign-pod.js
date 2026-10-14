import { canDockPod, canDrivePod, podReachability, podExchangeAt, podServiceAt, tryPodStep } from './city-pod.js';
import { interactionAt } from './ship-walk.js';
import { SHIP_REENTRY } from './city-walk.js';
import { initialPodCargo, validateCargoSlots, reduceWarehouseCargo } from './cargo.js';
import { refuelOnPodDock } from './ship-power.js';
import { parkedPodGeometry, canBoardParkedPod, findPodFootExit } from './parked-pod.js';
import { currentShipLocation } from './regional-world.js';

const keys=(v,names)=>v&&typeof v==='object'&&!Array.isArray(v)&&Object.keys(v).length===names.length&&names.every(k=>Object.hasOwn(v,k));
const reachability=new WeakMap();
const footGeometries=new WeakMap();
export function campaignFootGeometry(city,pod) {
  if(pod.attached)return city;
  const key=`${pod.position.x}/${pod.position.y}/${pod.heading}`,cached=footGeometries.get(city);
  if(cached?.key===key)return cached.geometry;
  const geometry=parkedPodGeometry(city,city.pod,pod.position,pod.heading);
  geometry.footOrigins=[city.spawn,findPodFootExit(geometry,pod.position)].filter(Boolean);
  footGeometries.set(city,{key,geometry});return geometry;
}
// Game15 returns at (98,119). The browser's full seven-pixel collision mask
// overlaps one wall pixel there; the adjacent (99,119) is clear and connected.
export const POD_REENTRY=Object.freeze({x:99,y:119});
export const initialCampaignPod=()=>({attached:true,position:null,heading:16,cargo:initialPodCargo(),occupied:false});
export function validateCampaignPod(value,travel,geometry,{depot=true,auxiliaryFuel=true,parking=true,salvage=false}={}) {
  if(!keys(value,['attached','position','heading','cargo',...(parking?['occupied']:[])])||typeof value.attached!=='boolean'||(parking&&typeof value.occupied!=='boolean'))throw new Error('invalidPod');
  const occupied=parking?value.occupied:!value.attached;
  const cargo=validateCargoSlots(value.cargo,'pod',{auxiliaryFuel,salvage});
  if(value.attached) {
    if(value.position!==null||value.heading!==16||occupied)throw new Error('invalidPod');
  } else {
    if(!geometry||!keys(value.position,['x','y'])||
      (occupied&&(!(depot?['city','exchange','depot','colony']:['city','exchange']).includes(travel.scene)||value.position.x!==travel.cityPosition?.x||value.position.y!==travel.cityPosition?.y))||
      (!occupied&&!['ship','city','room','bank','exchange','depot','transstation','colony'].includes(travel.scene)))throw new Error('invalidPod');
    if(!reachability.has(geometry))reachability.set(geometry,podReachability(geometry));
    if(!reachability.get(geometry)(value.position,value.heading)||
      (occupied&&['exchange','depot','colony'].includes(travel.scene)&&podServiceAt(geometry,value.position,value.heading)!==travel.scene))throw new Error('invalidPod');
  }
  return {attached:value.attached,position:value.position&&{...value.position},heading:value.heading,cargo,occupied};
}
export function reduceCampaignPod(previous,geometry,action,city=null) {
  if(previous.ground&&((['depart','dock'].includes(action.type)?previous.ground.cityId!==currentShipLocation(previous).cityId:!previous.regional&&previous.ground.cityId!==previous.start.shipLocation.cityId)||
    (previous.pod.occupied&&previous.ground.podCityId!==previous.ground.cityId)))throw new Error('podUnavailable');
  validateCampaignPod(previous.pod,previous.travel,geometry,{salvage:Object.hasOwn(previous.space||{},'wrecks')});
  const next=structuredClone(previous),p=next.pod;
  if(action.type==='depart') {
    if(next.travel.scene!=='ship'||!p.attached||interactionAt(next.ship.position)!==3||!canDrivePod(geometry,geometry.spawn,16))throw new Error('podUnavailable');
    p.attached=false;p.occupied=true;p.position={...geometry.spawn};p.heading=16;
    next.travel={scene:'city',cityPosition:{...p.position}};next.ship.position={...SHIP_REENTRY};
  } else if(action.type==='dock') {
    if(next.travel.scene!=='city'||!p.occupied||!canDockPod(geometry,p.position,p.heading))throw new Error('podUnavailable');
    p.attached=true;p.occupied=false;p.position=null;p.heading=16;
    const refueled=refuelOnPodDock(next.resources.fuel,p.cargo);
    next.resources.fuel=refueled.fuel;p.cargo=refueled.cargo;
    next.travel={scene:'ship',cityPosition:null};next.ship.position={...POD_REENTRY};
  } else if(action.type==='move') {
    if(next.travel.scene!=='city'||!p.occupied)throw new Error('podUnavailable');
    const moved=tryPodStep(geometry,p.position,action.dx,action.dy);
    if(moved){Object.assign(p,moved);next.travel.cityPosition={...p.position}}
  } else if(action.type==='park'||action.type==='board') {
    if(!city||next.travel.scene!=='city'||p.attached)throw new Error('podUnavailable');
    const foot=campaignFootGeometry(city,p);
    if(action.type==='park') {
      if(!p.occupied)throw new Error('podUnavailable');
      const exit=findPodFootExit(foot,p.position);if(!exit)throw new Error('podExitBlocked');
      p.occupied=false;next.travel.cityPosition=exit;
    } else {
      if(p.occupied||!canBoardParkedPod(foot,next.travel.cityPosition,p.position))throw new Error('podUnavailable');
      p.occupied=true;next.travel.cityPosition={...p.position};
    }
  } else if(['store','fetch','swap'].includes(action.type)) {
    if(next.travel.scene!=='exchange'||!p.occupied||!podExchangeAt(geometry,p.position,p.heading))throw new Error('cargoUnavailable');
    const loaded=reduceWarehouseCargo({warehouse:next.economy.exchange.warehouse,pod:p.cargo},
      {cityId:next.economy.exchange.market.cityId,transport:'pod'},action,{auxiliaryFuel:true,salvage:Object.hasOwn(next.space||{},'wrecks')});
    next.economy.exchange.warehouse=loaded.warehouse;p.cargo=loaded.pod;
  } else throw new Error('podUnavailable');
  return next;
}

// Only the current city's initial cryogens may move, and none may disappear or
// multiply. Other cities are still immutable. Ordinary lots retain local origin.
export function validateLocalCargo(start,exchange,pod) {
  const initial=start.economy.warehouses.find(w=>w.cityId===exchange.warehouse.cityId).slots.filter(Boolean);
  const all=[...exchange.warehouse.slots,...pod.cargo].filter(Boolean);
  const cryogens=all.filter(c=>c.commodityId==='cargo-31');
  const signature=c=>[c.commodityId,c.quality,c.originCity,c.pricePaid].join('/');
  if(JSON.stringify(cryogens.map(signature).sort())!==JSON.stringify(initial.map(signature).sort())||
    all.some(c=>c.commodityId==='cargo-01' ? c.originWorld!==start.playerLocation.worldId : c.commodityId!=='cargo-31'&&(c.originCity!==exchange.market.cityId||c.pricePaid<100||exchange.market.lastUpdateDay===-16)))throw new Error('invalidCargo');
}
