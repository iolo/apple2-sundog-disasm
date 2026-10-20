import { validateCargoSlots } from './cargo.js';
import { sourceRandom } from './random.js';

const integer=(n,lo,hi)=>Number.isInteger(n)&&n>=lo&&n<=hi;
const fail=()=>{throw new Error('invalidShipPower')};
const cargoCopy=cargo=>validateCargoSlots(cargo,'pod',{auxiliaryFuel:true,salvage:true});

// Library24 proc16: consume the first auxiliary lot only when attached and
// working fuel <=0. Add255 BEFORE clamping; a deficit reduces the refill.
export function consumeAuxiliaryFuel(fuel,cargo,podAttached) {
  if(!integer(fuel,-32768,255)||typeof podAttached!=='boolean')fail();
  const next=cargoCopy(cargo);let consumedSlot=null;
  if(fuel<=0&&podAttached) {
    const i=next.findIndex(lot=>lot?.commodityId==='cargo-01');
    if(i!==-1){fuel+=255;next[i]=null;consumedSlot=i}
  }
  return {fuel:Math.max(0,fuel),cargo:next,consumedSlot};
}

// Game15 proc10, called by proc11's return-from-pod branch ($05EE–$060A).
// Unlike the machinery helper, this sets255 if fuel<5; it does not add255.
// Transport access and attachment must be established by the campaign host.
export function refuelOnPodDock(fuel,cargo) {
  if(!integer(fuel,0,255))fail();
  const next=cargoCopy(cargo);let consumedSlot=null;
  if(fuel<5) {
    const i=next.findIndex(lot=>lot?.commodityId==='cargo-01');
    if(i!==-1){fuel=255;next[i]=null;consumedSlot=i}
  }
  return {fuel,cargo:next,consumedSlot};
}

// Library24 proc14: signed step bounded by a target, including downward steps.
const delta=(current,step,target,direction)=>direction*(current+step)>direction*target?target-current:step;
const clamp=n=>Math.max(0,Math.min(255,n));

// Isolated Library24 proc15 power phase ($0BE2–$0DAA), after movement has
// supplied working fuel. Source flags/words match equipmentDependencyResult.
// The caller owns phase cycling, clock, movement, beacon arrival and combat.
// words227 is committed fuel; workingFuel may include this tick's movement cost.
export function stepShipPower(previous,performance,phase,workingFuel=previous?.words?.[227]) {
  if(!Array.isArray(previous?.flags)||previous.flags.length!==128||
    Object.keys(previous.flags).length!==128||!Array.from(previous.flags).every(v=>typeof v==='boolean')||
    ![222,223,224,225,226,227].every(n=>integer(previous.words?.[n],0,255))||
    ![349,350].every(n=>integer(previous.words?.[n],0,1))||
    !Array.isArray(performance)||performance.length!==6||Object.keys(performance).length!==6||
    !Array.from(performance).every(n=>integer(n,0,16))||!integer(phase,1,4)||!integer(workingFuel,-32768,255))fail();
  const next=structuredClone(previous),w=next.words,f=next.flags,rng=sourceRandom(next.randomState);
  next.cargo=cargoCopy(next.cargo);
  let fuel=workingFuel,draws=0;const consumedSlots=[];
  const refuel=()=>{
    const result=consumeAuxiliaryFuel(fuel,next.cargo,f[7]);fuel=result.fuel;next.cargo=result.cargo;
    if(result.consumedSlot!==null)consumedSlots.push(result.consumedSlot);
  };
  // Proc17 deducts cost and refuels before changing charge. Even a failed
  // refuel clamps to0, so its >=0 guard still permits the bounded charge step.
  const charge=(word,step,cost)=>{fuel-=cost;refuel();w[word]=clamp(w[word]+step)};
  // Pascal FJP tests bit0: this raw phase-word branch runs on phases1 and3.
  if(phase&1) {
    let change=0,cost=0;
    if(fuel>0&&performance[2]>0&&f[2]) {
      change=delta(w[226],(performance[2]+1)*16,255,1);if(change>0)cost=4;
    } else if(w[226]>0)change=-8;
    if(change!==0)charge(226,change,cost);
  }
  if(phase===2) {
    if(w[225]!==w[224])charge(225,delta(w[225],performance[4]*8,w[224],1),0);
    if(w[224]>0)fuel-=Math.floor((w[224]+1)/64);
  }
  if(phase===3&&f[12])fuel-=12;
  if(phase===4&&w[223]!==w[222]) {
    const before=w[223];let change,cost;
    if(before<w[222]) {
      const roll=rng.next()&15;draws++;
      change=roll<performance[0]?delta(before,8,w[222],1):0;cost=2;
    } else {change=delta(before,-4,w[222],-1);cost=0}
    charge(223,change,cost);
    if(w[349]===1&&f[0]&&w[223]===w[222]&&before<w[222])w[350]=1;
  }
  refuel();
  if(fuel===0&&w[227]>0) {
    // Preserve charged guns (index2); all other0..4 controls are cleared.
    // The source's extra index0 test is redundant with index!==2.
    for(let i=0;i<=4;i++)if(i!==2||(i===0&&w[223]<w[222])) {
      f[i]=false;f[8+i]=false;if(i===0)w[222]=0;
    }
    w[224]=0;
  }
  w[227]=fuel;next.randomState=rng.state;
  return {state:next,draws,consumedSlots};
}
