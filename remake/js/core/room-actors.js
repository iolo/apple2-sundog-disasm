import { sourceRandom } from './random.js';
import { canStand } from './ship-walk.js';

// Library22 mode1: visible glyph pixels XOR the same buffer used by collision.
function drawGlyph(rows, {x,y}, glyph) {
  glyph.forEach((mask,row)=>{
    for(let bit=0;bit<7;bit++)if(mask&(1<<bit)) {
      const px=x+bit,py=y-7+row;
      if(py<0||py>=rows.length||px<0||px>=rows[py].length*7)throw new Error('roomPopulationUnavailable');
      rows[py][Math.floor(px/7)]^=1<<(px%7);
    }
  });
}

// Initial foot population only: Game18 procedures16,14,13,9. Native words
// retain unresolved flag/value meanings instead of assigning dialogue roles.
export function populateRoom(room, seed) {
  const rng=sourceRandom(seed),range=(lo,hi)=>lo+rng.next()%(hi-lo+1);
  const {bounds:b,offset,maximum}=room.population;
  const rows=room.backgrounds.ship.map(row=>[...row]);
  const geometry={...room,backgrounds:{ship:rows}};
  const actors=[];
  const add=(slot,x,y,glyph,flags,value,timer)=>{
    const actor={slot,words:[y,x,y,x,y,x,23*256+glyph,flags,value,timer]};
    actors.push(actor);drawGlyph(rows,{x,y},room.npcRows);return actor;
  };
  let count=range(3,maximum);
  drawGlyph(rows,room.spawn,room.spriteRows);
  const dx=5*Math.sign(Math.trunc((b.right-b.left)/4));
  const dy=3*Math.sign(Math.trunc((b.bottom-b.top)/4));
  for(let slot=2;slot<=count;) {
    const flag=rng.next()%8===0 ? 1 : 0,value=rng.next()%5;
    let attempts=10,x,y,clear;
    do {
      x=range(b.left,b.right);y=range(b.top,b.bottom);attempts--;
      clear=canStand(geometry,{x:x-dx,y:y-dy})&&canStand(geometry,{x:x+dx,y:y+dy});
    } while(!clear&&attempts>0);
    // Source rejects even a clear tenth candidate and retries this slot with
    // a smaller population. Failed attempts consume traits but no timer draw.
    if(attempts===0){count--;continue}
    add(slot++,x,y,24,3*256+24+flag,value,2+rng.next()%250);
  }
  // The no-visitor branch ($0A43) reverses its X range, including a zero
  // divisor in records8–11. Until resolved, fail atomically at the street.
  if(!actors.length)throw new Error('roomPopulationUnavailable');
  const first=actors[0].words;
  add(0,first[5]+offset.x,first[4]+offset.y,3,0,3,0);
  drawGlyph(rows,room.spawn,room.spriteRows); // Player is drawn separately.
  return {seed,randomState:rng.state,actors,geometry};
}
