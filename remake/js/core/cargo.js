// Game20 procedures11–13: four warehouse lots and the pod's two cargo lots.
// Game14 procedure6 reads that same pod manifest aboard the ship; there is no
// additional ship hold in this boundary. Transport access belongs to the host.
export const CARGO_CAPACITY=Object.freeze({warehouse:4,pod:2});
const keys=(v,names)=>v&&typeof v==='object'&&!Array.isArray(v)&&Object.keys(v).length===names.length&&names.every(k=>Object.hasOwn(v,k));
const integer=(v,min,max)=>Number.isInteger(v)&&v>=min&&v<=max;
const city=id=>typeof id==='string'&&/^city-(0[1-9]|[1-4][0-9]|5[0-7])$/.test(id);
const fail=()=>{throw new Error('invalidCargo')};

// Ordinary exchange lots and the initialized cryogens. Auxiliary fuel, unknown
// salvage and colony records need their own producers before being accepted.
export function validateCargoLot(lot) {
  if(!keys(lot,['commodityId','quality','originCity','pricePaid'])||
    typeof lot.commodityId!=='string'||!/^cargo-(0[2-9]|[12][0-9]|3[01])$/.test(lot.commodityId)||
    !integer(lot.quality,1,7)||!city(lot.originCity)||
    !integer(lot.pricePaid,0,3276700)||lot.pricePaid%100!==0||
    (lot.commodityId==='cargo-31'&&(lot.quality!==7||lot.pricePaid!==0)))fail();
  return {commodityId:lot.commodityId,quality:lot.quality,originCity:lot.originCity,pricePaid:lot.pricePaid};
}
export function validateCargoSlots(slots,container) {
  const size=Object.hasOwn(CARGO_CAPACITY,container)&&CARGO_CAPACITY[container];
  if(!size||!Array.isArray(slots)||slots.length!==size||Object.keys(slots).length!==size||
    !Array.from({length:size},(_,i)=>Object.hasOwn(slots,i)).every(Boolean))fail();
  return slots.map(lot=>lot===null ? null : validateCargoLot(lot));
}
export const initialPodCargo=()=>Array(CARGO_CAPACITY.pod).fill(null);
export function warehouseCargoSnapshot(value) {
  if(!keys(value,['warehouse','pod'])||!keys(value.warehouse,['cityId','slots'])||!city(value.warehouse.cityId))fail();
  return {warehouse:{cityId:value.warehouse.cityId,slots:validateCargoSlots(value.warehouse.slots,'warehouse')},
    pod:validateCargoSlots(value.pod,'pod')};
}

// A pure loading session. The campaign-pod controller derives this visit from
// actual pod entry at a door and commits both containers together.
// A foot visit cannot operate on the pod merely because it owns warehouse lots.
export function reduceWarehouseCargo(previous,visit,action) {
  const next=warehouseCargoSnapshot(previous);
  if(!keys(visit,['cityId','transport'])||visit.transport!=='pod'||visit.cityId!==next.warehouse.cityId)
    throw new Error('cargoUnavailable');
  const warehouse=next.warehouse.slots,pod=next.pod;
  const occupied=(slots,slot)=>{
    if(!integer(slot,0,slots.length-1)||slots[slot]===null)throw new Error('cargoInvalidSelection');
  };
  if(action?.type==='store'||action?.type==='fetch') {
    if(!keys(action,['type','slot']))throw new Error('cargoInvalidSelection');
    const from=action.type==='store' ? pod : warehouse,to=action.type==='store' ? warehouse : pod;
    occupied(from,action.slot);
    const free=to.indexOf(null); // Procedure11 scans from the first slot.
    if(free<0)throw new Error(action.type==='store' ? 'cargoWarehouseFull' : 'cargoPodFull');
    to[free]=from[action.slot];from[action.slot]=null;
  } else if(action?.type==='swap') {
    if(!keys(action,['type','podSlot','warehouseSlot']))throw new Error('cargoInvalidSelection');
    // Procedure12 rejects empty selections, even for the second half of Swap.
    occupied(pod,action.podSlot);occupied(warehouse,action.warehouseSlot);
    [pod[action.podSlot],warehouse[action.warehouseSlot]]=[warehouse[action.warehouseSlot],pod[action.podSlot]];
  } else throw new Error('cargoInvalidSelection');
  return next;
}
