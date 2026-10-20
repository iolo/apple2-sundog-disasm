import { sourceRandom } from './random.js';

const integer=(n,min,max)=>Number.isInteger(n)&&n>=min&&n<=max;
const point=p=>integer(p?.x,0,39)&&integer(p?.y,0,23);

// Game21 proc28 $1136–$11AD: private world seed, X-major traversal, restore
// gameplay RNG. Tile13 on disk is NOT a city; city records are overlaid later.
export function composeSurfaceMap(record,cities) {
  if(!/^world-(0[1-9]|1[0-8])$/.test(record?.id)||
      !Array.isArray(record.tiles)||record.tiles.length!==24||
      record.tiles.some(r=>!Array.isArray(r)||r.length!==40||r.some(t=>!integer(t,0,13)))||
      !Array.isArray(cities))throw new Error('Invalid surface map');
  const world=Number(record.id.slice(6)),random=sourceRandom(((11*world+51)*65536+3*world+39)>>>0);
  const tiles=record.tiles.map(r=>[...r]),local=cities.filter(c=>c.worldId===record.id);
  for(let x=0;x<40;x++)for(let y=0;y<24;y++)if(tiles[y][x]===13)tiles[y][x]=14+random.next()%7;
  const occupied=new Set(),ids=new Set();
  for(const c of local) {
    if(!/^city-(0[1-9]|[1-4][0-9]|5[0-7])$/.test(c.cityId)||!point(c.position)||
        occupied.has(c.position.y*40+c.position.x)||ids.has(c.cityId))throw new Error('Invalid surface city');
    occupied.add(c.position.y*40+c.position.x);ids.add(c.cityId);
    tiles[c.position.y][c.position.x]=13;
  }
  return {worldId:record.id,tiles,cities:structuredClone(local)};
}

// Game21 $1215–$126D. New colony placement alone consumes gameplay RNG;
// subsequent visits overlay the persisted coordinate without drawing again.
export function placeSurfaceColony(map,randomState,position=null) {
  if(map.worldId!=='world-01')throw new Error('Invalid colony world');
  const random=sourceRandom(randomState);
  if(position!==null&&!point(position))throw new Error('Invalid colony position');
  if(position===null) {
    if(!map.tiles.some(r=>r.some(t=>t>=14)))throw new Error('No colony terrain');
    // These two source RNG states cannot escape zero; reject instead of hanging.
    if(randomState===0||randomState===0x80000000)throw new Error('Invalid colony random state');
    do {const index=random.next()%960;position={x:index%40,y:Math.floor(index/40)}}
    while(map.tiles[position.y][position.x]<14);
  }
  if(map.cities.some(c=>c.position.x===position.x&&c.position.y===position.y))throw new Error('Occupied colony position');
  const tiles=map.tiles.map(r=>[...r]);tiles[position.y][position.x]=13;
  return {map:{...map,tiles,cities:[...structuredClone(map.cities),{cityId:'city-60',worldId:'world-01',position:{...position}}]},
    randomState:random.state,position:{...position}};
}
