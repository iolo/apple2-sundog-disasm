import { roomDoorGeometry } from './room-walk.js';
import { sourceRandom } from './random.js';

const inside=(b,p)=>p.x>=b.left&&p.x<=b.right&&p.y>=b.top&&p.y<=b.bottom;
export const initialLodging=()=>({rented:0,openMask:0});
export function validateLodging(value) {
  if(!value||typeof value!=='object'||Array.isArray(value)||Object.keys(value).length!==2||
    !['rented','openMask'].every(k=>Object.hasOwn(value,k))||!Number.isInteger(value.rented)||value.rented<0||value.rented>4||
    !Number.isInteger(value.openMask)||value.openMask<0||value.openMask>15||(!value.rented&&value.openMask))
    throw new Error('invalidCampaign');
  return {rented:value.rented,openMask:value.openMask};
}
const geometries=new WeakMap();
export function lodgingGeometry(room,lodging,{access=false}={}) {
  if(room.index!==1)return room;
  const state=validateLodging(lodging),mask=state.openMask|(access&&state.rented ? 1<<(state.rented-1) : 0);
  if(!geometries.has(room))geometries.set(room,new Map());
  const cached=geometries.get(room);
  if(!cached.has(mask))cached.set(mask,roomDoorGeometry(room,Array.from({length:4},(_,i)=>!!(mask&(1<<i)))));
  return cached.get(mask);
}

// Game18 procedure21 $0F92–$0FB9: choose one of four rooms after flag65,
// open its door and consume the flag at the caller's atomic return boundary.
export function rentLodging(previous,randomState) {
  const state=validateLodging(previous),rng=sourceRandom(randomState),rented=1+rng.next()%4;
  return {lodging:{rented,openMask:state.openMask|(1<<(rented-1))},randomState:rng.state};
}

// Procedure25 $1438–$148C. The browser applies the release-area rule after
// each movement step so keyboard, pointer and touch use the same door behavior.
export function updateLodgingAccess(room,previous,position) {
  const lodging=validateLodging(previous);
  if(room.index!==1)throw new Error('invalidRoomDoors');
  if(!lodging.rented)return {lodging,sheltered:false};
  let sheltered=false;
  if(inside(room.fixtures.approach,position)) {
    // local131 is the floor's left edge (20); source subtracts131−2.
    const number=1+Math.trunc((position.x-18)/28);
    if(number===lodging.rented)lodging.openMask|=1<<(number-1);
  } else {
    lodging.openMask&=~(1<<(lodging.rented-1));
    sheltered=inside(room.fixtures.bedrooms,position);
  }
  return {lodging,sheltered};
}
