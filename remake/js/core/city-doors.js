// Game21 procedures19/20: coordinates are relative to (x-3,y+3),
// whereas procedure21 selects the tile containing (x+3,y-3).
// Scene5 is a walking interior; scene6 dispatches service screens.
const doors = [
  [7,'foot',14,30,3,1],
  [8,'foot',1,15,5,8], [9,'foot',2,16,5,9],
  [10,'foot',1,15,5,10], [11,'foot',1,21,5,11],
  [12,'foot',6,28,6,1], [13,'foot',1,18,6,2],
  [14,'foot',1,15,6,3], [14,'pod',2,22,6,3],
  [15,'pod',14,21,6,4], [15,'foot',2,15,6,5],
];

export function cityDoorAt(map, position, mode='foot') {
  if (!Number.isInteger(position?.x) || !Number.isInteger(position?.y) || position.x<3 || position.y<3) return null;
  const x=Math.floor((position.x+3)/28),y=Math.floor((position.y-3)/32);
  const tile=map?.tiles[y]?.[x];
  if (!Number.isInteger(tile) || tile<7 || tile>31) return null;
  const localX=(position.x-3)%28,localY=(position.y+3)%32;
  const door=doors.find(([base,vehicle,dx,dy])=>base===tile%16 && vehicle===mode &&
    Math.abs(localX-dx)<=4 && Math.abs(localY-dy)<=4);
  return door ? {tileX:x,tileY:y,tile:tile%16,scene:door[4],type:door[5]} : null;
}

export function atCityBank(map, position) {
  const door=cityDoorAt(map,position);
  return door?.scene===6 && door.type===2;
}

// startup_disk1 scene6 -> Game19 types1..3, Game20 types4/5.
// Type4 is the pod exchange entrance; foot entry is type5.
export function cityServiceAt(map, position, mode='foot') {
  const door=cityDoorAt(map,position,mode);
  return door?.scene===6 ? ({1:'transstation',2:'bank',3:'depot',4:'exchange',5:'exchange'})[door.type] ?? null : null;
}
