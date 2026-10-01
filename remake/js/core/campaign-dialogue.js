import { ATTRIBUTES } from './character.js';
import { updateLodgingAccess } from './room-lodging.js';
import { requestRoomCounter, cancelRoomCounter, moveRoomCounter, tickRoomCounter,
  openRoomCounter, advanceRoomCounter } from './room-counter.js';

const keys=(v,names)=>v&&typeof v==='object'&&!Array.isArray(v)&&Object.keys(v).length===names.length&&names.every(k=>Object.hasOwn(v,k));
const integer=(v,min,max)=>Number.isInteger(v)&&v>=min&&v<=max;
const array=(v,n,test)=>Array.isArray(v)&&v.length===n&&Object.keys(v).length===n&&Array.from(v).every(test);
const fail=()=>{throw new Error('invalidCampaign')};
export const MAX_DIALOGUE_INPUTS=1024;
export const initialCounter=()=>({service:'idle',conversation:null});
export function initialCampaignDialogue(start) {
  return {cash:start.credits,attributes:ATTRIBUTES.map(key=>start.character.attributes[key]),flags:Array(128).fill(false),
    workspace:{lastCity:0,mood:3,quantity:1,gate:0,item:0,actor:0}};
}
export function validateCampaignDialogue(value,{legacyCash,visitors=false}={}) {
  const legacy=legacyCash!==undefined;
  if(!keys(value,legacy ? ['attributes','flags','workspace'] : ['cash','attributes','flags','workspace'])||
    (!legacy&&!integer(value.cash,0,32767999))||!array(value.attributes,5,n=>integer(n,0,255))||
    !array(value.flags,128,b=>typeof b==='boolean')||value.flags[65]||
    !keys(value.workspace,['lastCity','mood','quantity','gate','item','actor']))fail();
  const w=value.workspace;
  if(!integer(w.lastCity,0,63)||!integer(w.mood,0,4)||w.quantity!==1||!integer(w.gate,0,1)||
    !integer(w.item,0,255)||!integer(w.actor,0,visitors ? 8 : 0)||w.actor===1)fail();
  return {cash:legacy ? legacyCash : value.cash,attributes:[...value.attributes],flags:[...value.flags],workspace:
    Object.fromEntries(['lastCity','mood','quantity','gate','item','actor'].map(k=>[k,w[k]]))};
}
export function validateCounterRecord(value) {
  if(!keys(value,['service','conversation'])||!['idle','waiting','talking','served'].includes(value.service))fail();
  const c=value.conversation;
  // Dispatch and opening are a single campaign operation; no half-open saves.
  if((value.service==='talking')!==(c!==null))fail();
  if(c!==null) {
    if(!keys(c,['seed','inputs'])||!integer(c.seed,0,0xffffffff)||!Array.isArray(c.inputs)||
      c.inputs.length>MAX_DIALOGUE_INPUTS||Object.keys(c.inputs).length!==c.inputs.length)fail();
    for(const input of c.inputs)validateDialogueInput(input);
  }
  return {service:value.service,conversation:c===null ? null : {seed:c.seed,inputs:c.inputs.map(validateDialogueInput)}};
}
function validateDialogueInput(input) {
  const fields={purchase:['type','slot'],reply:['type','slot'],item:['type','item'],offer:['type','direction','step'],cancel:['type'],timeout:['type']};
  if(!Object.hasOwn(fields,input?.type)||!keys(input,fields[input.type]))fail();
  if(input.type==='reply'&&!integer(input.slot,0,2))fail();
  if(input.type==='purchase'&&!integer(input.slot,0,3))fail();
  if(input.type==='item'&&!integer(input.item,8,255))fail();
  if(input.type==='offer'&&(!['increase','decrease'].includes(input.direction)||![1,10,100,1000,10000].includes(input.step)))fail();
  return Object.fromEntries(fields[input.type].map(k=>[k,input[k]]));
}
function setup(state,content) {
  const location=state.start.playerLocation,index=content.navigation.systems.findIndex(s=>s.id===location.systemId);
  const world=content.navigation.worlds.findIndex(w=>w.id===location.worldId);
  const system=content.dialogue?.systems.systems[index];
  if(!system||index<0||world<0)fail();
  return {context:{...state.dialogue,system,city:Number(location.cityId.slice(-2)),
    hour:Math.floor(state.ship.minutes/60)%24,surface:location.surfacePosition,
    cash:state.dialogue.cash,carried:state.ship.inventory.carried},
    places:{systems:content.navigation.systems.map(s=>s.name),worlds:content.navigation.worlds.map(w=>w.name),system:index+1,world:world+1}};
}
function frameFor(state,room) {
  return {room:room.index,traffic:structuredClone(state.encounters.roomState),position:{...state.travel.roomPosition},
    randomState:state.encounters.randomState,service:state.encounters.counter.service,conversation:null,
    ...(room.index===1 ? {lodging:structuredClone(state.travel.lodging)} : {})};
}
export function restoreCampaignConversation(state,content,room,options) {
  const record=validateCounterRecord(state.encounters.counter),frame=frameFor(state,room);
  if(!record.conversation)return frame;
  const {context,places}=setup(state,content);
  frame.randomState=record.conversation.seed;
  let next=openRoomCounter(content.dialogue,room,frame,context,{places});
  for(const input of record.conversation.inputs) {
    const result=advanceRoomCounter(content.dialogue,room,next,input,options);
    if(result.outcome)fail(); // A completed conversation must already have committed its outcome.
    next=result.frame;
  }
  if(next.randomState!==state.encounters.randomState)fail();
  return next;
}

// Campaign-level atomic boundary. Interpreter frames/text are derived and never
// saved; only the initial RNG and validated inputs reconstruct an open dialogue.
export function reduceCampaignCounter(previous,content,room,action) {
  if(previous.travel.scene!=='room'||!previous.encounters.counter)throw new Error('roomCounterUnavailable');
  const state=structuredClone(previous),counter=state.encounters.counter;
  let frame=restoreCampaignConversation(state,content,room),outcome=null;
  switch(action.type) {
    case 'request':frame=requestRoomCounter(room,frame);break;
    case 'cancel':frame=cancelRoomCounter(room,frame);break;
    case 'move':frame=moveRoomCounter(room,frame,action.position);break;
    case 'tick':frame=tickRoomCounter(room,frame);break;
    case 'dialogue':{
      validateDialogueInput(action.input);
      ({frame,outcome}=advanceRoomCounter(content.dialogue,room,frame,action.input));
      if(!outcome) {
        if(counter.conversation.inputs.length>=MAX_DIALOGUE_INPUTS)throw new Error('dialogueHistoryFull');
        counter.conversation.inputs.push(structuredClone(action.input));
      }
      break;
    }
    default:throw new Error('invalidRoomService');
  }
  if(frame.service==='talking'&&!frame.conversation) {
    const {context,places}=setup(state,content);
    counter.conversation={seed:frame.randomState,inputs:[]};
    frame=openRoomCounter(content.dialogue,room,frame,context,{places});
  }
  if(outcome) {
    // Only verified replay inputs can change carried items. Purchases and fees
    // debit cash; personal-item sales are outside this save scope.
    if(outcome.locals[104]>state.dialogue.cash)
      throw new Error('unsupportedRoomDialogueReturn');
    state.dialogue=validateCampaignDialogue({cash:outcome.locals[104],attributes:outcome.attributes,flags:outcome.flags,workspace:outcome.workspace},{visitors:true});
    state.ship.inventory.carried=[...outcome.carried];
    counter.conversation=null;
  }
  counter.service=frame.service;
  state.encounters.roomState=frame.traffic;state.encounters.randomState=frame.randomState;
  state.travel.roomPosition=frame.position;
  if(room.index===1) {
    state.travel.lodging=frame.lodging;
    state.dialogue.flags[57]=updateLodgingAccess(room,frame.lodging,frame.position).sheltered;
  }
  return {state,conversation:frame.conversation};
}
