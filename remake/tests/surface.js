import { composeSurfaceMap,placeSurfaceColony } from '../js/core/surface-map.js';
import { createSurfaceGeometry,canStandSurface,trySurfaceStep,surfaceCityAt,cityTravelBounds,citySurfaceExit,surfaceCityEntry } from '../js/core/surface-walk.js';

export async function surfaceTests(test,equal) {
  const [maps,data]=await Promise.all(['maps','surface-walk'].map(n=>fetch(`../data/${n}.json`).then(r=>r.json())));
  const reject=f=>{let failed=false;try{f()}catch{failed=true}equal(failed,true)};
  const map=composeSurfaceMap(maps.worlds[0],data.cities),city=map.cities[0];
  await test('All18 surface maps match independent bit-array RNG reference digests and57 city overlays',async()=>{
    // Python bit-array LFSR reference, independent of sourceRandom's integer shifts.
    const hashes=['aaf6798dcec38e046def8516d636d74074e9e5974da871d0969df2c14125387d','a9542bc463f0f1820b59a6cf4b6a6c7b358b72b8d3a6e8e3fc22e50fd3180180','037a4c5c6d221ea8b26557134598ad1d7c534967d76c0d3358e19943511e9156','45eb5a9eb13aa8e30b62f431ac8c3154762c4039882d66e7f89b1a4815d5099c','9c289d65dff6b9ed83fce4973b8134da957db9e3e63b23bd3fed84171fa3def2','46cd3e72c78b65baf05d8241282798c59ef4c6ba9bf2836b179ef830b3ba11e0','e633c6aefa4435f0753b0b98b2e9ea669bc606074170164101b05125e5cb1a54','407ba7185ed76712d3b85fd88ae63f6249b8fa80e3ab6f9c7ea5a35d2ffa3a78','377a649d14daa6d12c5d5d65405ccc924b92ee9f5ab9891e0bd03123ff348a78','5a8beb5889e557134710c10657d47c4ffa9941579793493ce93f725e66fdc9ce','e7cea6a94ccba3328b2e78a28b9bd1508481333ef33a20f92c8ec109529980ac','cee277135339fbebf2ecba61af0222d1b2871afac246d9a6e0137548c08132ca','fd2a3b96a7472d94418f49978279dfb040ce79196a4d0be6e8fcdba26d660249','6210c933c6ba230142ade7dcfe51026ced0fde16a7c6126808979e0d97e608ac','187869bd7473681b5c5198cbd504d73f4bf271836a1b2bfae8181d70eb751efc','23bf00e23b0c9dfa5d005e0cfcda4ec7de04b36bad8bf24f38cf5142d0c61db2','0187dd3df4ec464772b23edc06c51a0d768f67dcb479fa4d37e70b1476762e56','782b7877e0c087092db5d13cca3a88687295fa1ec8b4584cb7c9d44813bb1e56'];
    const before=JSON.stringify(maps);let count=0;
    for(const [i,record] of maps.worlds.entries()) {
      const m=composeSurfaceMap(record,data.cities);
      const digest=await crypto.subtle.digest('SHA-256',new Uint8Array(m.tiles.flat()));
      equal([...new Uint8Array(digest)].map(v=>v.toString(16).padStart(2,'0')).join(''),hashes[i]);
      equal(m.tiles.flat().filter(t=>t===13).length,m.cities.length);count+=m.cities.length;
    }
    equal(count,57);equal(JSON.stringify(maps),before);
    reject(()=>composeSurfaceMap({...maps.worlds[0],id:'world-19'},data.cities));
    reject(()=>composeSurfaceMap(maps.worlds[0],[city,city]));
  });
  await test('Colony placement consumes gameplay RNG only on initial placement and preserves map inputs',()=>{
    const before=JSON.stringify(map),first=placeSurfaceColony(map,12345);
    equal(first.position,{x:16,y:13});equal(first.randomState,1580217);
    equal(first.map.tiles[13][16],13);equal(first.map.cities.length,6);
    const revisit=placeSurfaceColony(map,98765,first.position);
    equal(revisit.map,first.map);equal(revisit.randomState,98765);equal(JSON.stringify(map),before);
    reject(()=>placeSurfaceColony(map,0));reject(()=>placeSurfaceColony(map,0x80000000));
    reject(()=>placeSurfaceColony(map,1,city.position));reject(()=>placeSurfaceColony({...map,worldId:'world-02'},1));
  });
  await test('Surface terrain collision matches independent pixel stencil across every tile and sub-tile anchor',()=>{
    let clear=0,blocked=0;
    for(let tile=0;tile<21;tile++) {
      const g=createSurfaceGeometry({...map,tiles:Array.from({length:24},()=>Array(40).fill(tile))},data);
      const pixels=data.tiles[tile].map(row=>row.flatMap(byte=>Array.from({length:7},(_,b)=>!!(byte&(1<<b)))));
      const stencil=data.collisionRows.flatMap((mask,y)=>Array.from({length:7},(_,x)=>({x,y,on:!!(mask&(1<<x))}))).filter(p=>p.on);
      for(let y=0;y<24;y++)for(let x=0;x<28;x++) {
        const expected=stencil.every(p=>!pixels[(y+17+p.y)%24][(x+p.x)%28]||(x+p.x)%2===1);
        equal(canStandSurface(g,{x,y}),expected);if(expected)clear++;else blocked++;
      }
    }
    equal(clear>0&&blocked>0,true);
  });
  await test('Surface movement wraps both seams, slides past obstacles and rejects blocked/invalid requests',()=>{
    const g=createSurfaceGeometry({...map,tiles:Array.from({length:24},()=>Array(40).fill(14))},data);
    equal(trySurfaceStep(g,{x:0,y:0},-1,-1),{x:1119,y:575});
    equal(trySurfaceStep(g,{x:1119,y:575},2,2),{x:1,y:1});
    equal(trySurfaceStep(g,{x:0,y:0},3,1),{x:0,y:0});equal(canStandSurface(g,{x:-1,y:0}),false);
    // One-pixel stencil isolates fallback order from art and seam handling.
    const wall={...g,collisionRows:[0,0,0,0,0,0,0,1],backgrounds:{ship:g.backgrounds.ship.map(r=>[...r])}};
    wall.backgrounds.ship[11][1]|=1<<4;
    equal(trySurfaceStep(wall,{x:10,y:10},1,1),{x:11,y:10});
    const solid=createSurfaceGeometry({...map,tiles:Array.from({length:24},()=>Array(40).fill(12))},data);
    equal(trySurfaceStep(solid,{x:100,y:100},1,0),{x:100,y:100});
  });
  await test('City exit uses strict camera thresholds and preserves side offsets for ordinary and colony sizes',()=>{
    equal(cityTravelBounds(),{left:9,right:30,top:5,bottom:18});
    equal(cityTravelBounds(0),{left:18,right:21,top:10,bottom:13});
    equal(citySurfaceExit({x:3,y:2},city),null);equal(citySurfaceExit({x:26,y:16},city),null);
    equal(citySurfaceExit({x:2,y:9},city),{x:336,y:184});
    equal(citySurfaceExit({x:27,y:9},city),{x:357,y:184});
    equal(citySurfaceExit({x:10,y:1},city),{x:347,y:175});
    equal(citySurfaceExit({x:10,y:17},city),{x:347,y:191});
    equal(citySurfaceExit({x:2,y:1},city),{x:336,y:175});
    equal(citySurfaceExit({x:12,y:7},city,0),null);reject(()=>cityTravelBounds(10));
    const g=createSurfaceGeometry(map,data),north=citySurfaceExit({x:10,y:1},city),south=citySurfaceExit({x:10,y:17},city);
    equal(canStandSurface(g,north),false);equal(canStandSurface(g,south),false);
    equal(trySurfaceStep(g,north,0,-1),{x:347,y:174});
    equal(trySurfaceStep(g,south,0,2),{x:347,y:193});
    equal(surfaceCityAt(map,south).cityId,'city-01');
  });
  await test('Surface city contact uses center tile, exact entry fractions and strict side priority',()=>{
    const p=(x,y)=>({x:336+x-3,y:168+y+3});
    equal(surfaceCityAt(map,p(0,0)).cityId,'city-01');
    equal(surfaceCityEntry(map,p(6,11)),{cityId:'city-01',position:{x:272,y:364},direction:8});
    equal(surfaceCityEntry(map,p(7,11)),{cityId:'city-01',position:{x:412,y:172},direction:6});
    equal(surfaceCityEntry(map,p(7,12)),{cityId:'city-01',position:{x:412,y:588},direction:4});
    equal(surfaceCityEntry(map,p(21,12)),{cityId:'city-01',position:{x:860,y:396},direction:2});
    equal(surfaceCityEntry(map,p(21,11)).direction,6);
    equal(surfaceCityEntry(map,{x:0,y:0}),null);
  });
}
