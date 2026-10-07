import { sourceRandom } from './random.js';
import { validateCargoSlots } from './cargo.js';
import { hitEquipmentComponent, equipmentDependencyResult } from './equipment-failures.js';

const integer=(n,lo,hi)=>Number.isInteger(n)&&n>=lo&&n<=hi;
const signed=n=>((n&65535)^32768)-32768;
const left=(n,bits)=>signed(n<<bits);
const fail=()=>{throw Error('invalidShipCombat')};
const dense=(v,length)=>Array.isArray(v)&&v.length===length&&Object.keys(v).length===length;

// Source-facing session for Library24 proc13 and Game12 proc7/21. The campaign
// adapter owns encounters, clock, location, resources and persistent loss ledgers.
function snapshot(value) {
  if(!value||!Array.isArray(value.flags)||value.flags.length!==128||
    Object.keys(value.flags).length!==128||!Array.from(value.flags).every(b=>typeof b==='boolean')||
    ![205,206].every(n=>integer(value.words?.[n],0,1023))||
    ![207,208,209].every(n=>integer(value.words?.[n],-4,4))||
    !integer(value.words?.[214],0,3)||!integer(value.words?.[215],-32768,32767)||
    !integer(value.words?.[216],0,255)||!integer(value.words?.[217],0,32767)||
    ![222,224,225,226].every(n=>integer(value.words?.[n],0,255))||
    !integer(value.words?.[347],0,1)||!integer(value.words?.[354],-32768,32767)||!integer(value.rangeMemory,0,255)||
    !integer(value.hull,0,16)||!integer(value.sceneHigh,0,15)||typeof value.shipWorld!=='boolean'||
    !dense(value.equipment,6)||
    !value.equipment.every(e=>integer(e.pendingFailure,0,31)&&
      (e.pendingFailure===31||e.pendingFailure%5<4&&e.pendingFailure<19)&&
      integer(e.group?.performance,0,16)&&typeof e.group?.specialAvailable==='boolean'&&
      integer(e.group.requiredSocket,0,3)&&integer(e.group.requiredComponent,0,31)&&
      dense(e.group.spares,4)&&e.group.spares.every(b=>integer(b,0,31))&&
      dense(e.group.units,4)&&
      e.group.units.every(u=>integer(u.performance,0,4)&&dense(u.components,4)&&
        u.components.every(b=>integer(b,0,255)))))fail();
  sourceRandom(value.randomState);
  const next=structuredClone(value);
  next.cargo=validateCargoSlots(value.cargo,'pod',{auxiliaryFuel:true});
  return next;
}
export { snapshot as snapshotShipCombat };
function randomFor(state) {
  let rng=sourceRandom(state.randomState),draws=0;
  return {next(){draws++;const n=rng.next();state.randomState=rng.state;return n},
    get draws(){return draws},range(lo,hi){return lo+this.next()%(hi-lo+1)},
    absorb(result){draws+=result.draws;state.randomState=result.randomState;rng=sourceRandom(result.randomState)}};
}

// Game12 proc22's Comm preparation; startup proc3 dispatches Game16 kind19.
export function prepareShipCommunication(previous) {
  const state=snapshot(previous),f=state.flags;
  if(!f[40]||f[47])throw Error('shipCommunicationUnavailable');
  f[35]=f[44]=true;f[48]=f[49]=f[50]=false;
  return {state,workspace:{item:0,mood:0,quantity:state.words[214]+1},kind:19,sceneMiddle:1};
}

// Game12 proc9 $0754–$07BE. Agree starts a six-tick cargo deadline; it does
// not transfer bank money, jettison automatically or grant a permanent truce.
export function resumeShipCommunication(previous,flags,randomState) {
  if(!previous?.flags?.[35]||!previous.flags[40]||previous.flags[47])throw Error('shipCommunicationUnavailable');
  const state=snapshot({...previous,flags,randomState}),f=state.flags;
  f[35]=f[44]=false;
  const communication={pending:false,ticks:0};
  if(f[49]){f[49]=false;state.words[215]=128;state.words[207]=2}
  else if(f[51]){communication.pending=true;communication.ticks=6;f[51]=false}
  else f[44]=true;
  f[41]=false;f[47]=true;
  return {state,communication};
}

// Game12 proc10 $0B8A–$0BAC, once after a due power tick. The zero test is
// performed before decrement, so aggression resumes on the following tick.
export function stepShipCommunication(previous,communication) {
  if(!communication||Object.keys(communication).length!==2||
    typeof communication.pending!=='boolean'||!integer(communication.ticks,0,6)||
    !communication.pending&&communication.ticks!==0)throw Error('invalidShipCommunication');
  const state=snapshot(previous),next={...communication};
  if(next.pending) {
    if(next.ticks>0)next.ticks--;
    else {next.pending=false;state.flags[44]=true}
  }
  return {state,communication:next};
}
function drift(value,type,rng) {
  const limit=4-type;
  return Math.max(-limit,Math.min(limit,value+rng.next()%(limit+1)-(limit>>1)));
}

// Library24 proc12 $04BA–$0621: engine-powered movement production. The
// non-arrival jump at $042D also reaches this gate. System nibbles3/7 come
// from the host; the historical API name `piracy` denotes the lower bound.
export function produceShipEncounter(previous,{cityPresent,system}={}) {
  const state=snapshot(previous),rng=randomFor(state),f=state.flags,w=state.words;
  if(typeof cityPresent!=='boolean'||!integer(system?.piracy,0,15)||!integer(system?.cooldown,0,15))fail();
  const nextSystem={...system};let produced=false;
  if(!f[40]&&!f[12]&&!f[36]) {
    const roll=rng.next()&15; // Eager LAND draws even when a city is present.
    const valuable=state.cargo.some(l=>l&&Number(l.commodityId.slice(6))>1&&Number(l.commodityId.slice(6))<31);
    if(!cityPresent&&roll===13&&valuable&&system.piracy<=(rng.next()&15)) {
      if(system.cooldown<=(rng.next()&7)) {
        w[214]=rng.next()&3;f[40]=f[41]=f[44]=true;f[45]=f[46]=f[47]=false;
        w[217]=state.rangeMemory=127;w[206]=rng.next()&1023;w[205]=rng.next()&1023;
        w[216]=rng.range(150,255);w[209]=w[208]=0;w[207]=-1;w[215]=40;produced=true;
      } else nextSystem.cooldown--;
    }
  }
  return {state,system:nextSystem,produced,draws:rng.draws};
}

// Library24 proc13 $0690–$0A8D. One tick, AFTER movement and power. Source
// coordinates wrap at1024, range bottoms at5, and all boolean RNG tests use bit0.
export function stepShipCombat(previous) {
  const state=snapshot(previous),rng=randomFor(state),w=state.words,f=state.flags;
  const events=[],hits=[];const health=w[216];
  if(w[217]>128||health===0){f[40]=false;events.push(health===0?'enemyDestroyed':'enemyEscaped')}
  if(w[215]>0&&state.sceneHigh!==1) {
    w[206]=(w[206]+left(w[209],3))&1023;w[205]=(w[205]+left(w[208],3))&1023;
    w[217]=Math.max(5,signed(w[217]+left(w[207],2)));w[215]=signed(w[215]-4);
  } else if(w[215]<=0) {
    w[209]=drift(w[209],w[214],rng);w[208]=drift(w[208],w[214],rng);
    const weak=health<rng.range(20,80),cloakRoll=rng.next()&1; // Eager source OR/LAND.
    if(weak||state.shipWorld||f[12]&&cloakRoll||f[29]) {
      w[207]=2;w[215]=130;f[44]=f[29]=false;if(f[12])f[46]=true;events.push('enemyRetreating');
    } else {
      const threshold=(state.rangeMemory+40)>>1;
      if(w[217]<40)w[207]=1;
      else if(w[217]>=threshold)w[207]=-1;
      else w[207]=(rng.next()&1)-1;
      if(w[207]<0)w[215]=w[217]-10;
      else {
        if(threshold===w[217])fail();
        w[215]=rng.next()%(threshold-w[217]);state.rangeMemory=threshold;
      }
      if(w[214]===0){w[207]=left(w[207],1);w[215]>>=1}
    }
  }
  // All three movement/aim branches jump to $084C, including a retreat.
  // Pending fire is resolved on every tick, not only when cooldown expires.
    if(f[45]) {
      f[45]=false;f[43]=true;
      const close=w[217]<rng.range(15,70),shotRoll=rng.next()&1;
      if(close&&shotRoll) {
        let strength=left(1+(rng.next()&3),9+left(w[214],1));
        if(strength<=0)strength=32767;
        if(w[217]===0)fail();
        const damage=Math.trunc(strength/w[217]);
        if(damage<=w[225]) {w[225]-=damage;hits.push({kind:'shield',damage});events.push('shieldHit')}
        else {
          let excess=damage-w[225];
          w[225]=0;
          do {
          let group=rng.next()&7;if(group===7)group=6;
          // The source retains the original record pointer on its zero-output
          // redirect to hull. A hit on an already inoperative group is fatal.
          const recordValue=group===6?state.hull:state.equipment[group].group.performance;
          const recordGroup=group;
          if(recordValue===0)group=6;
          if(group===6) {
            const remaining=Math.max(0,recordValue-(rng.next()%3+1));
            if(recordGroup===6)state.hull=remaining;
            hits.push({kind:'hull',damage:recordValue-remaining,
              ...(recordGroup!==6?{redirectedFrom:recordGroup}:{})});events.push('hullHit');
            if(remaining===0){w[347]=1;state.sceneHigh=12;excess=0;events.push('shipDestroyed')}
          } else {
            const g=state.equipment[group].group;let offset=5*(rng.next()&3)+g.requiredSocket;
            if(g.units[Math.floor(offset/5)].components[offset%5]!==g.requiredComponent)
              offset=5*Math.floor(offset/5)+(rng.next()&3);
            const byte=g.units[Math.floor(offset/5)].components[offset%5];
            const damaged=hitEquipmentComponent(state.equipment[group],offset,state.randomState);
            state.equipment[group]=damaged.state;rng.absorb(damaged);
            if(byte>7&&byte<128) {
              const source=equipmentDependencyResult(state.equipment.map(e=>e.group),state);
              state.flags=source.flags;state.words=source.words;
            }
            hits.push({kind:'component',group,offset});events.push('componentHit');
            excess=byte; // Source overwrites local12 with the selected byte.
          }
          excess-=512;
          } while(excess>0);
        }
      }
    } else if(f[44]&&!f[12]) {
      const close=w[217]<rng.range(15,70),shotRoll=rng.next()&1;
      f[45]=!!(close&&shotRoll);
    }
  state.words[216]=health; // Combat doesn't mutate enemy health; player shots do.
  return {state,draws:rng.draws,events,hits,hit:hits.at(-1)??null};
}

// Game12 proc7 $0296–$0461 and proc9 $04F2: actual charge expenditure and
// aimed/spray hit/damage. The host supplies dexterity, not a made-up aim rating.
export function fireShipGun(previous,{focused,dexterity}={}) {
  const state=snapshot(previous),w=state.words,f=state.flags,events=[];
  if(typeof focused!=='boolean'||!integer(dexterity,0,255))fail();
  if(state.equipment[2].group.performance===0||w[226]===0)throw Error('shipGunUnavailable');
  const miss=Math.abs(w[206]-512)+Math.abs(w[205]-512),accuracy=1+Math.trunc((5+dexterity)/10);
  const tolerance=Math.max(0,focused?accuracy-(w[217]>>5):2*accuracy-(w[217]>>4));
  let damage=0,hit=false,cooldownIncrement=0;
  if(f[40]) {
    state.rangeMemory=(state.rangeMemory+127)>>1;
    if(miss<=tolerance) {
      hit=true;w[215]=4;w[354]=signed(w[354]+1);
      const denominator=Math.max(1,focused?left(miss,4):left(w[217]+miss,1));
      const shift=5+(f[18]?1:0)-w[214];
      damage=Math.trunc(left(w[226]+1,shift)/denominator);
      w[216]=Math.max(0,w[216]-damage);events.push(w[216]===0?'enemyDestroyed':'enemyHit');
      if(w[216]===0){cooldownIncrement=w[214];for(let i=41;i<=47;i++)f[i]=false}
    } else if(miss<left(tolerance,2))w[215]=0;
  }
  w[226]=0; // Every shot consumes the whole current charge, including misses.
  return {state,hit,damage,events,draws:0,cooldownIncrement};
}

// Game12 proc21 $1114–$11AE: selector3 jettisons slot2 BEFORE slot1. Source
// accepts auxiliary/cryogens too; the campaign host must persist lost lots.
export function jettisonShipCargo(previous,selection) {
  const state=snapshot(previous),rng=randomFor(state),jettisoned=[];let resetSystemCooldown=false;
  if(![1,2,3].includes(selection))fail();
  for(const slot of selection===3?[1,0]:[selection-1]) {
    const lot=state.cargo[slot],type=lot?Number(lot.commodityId.slice(6)):0;
    state.cargo[slot]=null;if(lot)jettisoned.push({slot,lot});
    const roll=rng.next()&1; // Eager source LAND/OR draws for every selected slot.
    if(type>1) {
      const other=state.cargo[1-slot],otherType=other?Number(other.commodityId.slice(6)):0;
      if(otherType<2||otherType===31||roll) {
        resetSystemCooldown=true;
        state.words[215]=128;state.words[207]=1;state.flags[44]=false;
        state.flags[46]=state.flags[47]=true;
      }
    }
  }
  return {state,jettisoned,draws:rng.draws,resetSystemCooldown};
}
