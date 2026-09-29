import { sourceRandom } from './random.js';
import { canStand, tryStep } from './ship-walk.js';
import { drawRoomGlyph, roomActorGeometry } from './room-actors.js';
import { cityReachability } from './city-walk.js';

// Browser cadence, not an assertion of native CPU timing. Remainders are
// transient like player input; pause/load discard partial ticks.
export const ROOM_TICK_MS=50;
export const initialRoomTraffic=population=>({actors:structuredClone(population.actors),active:0,waiting:0});
const position=w=>({x:w[5],y:w[4]});
const flag=(w,bit)=>!!(w[7]&(1<<bit));
const setFlag=(w,bit,value)=>{w[7]=value ? w[7]|(1<<bit) : w[7]&~(1<<bit)};
const action=w=>w[7]>>>8;
const setAction=(w,value)=>{w[7]=(w[7]&255)|(value<<8)};
const reachableRooms=new WeakMap();

export function validateRoomTraffic(room,value,player) {
  const fail=()=>{throw new Error('invalidCampaign')};
  const keys=(v,list)=>v&&typeof v==='object'&&!Array.isArray(v)&&Object.keys(v).length===list.length&&list.every(k=>Object.hasOwn(v,k));
  if(!keys(value,['actors','active','waiting'])||!Array.isArray(value.actors)||
    value.actors.length<1||value.actors.length>room.population.maximum||Object.keys(value.actors).length!==value.actors.length)fail();
  const count=value.actors.length;
  if(!reachableRooms.has(room))reachableRooms.set(room,cityReachability(room));
  const reachable=reachableRooms.get(room);
  if(!reachable(player))fail();
  if(!Number.isInteger(value.active)||(value.active!==0&&(value.active<2||value.active>count)))fail();
  let waiting=0;
  const state=structuredClone(value);
  for(const [i,a] of state.actors.entries()) {
    const slot=i===count-1 ? 0 : i+2,w=a.words;
    if(!keys(a,['slot','words'])||a.slot!==slot||!Array.isArray(w)||w.length!==10||Object.keys(w).length!==10||!w.every(Number.isInteger))fail();
    if(w[6]!==23*256+(slot===0 ? 3 : 24)||w[8]<0||w[8]>4||w[9]<0||w[9]>255||
      w[7]<0||w[7]>0xffff||(w[7]&~(0x300|57))||![0,2,3].includes(action(w)))fail();
    for(const offset of [0,2])if(w[offset]<0||w[offset]>102||w[offset+1]<-7||w[offset+1]>140)fail();
    if(!canStand({...room,collisionRows:slot===0 ? room.counterCollisionRows : room.collisionRows},position(w)))fail();
    if(slot===0) {
      if(w[8]!==3||action(w)!==0||(w[7]&~32)||w[9]===1||w[9]>count||flag(w,5)!==(w[9]>0))fail();
      // Counter motion stays on its side of the solid counter. This also
      // excludes unsupported blocked-counter/action branches from imports.
      const vertical=room.population.offset.x!==0;
      const b=room.population.bounds,offset=room.population.offset;
      if(vertical ? [w[5],w[1],w[3]].some(x=>x<b.left+offset.x||x>b.right+offset.x) :
        [w[4],w[0],w[2]].some(y=>y<b.top+offset.y||y>b.bottom+offset.y))fail();
      for(const i of [0,2])if(!canStand({...room,collisionRows:room.counterCollisionRows},{x:w[i+1],y:w[i]}))fail();
    } else {
      if(!reachable(position(w)))fail();
      if(flag(w,5)!==(slot===state.active))fail();
      if(flag(w,5)) {
        if(flag(w,3)||![2,3].includes(action(w)))fail();
      } else if(!flag(w,3)||action(w)===2||w[0]!==w[4]||w[2]!==w[4]||w[1]!==w[5]||w[3]!==w[5])fail();
      if(flag(w,3)&&!flag(w,4)) {
        if(w[9]!==0||action(w)!==0)fail();
        waiting++;
      }
    }
  }
  const counter=state.actors.at(-1).words;
  if(counter[9] && !state.actors.some(a=>a.slot===counter[9]&&flag(a.words,3)&&!flag(a.words,4)))fail();
  if(value.waiting!==waiting)fail();
  const geometry=roomActorGeometry(room,state.actors);
  if(!canStand({...geometry,collisionRows:room.spriteRows},player))fail();
  for(const a of state.actors) {
    const other=roomActorGeometry(room,state.actors.filter(b=>b!==a));
    if(!canStand({...other,collisionRows:room.npcRows},position(a.words)))fail();
  }
  return {state,geometry};
}

// Game18 procedures5/6/9–13/27/28, fresh foot visits to types9/10 only.
// Seat and dialogue flags are unavailable in these scenes; secondary mover123
// stays zero. Player service requests are deferred with dialogue.
export function tickRoomTraffic(room, previous, randomState, player) {
  const state=structuredClone(previous),rng=sourceRandom(randomState);
  const range=(lo,hi)=>lo+rng.next()%(hi-lo+1),b=room.population.bounds,door=room.population.doorway;
  const actor=slot=>state.actors.find(a=>a.slot===slot)?.words;
  const geometry=roomActorGeometry(room,state.actors),rows=geometry.backgrounds.ship;
  drawRoomGlyph(rows,player,room.spriteRows);
  const draw=w=>drawRoomGlyph(rows,position(w),room.npcRows);
  const atCounter=w=>w[5]>=b.left&&w[5]<=b.right&&w[4]>=b.top&&w[4]<=b.bottom;
  function counterPlace(w) {
    const dx=5*Math.sign(Math.trunc((b.right-b.left)/4)),dy=3*Math.sign(Math.trunc((b.bottom-b.top)/4));
    for(let remaining=9;remaining>=0;remaining--) {
      const x=range(b.left,b.right),y=range(b.top,b.bottom);
      const clear=canStand(geometry,{x:x-dx,y:y-dy})&&canStand(geometry,{x:x+dx,y:y+dy});
      if(!remaining)return null;
      if(clear){setAction(w,3);return {x,y}}
    }
  }
  function depart(slot) {
    const w=actor(slot);setAction(w,2);w[3]=door.x;w[2]=door.y-5;w[1]=w[5];w[0]=w[4];setFlag(w,1,false);
    if(!flag(w,4)&&w[9]===0&&flag(w,3)) {
      state.waiting--;
      if(actor(0)[9]===state.active){setFlag(actor(0),5,false);actor(0)[9]=0}
    }
    setFlag(w,5,true);setFlag(w,3,false);
  }
  function retarget(slot) {
    const w=actor(slot);
    if(flag(w,3))return; // Procedure8 immediately fails outside a tavern.
    const target=counterPlace(w);if(!target)return;
    w[0]=target.y-10;w[1]=w[3]=target.x;w[2]=target.y;
    setFlag(w,5,true);setFlag(w,3,false);
  }
  function remove(slot) {
    draw(actor(slot));state.actors=state.actors.filter(a=>a.slot!==slot);
    for(const a of state.actors)if(a.slot>slot)a.slot--;
    state.active=state.active===slot ? 0 : state.active>slot ? state.active-1 : state.active;
    // Preserve the followed actor's identity across compaction. Native proc6
    // repairs mover indices but omits this counter reference (browser repair).
    const counter=actor(0);
    if(counter[9]===slot){counter[9]=0;setFlag(counter,5,false)}
    else if(counter[9]>slot)counter[9]--;
  }
  function move(slot) {
    const w=actor(slot);
    if(w[5]!==w[1]||w[4]!==w[0]) {
      const old=position(w),dx=Math.sign(w[1]-w[5])*Math.min(2,Math.abs(w[1]-w[5])),dy=Math.sign(w[0]-w[4])*Math.min(2,Math.abs(w[0]-w[4]));
      draw(w);
      const next=tryStep({...geometry,collisionRows:slot===0 ? room.counterCollisionRows : room.collisionRows},old,dx,dy);
      w[5]=next.x;w[4]=next.y;draw(w);
      if(next.x!==old.x||next.y!==old.y)return;
      // Native repeats the same step after hiding its pointer graphic. The
      // browser cursor is absent from collision, so that retry is identical.
      if(action(w)===3&&atCounter(w)){w[1]=w[3]=w[5];w[0]=w[2]=w[4];return}
      if(rng.next()&1) {
        w[1]=w[5]+range(-7,7);w[0]=w[4]+range(-7,7);
        if(w[1]===w[5])w[0]=w[4]+range(-2,2);
        if(w[0]===w[4])w[1]=w[5]+range(-2,2);
      } else {
        setFlag(w,5,false);retarget(slot);if(!flag(w,5))depart(slot);
      }
      return;
    }
    if(w[3]!==w[1]||w[2]!==w[0]){w[1]=w[3];w[0]=w[2];return}
    setFlag(w,5,false);if(state.active===slot)state.active=0;
    if(action(w)===2){remove(slot);return}
    if(action(w)===3){setFlag(w,3,true);setFlag(w,4,false);w[9]=0;state.waiting++;setAction(w,0)}
  }
  function counterTick() {
    const w=actor(0);
    if(flag(w,5)) {
      move(0);
      if(!flag(w,5)) {
        const target=actor(w[9]);
        if(target){setFlag(target,4,true);target[9]=64+rng.next()%192;state.waiting--}
        w[9]=0;
      }
    } else {
      const choose=rng.next()%8===0; // Eager even when nobody waits.
      if(state.waiting>0&&choose) {
        const target=state.actors.find(a=>a.slot>=2&&flag(a.words,3)&&!flag(a.words,4));
        if(target) {
          setFlag(w,5,true);w[9]=target.slot;
          w[1]=w[3]=target.words[5]+room.population.offset.x;
          w[0]=w[2]=target.words[4]+room.population.offset.y;
        }
      }
    }
  }
  function arrive() {
    if(state.actors.length>=room.population.maximum)return;
    const w=Array(10).fill(0);setFlag(w,0,rng.next()%8===0);w[8]=rng.next()%5;
    rng.next(); // random mod3 seating preference, procedure8 fails for types9/10.
    const target=counterPlace(w);
    if(!target||!canStand(geometry,{x:door.x,y:door.y+5}))return;
    w[5]=door.x;w[4]=door.y+5;w[3]=target.x;w[2]=target.y;
    if(Math.abs(b.right-b.left)>4){w[1]=target.x;w[0]=target.y+10*Math.sign(w[4]-target.y)}
    else {w[1]=target.x+Math.sign(w[5]-target.x)*Math.abs(target.y-w[4]);w[0]=target.y}
    w[6]=5912;setFlag(w,5,true);
    const slot=state.actors.length+1;
    state.actors.splice(state.actors.length-1,0,{slot,words:w});state.active=slot;draw(w);
  }
  counterTick();
  if(state.active>1)move(state.active);
  else if(rng.next()%room.population.activityDivisor===0) {
    const count=state.actors.length,threshold=2+Math.trunc(room.population.maximum/2);
    const add=rng.next()%count<threshold;
    if((add&&count<threshold)||count===1)arrive();
    else {state.active=range(2,count);rng.next();depart(state.active)} // Eager draw; non-tavern OR is true.
  }
  drawRoomGlyph(rows,player,room.spriteRows);
  return {state,randomState:rng.state,geometry};
}
