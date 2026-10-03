import { fitsComponent, recalculateEquipment } from './equipment.js';
import { sourceRandom } from './random.js';

const integer=(v,min,max)=>Number.isInteger(v)&&v>=min&&v<=max;
const slot=n=>integer(n,0,18)&&n%5<4;
const fail=()=>{throw new Error('invalidEquipmentFailure')};
function snapshot(value) {
  const g=value?.group;
  if(!g||!Array.isArray(g.units)||g.units.length!==4||
    !g.units.every(u=>Array.isArray(u.components)&&u.components.length===4&&u.components.every(b=>integer(b,0,255)))||
    !Array.isArray(g.spares)||g.spares.length!==4||!g.spares.every(b=>integer(b,0,31))||
    !integer(g.requiredSocket,0,3)||!integer(g.requiredComponent,0,31)||
    !(value.pendingFailure===31||slot(value.pendingFailure)))fail();
  return structuredClone(value);
}
const component=(g,n)=>g.units[Math.floor(n/5)].components[n%5];
const write=(g,n,b)=>{g.units[Math.floor(n/5)].components[n%5]=b};

// Byte25 is a pending *failure* offset, not a repair timer. It uses the
// original five-byte row stride;31 means no pending failure.
export function createEquipmentFailureState(group) {
  return snapshot({group:recalculateEquipment(group),pendingFailure:31});
}

// Game14 proc8 $05B9–$05F2. Fit is tested on the low five bits (proc11).
// Recalculate BEFORE restoring the faulty byte. The temporary output really
// exists in the source; a later engineering tick invalidates it.
// The campaign host must own inventory transfer/access and both destinations.
export function installEquipmentComponent(previous,offset,byte) {
  const next=snapshot(previous);
  if(!slot(offset)||!integer(byte,0,255)||
    (byte!==0&&!fitsComponent(next.group,byte&31,offset%5)))fail();
  write(next.group,offset,byte&31);
  next.group=recalculateEquipment(next.group);
  if(byte>127) {next.pendingFailure=offset;write(next.group,offset,byte)}
  return next;
}

// Game14 proc7 $0513–$053E. Entering/cycling a frame clears byte25 and
// displays installed bytes>144 as destroyed7. The original does not recompute
// the displayed performance here; preserve that ordering in this source core.
export function enterEquipmentFrame(previous) {
  const next=snapshot(previous);next.pendingFailure=31;
  for(const u of next.group.units)for(let s=0;s<4;s++)if(u.components[s]>144)u.components[s]=7;
  return next;
}

// Game14 proc9/10 $06AE–$070F: burn the marked offset first, then remaining
// high-bit bytes in descending offset order. Recompute only after the sweep.
export function resolveEquipmentFailures(previous) {
  const next=snapshot(previous),destroyed=[];
  if(next.pendingFailure!==31) {
    const burn=n=>{write(next.group,n,7);destroyed.push(n)};
    burn(next.pendingFailure);next.pendingFailure=31;
    for(let n=18;n>=0;n--)if(slot(n)&&component(next.group,n)>127)burn(n);
    next.group=recalculateEquipment(next.group);
  }
  return {state:next,destroyed};
}

// Library24 proc13 $09B1–$0A07, after combat chooses a group/slot. This is
// only the component-hit operation, not an invented landed combat producer.
// A shunt hit makes20 eager RNG draws, including the four performance bytes.
export function hitEquipmentComponent(previous,offset,randomState) {
  const next=snapshot(previous),rng=sourceRandom(randomState);
  if(!slot(offset))fail();
  const byte=component(next.group,offset);let draws=0;
  if(byte===23)for(let n=0;n<20;n++) {
    const roll=rng.next();draws++;
    if(slot(n)&&component(next.group,n)===23&&(roll&1))write(next.group,n,151);
  }
  if(byte>7&&byte<128) {
    next.pendingFailure=offset;write(next.group,offset,byte+128);
    next.group=recalculateEquipment(next.group);
  }
  return {state:next,randomState:rng.state,draws};
}

// Library24 proc8 $0177–$0181,$01F8–$0260. Flags0–5 are system power,
// flags8–13 special-feature controls, flags16–21 working special availability.
// Resource words are deliberately named by source offset until the live
// machinery owner connects them:222 warp target,224 shield target,226 guns.
export function equipmentDependencyResult(groups,previous) {
  if(!Array.isArray(groups)||groups.length!==6||!Array.isArray(previous?.flags)||previous.flags.length!==128||
    !previous.flags.every(b=>typeof b==='boolean')||![222,224,226].every(n=>integer(previous.words?.[n],0,255)))fail();
  const next=structuredClone(previous);
  groups.forEach((g,i)=>{
    if(!integer(g.performance,0,16)||typeof g.specialAvailable!=='boolean')fail();
    next.flags[16+i]=g.specialAvailable;
    if(g.performance===0) {
      next.flags[i]=false;
      const word=({0:222,2:226,4:224})[i];if(word)next.words[word]=0;
    }
    if(!g.specialAvailable)next.flags[8+i]=false;
  });
  return next;
}
