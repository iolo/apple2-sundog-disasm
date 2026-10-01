import { cityDoorAt, atCityBank, cityServiceAt } from '../js/core/city-doors.js';
import { createCityMaps } from '../js/core/city-map.js';
import { createCityGeometry, cityReachability, SHIP_REENTRY } from '../js/core/city-walk.js';
import { campaignSaveCodec } from '../js/core/campaign-saves.js';
import { createCharacter } from '../js/core/character.js';

export async function cityDoorTests(test,equal) {
  await test('Door footprints use inclusive source boundaries and tile lookup independently of bank variants',()=>{
    // Values transcribed from game21 proc19, including the two pod-only branches.
    const expected=[
      [7,'foot',14,30,3,1],[8,'foot',1,15,5,8],[9,'foot',2,16,5,9],
      [10,'foot',1,15,5,10],[11,'foot',1,21,5,11],[12,'foot',6,28,6,1],
      [13,'foot',1,18,6,2],[14,'foot',1,15,6,3],[14,'pod',2,22,6,3],
      [15,'foot',2,15,6,5],[15,'pod',14,21,6,4],
    ];
    for(let tile=0;tile<32;tile++)for(const mode of ['foot','pod']) {
      const map={tiles:Array.from({length:4},()=>Array(4).fill(tile))};
      for(let y=32;y<64;y++)for(let x=28;x<56;x++) {
        const match=expected.find(([base,vehicle,dx,dy])=>base===tile%16 && vehicle===mode &&
          (x-3)%28>=dx-4 && (x-3)%28<=dx+4 && (y+3)%32>=dy-4 && (y+3)%32<=dy+4);
        equal(cityDoorAt(map,{x,y},mode),match ? {tileX:Math.floor((x+3)/28),tileY:Math.floor((y-3)/32),tile:tile%16,scene:match[4],type:match[5]} : null);
      }
    }
    for(const p of [null,{x:1,y:1},{x:40.5,y:48},{x:1120,y:768}])equal(cityDoorAt({tiles:[]},p),null);
    equal(cityDoorAt({tiles:[]},{x:40,y:48}),null);
  });
  const [maps,navigation,economy,location,cityContent,inventory,shipGeometry]=await Promise.all([
    'maps','initial-navigation','initial-economy','initial-location','city-walk','ship-inventory','ship-walk',
  ].map(name=>fetch(`../data/${name}.json`).then(r=>r.json())));
  const map=createCityMaps(maps,navigation,economy)['city-01'];
  const geometry=createCityGeometry(map,cityContent,{...location,position:location.shipPosition});
  const codec=campaignSaveCodec({navigation,economy,location,inventory},shipGeometry,geometry);
  const fresh=()=>codec.create({...createCharacter(),name:'Bank pilot'},12345);
  const rejects=run=>{let error;try{run()}catch(e){error=e.message}equal(error,'invalidCampaign')};
  const reachable=cityReachability(geometry),serviceDoors={};
  for(let y=6;y<18;y++)for(let x=10;x<30;x++) {
    for(let dy=0;dy<32;dy++)for(let dx=0;dx<28;dx++) {
      const p={x:x*28+dx,y:y*32+dy},service=cityServiceAt(map,p);
      if(service&&!serviceDoors[service]&&reachable(p))serviceDoors[service]=p;
    }
  }
  await test('Every foot service dispatch has a reachable source door and preserves state through version11 saves',()=>{
    for(const scene of ['transstation','bank','depot','exchange']) {
      equal(!!serviceDoors[scene],true);
      const state=fresh();state.ship.position={...SHIP_REENTRY};state.travel={scene,cityPosition:{...serviceDoors[scene]}};
      const before=JSON.stringify(state),save=codec.make(state,0),loaded=codec.parse(JSON.stringify(save));
      equal(loaded.state,state);equal(JSON.stringify(state),before);
      loaded.state.travel.cityPosition.x++;equal(save.state.travel.cityPosition,state.travel.cityPosition);
      for(const mutate of [s=>s.travel.cityPosition={...geometry.spawn},s=>s.travel.service=scene,
        s=>s.travel.scene=scene==='bank'?'exchange':'bank',s=>s.ship.position={x:50,y:99},
        s=>s.encounters.roomSeed=0,s=>s.travel.cityPosition={x:0,y:0}]) {
        const bad=structuredClone(save);mutate(bad.state);rejects(()=>codec.validate(bad));
      }
    }
  });
  await test('Version10 migration preserves existing scenes and rejects newly introduced service scenes',()=>{
    for(const scene of ['ship','city','bank']) {
      const state=fresh();
      if(scene!=='ship'){state.ship.position={...SHIP_REENTRY};state.travel={scene,cityPosition:{...(scene==='bank'?serviceDoors.bank:geometry.spawn)}}}
      const old=codec.make(state,0);old.version=10;delete old.state.pod;delete old.state.economy;old.scope='landed-taverns-1';
      const before=JSON.stringify(old);equal(codec.parse(before).state,state);equal(JSON.stringify(old),before);
    }
    for(const scene of ['transstation','depot','exchange']) {
      const state=fresh();state.ship.position={...SHIP_REENTRY};state.travel={scene,cityPosition:serviceDoors[scene]};
      const old=codec.make(state,0);old.version=10;delete old.state.pod;delete old.state.economy;old.scope='landed-taverns-1';rejects(()=>codec.validate(old));
    }
  });
  await test('Bank saves require reachable bank doors and roundtrip without changing campaign balances or progress',()=>{
    const state=fresh();state.ship.position={...SHIP_REENTRY};state.ship.minutes=123;
    state.travel={scene:'bank',cityPosition:{x:369,y:299}};
    equal(atCityBank(map,state.travel.cityPosition),true);
    const save=codec.make(state,1),loaded=codec.parse(JSON.stringify(save));
    equal(loaded,save);equal(loaded.version,17);equal(loaded.scope,'landed-trader-matching-1');
    equal(loaded.state.start,fresh().start);equal(loaded.state.ship.minutes,123);
    loaded.state.travel.cityPosition.x++;equal(save.state.travel.cityPosition.x,369);
    for(const mutate of [s=>s.travel.cityPosition={...geometry.spawn},s=>s.travel.cityPosition={x:368,y:299},
      s=>s.ship.position={x:54,y:110},s=>s.travel.cityPosition.extra=true,s=>s.travel.bankBalance=1,
      s=>s.travel.scene='shop',s=>s.start.credits++,s=>s.start.systems[0].bankBalance++]) {
      const bad=structuredClone(save);mutate(bad.state);rejects(()=>codec.validate(bad));
    }
  });
  await test('Version3 upgrades preserve ship and city state but cannot smuggle bank visits or extra fields',()=>{
    for(const scene of ['ship','city']) {
      const state=fresh();
      if(scene==='city'){state.ship.position={...SHIP_REENTRY};state.travel={scene,cityPosition:{...geometry.spawn}}}
      const old=codec.make(state,0);old.version=3;delete old.state.pod;delete old.state.economy;old.scope='landed-city-1';delete old.state.encounters;delete old.state.dialogue;
      const before=JSON.stringify(old),next=codec.parse(before);
      equal(next.state,{...old.state,encounters:state.encounters,dialogue:state.dialogue,economy:state.economy,pod:state.pod});equal(next.version,17);equal(JSON.stringify(old),before);
      old.state.travel={scene:'bank',cityPosition:{x:369,y:299}};rejects(()=>codec.validate(old));
      old.state.travel={scene:'city',cityPosition:{...geometry.spawn},bank:false};rejects(()=>codec.validate(old));
    }
  });
}
