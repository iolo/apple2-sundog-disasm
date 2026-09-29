import { sourceRandom } from './random.js';

export const CITY_MAP_SIZE = Object.freeze({width:40,height:24});
export const CITY_VIEW_SIZE = Object.freeze({width:10,height:6});
const integer = (n,min,max) => Number.isInteger(n) && n>=min && n<=max;
const wrap = (n,size) => ((n%size)+size)%size;

// Game21 procedure26 ($0F0B–$0FCA) saves/restores the gameplay RNG around
// this private seed. Pascal words are little-endian; x is the outer loop.
// Only ordinary cities are accepted: colony clipping needs live colony state.
export function composeCityMap(record, location) {
  const city = Number(record?.id?.slice(5));
  const system = Number(location?.systemId?.slice(7));
  const world = Number(location?.worldId?.slice(6));
  if (!/^city-(0[1-9]|[1-4][0-9]|5[0-7])$/.test(record?.id) ||
      !/^system-(0[1-9]|1[0-2])$/.test(location?.systemId) ||
      !/^world-(0[1-9]|1[0-8])$/.test(location?.worldId) ||
      !Array.isArray(record.tiles) || record.tiles.length!==12 ||
      record.tiles.some(row=>!Array.isArray(row) || row.length!==20 ||
        row.some(tile=>!integer(tile,0,15)))) throw new Error('Invalid ordinary city map');
  const random = sourceRandom(((11*city+51)*65536 + 3*city+39)>>>0);
  const tiles = Array.from({length:24},()=>Array(40).fill(0));
  for(let x=0;x<20;x++) for(let y=0;y<12;y++) {
    tiles[y+6][x+10] = record.tiles[y][x] + 16*(random.next()%2);
  }
  // Game21 $0FD1–$0FEC / procedure3: two separate 16-tile banks.
  return {cityId:record.id,tiles,banks:[(system-1)%4,(world-1)%4]};
}

// Library23 procedure3 wraps columns at40, then reads consecutive rows.
// The inspector clamps its vertical camera to keep all six rows in bounds.
// Its initial center and scrolling are presentation, not player coordinates.
export function cityOrigin(center={x:20,y:12}) {
  if(!integer(center?.x,0,39)||!integer(center?.y,0,23)) throw new Error('Invalid city center');
  return {x:wrap(center.x-5,40),y:Math.min(18,Math.max(0,center.y-3))};
}

export function cityWindow(map, origin) {
  if(!integer(origin?.x,0,39)||!integer(origin?.y,0,18)) throw new Error('Invalid city origin');
  return Array.from({length:6},(_,y)=>Array.from({length:10},(_,x)=>{
    const column=wrap(origin.x+x,40),row=origin.y+y;
    const tile=map.tiles[row][column];
    return {x:column,y:row,tile,bank:map.banks[Math.floor(tile/16)],index:tile%16};
  }));
}

export function createCityMaps(maps, navigation, economy) {
  const result={};
  for(const city of economy.cities) {
    const system=navigation.systems.find(system=>system.worldIds.includes(city.worldId));
    const record=maps.cities.find(record=>record.id===city.id);
    if(!system||!record) throw new Error('Missing city membership');
    result[city.id]={...composeCityMap(record,{systemId:system.id,worldId:city.worldId}),name:city.name};
  }
  return result;
}
