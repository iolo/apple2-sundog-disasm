import { cityDoorAt } from './city-doors.js';
import { canStand } from './ship-walk.js';

export function createRoomGeometries(content) {
  return Object.fromEntries(content.layouts.map(room=>[room.index,{
    index:room.index,width:room.width,height:room.height,spawn:{...room.spawn},exitX:room.exitX,
    backgrounds:{ship:room.rows.map(row=>[...row])},collisionRows:[...content.collisionRows],
    population:structuredClone(room.population),spriteRows:[...content.spriteRows],npcRows:[...content.npcRows],
  }]));
}

// Game18 $0BA8–$0BC5; only the two types without extra fixture drawing.
export function roomAt(rooms,map,streetPosition) {
  const door=cityDoorAt(map,streetPosition);
  if(door?.scene!==5 || ![9,10].includes(door.type))return null;
  return rooms?.[4*(door.type-7)+(door.tileX+door.tileY)%4] || null;
}

// Game18 $15E9–$15F6. Browser activation is explicit, as at city doors.
export function canLeaveRoom(geometry,position) {
  return canStand(geometry,position)&&position.x<=geometry.exitX;
}
