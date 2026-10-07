import { snapshotShipCombat } from './ship-combat.js';
import { sourceRandom } from './random.js';
import { validateCargoLot } from './cargo.js';

const integer=(n,a,b)=>Number.isInteger(n)&&n>=a&&n<=b;
const keys=(v,n)=>v&&typeof v==='object'&&!Array.isArray(v)&&Object.keys(v).length===n.length&&n.every(k=>Object.hasOwn(v,k));
const fail=()=>{throw Error('invalidShipSalvage')};
export const isShipSalvage=lot=>lot?.originCity===null;
export function validateShipWreck(value) {
  if(value===null)return null;
  if(!keys(value,['lot','present','tractorSlot'])||typeof value.present!=='boolean'||
    value.tractorSlot!==null&&!integer(value.tractorSlot,0,1)||!value.present&&value.tractorSlot===null)fail();
  const lot=validateCargoLot(value.lot,{salvage:true});
  if(!isShipSalvage(lot))fail();
  return {lot,present:value.present,tractorSlot:value.tractorSlot};
}
// Game12 proc6 $0197–$0210. Nibbles3/4 are source system local32/30.
// The source adds whole thousands to word6, preserving the bank remainder.
export function shipBounty(enemyType,{piracy,coefficient}) {
  if(!integer(enemyType,0,3)||![piracy,coefficient].every(n=>integer(n,0,15)))fail();
  return piracy+enemyType>12?1000*Math.max(1,((enemyType+1)*coefficient)>>3):0;
}
// Proc6 always draws its0..5 test; only success draws type1..30 and quality4..7.
// Local34/35 become the packed two-word lot: unknown origin and paid price0.
export function produceShipWreck(previous) {
  const state=snapshotShipCombat(previous),random=sourceRandom(state.randomState);
  if(state.words[216]!==0)fail();
  let draws=1,wreck=null;
  if(random.next()%6<=state.words[214]) {
    const commodityId=`cargo-${String(1+random.next()%30).padStart(2,'0')}`,quality=4+random.next()%4;draws=3;
    wreck={lot:{commodityId,quality,originCity:null,pricePaid:0},present:true,tractorSlot:null};
    state.flags[36]=true;state.words[207]=state.flags[1]?2:1;
  }
  state.randomState=random.state;
  return {state,wreck,draws};
}
// Proc12 $0A8D–$0AC4 runs once per call, independently of proc10's two moves.
export function moveShipWreck(previous,record) {
  const state=snapshotShipCombat(previous);let wreck=validateShipWreck(record);
  if(wreck?.present) {
    state.words[217]=(state.words[217]+state.words[207]<<16)>>16;
    if(state.words[217]<=2)state.words[217]=1;
    else if(state.words[217]>128){if(wreck.tractorSlot===null)wreck=null;else wreck.present=false;state.flags[36]=false}
  }
  return {state,wreck};
}
// Proc18 scans from slot2 down, without an attachment or fuel guard.
export function beginShipTractor(previous,record) {
  const state=snapshotShipCombat(previous),wreck=validateShipWreck(record);
  if(!wreck?.present)throw Error('shipTractorOutOfRange');
  if(wreck.tractorSlot!==null)throw Error('shipTractorActive');
  const slot=state.cargo.lastIndexOf(null);
  if(slot<0)throw Error('shipTractorNoRoom');
  wreck.tractorSlot=slot;state.words[207]=-4;
  return {state,wreck};
}
// Copy after proc12 (including a due machinery call), never before it.
export function finishShipTractor(previous,record) {
  const state=snapshotShipCombat(previous);let wreck=validateShipWreck(record),loaded=null;
  if(wreck&&wreck.tractorSlot!==null&&state.words[217]===1) {
    const slot=wreck.tractorSlot;
    if(state.cargo[slot]!==null)fail();
    state.cargo[slot]=structuredClone(wreck.lot);loaded={slot,lot:structuredClone(wreck.lot)};
    wreck=null;state.flags[36]=false;
  }
  return {state,wreck,loaded};
}
