import { canStand } from './ship-walk.js';

export const SHIP_REENTRY = Object.freeze({x:54,y:118}); // Game15 $060E–$061B.

// The legacy surfacePosition holds the active map tile, including in a city.
// Game21 procedures7/13 recover sub-tile offsets from the saved anchors.
export function cityShipAnchor(location) {
  return {x:location.surfacePosition.x*28+location.position.x%28,
    y:location.surfacePosition.y*32+location.position.y%32};
}

export function createCityGeometry(map, content, location) {
  const width=1120,height=768,shipAnchor=cityShipAnchor(location);
  const rows=Array.from({length:height},()=>Array(width/7).fill(127));
  // Limit this checkpoint to the stored city rectangle. Crossing into surface
  // travel needs a separate transition; the guard is an explicit browser limit.
  for(let y=6;y<18;y++) for(let x=10;x<30;x++) {
    const tile=map.tiles[y][x],bank=map.banks[Math.floor(tile/16)];
    const pixels=content.banks[bank][tile%16];
    for(let py=0;py<32;py++) for(let byte=0;byte<4;byte++) rows[y*32+py][x*4+byte]=pixels[py][byte];
  }
  // Game21 proc7 replaces glyphs36/37, then XORs attached-pod glyph16.
  // shipRows already contains that combination. Clear zero bits as well.
  for(let y=0;y<8;y++) for(let x=0;x<14;x++) {
    const px=shipAnchor.x+x,py=shipAnchor.y-7+y,byte=Math.floor(px/7),bit=1<<(px%7);
    rows[py][byte]=(rows[py][byte]&~bit)|((content.shipRows[y][Math.floor(x/7)]&(1<<(x%7))) ? bit : 0);
  }
  // Library22 collision pattern9 ignores the background's alternating columns.
  for(const row of rows) for(let byte=0;byte<row.length;byte++) row[byte]&=content.collisionByteMasks[byte%2];
  return {width,height,map,backgrounds:{ship:rows},collisionRows:[...content.collisionRows],shipAnchor,
    // Game15 proc6 sets exit direction6; game21 $0D06–$0D40 yields +0,+6.
    spawn:{x:shipAnchor.x,y:shipAnchor.y+6},
    walkBounds:{left:280,right:833,top:199,bottom:575}};
}

export function canBoardShip(geometry,position) {
  // Game21 proc21 tile gate, followed by proc15's ±4 pixel foot-entry box.
  const ship=geometry.shipAnchor;
  return canStand(geometry,position)&&Math.floor((position.y-3)/32)===Math.floor(ship.y/32)&&
    Math.abs(Math.floor((position.x+3)/28)-Math.floor(ship.x/28))<=3&&
    Math.abs(position.x-ship.x)<=4&&Math.abs(position.y-ship.y)<=4;
}

export function cityCamera(position) {
  return {x:Math.max(0,Math.min(30,Math.floor(position.x/28)-5)),
    y:Math.max(0,Math.min(18,Math.floor(position.y/32)-3))};
}

// Compact flood fill keeps imported positions on the component reachable from
// the airlock. Include all one/two-pixel requests supported by actual movement.
export function cityReachability(geometry) {
  const {width,height}=geometry,seen=new Uint8Array(width*height),queue=new Int32Array(width*height);
  const start=geometry.spawn.y*width+geometry.spawn.x;
  if(!canStand(geometry,geometry.spawn)) throw new Error('Blocked city airlock');
  let head=0,tail=1;queue[0]=start;seen[start]=1;
  while(head<tail) {
    const index=queue[head++],x=index%width,y=Math.floor(index/width);
    for(let dy=-2;dy<=2;dy++) for(let dx=-2;dx<=2;dx++) {
      if(!dx&&!dy)continue;
      const p={x:x+dx,y:y+dy},next=p.y*width+p.x;
      if(!seen[next]&&canStand(geometry,p)) {seen[next]=1;queue[tail++]=next}
    }
  }
  return point=>Number.isInteger(point?.x)&&Number.isInteger(point?.y)&&point.x>=0&&point.x<width&&point.y>=0&&point.y<height&&!!seen[point.y*width+point.x];
}
