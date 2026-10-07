import { stepShipPower } from './ship-power.js';
import { equipmentDependencyResult } from './equipment-failures.js';
import { conditionHour } from './survival.js';
import { stepCampaignFlight,finishCampaignFlight } from './campaign-flight.js';
import { campaignShipSource,commitCampaignShipSource,stepCampaignSpaceProducer,stepCampaignSpaceCombat,
  stepCampaignShipCommunication,leaveCampaignShipDeadline,clearCampaignTactical,neutralShipControl } from './campaign-space.js';

import { prepareShipTactical,beginShipTacticalFrame,finishShipTacticalFrame,shipTacticalControls } from './ship-tactical.js';
import { currentShipLocation } from './regional-world.js';

const integer=(n,lo,hi)=>Number.isInteger(n)&&n>=lo&&n<=hi;
export const initialMachinery=()=>({phase:0,cloaked:false});
export function validateMachinery(value,equipment,resources,{tacticalGunLoop=false}={}) {
  if(!value||Array.isArray(value)||Object.keys(value).length!==2||!Object.hasOwn(value,'phase')||!Object.hasOwn(value,'cloaked')||!integer(value.phase,0,3)||typeof value.cloaked!=='boolean'||
    (value.cloaked&&!equipment[4].specialAvailable)||
    (equipment[2].performance===0&&((resources.guns.powered&&!tacticalGunLoop)||resources.guns.charge!==0))||
    (equipment[4].performance===0&&resources.shields.targetCharge!==0))throw Error('invalidMachinery');
  return {phase:value.phase,cloaked:value.cloaked};
}

function sourceState(state) {
  if(state.space)return campaignShipSource(state);
  const r=state.resources,flags=Array(128).fill(false);
  flags[0]=r.warp.charging;flags[1]=r.enginesPowered;
  flags[2]=r.guns.powered;flags[4]=r.shields.targetCharge>0;flags[7]=state.pod.attached;flags[12]=state.machinery.cloaked;
  return {flags,words:{222:r.warp.targetCharge,223:r.warp.charge,224:r.shields.targetCharge,225:r.shields.charge,226:r.guns.charge,227:r.fuel,349:0,350:0},
    cargo:state.pod.cargo,randomState:state.encounters.randomState};
}
function applySource(state,source) {
  if(state.space){commitCampaignShipSource(state,source);return}
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
  if(previous.travel.scene!=='ship'||previous.space?.defeat||previous.combat?.defeat||previous.space?.communication?.conversation||previous.space?.activity?.sleeping)throw Error('machineryUnavailable');
  const next=structuredClone(previous),r=next.resources;
  if(next.space?.tactical) {
    const controls=shipTacticalControls(campaignShipSource(next),next.space.tactical.record);
    if(action.type==='shields'&&!controls.shields||action.type==='cloak'&&!controls.cloak)throw Error('shipTacticalUnavailable');
    if(action.type==='guns'&&next.space.tactical.record.firing)throw Error('machineryUnavailable');
  }
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


function machineryCycle(previous,s,content) {
  let next=previous;const space=!!next.space;
  const sleeping=s.sleeping;
  const phase=next.machinery.phase+1;
  if(phase===1) {
    s.minutes++;
    if(space&&Object.hasOwn(next.space,'tactical'))next.space.words[354]=0;
    if(s.minutes%60===0) {
      const hour=conditionHour(s.condition,sleeping);s.condition=hour.condition;s.dead=hour.dead;
      if(hour.exhausted&&!s.sleeping&&!s.dead){s.sleeping=true;s.forced=true;s.sleepPhase=0}
    }
  }
  next.ship.minutes=s.minutes;
  let workingFuel=next.resources.fuel;
  if(next.flight) {
    const moved=stepCampaignFlight(next,phase);next=moved.state;workingFuel=moved.workingFuel;
    if(space)next=stepCampaignSpaceProducer(next,content,{enabled:moved.encounterDue,arrived:moved.arrived});
  }
  applySource(next,stepShipPower(sourceState(next),next.equipment.map(g=>g.performance),phase,workingFuel).state);
  if(next.flight){next.ship.minutes=s.minutes;next=finishCampaignFlight(next)}
  if(space){next=stepCampaignSpaceCombat(next);next=stepCampaignShipCommunication(next);if(next.space.defeat)s.dead=true}
  next.machinery.phase=phase%4;
  if(space&&s.sleeping&&!sleeping){leaveCampaignShipDeadline(next);clearCampaignTactical(next);next.space.view='ship'}
  if(sleeping) {
    s.sleepPhase=(s.sleepPhase+1)%2;
    if(!s.dead&&s.sleepPhase===0)s.condition.rest=Math.min(255,s.condition.rest+1);
    if(s.condition.rest>128)s.forced=false;
  }
  return next;
}

export function enterCampaignShipTactical(previous,content,{warp=false}={}) {
  if(!content?.tactical||!Object.hasOwn(previous.space||{},'tactical')||previous.travel.scene!=='ship'||
    previous.pod.occupied||previous.space.activity.sleeping||previous.space.communication.conversation||
    previous.space.defeat||previous.combat.defeat)throw Error('spaceUnavailable');
  if(previous.space.tactical&&!warp)return previous;
  let next=structuredClone(previous);next.space.view='tactical';next.space.elapsed=0;
  const s={...next.space.activity,minutes:next.ship.minutes,condition:{...next.ship.condition},dead:false,elapsed:0};
  if(warp){next.space.words[354]=6;next=machineryCycle(next,s,content)}
  if(s.sleeping||s.dead||next.space.defeat) {
    next.ship.condition={...s.condition};next.space.activity={sleeping:s.sleeping&&!s.dead,forced:s.forced&&!s.dead,sleepPhase:s.sleepPhase};
    next.space.view='ship';clearCampaignTactical(next);
    if(s.condition.vigor===0&&!next.combat.defeat)next.combat.defeat={reason:'conditionDeath',minutes:s.minutes};
    return next;
  }
  const prepared=prepareShipTactical(campaignShipSource(next),{
    worldAngle:currentShipLocation(next).orbit.angle,frameLimit:5,grace:0});
  commitCampaignShipSource(next,prepared.state);
  next.space.tactical={record:prepared.tactical,control:neutralShipControl(),carry:0};
  for(let i=0;i<prepared.startupCycles&&!s.dead&&!s.sleeping&&!next.space.defeat;i++)next=machineryCycle(next,s,content);
  next.ship.minutes=s.minutes;next.ship.condition={...s.condition};next.space.activity={sleeping:s.sleeping,forced:s.forced,sleepPhase:s.sleepPhase};
  if(s.dead||next.space.defeat){clearCampaignTactical(next);next.space.elapsed=0;next.space.activity={sleeping:false,forced:false,sleepPhase:s.sleepPhase}}
  if(s.condition.vigor===0&&!next.combat.defeat)next.combat.defeat={reason:'conditionDeath',minutes:s.minutes};
  return next;
}

// One owner for the aboard clock and power phases. Normal cycles250ms, sleep
// cycles50ms; tactical frames50ms dispatch source calls through Game12. The
// source clock advances at phase1. Space-enabled saves own the
// integer millisecond remainder; historical hosts retain their transient clock.
export function advanceCampaignMachinery(previous,survival,milliseconds,paused=false,content=null) {
  if(previous.travel.scene!=='ship')throw Error('machineryUnavailable');
  const space=!!previous.space;
  if(space&&(!integer(milliseconds,0,60000)||!content?.dialogue?.systems))throw Error('invalidCampaignSpace');
  const ownedSurvival=space?{...survival,...previous.space.activity,minutes:previous.ship.minutes,condition:{...previous.ship.condition},
    dead:previous.ship.condition.vigor===0||!!previous.space.defeat||!!previous.combat.defeat}:survival;
  if(paused||ownedSurvival.dead||previous.combat?.defeat||previous.space?.communication?.conversation)
    return {state:previous,survival:{...ownedSurvival,elapsed:space?previous.space.elapsed:0},cycles:0};
  const elapsed=(space?previous.space.elapsed+(previous.space.tactical?.carry||0):ownedSurvival.elapsed)+(space?milliseconds:Math.max(0,Math.min(250,milliseconds)));
  const period=state=>ownedSurvival.sleeping?50:state.space?.tactical?50:250;
  if(elapsed<period(previous)) {
    const state=space?structuredClone(previous):previous;if(space){state.space.elapsed=elapsed;if(state.space.tactical)state.space.tactical.carry=0}
    return {state,survival:{...ownedSurvival,elapsed},cycles:0};
  }
  let next=structuredClone(previous);if(next.space?.tactical)next.space.tactical.carry=0;const s={...ownedSurvival,condition:{...ownedSurvival.condition},elapsed};
  let cycles=0,frames=0;
  while(!s.dead&&s.elapsed>=(s.sleeping?50:next.space?.tactical?50:250)) {
    const sleeping=s.sleeping;s.elapsed-=sleeping?50:next.space?.tactical?50:250;
    if(next.space?.tactical&&!sleeping) {
      const controller=next.space.tactical;
      const begun=beginShipTacticalFrame(campaignShipSource(next),controller.record,controller.control,
        {dexterity:next.dialogue.attributes[2],worldAngle:currentShipLocation(next).orbit.angle});
      commitCampaignShipSource(next,begun.state);controller.record=begun.tactical;
      if(begun.shot) {
        const index=next.start.systems.findIndex(system=>system.id===currentShipLocation(next).systemId);
        next.space.cooldowns[index]=(next.space.cooldowns[index]+begun.shot.cooldownIncrement)&15;
      }
      if(begun.due) {
        next=machineryCycle(next,s,content);cycles++;
        if(next.space.tactical&&!next.space.defeat&&!s.dead) {
          const finished=finishShipTacticalFrame(campaignShipSource(next),next.space.tactical.record,begun.delta);
          commitCampaignShipSource(next,finished.state);next.space.tactical.record=finished.tactical;
        }
      }
      frames++;
    } else {next=machineryCycle(next,s,content);cycles++}
  }
  if(s.dead){s.sleeping=false;s.elapsed=0;if(space){s.forced=false;leaveCampaignShipDeadline(next);clearCampaignTactical(next)}}
  next.ship.minutes=s.minutes;next.ship.condition={...s.condition};
  if(space){next.space.elapsed=s.elapsed;if(next.space.activity)next.space.activity={sleeping:s.sleeping,forced:s.forced,sleepPhase:s.sleepPhase}}
  if(s.condition.vigor===0&&next.combat&&!next.combat.defeat)next.combat.defeat={reason:'conditionDeath',minutes:s.minutes};
  return {state:next,survival:s,cycles,frames};
}
