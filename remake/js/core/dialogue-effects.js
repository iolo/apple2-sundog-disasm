import { sourceRandom } from './random.js';
import { evaluateDialoguePredicate, refreshDialoguePrice } from './dialogue-state.js';

const integer=(n,min,max)=>Number.isInteger(n)&&n>=min&&n<=max;
const money=n=>{if(!integer(n,0,32767999))throw new Error('unsupportedDialogueMoney');return n};

// All mutations below are confined to an owned frame. Public reducers clone
// first; the conversation runner also owns its frame until the whole step succeeds.
export function dialogueEffects(frame,items) {
  const s=frame.state,v=s.locals;
  function next(){const rng=sourceRandom(frame.randomState),n=rng.next();frame.randomState=rng.state;return n}
  function predicate(code) {
    const result=evaluateDialoguePredicate(code,s,frame.randomState,items);
    Object.assign(v,result.state.locals);
    s.attributes=result.state.attributes;s.flags=result.state.flags;s.workspace=result.state.workspace;
    frame.randomState=result.randomState;return result.value;
  }
  const price=()=>refreshDialoguePrice(v,s.flags,items);
  function itemList(first,last) {
    if(last===0)last=14; // Procedure7's special blank-list path.
    if(!integer(first,0,255)||!integer(last,first,255)||last-first>31)throw new Error('unsupportedDialogueItemList');
    v[46]=first;
    frame.panel={kind:'items',items:Array.from({length:last-first+1},(_,i)=>first ? first+i : 0)};
  }
  function chooseItem() {
    if(v[41]===0) {
      const high=s.kind===17 ? 22 : s.kind===15 ? 18 : 31,seen=new Set();
      for(;;) {
        if(seen.has(frame.randomState))throw new Error('dialogueItemUnavailable');
        seen.add(frame.randomState);v[41]=12+next()%(high-11);
        const flag=s.flags[80+v[41]],accept=v[41]<14||v[41]>22 ? !flag : flag;
        if(accept)break;
      }
    }
    if(s.kind>=17) {
      v[4]=20;v[5]=24+next()%(v[41]>22 ? 2 : 12);
      const attribute=predicate(30),chance=predicate(166); // Eager OR, even for item<=14.
      if(v[41]>14&&!attribute&&!chance)v[41]+=128;
      if(v[18]){v[36]=-1;[v[4],v[5]]=[v[5],v[4]]}else v[36]=1;
    }
    price();
    if(s.kind===15){v[100]=0;v[106]=0;v[108]='0 Cr'} // Procedure3(0,true).
  }
  function controls(code) {
    if(!integer(code,0,255))throw new Error('invalidDialogueControls');
    if(code&1)v[20]=true;
    if(code&2)v[15]=true;
    const mood=(code>>2)&3;
    v[33]=Math.max(0,Math.min(4,mood===3 ? 4 : v[33]+(mood===1 ? 1 : mood===2 ? -1 : 0)));
    if(code&16){v[41]=0;v[18]=false}
    if(code&32)chooseItem();
    switch(code>>6) {
      case 1:v[104]=money(v[104]-v[100]);break;
      case 2:v[104]=money(v[104]+v[100]);break;
      case 3:v[100]=v[102];break;
    }
  }
  function action(record) {
    if(!record)return;
    const {opcode,operands:a}=record,arity=[0,1,2,4,0,1,1,1];
    if(!integer(opcode,0,7)||!Array.isArray(a)||a.length!==arity[opcode]||!a.every(n=>integer(n,0,255)))
      throw new Error('invalidDialogueAction');
    switch(opcode) {
      case 0:
        frame.panel={kind:'offer'};frame.offerControls=true;v[95][0]=1;v[95][1]=2;
        if(frame.view)frame.view.replies=frame.view.replies.filter(r=>r.slot>=2);
        v[106]=money(v[30]*(5+next()%63));v[17]=true;break;
      case 1:{
        let shown=0;
        if(!v[18]) {
          if(v[41]===0) {
            if(!integer(v[35],32,63))throw new Error('missingDialogueItemSelection');
            v[41]=v[35]-32;
          }
          if(v[41]===11||v[41]===13)v[41]+=224;
          shown=v[41];
        }
        if(s.kind!==15)price();
        itemList(shown,shown);v[95][0]=a[0];break;
      }
      case 2:case 3:
        v[18]=opcode===2;v[19]=true;v[95][0]=a[0];v[95][1]=a[1];
        if(opcode===3) {
          v[28]=a[2];v[27]=a[3];
          if(v[27]<v[28]) {
            if(!integer(v[27],0,2))throw new Error('unsupportedDialogueItemList');
            v[27]=v[87][v[27]];
          }
          itemList(v[28],v[27]);
        }else frame.panel={kind:'inventory',items:[...s.carried]};
        break;
      case 4:break;
      case 5:case 6:case 7:v[53][opcode-5]=a[0];break;
    }
  }
  function builtin(code,step) {
    if(!integer(code,0,15))throw new Error('unsupportedDialogueState');
    switch(code) {
      case 0:case 4:
        s.flags[49]=true;frame.ended=true;
        if(code===4) {
          if(!v[18]&&v[41]<23&&s.kind===17)s.flags[80+v[41]]=!!(next()&1);
          s.workspace.gate=0;s.workspace.item=0;s.flags[65]=false;s.flags[66]=false;
        }
        break;
      case 1:case 2:
        if(![1,10,100,1000,10000].includes(step))throw new Error('missingDialogueOfferStep');
        v[43]++;
        if(code===1){if(money(v[100]+step)<=v[104])v[100]+=step}
        else v[100]=step>v[100] ? v[102] : v[100]-step;
        break;
      case 3:frame.ended=true;s.flags[65]=true;s.flags[66]=v[18];s.workspace.item=v[41];break;
      case 5:case 6:frame.ended=true;s.flags[51]=code===5;break;
      case 7:frame.ended=true;s.flags[50]=s.flags[48]=s.flags[49]=false;break;
      case 8:frame.ended=true;s.flags[48]=true;break;
      case 9:case 10:case 11:return v[53][code-9];
    }
    return null;
  }
  return {predicate,controls,action,builtin};
}

// Small independently testable wrappers for the source handlers.
export function reduceDialogueEffect(previous,operation,items) {
  const frame=structuredClone(previous),handlers=dialogueEffects(frame,items);
  let redirect=null;
  if(operation.type==='controls')handlers.controls(operation.code);
  else if(operation.type==='action')handlers.action(operation.action);
  else if(operation.type==='builtin')redirect=handlers.builtin(operation.code,operation.step);
  else throw new Error('invalidDialogueOperation');
  return {frame,redirect};
}
