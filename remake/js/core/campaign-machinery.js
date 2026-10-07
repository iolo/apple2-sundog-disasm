import { stepShipPower } from './ship-power.js';
import { equipmentDependencyResult } from './equipment-failures.js';
import { conditionHour } from './survival.js';
import { stepCampaignFlight,finishCampaignFlight } from './campaign-flight.js';

const integer=(n,lo,hi)=>Number.isInteger(n)&&n>=lo&&n<=hi;
export const initialMachinery=()=>({phase:0,cloaked:false});
export function validateMachinery(value,equipment,resources) {
  if(!value||Array.isArray(value)||Object.keys(value).length!==2||!Object.hasOwn(value,'phase')||!Object.hasOwn(value,'cloaked')||!integer(value.phase,0,3)||typeof value.cloaked!=='boolean'||
    (value.cloaked&&!equipment[4].specialAvailable)||
    (equipment[2].performance===0&&(resources.guns.powered||resources.guns.charge!==0))||
    (equipment[4].performance===0&&resources.shields.targetCharge!==0))throw Error('invalidMachinery');
  return {phase:value.phase,cloaked:value.cloaked};
}

function sourceState(state) {
  const r=state.resources,flags=Array(128).fill(false);
  flags[0]=r.warp.charging;flags[1]=r.enginesPowered;
  flags[2]=r.guns.powered;flags[4]=r.shields.targetCharge>0;flags[7]=state.pod.attached;flags[12]=state.machinery.cloaked;
  return {flags,words:{222:r.warp.targetCharge,223:r.warp.charge,224:r.shields.targetCharge,225:r.shields.charge,226:r.guns.charge,227:r.fuel,349:0,350:0},
    cargo:state.pod.cargo,randomState:state.encounters.randomState};
}
function applySource(state,source) {
  const r=state.resources,w=source.words;
  r.fuel=w[227];r.guns={charge:w[226],powered:source.flags[2]};r.shields={charge:w[225],targetCharge:w[224]};
  state.machinery.cloaked=source.flags[12];state.pod.cargo=source.cargo;state.encounters.randomState=source.randomState;
  if(state.flight) {
    r.warp={charge:w[223],targetCharge:w[222],targetSystemId:source.flags[0]?r.warp.targetSystemId:null,charging:source.flags[0]};
    r.enginesPowered=source.flags[1];
  }
}
// Called after equipment recalculation, not on every power tick. A repaired
// system remains off; removing its last working unit clears only source dependents.
export function reconcileMachinery(state) {
  const next=structuredClone(state);
  applySource(next,equipmentDependencyResult(next.equipment,sourceState(next)));
  return state.flight?finishCampaignFlight(next):next;
}
export function reduceMachineryControl(previous,action) {
  if(previous.travel.scene!=='ship')throw Error('machineryUnavailable');
  const next=structuredClone(previous),r=next.resources;
  if(action.type==='guns'&&typeof action.enabled==='boolean') {
    if(action.enabled&&next.equipment[2].performance===0)throw Error('machineryInoperative');
    r.guns.powered=action.enabled;
  } else if(action.type==='shields'&&[-256,-64,64,256].includes(action.delta)) {
    if(action.delta>0&&r.fuel===0)throw Error('machineryNoFuel');
    if(action.delta>0&&next.equipment[4].performance===0)throw Error('machineryInoperative');
    r.shields.targetCharge=Math.max(0,Math.min(255,r.shields.targetCharge+action.delta));
  } else if(action.type==='cloak'&&typeof action.enabled==='boolean') {
    if(action.enabled&&!next.equipment[4].specialAvailable)throw Error('machineryNoCloaker');
    next.machinery.cloaked=action.enabled;
  } else throw Error('machineryUnavailable');
  return next;
}

// One owner for the aboard clock and power phases. Normal cycles250ms, sleep
// cycles50ms; source clock advances at phase1. Fractional browser time is transient.
export function advanceCampaignMachinery(previous,survival,milliseconds,paused=false) {
  if(previous.travel.scene!=='ship')throw Error('machineryUnavailable');
  if(paused||survival.dead)return {state:previous,survival:{...survival,elapsed:0},cycles:0};
  const elapsed=survival.elapsed+Math.max(0,Math.min(250,milliseconds));
  if(elapsed<(survival.sleeping?50:250))return {state:previous,survival:{...survival,elapsed},cycles:0};
  let next=structuredClone(previous);const s={...survival,condition:{...survival.condition},elapsed};
  let cycles=0;
  while(!s.dead&&s.elapsed>=(s.sleeping?50:250)) {
    const sleeping=s.sleeping;s.elapsed-=sleeping?50:250;
    const phase=next.machinery.phase+1;
    if(phase===1) {
      s.minutes++;
      if(s.minutes%60===0) {
        const hour=conditionHour(s.condition,sleeping);s.condition=hour.condition;s.dead=hour.dead;
        if(hour.exhausted&&!s.sleeping&&!s.dead){s.sleeping=true;s.forced=true;s.sleepPhase=0}
      }
    }
    let workingFuel=next.resources.fuel;
    if(next.flight) {
      const moved=stepCampaignFlight(next,phase);next=moved.state;workingFuel=moved.workingFuel;
    }
    applySource(next,stepShipPower(sourceState(next),next.equipment.map(g=>g.performance),phase,workingFuel).state);
    if(next.flight){next.ship.minutes=s.minutes;next=finishCampaignFlight(next)}
    next.machinery.phase=phase%4;cycles++;
    if(sleeping) {
      s.sleepPhase=(s.sleepPhase+1)%2;
      if(!s.dead&&s.sleepPhase===0)s.condition.rest=Math.min(255,s.condition.rest+1);
      if(s.condition.rest>128)s.forced=false;
    }
  }
  if(s.dead){s.sleeping=false;s.elapsed=0}
  next.ship.minutes=s.minutes;next.ship.condition={...s.condition};
  return {state:next,survival:s,cycles};
}
