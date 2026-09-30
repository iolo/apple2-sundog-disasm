import { validateRoomTraffic, tickRoomTraffic } from './room-traffic.js';
import { setupCounterDialogue } from './dialogue-state.js';
import { startCounterConversation, advanceDialogue } from './dialogue-runner.js';
import { sourceRandom } from './random.js';
import { initialLodging, validateLodging, lodgingGeometry, rentLodging, updateLodgingAccess } from './room-lodging.js';

const atCounter=(room,p)=>{
  const b=room.population.bounds;
  return p.x>=b.left&&p.x<=b.right&&p.y>=b.top&&p.y<=b.bottom;
};
const kind=room=>{
  if(room?.index===1)return 23;
  if(!Number.isInteger(room?.index)||room.index<8||room.index>15)throw new Error('unsupportedRoomCounter');
  return room.index<12 ? 13 : 14;
};
function own(room,previous) {
  kind(room);
  if(previous?.room!==room.index||!['idle','waiting','talking','served'].includes(previous.service)||
    (previous.conversation!==null&&previous.service!=='talking'))throw new Error('invalidRoomService');
  sourceRandom(previous.randomState);
  if(room.index===1)validateLodging(previous.lodging);
  validateRoomTraffic(lodgingGeometry(room,previous.lodging),previous.traffic,previous.position,
    {service:previous.service,playerRoom:lodgingGeometry(room,previous.lodging,{access:true})});
  return structuredClone(previous);
}

// This controller owns a room visit, not a campaign save. Position is explicit;
// movement must cancel a pending request before submitting another position.
export function createRoomCounter(room,traffic,randomState,position) {
  kind(room);sourceRandom(randomState);
  return {room:room.index,traffic:validateRoomTraffic(room,traffic,position).state,
    randomState,position:{...position},service:'idle',conversation:null,...(room.index===1 ? {lodging:initialLodging()} : {})};
}

// Game18 procedure26's release at inclusive counter bounds. Repeated browser
// requests are idempotent; native button-edge handling prevented those repeats.
export function requestRoomCounter(room,previous) {
  const frame=own(room,previous);
  if(frame.service==='talking')throw new Error('roomConversationActive');
  if(!atCounter(room,frame.position))throw new Error('notAtRoomCounter');
  if(frame.service!=='waiting'){frame.traffic.waiting++;frame.service='waiting'}
  return frame;
}

// Procedure26 cancels staff following actor1 when movement starts. Native leaves
// a stale waiting count; keep the browser's count equal to actual waiting actors.
export function cancelRoomCounter(room,previous) {
  const frame=own(room,previous);
  if(frame.service==='talking')throw new Error('roomConversationActive');
  if(frame.service==='waiting')frame.traffic.waiting--;
  const counter=frame.traffic.actors.at(-1).words;
  if(counter[9]===1){counter[9]=0;counter[7]&=~32}
  frame.service='idle';return frame;
}

export function moveRoomCounter(room,previous,position) {
  const frame=cancelRoomCounter(room,previous);
  // Validate the caller's completed walk step before publishing cancellation.
  validateRoomTraffic(lodgingGeometry(room,frame.lodging),frame.traffic,position,
    {service:frame.service,playerRoom:lodgingGeometry(room,frame.lodging,{access:true})});
  frame.position={...position};return frame;
}

export function tickRoomCounter(room,previous) {
  const frame=own(room,previous);
  if(frame.service==='talking')return frame; // Game18 has yielded to Game16.
  if(room.index===1)frame.lodging=updateLodgingAccess(room,frame.lodging,frame.position).lodging;
  const next=tickRoomTraffic(lodgingGeometry(room,frame.lodging),frame.traffic,frame.randomState,frame.position,{service:frame.service});
  frame.traffic=next.state;frame.randomState=next.randomState;frame.service=next.service;
  return frame;
}

// Game18 procedure23 dispatches types9/10/11 as kinds13/14/23 and prepares workspace
// from counter actor0. Campaign context supplies city/hour/cash/system/attributes.
export function openRoomCounter(content,room,previous,context,{places}={}) {
  const frame=own(room,previous);
  if(frame.service!=='talking'||frame.conversation!==null)throw new Error('roomCounterNotReady');
  const counter=frame.traffic.actors.at(-1).words;
  const setup=setupCounterDialogue({...context,kind:kind(room),randomState:frame.randomState,
    workspace:{...context.workspace,item:counter[8]>>>8,mood:counter[8]&255,actor:0,quantity:1,gate:Number(!!(counter[7]&2))}});
  frame.conversation=startCounterConversation(content,setup,{places});
  frame.randomState=frame.conversation.randomState;return frame;
}

export function advanceRoomCounter(content,room,previous,input) {
  const frame=own(room,previous);
  if(!frame.conversation||frame.conversation.randomState!==frame.randomState)throw new Error('roomCounterNotReady');
  frame.conversation=advanceDialogue(content,frame.conversation,input);
  frame.randomState=frame.conversation.randomState;
  if(!frame.conversation.ended)return {frame,outcome:null};
  // Lodging consumes flag65 locally; other kinds still need R07/R10 return handling.
  if(frame.conversation.state.flags[65]&&room.index!==1)throw new Error('unsupportedRoomDialogueReturn');
  const outcome=structuredClone(frame.conversation.state),counter=frame.traffic.actors.at(-1).words;
  if(outcome.flags[65]) {
    const rented=rentLodging(frame.lodging,frame.randomState);
    frame.lodging=rented.lodging;frame.randomState=rented.randomState;outcome.flags[65]=false;
  }
  // Game18 procedure21 restores actor0's low mood byte and bit1 greeting gate,
  // then clears the four transient dialogue return flags48..51.
  counter[8]=(counter[8]&0xff00)|outcome.workspace.mood;
  counter[7]=outcome.workspace.gate ? counter[7]|2 : counter[7]&~2;
  outcome.flags.fill(false,48,52);
  frame.conversation=null;frame.service='served';
  return {frame,outcome}; // The host must commit the outcome with its campaign atomically.
}
