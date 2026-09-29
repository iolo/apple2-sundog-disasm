import { composeCityMap, createCityMaps, cityWindow, cityOrigin } from '../js/core/city-map.js';
import { createPreview, reducePreview } from '../js/core/preview.js';
import { sourceRandom } from '../js/core/random.js';

export async function cityMapTests(test,equal) {
  const [maps,navigation,economy,reference]=await Promise.all([
    '../data/maps.json','../data/initial-navigation.json','../data/initial-economy.json',
    'fixtures/city-map-reference.json',
  ].map(path=>fetch(path).then(r=>r.json())));
  const before=JSON.stringify({maps,navigation,economy});
  const cities=createCityMaps(maps,navigation,economy);
  await test('All 57 ordinary cities match independent packed-byte composition and bank references',async()=>{
    equal(Object.keys(cities).length,57);
    for(const record of reference.records) {
      const city=cities[record.cityId];
      const digest=await crypto.subtle.digest('SHA-256',new Uint8Array(city.tiles.flat()));
      equal(Array.from(new Uint8Array(digest),v=>v.toString(16).padStart(2,'0')).join(''),record.sha256);
      equal(city.banks,record.banks);
    }
  });
  await test('City margins are zero and every interior variant retains its stored nibble',()=>{
    for(const record of maps.cities.slice(0,57)) {
      const map=cities[record.id];equal(map.tiles.length,24);
      for(let y=0;y<24;y++) {
        equal(map.tiles[y].length,40);
        for(let x=0;x<40;x++) {
          const tile=map.tiles[y][x];
          equal(tile>=0&&tile<32,true);
          equal(x>=10&&x<30&&y>=6&&y<18 ? tile%16 : tile,
            x>=10&&x<30&&y>=6&&y<18 ? record.tiles[y-6][x-10] : 0);
        }
      }
    }
  });
  await test('Map regeneration owns its rows and never consumes a campaign random stream or content',()=>{
    const random=sourceRandom(123456),state=random.state;
    const other=createCityMaps(maps,navigation,economy);
    equal(other,cities);equal(random.state,state);equal(JSON.stringify({maps,navigation,economy}),before);
    other['city-01'].tiles[0][0]=31;other['city-01'].banks[0]=3;
    equal(cities['city-01'].tiles[0][0],0);equal(cities['city-01'].banks,[0,0]);
    equal(other['city-01'].tiles[1][0],0);
  });
  await test('City composition refuses unnamed/reserved/colony records, invalid nibbles and missing membership',()=>{
    const location={systemId:'system-01',worldId:'world-01'};
    const rejects=run=>{let rejected=false;try{run()}catch{rejected=true}equal(rejected,true)};
    for(const record of [null,...maps.cities.slice(57),{...maps.cities[0],tiles:[]},
      {...maps.cities[0],tiles:Array.from({length:12},()=>Array(20).fill(16))}]) rejects(()=>composeCityMap(record,location));
    for(const bad of [{},null,{systemId:'system-00',worldId:'world-01'},{systemId:'system-01',worldId:'world-19'}]) {
      rejects(()=>composeCityMap(maps.cities[0],bad));
    }
    rejects(()=>createCityMaps({...maps,cities:[]},navigation,economy));
    rejects(()=>createCityMaps(maps,{systems:[]},economy));
    for(const origin of [{x:40,y:0},{x:0,y:19},{x:0.5,y:0}]) rejects(()=>cityWindow(cities['city-01'],origin));
  });
  await test('Ten by six city window resolves both banks, wraps columns and preserves row order',()=>{
    const map={banks:[2,3],tiles:Array.from({length:24},(_,y)=>Array.from({length:40},(_,x)=>(x+y)%32))};
    const window=cityWindow(map,{x:38,y:18});
    equal(window.length,6);equal(window[0].length,10);
    equal(window[0][0],{x:38,y:18,tile:24,bank:3,index:8});
    equal(window[5][2],{x:0,y:23,tile:23,bank:3,index:7});
    equal(window[0][9],{x:7,y:18,tile:25,bank:3,index:9});
    equal(cityWindow(map,{x:0,y:0})[0][0].bank,2);
    equal(cityOrigin(),{x:15,y:9});equal(cityOrigin({x:0,y:0}),{x:35,y:0});
    equal(cityOrigin({x:39,y:23}),{x:34,y:18});
  });
  await test('Preview camera bounds, record reset and mode changes do not affect stored bank or other indices',()=>{
    const counts={cities:60,worlds:18,ship:2};
    let state={...createPreview(),view:'cities',cityMode:'composed',bank:3};
    const reduce=action=>{state=reducePreview(state,action,counts)};
    for(let i=0;i<40;i++) reduce({type:'city-pan',dx:1,dy:0});equal(state.cityOrigin,{x:15,y:9});
    for(let i=0;i<24;i++) reduce({type:'city-pan',dx:0,dy:1});equal(state.cityOrigin.y,18);
    for(let i=0;i<24;i++) reduce({type:'city-pan',dx:0,dy:-1});equal(state.cityOrigin.y,0);
    reduce({type:'select',point:{x:4,y:2}});reduce({type:'city-pan',dx:-1,dy:0});equal(state.selection,null);
    reduce({type:'step',delta:1});equal(state.cityOrigin,cityOrigin());equal(state.indices.worlds,0);
    reduce({type:'city-mode',mode:'stored'});equal(state.bank,3);
    const previous=state;reduce({type:'city-pan',dx:1,dy:0});equal(state,previous);
    reduce({type:'city-mode',mode:'bad'});equal(state,previous);
  });
}
