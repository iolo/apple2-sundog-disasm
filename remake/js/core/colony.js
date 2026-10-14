import { validateCargoLot } from './cargo.js';
import { cityServiceAt } from './city-doors.js';
import { podServiceAt } from './city-pod.js';

const keys=(v,n)=>v&&typeof v==='object'&&!Array.isArray(v)&&Object.keys(v).length===n.length&&n.every(k=>Object.hasOwn(v,k));
const integer=(n,a,b)=>Number.isInteger(n)&&n>=a&&n<=b;
const fail=()=>{throw Error('invalidColony')};
const recipes=content=>content?.economy?.colonyRequirements;
const number=id=>Number(id?.slice(6));
export const initialColony=()=>({completedPhase:0,activePhase:0,warehouse:[null,null,null,null],receipts:[]});

export function colonyDemand(colony,content) {
  const demands=recipes(content);
  if(!Array.isArray(demands)||demands.length!==9||demands.some(r=>!Array.isArray(r)||r.length!==31))fail();
  const result=colony.activePhase>0&&colony.activePhase<=9?[...demands[colony.activePhase-1]]:Array(31).fill(0);
  for(const receipt of colony.receipts)if(receipt.phase===colony.activePhase)result[number(receipt.lot.commodityId)-1]--;
  return result;
}

// Each delivered lot is a receipt, including its original city and paid cost.
// The preceding phases must be exhausted in full, and the current phase may
// only contain its own bounded recipe quantities. No receipt can be reused.
export function validateColony(value,content) {
  if(!keys(value,['completedPhase','activePhase','warehouse','receipts'])||
    !integer(value.completedPhase,0,9)||!integer(value.activePhase,0,10)||
    value.activePhase!==0&&value.activePhase!==value.completedPhase+1||
    value.activePhase===0&&value.completedPhase!==0||
    !Array.isArray(value.warehouse)||value.warehouse.length!==4||Object.keys(value.warehouse).length!==4||
    !Array.isArray(value.receipts)||value.receipts.length>61||Object.keys(value.receipts).length!==value.receipts.length)fail();
  const warehouse=value.warehouse.map(lot=>lot===null?null:validateCargoLot(lot,{auxiliaryFuel:true,salvage:true}));
  const counts=Array.from({length:9},()=>Array(31).fill(0)),receipts=[];
  let previous=1;
  for(const r of value.receipts) {
    if(!keys(r,['phase','lot'])||!integer(r.phase,1,9)||r.phase<previous||r.phase>value.activePhase||r.phase===10)fail();
    const lot=validateCargoLot(r.lot,{salvage:true});
    if(lot.commodityId==='cargo-01')fail();
    const i=number(lot.commodityId)-1;
    if(++counts[r.phase-1][i]>recipes(content)?.[r.phase-1]?.[i])fail();
    previous=r.phase;receipts.push({phase:r.phase,lot});
  }
  for(let phase=1;phase<value.activePhase;phase++)if(counts[phase-1].some((n,i)=>n!==recipes(content)[phase-1][i]))fail();
  if(value.activePhase===0&&receipts.length)fail();
  if(value.activePhase===10&&value.completedPhase!==9)fail();
  if(warehouse.some(lot=>lot?.commodityId==='cargo-01'))fail();
  return {completedPhase:value.completedPhase,activePhase:value.activePhase,warehouse,receipts};
}

export function reduceCampaignColony(previous,content,geometry,action) {
  const p=previous.travel.cityPosition,driving=previous.pod.occupied;
  if(previous.ground?.worldId!=='world-01'||previous.ground.cityId!=='city-60'||geometry?.map?.cityId!=='city-60'||
    !['city','colony'].includes(previous.travel.scene)||
    (driving?podServiceAt(geometry,p,previous.pod.heading):cityServiceAt(geometry.map,p))!=='colony')throw Error('colonyUnavailable');
  const next=structuredClone(previous),c=next.colony;
  if(action?.type==='enter') {
    if(previous.travel.scene!=='city')throw Error('colonyUnavailable');
    if(c.activePhase===0||c.activePhase<=9&&colonyDemand(c,content).every(n=>n===0)) {
      c.completedPhase=c.activePhase;c.activePhase++;
    }
    next.travel.scene='colony';return next;
  }
  if(previous.travel.scene!=='colony')throw Error('colonyUnavailable');
  if(action?.type==='leave'){next.travel.scene='city';return next}
  if(c.activePhase===10)throw Error('colonyUnavailable');
  if(!driving)throw Error('colonyPodRequired');
  const pod=next.pod.cargo,warehouse=c.warehouse;
  if(action?.type==='store'||action?.type==='fetch') {
    const from=action.type==='store'?pod:warehouse,to=action.type==='store'?warehouse:pod;
    if(!integer(action.slot,0,from.length-1)||!from[action.slot])throw Error('colonyInvalidSelection');
    const free=to.indexOf(null);if(free<0)throw Error(action.type==='store'?'cargoWarehouseFull':'cargoPodFull');
    to[free]=from[action.slot];from[action.slot]=null;
  } else if(action?.type==='deliver') {
    const from=action.container==='pod'?pod:action.container==='warehouse'?warehouse:null;
    if(!from||!integer(action.slot,0,from.length-1)||!from[action.slot])throw Error('colonyInvalidSelection');
    const lot=from[action.slot],i=number(lot.commodityId)-1;
    if(i<1||i>30||colonyDemand(c,content)[i]===0)throw Error('colonyNotNeeded');
    c.receipts.push({phase:c.activePhase,lot});from[action.slot]=null;
    // Game20 proc25 $14C8 calls proc4 after every delivery. The last unit
    // advances the phase during this visit; no second Center entry is needed.
    if(colonyDemand(c,content).every(n=>n===0)){
      c.completedPhase=c.activePhase;c.activePhase++;
    }
  } else throw Error('colonyInvalidSelection');
  return next;
}
