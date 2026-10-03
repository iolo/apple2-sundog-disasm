import { createCityGeometry } from './city-walk.js';
import { canStand } from './ship-walk.js';
import { cityDoorAt } from './city-doors.js';

// Game21 proc22 expands bases14/15 into direction-indexed visible/collision
// glyphs; proc12 indexes them by 5 + 3*sign(dx) + sign(dy).
const offsets=[null,6,2,4,0,null,0,4,2,6];
export function podHeading(dx,dy) {
  if(!Number.isInteger(dx)||!Number.isInteger(dy)||Math.abs(dx)>2||Math.abs(dy)>2||(!dx&&!dy))return null;
  return 14+offsets[5+3*Math.sign(dx)+Math.sign(dy)];
}
export function createPodGeometry(map,content,location,options) {
  const geometry=createCityGeometry(map,{...content,shipRows:content.detachedShipRows,collisionRows:content.podGlyphs[17]},location,options);
  // Game15 proc7 departs in direction8; Game21 $0D06–$0D40 adds (9,0).
  return {...geometry,podGlyphs:structuredClone(content.podGlyphs),
    spawn:geometry.shipAnchor?{x:geometry.shipAnchor.x+9,y:geometry.shipAnchor.y}:null};
}
export function canDrivePod(geometry,position,heading) {
  return [14,16,18,20].includes(heading)&&canStand({...geometry,collisionRows:geometry.podGlyphs[heading+1]},position);
}
// Game21 proc12 tries diagonal, X, Y using a different mask for each actual
// direction. If a two-pixel attempt fails, repeat those attempts at one pixel.
export function tryPodStep(geometry,position,dx,dy) {
  if(podHeading(dx,dy)===null)return null;
  const attempts=[[dx,dy],[dx,0],[0,dy]];
  if(Math.abs(dx)>1||Math.abs(dy)>1)attempts.push([Math.sign(dx),Math.sign(dy)],[Math.sign(dx),0],[0,Math.sign(dy)]);
  for(const [x,y] of attempts) {
    const heading=podHeading(x,y),next={x:position.x+x,y:position.y+y};
    if(heading!==null&&canDrivePod(geometry,next,heading))return {position:next,heading};
  }
  return null;
}
export function drivePodToward(geometry,previous,pointer) {
  // Proc12 calls Library22 proc31: arithmetic shift right by three, then
  // proc34's sign. Preserve its asymmetric rounding for negative deltas.
  const dx=Math.sign((Math.trunc(pointer.x)-3-previous.position.x)>>3);
  const dy=Math.sign((Math.trunc(pointer.y)+3-previous.position.y)>>3);
  if(!dx&&!dy)return previous;
  const repeated=previous.direction?.x===dx&&previous.direction?.y===dy;
  const moved=tryPodStep(geometry,previous.position,dx*(repeated?2:1),dy*(repeated?2:1));
  return {...previous,...moved,direction:{x:dx,y:dy}};
}
export function canDockPod(geometry,position,heading) {
  const ship=geometry.shipAnchor;
  // Proc21's nearby ship tile gate, then proc15's horizontal orientation and
  // ±6 X / ±4 Y box around the ship's right-hand half.
  return !!ship&&heading===16&&canDrivePod(geometry,position,heading)&&
    Math.floor((position.y-3)/32)===Math.floor(ship.y/32)&&
    Math.abs(Math.floor((position.x+3)/28)-Math.floor(ship.x/28))<=3&&
    Math.abs(position.x-(ship.x+7))<=6&&Math.abs(position.y-ship.y)<=4;
}
export function podServiceAt(geometry,position,heading) {
  const door=cityDoorAt(geometry.map,position,'pod');
  return canDrivePod(geometry,position,heading)&&door?.scene===6 ? ({3:'depot',4:'exchange'})[door.type]??null : null;
}
export function podExchangeAt(geometry,position,heading) {
  return podServiceAt(geometry,position,heading)==='exchange';
}

// Reachability includes all source one/two-pixel requests, with the mask of
// each actual direction. Final saved orientation must also fit independently.
export function podReachability(geometry) {
  const {width,height}=geometry,seen=new Uint8Array(width*height),queue=new Int32Array(width*height);
  const origins=(geometry.podOrigins||[{position:geometry.spawn,heading:16}]).filter(o=>o.position&&canDrivePod(geometry,o.position,o.heading));
  if(!origins.length)throw new Error('blockedPodDeparture');
  let head=0,tail=0;
  for(const {position} of origins){const start=position.y*width+position.x;if(!seen[start]){queue[tail++]=start;seen[start]=1}}
  while(head<tail) {
    const index=queue[head++],position={x:index%width,y:Math.floor(index/width)};
    for(let y=-1;y<=1;y++)for(let x=-1;x<=1;x++)if(x||y)for(const step of [1,2]) {
      const next={x:position.x+x*step,y:position.y+y*step},i=next.y*width+next.x;
      if(!seen[i]&&canDrivePod(geometry,next,podHeading(x,y))) {seen[i]=1;queue[tail++]=i}
    }
  }
  return (position,heading)=>Number.isInteger(position?.x)&&Number.isInteger(position?.y)&&
    position.x>=0&&position.x<width&&position.y>=0&&position.y<height&&
    !!seen[position.y*width+position.x]&&canDrivePod(geometry,position,heading);
}
