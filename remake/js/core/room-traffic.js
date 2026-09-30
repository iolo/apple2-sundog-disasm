import { sourceRandom } from './random.js';
import { canStand, tryStep } from './ship-walk.js';
import { drawRoomGlyph, roomActorGeometry } from './room-actors.js';
import { cityReachability } from './city-walk.js';
import { isTavern, initialTavern, playerSeatAt, actorSeat, seatOccupants, seatTarget, oppositeSeat } from './room-seating.js';

// Browser cadence, not an assertion of native CPU timing. Remainders are
// transient like player input; pause/load discard partial ticks.
export const ROOM_TICK_MS=50;
export const initialRoomTraffic=(population,room)=>({actors:structuredClone(population.actors),active:0,waiting:0,
  ...(room&&isTavern(room) ? {tavern:initialTavern()} : {})});
const position=w=>({x:w[5],y:w[4]});
const flag=(w,bit)=>!!(w[7]&(1<<bit));
const setFlag=(w,bit,value)=>{w[7]=value ? w[7]|(1<<bit) : w[7]&~(1<<bit)};
const action=w=>w[7]>>>8;
const setAction=(w,value)=>{w[7]=(w[7]&255)|(value<<8)};
const reachableRooms=new WeakMap();

export function validateRoomTraffic(room,value,player,{service=null,playerRoom=room}={}) {
  const fail=()=>{throw new Error('invalidCampaign')};
  const keys=(v,list)=>v&&typeof v==='object'&&!Array.isArray(v)&&Object.keys(v).length===list.length&&list.every(k=>Object.hasOwn(v,k));
  const tavern=isTavern(room);
  if(!keys(value,tavern ? ['actors','active','waiting','tavern'] : ['actors','active','waiting'])||!Array.isArray(value.actors)||
    value.actors.length<1||value.actors.length>room.population.maximum||Object.keys(value.actors).length!==value.actors.length)fail();
  const count=value.actors.length;
  if(!reachableRooms.has(room))reachableRooms.set(room,cityReachability(room));
  const reachable=reachableRooms.get(room);
  if(!reachableRooms.has(playerRoom))reachableRooms.set(playerRoom,cityReachability(playerRoom));
  if(!reachableRooms.get(playerRoom)(player))fail();
  if(!Number.isInteger(value.active)||(value.active!==0&&(value.active<2||value.active>count)))fail();
  if(tavern) {
    const t=value.tavern;
    if(!keys(t,['playerSeat','secondary','contact'])||
      (t.playerSeat!==null&&(!Number.isInteger(t.playerSeat)||t.playerSeat<4||t.playerSeat>9||t.playerSeat!==playerSeatAt(room,player)))||
      !Number.isInteger(t.secondary)||(t.secondary!==0&&(t.secondary<2||t.secondary>count||t.secondary===value.active)))fail();
    if(t.contact!==null&&(!keys(t.contact,['actor','kind'])||!Number.isInteger(t.contact.actor)||
      t.contact.actor<2||t.contact.actor>count||![21,22].includes(t.contact.kind)||t.playerSeat===null))fail();
  }
  if(service!==null&&!['idle','waiting','talking','served'].includes(service))fail();
  const playerWaiting=service==='waiting',b=room.population.bounds;
  if(service!==null&&service!=='idle'&&!(tavern&&value.tavern.contact&&service==='talking')&&
    !(player.x>=b.left&&player.x<=b.right&&player.y>=b.top&&player.y<=b.bottom))fail();
  let waiting=Number(playerWaiting);
  const state=structuredClone(value);
  for(const [i,a] of state.actors.entries()) {
    const slot=i===count-1 ? 0 : i+2,w=a.words;
    if(!keys(a,['slot','words'])||a.slot!==slot||!Array.isArray(w)||w.length!==10||Object.keys(w).length!==10||!w.every(Number.isInteger))fail();
    if(w[6]!==23*256+(slot===0 ? 3 : 24)||w[8]<0||w[8]>4||w[9]<0||w[9]>255||
      w[7]<0||w[7]>0xffff||(w[7]&~((tavern&&slot>1 ? 0xf00|61 : 0x300|57)|((slot===0||tavern)&&service!==null ? 2 : 0)))||
      !(tavern&&slot>1 ? [0,2,3,4,5,6,7,8,9] : [0,2,3]).includes(action(w)))fail();
    for(const offset of [0,2])if(w[offset]<0||w[offset]>102||w[offset+1]<-7||w[offset+1]>140)fail();
    if(!canStand({...room,collisionRows:slot===0 ? room.counterCollisionRows : room.collisionRows},position(w)))fail();
    if(slot===0) {
      if((service===null&&w[8]!==3)||action(w)!==0||(w[7]&~(service===null ? 32 : 34))||
        (w[9]===1&&!playerWaiting)||w[9]>count||flag(w,5)!==(w[9]>0))fail();
      // Counter motion stays on its side of the solid counter. This also
      // excludes unsupported blocked-counter/action branches from imports.
      const vertical=room.population.offset.x!==0;
      const b=room.population.bounds,offset=room.population.offset;
      if(vertical ? [w[5],w[1],w[3]].some(x=>x<b.left+offset.x||x>b.right+offset.x) :
        [w[4],w[0],w[2]].some(y=>y<b.top+offset.y||y>b.bottom+offset.y))fail();
      for(const i of [0,2])if(!canStand({...room,collisionRows:room.counterCollisionRows},{x:w[i+1],y:w[i]}))fail();
    } else {
      if(!reachable(position(w)))fail();
      if(flag(w,5)!==(slot===state.active||slot===state.tavern?.secondary))fail();
      if(flag(w,5)) {
        if(flag(w,3)||flag(w,2)||!(tavern ? [2,3,4,5,6,7,8,9] : [2,3]).includes(action(w)))fail();
        if(action(w)>=4) {
          const target=seatTarget(room,action(w));
          if(w[3]!==target.x||w[2]!==target.y)fail();
        }
      } else if((!flag(w,3)&&!flag(w,2))||action(w)===2||action(w)>=4||
        w[0]!==w[4]||w[2]!==w[4]||w[1]!==w[5]||w[3]!==w[5])fail();
      if(flag(w,2)&&(flag(w,3)||action(w)!==0||actorSeat(room,w)===null))fail();
      if(flag(w,3)&&!flag(w,4)) {
        if(w[9]!==0||action(w)!==0)fail();
        waiting++;
      }
    }
  }
  if(tavern) {
    const seats=seatOccupants(room,state),contact=state.tavern.contact;
    if(contact) {
      const speaker=state.actors.find(a=>a.slot===contact.actor).words;
      if(!flag(speaker,2)||flag(speaker,5)||seats[oppositeSeat(state.tavern.playerSeat)-4]!==contact.actor||
        (contact.kind===22&&!flag(speaker,0))||(state.active&&state.tavern.secondary))fail();
    }
  }
  const counter=state.actors.at(-1).words;
  if(counter[9] && !(counter[9]===1&&playerWaiting) &&
    !state.actors.some(a=>a.slot===counter[9]&&flag(a.words,3)&&!flag(a.words,4)))fail();
  if(counter[9]===1&&(counter[1]!==player.x+room.population.offset.x||counter[0]!==player.y+room.population.offset.y||
    counter[3]!==counter[1]||counter[2]!==counter[0]))fail();
  if(value.waiting!==waiting)fail();
  const geometry=roomActorGeometry(room,state.actors);
  if(!canStand({...geometry,collisionRows:room.spriteRows},player))fail();
  for(const a of state.actors) {
    const other=roomActorGeometry(room,state.actors.filter(b=>b!==a));
    if(!canStand({...other,collisionRows:room.npcRows},position(a.words)))fail();
  }
  return {state,geometry};
}

// Game18 procedures5/6/8–13/27/28. Tavern contacts yield to the host dialogue
// controller; fresh visits do not enable item solicitation or hostile pursuit.
export function tickRoomTraffic(room, previous, randomState, player,{service=null}={}) {
  return stepRoomTraffic(room,previous,randomState,player,{service});
}

function stepRoomTraffic(room, previous, randomState, player,{service=null,returnContact=false,dismiss=false}={}) {
  if(service!==null&&!['idle','waiting','served'].includes(service))throw new Error('invalidRoomService');
  const state=structuredClone(previous),rng=sourceRandom(randomState);
  const range=(lo,hi)=>lo+rng.next()%(hi-lo+1),b=room.population.bounds,door=room.population.doorway;
  const actor=slot=>state.actors.find(a=>a.slot===slot)?.words;
  const geometry=roomActorGeometry(room,state.actors),rows=geometry.backgrounds.ship;
  if(state.tavern?.contact&&!returnContact)return {state,randomState:rng.state,geometry,...(service===null ? {} : {service})};
  drawRoomGlyph(rows,player,room.spriteRows);
  const draw=w=>drawRoomGlyph(rows,position(w),room.npcRows);
  const atCounter=w=>w[5]>=b.left&&w[5]<=b.right&&w[4]>=b.top&&w[4]<=b.bottom;
  function seatPlace(w) {
    if(!isTavern(room))return null;
    let group=rng.next()%3,side=rng.next()%2,remaining=6;
    const seats=seatOccupants(room,state);
    while(seats[2*group+side]&&remaining>=0) {
      remaining--;side++;if(side>1){group=(group+1)%3;side=0}
    }
    if(remaining<0)return null;
    for(let attempt=0;attempt<2;attempt++,side=(side+1)%2) {
      const number=4+2*group+side,target=seatTarget(room,number);
      // A physically blocked candidate can flip onto a reserved moving seat.
      // Keep ownership atomic rather than overwrite the native packed table.
      if(seats[number-4]||!canStand({...geometry,collisionRows:room.npcRows},target))continue;
      setAction(w,number);
      if(seats[oppositeSeat(number)-4]===1){setFlag(w,0,true);setFlag(w,1,false);w[8]=4}
      return target;
    }
    return null;
  }
  function release(w,slot) {
    if(flag(w,3)&&!flag(w,4)&&w[9]===0)state.waiting--;
    const counter=actor(0);
    if(counter[9]===slot){setFlag(counter,5,false);counter[9]=0}
    setFlag(w,2,false);setFlag(w,3,false);setFlag(w,5,true);
  }
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
    release(w,slot);
  }
  function retarget(slot) {
    const w=actor(slot);
    const target=flag(w,3) ? seatPlace(w) : counterPlace(w);if(!target)return;
    w[0]=target.y+(flag(w,2) ? 10 : -10);w[1]=w[3]=target.x;w[2]=target.y;
    release(w,slot);
  }
  function remove(slot) {
    draw(actor(slot));state.actors=state.actors.filter(a=>a.slot!==slot);
    for(const a of state.actors)if(a.slot>slot)a.slot--;
    state.active=state.active===slot ? 0 : state.active>slot ? state.active-1 : state.active;
    if(state.tavern) {
      const t=state.tavern;
      t.secondary=t.secondary===slot ? 0 : t.secondary>slot ? t.secondary-1 : t.secondary;
      if(t.contact?.actor===slot)t.contact=null;
      else if(t.contact?.actor>slot)t.contact.actor--;
    }
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
    if(state.tavern?.secondary===slot)state.tavern.secondary=0;
    if(action(w)===2){remove(slot);return}
    if(action(w)===3){setFlag(w,3,true);setFlag(w,4,false);w[9]=0;state.waiting++;setAction(w,0)}
    if(action(w)>=4) {
      const seat=action(w);setFlag(w,2,true);setAction(w,0);
      if(state.tavern.playerSeat===oppositeSeat(seat))state.tavern.contact={actor:slot,kind:flag(w,0) ? 22 : 21};
    }
  }
  function counterTick() {
    const w=actor(0);
    if(flag(w,5)) {
      move(0);
      if(!flag(w,5)) {
        if(w[9]===1&&service==='waiting') {
          service='talking';state.waiting--; // Browser repair: consume the player's queue entry exactly once.
        } else {
          const target=actor(w[9]);
          if(target){setFlag(target,4,true);target[9]=64+rng.next()%192;state.waiting--}
        }
        w[9]=0;
      }
    } else {
      const choose=rng.next()%8===0; // Eager even when nobody waits.
      if(state.waiting>0&&choose) {
        const target=service==='waiting' ? {slot:1,words:[0,0,0,0,player.y,player.x]} :
          state.actors.find(a=>a.slot>=2&&flag(a.words,3)&&!flag(a.words,4));
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
    let target=rng.next()%3===0 ? seatPlace(w) : null;
    if(!target)target=counterPlace(w);
    if(!target)target=seatPlace(w);
    if(!target||!canStand(geometry,{x:door.x,y:door.y+5}))return;
    w[5]=door.x;w[4]=door.y+5;w[3]=target.x;w[2]=target.y;
    if(Math.abs(b.right-b.left)>4){w[1]=target.x;w[0]=target.y+10*Math.sign(w[4]-target.y)}
    else {w[1]=target.x+Math.sign(w[5]-target.x)*Math.abs(target.y-w[4]);w[0]=target.y}
    w[6]=5912;setFlag(w,5,true);
    const slot=state.actors.length+1;
    state.actors.splice(state.actors.length-1,0,{slot,words:w});state.active=slot;draw(w);
  }
  if(returnContact) {
    const slot=state.tavern.contact.actor;state.tavern.contact=null;
    if(dismiss) {
      // Keep an earlier returning visitor alive when the primary visitor has
      // just arrived opposite the player. Native overwrites mover123 here.
      if(state.tavern.secondary)state.active=state.tavern.secondary;
      state.tavern.secondary=slot;
      if(rng.next()&1)retarget(slot);
      if(!flag(actor(slot),5))depart(slot);
    }
  } else {
    counterTick();
    if(state.active>1||state.tavern?.secondary>1) {
      if(state.active>1)move(state.active);
      if(state.tavern?.secondary>1)move(state.tavern.secondary);
    } else if(rng.next()%room.population.activityDivisor===0) {
      const count=state.actors.length,threshold=2+Math.trunc(room.population.maximum/2);
      const add=rng.next()%count<threshold;
      if((add&&count<threshold)||count===1)arrive();
      else {
        state.active=range(2,count);
        const leave=rng.next()&1; // Eager draw even outside taverns.
        if(leave||!isTavern(room))depart(state.active);
        else {retarget(state.active);if(!flag(actor(state.active),5))state.active=0}
      }
    }
  }
  drawRoomGlyph(rows,player,room.spriteRows);
  return {state,randomState:rng.state,geometry,...(service===null ? {} : {service})};
}

// Procedure24: releasing movement in the bottom seating band claims a seat
// and speaks to an already seated opposite visitor. Walking releases ownership.
export function sitRoomTraffic(room,previous,player,{service=null}={}) {
  if(!isTavern(room))throw new Error('notAtTavernSeat');
  const state=validateRoomTraffic(room,previous,player,{service}).state,seat=playerSeatAt(room,player);
  if(seat===null)throw new Error('notAtTavernSeat');
  if(state.tavern.contact)return state;
  const occupants=seatOccupants(room,state);
  if(occupants[seat-4]>1)throw new Error('tavernSeatReserved');
  state.tavern.playerSeat=seat;
  const slot=occupants[oppositeSeat(seat)-4],w=state.actors.find(a=>a.slot===slot)?.words;
  if(slot>1&&flag(w,2)&&!flag(w,5)) {
    // A third moving visitor cannot fit the two source mover slots on return.
    // Defer a new player request until one slot is free, without losing actors.
    if(state.active&&state.tavern.secondary)throw new Error('roomTrafficBusy');
    state.tavern.contact={actor:slot,kind:21};
  }
  return state;
}

export function standRoomTraffic(room,previous,player,{service=null}={}) {
  const state=validateRoomTraffic(room,previous,player,{service}).state;
  if(!state.tavern)throw new Error('notAtTavernSeat');
  if(state.tavern.contact)throw new Error('roomConversationActive');
  state.tavern.playerSeat=null;return state;
}

// Procedure21: flag49 dispatches the speaker through secondary mover123.
// The host supplies the interpreted return flag; no conversation is invented.
export function finishTavernContact(room,previous,randomState,player,{dismiss=false,service=null}={}) {
  validateRoomTraffic(room,previous,player,{service});
  if(!previous.tavern?.contact)throw new Error('roomConversationInactive');
  return stepRoomTraffic(room,previous,randomState,player,{returnContact:true,dismiss});
}
