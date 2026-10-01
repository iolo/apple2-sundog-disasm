import { validateRoomTraffic, tickRoomTraffic, sitRoomTraffic, finishTavernContact } from './room-traffic.js';
import { isTavern, playerSeatAt } from './room-seating.js';
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
  if(room&&isTavern(room))return 12;
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
  if(isTavern(room)&&playerSeatAt(room,frame.position)!==null) {
    frame.traffic=sitRoomTraffic(room,frame.traffic,frame.position,{service:frame.service,solicitation:frame.solicitation});
    if(frame.traffic.tavern.contact)frame.service='talking';
    return frame;
  }
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
  if(isTavern(room))frame.traffic.tavern.playerSeat=null;
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
  const next=tickRoomTraffic(lodgingGeometry(room,frame.lodging),frame.traffic,frame.randomState,frame.position,{service:frame.service,solicitation:frame.solicitation});
  frame.traffic=next.state;frame.randomState=next.randomState;frame.service=next.service;
  if(frame.traffic.tavern?.contact)frame.service='talking';
  return frame;
}

// Game18 procedure23 dispatches counter actor0 or the pending seated contact.
// Campaign context supplies city/hour/cash/system/attributes.
export function openRoomCounter(content,room,previous,context,{places}={}) {
  const frame=own(room,previous);
  if(frame.service!=='talking'||frame.conversation!==null)throw new Error('roomCounterNotReady');
  const contact=frame.traffic.tavern?.contact,slot=contact?.actor??0;
  const speaker=frame.traffic.actors.find(a=>a.slot===slot).words;
  const setup=setupCounterDialogue({...context,kind:contact?.kind??kind(room),randomState:frame.randomState,
    workspace:{...context.workspace,item:speaker[8]>>>8,mood:speaker[8]&255,actor:slot,quantity:1,gate:Number(!!(speaker[7]&2))}});
  frame.conversation=startCounterConversation(content,setup,{places});
  frame.randomState=frame.conversation.randomState;return frame;
}

// Historical save scopes retain their original purchase/trader input gates.
export function roomDialogueInputAllowed(conversation,input,{purchases=true,visitorTrades=true,traderMatching=true}={}) {
  const kind=conversation.state.kind;
  if(kind===17&&!traderMatching)return false;
  if(!purchases&&input.type==='purchase')return false;
  if(!visitorTrades&&(input.type==='sale'||([17,21,22].includes(kind)&&input.type==='purchase')))return false;
  if(![12,17,21,22].includes(kind))return true;
  if(kind===12&&input.type==='item')return purchases&&(traderMatching||[8,9].includes(input.item));
  if((kind!==12&&visitorTrades)||(kind===12&&traderMatching))return true;
  if(input.type!=='reply')return true;
  const reply=conversation.view.replies.find(r=>r.slot===input.slot);
  return !reply||(![8,9].includes(reply.caption)&&!(kind!==12&&reply.caption===2));
}

export function advanceRoomCounter(content,room,previous,input,options) {
  const frame=own(room,previous);
  if(!frame.conversation||frame.conversation.randomState!==frame.randomState)throw new Error('roomCounterNotReady');
  if(!roomDialogueInputAllowed(frame.conversation,input,options))throw new Error('unsupportedRoomTrade');
  frame.conversation=advanceDialogue(content,frame.conversation,input);
  frame.randomState=frame.conversation.randomState;
  if(!frame.conversation.ended)return {frame,outcome:null};
  // Lodging consumes flag65; taverns keep it pending for visitor matching.
  if(frame.conversation.state.flags[65]&&room.index!==1&&!isTavern(room))throw new Error('unsupportedRoomDialogueReturn');
  const outcome=structuredClone(frame.conversation.state),contact=frame.traffic.tavern?.contact;
  if(outcome.flags[65]&&room.index===1) {
    const rented=rentLodging(frame.lodging,frame.randomState);
    frame.lodging=rented.lodging;frame.randomState=rented.randomState;outcome.flags[65]=false;
  }
  frame.solicitation=outcome.flags[65] ? {item:outcome.workspace.item} : null;
  // Game18 procedure21 restores NPC motion before writing back the actual
  // speaker's mood/gate and clearing the transient return flags48..51.
  if(contact) {
    const next=finishTavernContact(room,frame.traffic,frame.randomState,frame.position,
      {dismiss:outcome.flags[49],service:frame.service,solicitation:frame.solicitation});
    frame.traffic=next.state;frame.randomState=next.randomState;
  }
  const speaker=frame.traffic.actors.find(a=>a.slot===(contact?.actor??0)).words;
  speaker[8]=(speaker[8]&0xff00)|outcome.workspace.mood;
  speaker[7]=outcome.workspace.gate ? speaker[7]|2 : speaker[7]&~2;
  outcome.flags.fill(false,48,52);
  frame.conversation=null;frame.service=contact ? 'idle' : 'served';
  return {frame,outcome}; // The host must commit the outcome with its campaign atomically.
}
