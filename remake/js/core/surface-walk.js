const wrap=(n,size)=>((n%size)+size)%size;
const integer=(n,min,max)=>Number.isInteger(n)&&n>=min&&n<=max;
export const SURFACE_SIZE=Object.freeze({width:1120,height:576});

// Game21 proc23 uses collision glyph15 in BOTH modes; no terrain-type whitelist.
export function createSurfaceGeometry(map,content) {
  if(map.tiles.length!==24||map.tiles.some(r=>r.length!==40||r.some(t=>!integer(t,0,20))))throw new Error('Invalid surface tiles');
  const rows=Array.from({length:576},()=>Array(160).fill(0));
  for(let y=0;y<24;y++)for(let x=0;x<40;x++)for(let py=0;py<24;py++)for(let b=0;b<4;b++)
    rows[y*24+py][x*4+b]=content.tiles[map.tiles[y][x]][py][b]&content.collisionByteMasks[b%2];
  return {...SURFACE_SIZE,map,backgrounds:{ship:rows},collisionRows:[...content.collisionRows]};
}

// Native scrolling wraps map coordinates. Test each glyph pixel across seams;
// ordinary canStand's hard image boundary is inappropriate for a whole world.
export function canStandSurface(geometry,position) {
  if(!integer(position?.x,0,1119)||!integer(position?.y,0,575))return false;
  return geometry.collisionRows.every((mask,row)=>{
    for(let bit=0;bit<7;bit++)if(mask&(1<<bit)) {
      const x=wrap(position.x+bit,1120),y=wrap(position.y-7+row,576);
      if(geometry.backgrounds.ship[y][Math.floor(x/7)]&(1<<(x%7)))return false;
    }
    return true;
  });
}

export function trySurfaceStep(geometry,position,dx,dy) {
  // Proc11 can place an arrival anchor over city artwork. Proc12 tests the
  // destination only, allowing escape from that source-selected overlap.
  if(!integer(position?.x,0,1119)||!integer(position?.y,0,575)||!integer(dx,-2,2)||!integer(dy,-2,2)||(!dx&&!dy))return position;
  const attempts=[[dx,dy],[dx,0],[0,dy]];
  if(Math.abs(dx)>1||Math.abs(dy)>1)attempts.push([Math.sign(dx),Math.sign(dy)],[Math.sign(dx),0],[0,Math.sign(dy)]);
  for(const [x,y] of attempts)if(x||y) {
    const next={x:wrap(position.x+x,1120),y:wrap(position.y+y,576)};
    if(canStandSurface(geometry,next))return next;
  }
  return position;
}

// Proc21 checks the sprite center's tile before dispatching proc18.
export function surfaceCityAt(map,position) {
  if(!integer(position?.x,0,1119)||!integer(position?.y,0,575))return null;
  const x=Math.floor(wrap(position.x+3,1120)/28),y=Math.floor(wrap(position.y-3,576)/24);
  if(map.tiles[y][x]!==13)return null;
  return map.cities.find(c=>c.position.x===x&&c.position.y===y)??null;
}

// Proc17 includes a one-tile border around the drawn city rectangle.
export function cityTravelBounds(size=9) {
  if(!integer(size,0,9))throw new Error('Invalid city size');
  const half=Math.floor((size+1)/2);
  return {left:18-size,right:21+size,top:10-half,bottom:13+half};
}

// Proc11 receives the attempted camera origin from proc12, not the player tile.
export function citySurfaceExit(origin,city,size=9) {
  cityTravelBounds(size);
  if(!Number.isInteger(origin?.x)||!Number.isInteger(origin?.y)||
      !integer(city?.position?.x,0,39)||!integer(city?.position?.y,0,23))throw new Error('Invalid city exit');
  const half=Math.floor((size+1)/2);
  let x=11,y=16;
  if(origin.x<12-size)x=0;else if(origin.x>17+size)x=21;
  if(origin.y<7-half)y=7;else if(origin.y>11+half)y=23;
  if(x===11&&y===16)return null;
  return {x:city.position.x*28+x,y:city.position.y*24+y};
}

// Proc18 $08FA–$0999: center fractions, side priority, saved anchor160/108.
export function surfaceCityEntry(map,position,size=9) {
  const city=surfaceCityAt(map,position);if(!city)return null;
  const b=cityTravelBounds(size),x=wrap(position.x+3,28),y=wrap(position.y-3,24);
  let tx=b.left+Math.floor((b.right-b.left+1)*x/28),ty=b.top+Math.floor((b.bottom-b.top+1)*y/24),direction;
  if(x<7){tx=b.left;direction=8}
  else if(y<12){ty=b.top;direction=6}
  else if(x>20){tx=b.right;direction=2}
  else {ty=b.bottom;direction=4}
  return {cityId:city.cityId,position:{x:tx*28+20,y:ty*32+12},direction};
}
