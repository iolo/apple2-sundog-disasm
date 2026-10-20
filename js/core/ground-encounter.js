import { produceCampaignGroundChase, stepGroundChase,
  initializeCaughtGroundCombat } from './ground-chase.js';
import { stepGroundCombat, checkpointGroundCombat, resumeGroundCombat } from './ground-combat.js';
import { setupEncounterDialogue } from './dialogue-state.js';
import { startDialogueConversation, advanceDialogue } from './dialogue-runner.js';
import { validateDialogueInput } from './dialogue-input.js';
import { campaignLocation } from './regional-world.js';
import { CONDITION_FIELDS } from './condition.js';

const keys=(value,names)=>value&&typeof value==='object'&&!Array.isArray(value)&&
  Object.keys(value).length===names.length&&names.every(name=>Object.hasOwn(value,name));
const integer=(value,min,max)=>Number.isInteger(value)&&value>=min&&value<=max;
const fail=()=>{throw Error('invalidGroundEncounter')};
export const MAX_GROUND_INPUTS=1024,MAX_GROUND_TICKS=12000;

function personal(campaign) {
  return {attributes:[...campaign.dialogue.attributes],flags:[...campaign.dialogue.flags],cash:campaign.dialogue.cash,
    carried:[...campaign.ship.inventory.carried],condition:CONDITION_FIELDS.map(key=>campaign.ship.condition[key])};
}
function setup(campaign,combat,content,persistentWorkspace) {
  const location=campaignLocation(campaign,content),systemIndex=content.navigation.systems.findIndex(s=>s.id===location.systemId);
  const worldIndex=content.navigation.worlds.findIndex(w=>w.id===location.worldId);
  if(systemIndex<0||worldIndex<0)fail();
  const workspace={...persistentWorkspace,mood:combat.workspace[9],quantity:combat.workspace[11],
    item:combat.workspace[8],gate:combat.workspace[12],actor:combat.workspace[10]};
  const context={kind:combat.kind,system:content.dialogue.systems.systems[systemIndex],
    attributes:combat.attributes,flags:combat.flags,carried:combat.carried,cash:combat.cash,workspace,
    city:Number(location.cityId.slice(-2)),hour:Math.floor(campaign.ship.minutes/60)%24,
    surface:location.surfacePosition,sceneMiddle:combat.sceneMid,
    colonyProgress:campaign.colony?.completedPhase??campaign.start.economy.colony.completedPhase,
    randomState:combat.randomState};
  const places={systems:content.navigation.systems.map(s=>s.name),worlds:content.navigation.worlds.map(w=>w.name),
    system:systemIndex+1,world:worldIndex+1};
  const prepared=setupEncounterDialogue(context);
  return {context,conversation:startDialogueConversation(content.dialogue,prepared,{places})};
}

// Starts only from an actual due threat gate, retaining the legitimate map pose.
// The personal campaign fields stay frozen until the host commits a return.
export function produceGroundEncounter(previous,world,content) {
  const seed=previous.encounters.randomState;
  const produced=produceCampaignGroundChase(previous,world,content,content.combat.chase);
  const activation=produced.session ? {phase:'chase',chase:produced.session,combat:null,arena:null,
    conversation:null,context:null,outcome:null,receipts:[],sales:[],workspace:structuredClone(previous.dialogue.workspace)} : null;
  return {campaign:produced.campaign,record:activation ? {seed,inputs:[]} : null,activation,events:[]};
}

function control(value) {
  if(!keys(value,['move','fire','cancelSurrender','pointer'])||
    ![value.move,value.fire,value.cancelSurrender].every(v=>typeof v==='boolean')||
    value.pointer!==null&&(!keys(value.pointer,['x','y'])||!integer(value.pointer.x,0,279)||!integer(value.pointer.y,0,191))||
    (value.move||value.fire)&&value.pointer===null)fail();
  return structuredClone(value);
}
export const idleGroundControl=()=>({move:false,fire:false,cancelSurrender:false,pointer:null});
function eventFor(event) {
  if(event?.type==='tick') {
    if(!keys(event,['type','control','ticks'])||!integer(event.ticks,1,1200))fail();
    return {type:'tick',control:control(event.control),ticks:event.ticks};
  }
  if(event?.type==='dialogue'&&keys(event,['type','input'])) {
    try{return {type:'dialogue',input:validateDialogueInput(event.input)}}catch{fail()}
  }
  fail();
}
export function validateGroundEncounterRecord(value) {
  if(!keys(value,['seed','inputs'])||!integer(value.seed,0,0xffffffff)||!Array.isArray(value.inputs)||
    value.inputs.length>MAX_GROUND_INPUTS||Object.keys(value.inputs).length!==value.inputs.length)fail();
  const record={seed:value.seed,inputs:Array.from(value.inputs,eventFor)};
  if(record.inputs.reduce((sum,e)=>sum+(e.ticks??0),0)>MAX_GROUND_TICKS)fail();
  return record;
}

function conversationFor(frame,content) {
  const a=frame.activation;
  a.combat=checkpointGroundCombat(a.combat,a.arena);
  const opened=setup(frame.campaign,a.combat,content,a.workspace);
  a.context=opened.context;a.conversation=opened.conversation;a.phase='dialogue';
  a.combat.randomState=a.conversation.randomState;
  frame.campaign.encounters.randomState=a.conversation.randomState;
  if(a.combat.kind===15)a.receipts.push({kind:15,systemId:a.context.system.id,
    quantity:a.context.workspace.quantity,seed:a.context.randomState,amount:a.conversation.state.locals[100]});
}
function returned(frame) {
  const a=frame.activation,s=checkpointGroundCombat(a.combat,a.arena);
  a.combat=s;a.phase=s.sceneMid===12?'defeated':'returned';
  a.outcome={kind:s.kind,attributes:[...s.attributes],condition:[...s.condition],carried:[...s.carried],
    flags:[...s.flags],cash:s.cash,workspace:{...a.workspace,
      item:s.workspace[8],mood:s.workspace[9],quantity:s.workspace[11],gate:s.workspace[12],actor:s.workspace[10]},
    randomState:s.randomState,receipts:structuredClone(a.receipts),sales:structuredClone(a.sales),
    sceneMiddle:s.sceneMid};
  frame.campaign.encounters.randomState=s.randomState;
}
function tick(frame,content,held) {
  const a=frame.activation;
  if(a.phase==='chase') {
    const r=stepGroundChase(a.chase,content.combat.chase,{move:held.move,pointer:held.pointer});
    a.chase=r.state;frame.events.push(...r.events);frame.campaign.encounters.randomState=r.state.randomState;
    if(r.state.status==='escaped'){a.phase='escaped';return}
    if(r.state.status==='caught') {
      const initialized=initializeCaughtGroundCombat(r.state,content.combat.chase,content.combat.ground,personal(frame.campaign));
      a.combat=initialized.state;a.arena=initialized.arena;
      // Initial mandatory Game16 precedes the first active Game17 iteration.
      conversationFor(frame,content);frame.events.push('groundInitialDialogue');
    }
  } else if(a.phase==='combat') {
    const r=stepGroundCombat(a.combat,a.arena,held);
    a.combat=r.state;frame.events.push(...r.events);frame.campaign.encounters.randomState=r.state.randomState;
    if(r.state.sceneMid===12)returned(frame);
    else if(r.state.done) {
      if(r.state.lastEnemyKilled){conversationFor(frame,content);frame.events.push('groundPostFightDialogue')}
      else returned(frame);
    }
  } else throw Error('groundEncounterTickUnavailable');
}
function applyEvent(previous,content,event) {
  const frame=structuredClone(previous),a=frame.activation;
  frame.events=[];
  if(!a||['escaped','returned','defeated'].includes(a.phase))throw Error('groundEncounterInactive');
  if(event.type==='tick') {
    for(let count=0;count<event.ticks;count++) {
      tick(frame,content,event.control);
      // A tick batch cannot cross a dialogue/return boundary and hide inputs.
      if(!['chase','combat'].includes(a.phase)) {
        if(count!==event.ticks-1)throw Error('groundEncounterBoundary');
        break;
      }
    }
  } else {
    if(a.phase!=='dialogue')throw Error('groundEncounterDialogueUnavailable');
    a.conversation=advanceDialogue(content.dialogue,a.conversation,event.input);
    frame.campaign.encounters.randomState=a.conversation.randomState;
    if(a.conversation.ended) {
      const s=a.conversation.state;
      a.workspace=structuredClone(s.workspace);
      a.sales.push(...s.sales);
      Object.assign(a.combat,{attributes:[...s.attributes],carried:[...s.carried],flags:[...s.flags],cash:s.locals[104],randomState:a.conversation.randomState});
      Object.assign(a.combat.workspace,{8:s.workspace.item,9:s.workspace.mood,11:s.workspace.quantity,12:s.workspace.gate});
      a.conversation=null;a.context=null;
      if(a.combat.done)returned(frame);
      else {a.combat=resumeGroundCombat(a.combat,a.arena,a.combat).state;a.phase='combat'}
    }
  }
  return frame;
}

// Runtime reducers accept the already-derived activation. Save restoration
// replays the bounded record below; serialized activations are never accepted.
export function advanceGroundEncounter(previous,content,event) {
  const nextEvent=eventFor(event),record=validateGroundEncounterRecord(previous.record);
  const next=applyEvent(previous,content,nextEvent);
  const last=record.inputs.at(-1);
  if(nextEvent.type==='tick'&&last?.type==='tick'&&last.ticks+nextEvent.ticks<=1200&&
    JSON.stringify(last.control)===JSON.stringify(nextEvent.control))last.ticks+=nextEvent.ticks;
  else record.inputs.push(nextEvent);
  next.record=validateGroundEncounterRecord(record);
  return next;
}
export function restoreGroundEncounter(campaign,world,content,value,{allowReturn=false}={}) {
  if(typeof allowReturn!=='boolean')fail();
  const record=validateGroundEncounterRecord(value);
  const baseline=structuredClone(campaign);baseline.encounters.randomState=record.seed;
  let frame=produceGroundEncounter(baseline,world,content);
  if(!frame.activation)fail();
  for(const event of record.inputs)frame=applyEvent(frame,content,event);
  if(frame.campaign.encounters.randomState!==campaign.encounters.randomState)fail();
  if(!allowReturn&&['escaped','returned','defeated'].includes(frame.activation.phase))fail();
  frame.record=record;
  return frame;
}
