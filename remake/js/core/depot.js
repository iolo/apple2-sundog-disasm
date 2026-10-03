import { MAX_CREDITS } from './banking.js';
import { validateCargoLot } from './cargo.js';

const integer=(n,min,max)=>Number.isInteger(n)&&n>=min&&n<=max;
const keys=(v,names)=>v&&typeof v==='object'&&!Array.isArray(v)&&Object.keys(v).length===names.length&&names.every(k=>Object.hasOwn(v,k));
const fail=()=>{throw new Error('invalidDepot')};

// Game19 proc23, also used by proc22's two hull-price adjustments. Dividing
// first at the equality boundary is deliberate Pascal overflow avoidance.
export function scaleDepotPrice(value,multiplier,divisor) {
  if(!integer(value,0,32767)||!integer(multiplier,1,23)||!integer(divisor,1,23))fail();
  const scaled=Math.trunc(32767/multiplier)<=value ?
    Math.trunc(value/divisor)*multiplier : Math.trunc(value*multiplier/divisor);
  if(scaled>32767)throw new Error('depotPriceOverflow');
  return scaled;
}
function adjust(value,a,b) {
  const factor=8+Math.abs(a-b);
  return a>=b ? scaleDepotPrice(value,factor,8) : scaleDepotPrice(value,8,factor);
}

// Source-local names keep the three system nibbles explicit. Game19 proc26
// loads locals12/13/14 from system bytes18.high/18.low/17.high respectively.
export function depotPrices({local12,local13,local14},hull) {
  if(![local12,local13,local14].every(n=>integer(n,0,15))||!integer(hull,0,16))fail();
  const factor=local14+local13+16-local12;
  return {refuel:Math.trunc(100*factor/14),
    repair:adjust(adjust(250*(1+Math.trunc((16-hull)/4)),12,local12),local13,11),
    auxiliary:100*factor};
}

// Game19 proc20 preserves the original remainder when rebuilding the meter
// from floor((fuel+1)/16). At fuel=15 mod16, a paid unit therefore adds an
// extra source rounding unit. A cancelled review never runs that write-back.
export function depotRefuelResult(fuel,units) {
  if(!integer(fuel,0,255)||!integer(units,0,16-Math.trunc((fuel+1)/16)))fail();
  return units===0 ? fuel : Math.min(255,fuel%16+16*(Math.trunc((fuel+1)/16)+units));
}

function validateSession(value) {
  if(!keys(value,['hull','fuel','cash','bankBalance','pod'])||!integer(value.hull,0,16)||!integer(value.fuel,0,255)||
    !integer(value.cash,0,MAX_CREDITS)||!integer(value.bankBalance,0,MAX_CREDITS)||
    !Array.isArray(value.pod)||value.pod.length!==2||Object.keys(value.pod).length!==2||
    !Array.from(value.pod).every(lot=>lot===null||(lot&&typeof lot==='object'&&!Array.isArray(lot))))fail();
  for(const lot of value.pod)if(lot!==null) {
    if(lot.commodityId==='cargo-01') {
      if(!keys(lot,['commodityId','quality','originWorld','pricePaid'])||lot.quality!==7||lot.pricePaid!==0||
        !/^world-(0[1-9]|1[0-8])$/.test(lot.originWorld))fail();
    } else validateCargoLot(lot);
  }
}
function validateVisit(visit) {
  if(!keys(visit,['shipPresent','podPresent','cityId','worldId','local12','local13','local14'])||typeof visit.shipPresent!=='boolean'||typeof visit.podPresent!=='boolean'||
    !/^city-(0[1-9]|[1-4][0-9]|5[0-7])$/.test(visit.cityId)||!/^world-(0[1-9]|1[0-8])$/.test(visit.worldId))fail();
}

// A pure service session, not a campaign access grant. The host must derive
// presence from the actual depot entrance and ship/pod locations. Quote data
// is never trusted as an instruction; confirmation recomputes it from state.
export function quoteDepotService(previous,visit,type,units=1) {
  validateSession(previous);validateVisit(visit);
  if(!['refuel','repair','auxiliary'].includes(type))fail();
  const prices=depotPrices(visit,previous.hull),maximum=type==='refuel' ?
    16-Math.trunc((previous.fuel+1)/16) : type==='repair' ? 16-previous.hull : previous.pod.filter(lot=>lot===null).length;
  if(!(type==='auxiliary' ? visit.podPresent : visit.shipPresent))throw new Error('depotVehicleAbsent');
  if(!integer(units,1,maximum))throw new Error('depotCapacity');
  const unitPrice=prices[type],price=unitPrice*units;
  // Proc19 disables when the unit cost is greater than the available pool.
  // Exact funds are valid here, unlike the exchange's strict purchase search.
  if(price>previous.cash+previous.bankBalance)throw new Error('depotInsufficient');
  return {type,units,maximum,unitPrice,price,
    ...(type==='refuel' ? {fuel:depotRefuelResult(previous.fuel,units)} : {}),
    ...(type==='repair' ? {hull:previous.hull+units} : {})};
}

export function purchaseDepotService(previous,visit,{type,units=1}={}) {
  const quote=quoteDepotService(previous,visit,type,units),next=structuredClone(previous);
  const bankDebit=Math.min(next.bankBalance,quote.price);
  next.bankBalance-=bankDebit;next.cash-=quote.price-bankDebit;
  if(type==='refuel')next.fuel=quote.fuel;
  else if(type==='repair')next.hull=quote.hull;
  else for(let n=0;n<units;n++) {
    // Proc24 sets type1, quality7 and current-world origin, but never sets the
    // price word. Canonical zero avoids inheriting a stale emptied-slot price.
    next.pod[next.pod.indexOf(null)]={commodityId:'cargo-01',quality:7,originWorld:visit.worldId,pricePaid:0};
  }
  return next;
}
