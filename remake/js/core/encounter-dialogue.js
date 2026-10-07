import { setupEncounterDialogue } from './dialogue-state.js';
import { startDialogueConversation, advanceDialogue } from './dialogue-runner.js';
import { validateDialogueInput, MAX_DIALOGUE_INPUTS } from './dialogue-input.js';

const keys=(value,names)=>value&&typeof value==='object'&&!Array.isArray(value)&&
  Object.keys(value).length===names.length&&names.every(name=>Object.hasOwn(value,name));
const fail=()=>{throw Error('invalidEncounterDialogue')};
function inputFor(value) {
  try{return validateDialogueInput(value)}catch{fail()}
}

// Only the seed and explicit inputs are stored. The host owns the frozen
// setup context (personal state, system, location, hour, bank and colony).
// Imported interpreter locals, rendered messages and outcomes are never trusted.
export function validateEncounterDialogueRecord(value) {
  if(!keys(value,['seed','inputs'])||!Number.isInteger(value.seed)||value.seed<0||value.seed>0xffffffff||
    !Array.isArray(value.inputs)||value.inputs.length>MAX_DIALOGUE_INPUTS||
    Object.keys(value.inputs).length!==value.inputs.length)fail();
  return {seed:value.seed,inputs:Array.from(value.inputs,inputFor)};
}

export function startEncounterDialogue(content,context,{places}={}) {
  const record={seed:context.randomState,inputs:[]};
  const conversation=startDialogueConversation(content,setupEncounterDialogue(context),{places});
  if(conversation.ended)fail();
  return {record,conversation,outcome:null};
}

export function restoreEncounterDialogue(content,context,previous,{places,randomState}={}) {
  const record=validateEncounterDialogueRecord(previous);
  if(record.seed!==context.randomState)fail();
  let conversation=startEncounterDialogue(content,context,{places}).conversation;
  for(const input of record.inputs) {
    conversation=advanceDialogue(content,conversation,input);
    if(conversation.ended)fail(); // A return must have committed and removed the record.
  }
  if(randomState!==undefined&&conversation.randomState!==randomState)fail();
  return conversation;
}

// One owned transition, publishing money/inventory/flags only on source return.
// Unlike a room return, flags48–51 remain available to Game17/Game12's host.
export function advanceEncounterDialogue(content,context,previous,event,options={}) {
  const input=inputFor(event),record=validateEncounterDialogueRecord(previous);
  const frame=restoreEncounterDialogue(content,context,record,options);
  const conversation=advanceDialogue(content,frame,input);
  if(!conversation.ended) {
    if(record.inputs.length>=MAX_DIALOGUE_INPUTS)throw Error('dialogueHistoryFull');
    record.inputs.push(input);
    return {record,conversation,outcome:null};
  }
  const s=conversation.state;
  return {record:null,conversation,outcome:{kind:s.kind,
    cash:s.kind===19 ? context.cash : s.locals[104],
    bankBalance:s.kind===19 ? s.locals[104] : null,
    attributes:[...s.attributes],carried:[...s.carried],flags:[...s.flags],
    workspace:structuredClone(s.workspace),randomState:conversation.randomState}};
}
