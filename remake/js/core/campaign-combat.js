import { initialGroundClock,validateGroundClock } from './ground-host.js';
import { validateGroundEncounterRecord,restoreGroundEncounter } from './ground-encounter.js';
import { setupEncounterDialogue } from './dialogue-state.js';
import { validateCampaignDialogue } from './campaign-dialogue.js';
import { recordPersonalSales } from './personal-trade.js';
import { CONDITION_FIELDS } from './condition.js';

const keys=(value,names)=>value&&typeof value==='object'&&!Array.isArray(value)&&
  Object.keys(value).length===names.length&&names.every(name=>Object.hasOwn(value,name));
const integer=(value,min,max)=>Number.isInteger(value)&&value>=min&&value<=max;
const fail=()=>{throw Error('invalidCampaignCombat')};
export const initialCampaignCombat=()=>({clock:initialGroundClock(),ground:null,rewards:[],defeat:null});

// The money bound derives each receipt from the source RNG/system/quantity,
// as personal-sale receipts already derive their prices from source items.
export function validateGroundRewards(rewards,content) {
  if(!Array.isArray(rewards)||Object.keys(rewards).length!==rewards.length||rewards.length>1024)fail();
  return rewards.map(receipt=>{
    if(!keys(receipt,['kind','systemId','quantity','seed','amount'])||receipt.kind!==15||
      !integer(receipt.quantity,1,5)||!integer(receipt.seed,0,0xffffffff)||!integer(receipt.amount,0,22500))fail();
    const system=content.dialogue.systems.systems.find(s=>s.id===receipt.systemId);
    if(!system)fail();
    const prepared=setupEncounterDialogue({kind:15,system,attributes:Array(5).fill(30),carried:Array(4).fill(0),
      flags:Array(128).fill(false),workspace:{lastCity:0,mood:3,quantity:receipt.quantity,gate:0},
      city:0,hour:0,surface:{x:0,y:0},cash:0,sceneMiddle:3,randomState:receipt.seed});
    if(prepared.state.locals[100]!==receipt.amount)fail();
    return {...receipt};
  });
}

export function validateCampaignCombat(campaign,value,world,content) {
  if(!keys(value,['clock','ground','rewards','defeat']))fail();
  const clock=validateGroundClock(value.clock),rewards=validateGroundRewards(value.rewards,content);
  const ground=value.ground===null?null:validateGroundEncounterRecord(value.ground);
  if(ground) {
    if(!['city','surface'].includes(campaign.travel.scene)||campaign.encounters.roomSeed!==null||value.defeat!==null)fail();
    if(clock.scene!==campaign.travel.scene||clock.iterations!==0)fail();
    restoreGroundEncounter(campaign,world,content,ground);
  }
  let defeat=null;
  if(campaign.ship.condition.vigor===0&&value.defeat===null)fail();
  if(value.defeat!==null) {
    if(!keys(value.defeat,['reason','minutes'])||!['groundDeath','conditionDeath'].includes(value.defeat.reason)||
      value.defeat.minutes!==campaign.ship.minutes||campaign.ship.condition.vigor!==0||
      value.defeat.reason==='groundDeath'&&campaign.ship.condition.health!==0)fail();
    defeat={...value.defeat};
  }
  return {clock,ground,rewards,defeat};
}

// Terminal replay proves the return against the still-frozen personal/map
// context. Imported activations/outcomes cannot grant income or equipment.
export function finishCampaignGroundEncounter(previous,world,content) {
  if(!previous.combat?.ground)throw Error('groundEncounterReturnUnavailable');
  const activation=restoreGroundEncounter(previous,world,content,previous.combat.ground,{allowReturn:true}).activation;
  if(!['escaped','returned','defeated'].includes(activation.phase))
    throw Error('groundEncounterReturnUnavailable');
  const next=structuredClone(previous);
  if(activation.phase!=='escaped') {
    const out=activation.outcome;
    if(!out)fail();
    const receipts=validateGroundRewards(out.receipts,content);
    const income=receipts.reduce((sum,r)=>sum+r.amount,0)+out.sales.reduce((sum,s)=>sum+s.price,0);
    if(out.cash>next.dialogue.cash+income)fail();
    next.economy.personalTrade=recordPersonalSales(next.economy.personalTrade,out.sales,content.dialogue.items);
    next.combat.rewards=validateGroundRewards([...next.combat.rewards,...receipts],content);
    next.dialogue=validateCampaignDialogue({cash:out.cash,attributes:out.attributes,flags:out.flags,workspace:out.workspace},
      {visitors:true,traderMatching:true,groundEncounters:true});
    next.ship.inventory.carried=[...out.carried];
    next.ship.condition=Object.fromEntries(CONDITION_FIELDS.map((key,index)=>[key,out.condition[index]]));
    if(activation.phase==='defeated')next.combat.defeat={reason:'groundDeath',minutes:next.ship.minutes};
  }
  next.combat.ground=null;next.encounters.randomState=activation.outcome?.randomState??activation.chase.randomState;
  return next;
}

// Persist only the source clock and replay inputs. Personal state stays owned
// by the campaign until a source return, which this boundary commits once.
export function snapshotCampaignGroundHost(frame,world,content) {
  if(!frame.campaign.combat)fail();
  const next=structuredClone(frame.campaign);
  next.combat.clock=validateGroundClock(frame.clock);
  next.combat.ground=frame.encounter?validateGroundEncounterRecord(frame.encounter.record):null;
  if(frame.encounter&&['escaped','returned','defeated'].includes(frame.encounter.activation.phase))
    return finishCampaignGroundEncounter(next,world,content);
  if(frame.defeated)next.combat.defeat={reason:'conditionDeath',minutes:next.ship.minutes};
  return next;
}
