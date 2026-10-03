import { canDockPod, canDrivePod, podReachability, podExchangeAt, podServiceAt, tryPodStep } from './city-pod.js';
import { interactionAt } from './ship-walk.js';
import { SHIP_REENTRY } from './city-walk.js';
import { initialPodCargo, validateCargoSlots, reduceWarehouseCargo } from './cargo.js';

const keys=(v,names)=>v&&typeof v==='object'&&!Array.isArray(v)&&Object.keys(v).length===names.length&&names.every(k=>Object.hasOwn(v,k));
const reachability=new WeakMap();
// Game15 returns at (98,119). The browser's full seven-pixel collision mask
// overlaps one wall pixel there; the adjacent (99,119) is clear and connected.
export const POD_REENTRY=Object.freeze({x:99,y:119});
export const initialCampaignPod=()=>({attached:true,position:null,heading:16,cargo:initialPodCargo()});
export function validateCampaignPod(value,travel,geometry,{depot=true,auxiliaryFuel=true}={}) {
  if(!keys(value,['attached','position','heading','cargo'])||typeof value.attached!=='boolean')throw new Error('invalidPod');
  const cargo=validateCargoSlots(value.cargo,'pod',{auxiliaryFuel});
  if(value.attached) {
    if(value.position!==null||value.heading!==16)throw new Error('invalidPod');
  } else {
    if(!geometry||!(depot?['city','exchange','depot']:['city','exchange']).includes(travel.scene)||!keys(value.position,['x','y'])||
      value.position.x!==travel.cityPosition?.x||value.position.y!==travel.cityPosition?.y)throw new Error('invalidPod');
    if(!reachability.has(geometry))reachability.set(geometry,podReachability(geometry));
    if(!reachability.get(geometry)(value.position,value.heading)||
      (['exchange','depot'].includes(travel.scene)&&podServiceAt(geometry,value.position,value.heading)!==travel.scene))throw new Error('invalidPod');
  }
  return {attached:value.attached,position:value.position&&{...value.position},heading:value.heading,cargo};
}
export function reduceCampaignPod(previous,geometry,action) {
  validateCampaignPod(previous.pod,previous.travel,geometry);
  const next=structuredClone(previous),p=next.pod;
  if(action.type==='depart') {
    if(next.travel.scene!=='ship'||!p.attached||interactionAt(next.ship.position)!==3||!canDrivePod(geometry,geometry.spawn,16))throw new Error('podUnavailable');
    p.attached=false;p.position={...geometry.spawn};p.heading=16;
    next.travel={scene:'city',cityPosition:{...p.position}};next.ship.position={...SHIP_REENTRY};
  } else if(action.type==='dock') {
    if(next.travel.scene!=='city'||p.attached||!canDockPod(geometry,p.position,p.heading))throw new Error('podUnavailable');
    p.attached=true;p.position=null;p.heading=16;
    next.travel={scene:'ship',cityPosition:null};next.ship.position={...POD_REENTRY};
  } else if(action.type==='move') {
    if(next.travel.scene!=='city'||p.attached)throw new Error('podUnavailable');
    const moved=tryPodStep(geometry,p.position,action.dx,action.dy);
    if(moved){Object.assign(p,moved);next.travel.cityPosition={...p.position}}
  } else if(['store','fetch','swap'].includes(action.type)) {
    if(next.travel.scene!=='exchange'||p.attached||!podExchangeAt(geometry,p.position,p.heading))throw new Error('cargoUnavailable');
    const loaded=reduceWarehouseCargo({warehouse:next.economy.exchange.warehouse,pod:p.cargo},
      {cityId:next.economy.exchange.market.cityId,transport:'pod'},action,{auxiliaryFuel:true});
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
