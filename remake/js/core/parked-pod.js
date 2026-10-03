import { canStand } from './ship-walk.js';
import { canDrivePod } from './city-pod.js';

// Game21 proc8/7 draws the unattended pod with its saved visible glyph, XORed
// into the detached-ship background. Pattern9 filters the resulting collision
// pixels just as it does the rest of the city. Clone only the affected rows.
export function parkedPodGeometry(footGeometry,podGeometry,position,heading) {
  if(!canDrivePod(podGeometry,position,heading))throw Error('invalidParkedPod');
  const rows=podGeometry.backgrounds.ship.slice(),glyph=podGeometry.podGlyphs[heading];
  for(let y=0;y<8;y++) {
    const py=position.y-7+y;rows[py]=rows[py].slice();
    for(let x=0;x<7;x++)if(glyph[y]&(1<<x)) {
      const px=position.x+x,byte=Math.floor(px/7),bit=1<<(px%7);
      rows[py][byte]^=bit&podGeometry.collisionByteMasks[byte%2];
    }
  }
  return {...footGeometry,backgrounds:{...footGeometry.backgrounds,ship:rows}};
}

// Game21 proc21 $0B1B–$0B5A: same city, detached pod, foot mode and ±1 tile;
// proc16 $0783–$07A1 then requires ±4 pixels on each axis. The caller owns
// scene/mode/location identity. This predicate owns only local geometry.
export function canBoardParkedPod(geometry,player,pod) {
  return Number.isInteger(pod?.x)&&Number.isInteger(pod?.y)&&canStand(geometry,player)&&
    Math.abs(Math.floor((player.x+3)/28)-Math.floor(pod.x/28))<=1&&
    Math.abs(Math.floor((player.y-3)/32)-Math.floor(pod.y/32))<=1&&
    Math.abs(player.x-pod.x)<=4&&Math.abs(player.y-pod.y)<=4;
}

// Game21 proc25 $0DCE–$0E36: test49 positions at scale1, then scale2, etc.
// X is outer and Y inner: (index div7−3, index mod7−3)*scale. The source
// repeats until collision is clear. Stop once every nonzero offset must be
// outside this finite browser map, returning null instead of looping forever.
export function findPodFootExit(geometry,pod) {
  if(!Number.isInteger(pod?.x)||!Number.isInteger(pod?.y)||pod.x<0||pod.x>=geometry.width||pod.y<7||pod.y>=geometry.height)return null;
  const limit=Math.max(pod.x,geometry.width-1-pod.x,pod.y-7,geometry.height-1-pod.y);
  for(let scale=1;scale<=limit;scale++)for(let index=0;index<49;index++) {
    const point={x:pod.x+(Math.floor(index/7)-3)*scale,y:pod.y+(index%7-3)*scale};
    if(canStand(geometry,point))return point;
  }
  return null;
}
