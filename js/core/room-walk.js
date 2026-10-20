import { cityDoorAt } from './city-doors.js';
import { canStand } from './ship-walk.js';

export function createRoomGeometries(content) {
  return Object.fromEntries(content.layouts.map(room=>[room.index,{
    index:room.index,width:room.width,height:room.height,spawn:{...room.spawn},exitX:room.exitX,
    backgrounds:{ship:room.rows.map(row=>[...row])},collisionRows:[...content.collisionRows],
    population:structuredClone(room.population),spriteRows:[...content.spriteRows],npcRows:[...content.npcRows],
    counterCollisionRows:[...content.counterCollisionRows],
    fixtures:structuredClone(room.fixtures),floorPattern:[...room.floorPattern],
  }]));
}

// Game18 procedure15. Always derive doors from an owned static background,
// never XOR an opening into an actor overlay or mutate the cached layout.
export function roomDoorGeometry(room,openDoors) {
  if(room.index!==1||!Array.isArray(openDoors)||openDoors.length!==4||
    !Array.from(openDoors).every(v=>typeof v==='boolean'))throw new Error('invalidRoomDoors');
  const rows=room.backgrounds.ship.map(row=>[...row]);
  room.fixtures.doors.forEach((door,index)=>{
    if(!openDoors[index])return;
    for(let y=door.top;y<=door.bottom;y++)for(let x=door.left;x<=door.right;x++) {
      const byte=Math.floor(x/7),bit=1<<(x%7);
      rows[y][byte]=(rows[y][byte]&~bit)|(room.floorPattern[byte%2]&bit);
    }
  });
  return {...room,backgrounds:{ship:rows}};
}

// Game18 $0BA8–$0BC5: foot-interior selection.
export function roomAt(rooms,map,streetPosition) {
  const door=cityDoorAt(map,streetPosition);
  if(door?.scene!==5 || ![8,9,10,11].includes(door.type))return null;
  return rooms?.[door.type===11 ? 1 : 4*(door.type-7)+(door.tileX+door.tileY)%4] || null;
}

// Game18 $15E9–$15F6. Browser activation is explicit, as at city doors.
export function canLeaveRoom(geometry,position) {
  return canStand(geometry,position)&&position.x<=geometry.exitX;
}
