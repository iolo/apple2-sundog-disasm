import { dialogueRecord, selectDialogueValue, dialogueTransition } from './dialogue.js';
import { dialogueDictionary, dialogueCaption, renderDialogueMessage } from './dialogue-text.js';
import { dialogueEffects } from './dialogue-effects.js';
import { sourceRandom } from './random.js';
import { saleItem } from './personal-trade.js';

// Source procedure34's redirect loop, with procedure23's exact ordering:
// controls -> selection -> rendering -> transition predicates -> replies -> action.
export function enterDialogueState(content,previous,target,{offerStep}={}) {
  if(previous.ended)throw new Error('dialogueAlreadyEnded');
  const frame=structuredClone(previous),s=frame.state,v=s.locals;
  const handlers=dialogueEffects(frame,content.items);
  for(let hops=0;hops<64;hops++) {
    if(!Number.isInteger(target)||target<0||target>223)throw new Error('unsupportedDialogueState');
    if(target<16) {
      const redirect=handlers.builtin(target,offerStep);
      if(redirect!==null){target=redirect;continue}
      v[44]=target;
      // Procedure47's non-graphical return state, without committing cash or
      // equipment to a live campaign. Its gate write follows builtin4's clear.
      if(frame.ended) {
        if(s.kind!==19)v[104]=Math.max(v[104],v[102]);
        s.workspace.mood=v[33];s.workspace.gate=Number(v[20]);
      }
      return frame;
    }
    const record=dialogueRecord(content.scripts,target);
    if(frame.block!==record.block){frame.dictionary=dialogueDictionary(content.text,record.block,frame.dictionary);frame.block=record.block}
    v[19]=false;v[43]=record.delayUnits;frame.offerControls=false;
    handlers.controls(record.controls);
    // Selector predicates can update attributes/flags. The selector context only
    // owns the independent random-index/reuse locals14/15.
    const random={next(){const r=sourceRandom(frame.randomState),n=r.next();frame.randomState=r.state;return n}};
    const selected=selectDialogueValue(record.selection,{mood:v[33],gate:v[20],randomIndex:v[14],reuseRandom:v[15]},random,handlers.predicate);
    v[14]=selected.context.randomIndex;v[15]=selected.context.reuseRandom;
    if(record.redirect){handlers.action(record.action);target=selected.value;continue}
    const rendered=renderDialogueMessage(content.text,frame.dictionary,record.block,selected.value,frame.randomState,{
      mood:v[33],mode18:v[18],workspace11:s.workspace.quantity,strings:{108:v[108],124:v[124]},places:frame.places});
    frame.randomState=rendered.randomState;
    // Predicates replace owned locals (including arrays); assign only after
    // evaluation so the write cannot land in an obsolete targets array.
    for(let i=0;i<2;i++) {
      const target=dialogueTransition(record.transitions[i],handlers.predicate);
      v[95][3+i]=target;
    }
    v[95].fill(-1,0,3); // Procedure27 clears unavailable reply targets.
    const replies=record.replies.map((reply,i)=>{
      const slot=3-record.replies.length+i,target=dialogueTransition(reply.transition,handlers.predicate);
      v[95][slot]=target;
      return {slot,caption:reply.caption,text:dialogueCaption(frame.dictionary,reply.caption),target};
    });
    frame.view={state:target,word:selected.value,text:rendered.text,replies,
      ...(rendered.chosenPlaces ? {chosenPlaces:rendered.chosenPlaces} : {})};
    handlers.action(record.action);
    for(const reply of frame.view.replies)reply.target=v[95][reply.slot];
    v[44]=target;return frame;
  }
  throw new Error('dialogueRedirectLimit');
}

export function startCounterConversation(content,setup,{places}={}) {
  const frame={state:structuredClone(setup.state),randomState:setup.randomState,
    dictionary:structuredClone(content.text.base),block:null,panel:null,view:null,ended:false,places};
  Object.assign(frame.state.locals,{19:false,43:0,95:[0,0,0,0,0]});
  frame.state.sales=[];
  return enterDialogueState(content,frame,frame.state.entry);
}

// An action1 display is the native draggable offer. Never infer acceptance
// from a stale panel left over by a quote, information or impatience record.
export function dialoguePurchase(content,frame) {
  const s=frame.state,v=s.locals;
  if(frame.ended||![12,13,14,17,21,22].includes(s.kind)||v[18]||v[19]||
    !frame.view||frame.view.state<16||dialogueRecord(content.scripts,frame.view.state).action?.opcode!==1)return null;
  const item=frame.panel?.items?.[0];
  if(frame.panel?.items?.length!==1||!Number.isInteger(item)||item<=7||item>255||
    (s.kind===12&&![8,9].includes(item)))return null;
  return {item,price:v[106],cash:v[104]};
}

export function dialogueSale(content,frame) {
  const s=frame.state,v=s.locals;
  if(frame.ended||![17,21,22].includes(s.kind)||!v[18]||v[19]||!saleItem(v[41]&255)||
    !frame.view||frame.view.state<16||dialogueRecord(content.scripts,frame.view.state).action?.opcode!==1)return null;
  // Source local41 is a word: appraisal can add128 to an already charged byte.
  // Only the type selects a sale; the chosen inventory byte is handed over.
  return {item:v[41]&255,price:v[106],cash:v[104]};
}

// Explicit browser inputs replace pointer hit-testing and CPU-loop timing.
// Timeout is a caller event in source delay units, not a wall-clock assertion.
export function advanceDialogue(content,previous,input) {
  if(previous.ended||!previous.view)throw new Error('dialogueAlreadyEnded');
  const frame=structuredClone(previous),s=frame.state,v=s.locals;
  let target,offerStep;
  switch(input.type) {
    case 'sale':{
      const offer=dialogueSale(content,frame),item=s.carried[input.slot];
      if(!offer||!Number.isInteger(input.slot)||input.slot<0||input.slot>=4||!saleItem(item)||(item&31)!==(offer.item&31))
        throw new Error('invalidDialogueSale');
      if(!Number.isInteger(offer.price)||offer.price<0||offer.price>32767)throw new Error('unsupportedDialogueMoney');
      if(offer.cash+offer.price>32767999)throw new Error('dialogueCashOverflow');
      s.carried[input.slot]=0;v[104]+=offer.price;v[43]+=2;v[41]=item;
      s.sales.push({item,price:offer.price});target=v[95][0];break;
    }
    case 'purchase':{
      const offer=dialoguePurchase(content,frame);
      if(!offer||!Number.isInteger(input.slot)||input.slot<0||input.slot>=4)throw new Error('invalidDialoguePurchase');
      if(s.carried[input.slot]!==0)throw new Error('dialogueSlotOccupied');
      if(!Number.isInteger(offer.price)||offer.price<0||offer.price>32767999)throw new Error('unsupportedDialogueMoney');
      if(offer.price>offer.cash)throw new Error('dialogueInsufficientCash');
      // Game16 procedures40–43: transfer the complete byte, pay price106,
      // extend delay, then execute the action's continuation (usually9 or16).
      s.carried[input.slot]=offer.item;v[104]-=offer.price;v[43]+=2;
      v[41]=offer.item;target=v[95][0];break;
    }
    case 'reply':{
      const reply=frame.view.replies.find(r=>r.slot===input.slot);
      if(!reply)throw new Error('invalidDialogueReply');
      v[35]=reply.caption;target=reply.target;break;
    }
    case 'cancel':target=v[95][3];break;
    case 'timeout':target=v[95][4];break;
    case 'offer':
      if(!frame.offerControls||!['increase','decrease'].includes(input.direction))throw new Error('invalidDialogueOffer');
      target=input.direction==='increase' ? 1 : 2;offerStep=input.step;break;
    case 'item':
      if(!v[19]||!frame.panel?.items?.includes(input.item)||!Number.isInteger(input.item)||input.item<=7)
        throw new Error('invalidDialogueItem');
      v[41]=input.item;
      target=v[95][Number(v[18] ? v[41]>=10 : s.flags[80+v[41]])];break;
    default:throw new Error('invalidDialogueInput');
  }
  return enterDialogueState(content,frame,target,{offerStep});
}
