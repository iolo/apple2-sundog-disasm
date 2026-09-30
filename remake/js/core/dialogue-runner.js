import { dialogueRecord, selectDialogueValue, dialogueTransition } from './dialogue.js';
import { dialogueDictionary, dialogueCaption, renderDialogueMessage } from './dialogue-text.js';
import { dialogueEffects } from './dialogue-effects.js';
import { sourceRandom } from './random.js';

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
    frame.view={state:target,word:selected.value,text:rendered.text,replies};
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
  return enterDialogueState(content,frame,frame.state.entry);
}

// Explicit browser inputs replace pointer hit-testing and CPU-loop timing.
// Timeout is a caller event in source delay units, not a wall-clock assertion.
export function advanceDialogue(content,previous,input) {
  if(previous.ended||!previous.view)throw new Error('dialogueAlreadyEnded');
  const frame=structuredClone(previous),s=frame.state,v=s.locals;
  let target,offerStep;
  switch(input.type) {
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
