import { sourceRandom } from './random.js';

const integer=(n,min,max)=>Number.isInteger(n)&&n>=min&&n<=max;
const list=(a,length,test)=>Array.isArray(a)&&a.length===length&&Array.from(a).every(test);
const byte=n=>integer(n,0,255);
const money=n=>integer(n,0,32767999); // Canonical positive library28 thousands/remainder pair.

// Game16 procedures37/38/39, restricted to fresh counter kinds13/14. Numeric
// local identities keep unproven field names out of gameplay semantics.
export function setupCounterDialogue(input) {
  const {kind,system,attributes,carried,flags,workspace,city,hour,surface,cash,randomState}=input??{};
  if(![13,14].includes(kind)||typeof system?.local16!=='boolean'||
    ![29,30,31,32].every(n=>integer(system[`local${n}`],0,15))||
    !list(attributes,5,byte)||!list(carried,4,byte)||!list(flags,128,b=>typeof b==='boolean')||
    !integer(workspace?.lastCity,0,63)||!integer(workspace?.mood,0,4)||
    !byte(workspace?.quantity)||!byte(workspace?.gate)||!integer(city,1,63)||!integer(hour,0,23)||
    !integer(surface?.x,0,63)||!integer(surface?.y,0,31)||!money(cash))throw new Error('invalidDialogueSetup');
  sourceRandom(randomState); // Validate, but do not draw: setup38 is a flag-fill loop.
  const thresholds=[11+Math.trunc((16-system.local32)/6),15+Math.trunc((16-system.local32)/2),
    23+2*Math.trunc((system.local31-1)/3)];
  const nextFlags=[...flags],nextWorkspace={...workspace};
  const fill=(first,last,from,to)=>{for(let bit=first;bit<=last;bit++)nextFlags[bit]=from++<=to};
  nextFlags[117]=false;fill(88,89,8,9);
  if(workspace.lastCity!==city) {
    nextFlags[80]=hour<3||hour>6;
    fill(90,94,10,thresholds[0]);fill(95,102,15,thresholds[1]);fill(103,111,23,thresholds[2]);
    nextWorkspace.lastCity=city;
  }
  let count6=0,count7=0;
  for(const item of carried) {
    if(item===12)count7++;
    else if((item&31)===13)count7+=2;
    else if((item&31)===11)count6+=2;
  }
  return {randomState,state:{kind,entry:kind===13 ? 80 : 81,attributes:[...attributes],carried:[...carried],flags:nextFlags,
    workspace:nextWorkspace,locals:{
      4:26+(surface.x+surface.y)%9,5:30,6:count6,7:count7,14:0,15:false,16:system.local16,
      17:null,18:false,20:workspace.gate!==0,29:system.local29,30:system.local30,
      31:system.local31,32:system.local32,33:workspace.mood,36:null,40:system.local30,41:0,
      53:[0,0,0],87:thresholds,100:0,102:0,104:cash,106:0,108:'',124:''}}};
}

// Game16 procedures2/3, mode0. Refresh the working valuation and strings;
// local100 (the offered amount) is deliberately left unchanged.
export function refreshDialoguePrice(v,flags,items) {
  const index=v[41]&31,item=items?.[index];
  if(!item||item.sourceIndex!==index||!byte(item.valueByte)||typeof item.name!=='string')
    throw new Error('missingDialogueItems');
  if(!integer(v[30],0,15))throw new Error('invalidDialoguePredicateState');
  v[5]=Math.max(0,v[5]);v[4]=Math.max(1,v[4]);
  if(v[5]*v[30]>32767)throw new Error('unsupportedDialogueValuation');
  let scale=Math.trunc(v[5]*v[30]/v[4]),value=item.valueByte,cap;
  if(index>=15&&index<=22){cap=42;value*=3}
  else if(!flags[80+index]){cap=64;value*=2}
  else cap=128;
  scale=Math.max(1,Math.min(cap,scale));
  const price=scale*value;
  if(price>32767)throw new Error('unsupportedDialogueValuation');
  v[106]=price;v[108]=`${price} Cr`;v[124]=item.name;
}

// Game16 procedures8/9/10. This runs on owned interpreter state and never
// commits campaign money, attributes or flags. Items are needed only when
// predicate7 actually refreshes a price.
export function evaluateDialoguePredicate(code, previous, randomState, items) {
  const l=previous?.locals;
  if(!integer(code,-32768,255)||!integer(previous?.kind,0,255)||
    !list(previous?.attributes,5,byte)||!list(previous?.flags,128,b=>typeof b==='boolean')||
    !byte(previous?.workspace?.quantity)||!l||![4,5].every(n=>integer(l[n],-32768,32767))||
    ![6,7].every(n=>integer(l[n],0,8))||!integer(l[29],0,15)||!integer(l[33],0,4)||!byte(l[41])||
    ![18,20].every(n=>typeof l[n]==='boolean')||![100,102,104,106].every(n=>money(l[n])))
    throw new Error('invalidDialoguePredicateState');
  const state=structuredClone(previous),v=state.locals,random=sourceRandom(randomState);
  let draws=0;
  const next=()=>{draws++;return random.next()};
  const chance=threshold=>next()%100<threshold; // Always draws, including thresholds0/100.
  const attribute=(index,offset)=>{
    const value=chance(state.attributes[index]+offset);
    if(index===4)state.attributes[4]=Math.trunc(state.attributes[4]/2);
    return value;
  };
  const fallback=()=>attribute(4,40);
  let result=false,branch=code,index=0,threshold=0;
  if(code===0)result=true;
  else if(code>0) {
    if(code>=200){index=code-200;branch=20}
    else if(code>=100){threshold=code-100;branch=19}
    else if(code>=90){index=code-90;branch=15}
    else if(code>=20) {
      threshold=(code%10||10)*10;index=Math.trunc((code-20)/10);
      branch=index>=4 ? index+13 : 16;
    }
    switch(branch) {
      case 1:
        if(attribute(3,40)){v[17]=false;result=chance(v[33]*15)||fallback()}
        break;
      case 2:result=v[33]===0;break;
      case 3:result=v[104]===v[102]||attribute(3,40);break;
      case 4:result=v[20];break;
      case 5:result=attribute(4,0);break;
      case 6:result=v[18];break;
      case 7:
        if(v[5]!==v[4]) {
          const distance=Math.abs(v[5]-v[4]);
          if(distance>32767)throw new Error('unsupportedDialogueValuation');
          if(next()%10<distance) {
            if(![-1,1].includes(v[36]))throw new Error('missingDialogueValuation');
            v[5]-=v[36]*(1+next()%Math.min(distance,4));
            if(!integer(v[5],-32768,32767))throw new Error('unsupportedDialogueValuation');
            refreshDialoguePrice(v,state.flags,items);result=true;
          }
        }
        break;
      case 8:
        if(v[106]>v[100])v[106]-=v[100];else result=true;
        break;
      case 9:result=v[41]<128||(v[41]&31)<15;break;
      case 10:result=chance(20*(v[7]+v[6]-state.workspace.quantity));break;
      case 11:
        result=state.flags[80]||attribute(3,-20);
        if(result)state.flags[80]=true;
        break;
      case 12:case 13:case 14:break;
      case 15:result=state.kind===index+12;break;
      case 16:result=attribute(index,threshold-60)||fallback();break;
      case 17:result=chance(threshold+(v[33]-2)*20)||fallback();break;
      case 18:{
        const systemCheck=chance(v[29]*10),secondCheck=chance(threshold);
        result=systemCheck&&secondCheck;break; // Pascal LAND evaluates both draws.
      }
      case 19:result=chance(threshold);break;
      case 20:result=v[41]===index;break;
    }
  }
  return {value:result,state,randomState:random.state,draws};
}
