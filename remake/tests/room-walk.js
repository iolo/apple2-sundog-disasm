import { createRoomGeometries, roomAt, canLeaveRoom, roomDoorGeometry } from '../js/core/room-walk.js';
import { canStand, tryStep, walkToward } from '../js/core/ship-walk.js';
import { createCityMaps } from '../js/core/city-map.js';
import { createCityGeometry, cityReachability, SHIP_REENTRY } from '../js/core/city-walk.js';
import { campaignSaveCodec } from '../js/core/campaign-saves.js';
import { createCharacter } from '../js/core/character.js';
import { populateRoom, roomStaffFallback } from '../js/core/room-actors.js';
import { initialRoomTraffic } from '../js/core/room-traffic.js';
import { sourceRandom } from '../js/core/random.js';

export async function roomWalkTests(test,equal) {
  const [data,maps,navigation,economy,location,cityData,inventory,ship]=await Promise.all([
    'room-walk','maps','initial-navigation','initial-economy','initial-location','city-walk','ship-inventory','ship-walk',
  ].map(n=>fetch(`../data/${n}.json`).then(r=>r.json())));
  const rooms=createRoomGeometries(data),map=createCityMaps(maps,navigation,economy)['city-01'];
  const city=createCityGeometry(map,cityData,{...location,position:location.shipPosition});city.rooms=rooms;
  const codec=campaignSaveCodec({navigation,economy,location,inventory},ship,city);
  const fresh=()=>codec.create({...createCharacter(),name:'Room pilot'},12345);
  const rejects=run=>{let error;try{run()}catch(e){error=e.message}equal(error,'invalidCampaign')};
  await test('Every supported room has a clear entry, connected doorway and solid counter/wall collision',()=>{
    const counts=[6310,6327,6381,6256,6196,6213,6196,6213];
    for(const room of Object.values(rooms).filter(r=>r.index>=8)) {
      equal(room.spawn,{x:12,y:56});equal(room.collisionRows,Array(8).fill(127));
      equal(canLeaveRoom(room,room.spawn),true);equal(canLeaveRoom(room,{x:13,y:56}),false);
      const reached=cityReachability(room);let count=0;
      for(let y=7;y<96;y++)for(let x=0;x<134;x++)if(reached({x,y}))count++;
      equal(count,counts[room.index-8]);equal(reached({x:40,y:50}),true);
      equal(reached({x:40,y:10}),false);equal(reached({x:136,y:50}),false);
      const counter=data.layouts.find(r=>r.index===room.index).bounds[2];
      equal(canStand(room,{x:counter.left,y:counter.bottom}),false);
      const behind=room.index<12 ? {x:116,y:50} : {x:40,y:84};
      equal(canStand(room,behind),true);equal(reached(behind),false);
      let p={x:40,y:50};for(let i=0;i<80;i++)p=walkToward(room,p,{x:130,y:90});
      equal(reached(p),true);equal(p.x<124||p.y<86,true);
      equal(tryStep(room,room.spawn,2,0),{x:14,y:56});
    }
  });
  await test('Room selection follows source tile coordinates, excludes incomplete types and owns geometry',()=>{
    for(const [p,index] of [[{x:311,y:267},15],[{x:395,y:300},11],[{x:675,y:268},8]])equal(roomAt(rooms,map,p).index,index);
    equal(roomAt(rooms,map,{x:369,y:299}),null);equal(roomAt(rooms,map,{x:287,y:217}),null);
    const source=data.layouts.find(r=>r.index===8),original=source.rows[0][0];rooms[8].backgrounds.ship[0][0]=0;
    equal(source.rows[0][0],original);rooms[8].backgrounds.ship[0][0]=original;
  });
  await test('Room saves validate both the street door and reachable interior, without accepting invented room metadata',()=>{
    const state=fresh();state.ship.position={...SHIP_REENTRY};state.ship.minutes=135;
    state.travel={scene:'room',cityPosition:{x:311,y:267},roomPosition:{x:40,y:50}};
    const save=codec.make(state,0),loaded=codec.parse(JSON.stringify(save));equal(loaded,save);
    equal(loaded.version,17);equal(loaded.scope,'landed-trader-matching-1');equal(loaded.state.start,fresh().start);
    loaded.state.travel.roomPosition.x++;equal(save.state.travel.roomPosition.x,40);
    for(const mutate of [s=>s.travel.cityPosition={x:369,y:299},s=>s.travel.cityPosition={x:287,y:217},
      s=>s.travel.roomPosition={x:40,y:10},s=>s.travel.roomPosition={x:40.5,y:50},s=>s.travel.roomPosition.x=140,
      s=>delete s.travel.roomPosition,s=>s.travel.roomIndex=15,s=>s.travel.roomPosition.extra=1,
      s=>s.travel.scene='city',s=>s.ship.position={x:54,y:110}]) {
      const bad=structuredClone(save);mutate(bad.state);rejects(()=>codec.validate(bad));
    }
  });
  await test('Version4 ship, city and bank migrate unchanged and cannot introduce room state',()=>{
    for(const scene of ['ship','city','bank']) {
      const state=fresh();
      if(scene!=='ship'){state.ship.position={...SHIP_REENTRY};state.travel={scene,cityPosition:scene==='bank' ? {x:369,y:299} : {...city.spawn}}}
      const old=codec.make(state,0);old.version=4;delete old.state.pod;delete old.state.economy;old.scope='landed-bank-1';delete old.state.encounters;delete old.state.dialogue;
      const before=JSON.stringify(old),loaded=codec.parse(before);equal(loaded.state,{...old.state,encounters:state.encounters,dialogue:state.dialogue,economy:state.economy,pod:state.pod});equal(loaded.version,17);equal(JSON.stringify(old),before);
      old.state.travel={scene:'room',cityPosition:{x:311,y:267},roomPosition:{x:12,y:56}};
      rejects(()=>codec.validate(old));
    }
  });
  await test('Initial occupants match 64 independent pixel-grid references including retries and tenth-candidate rejection',async()=>{
    const vectors=await fetch('./fixtures/room-population.json').then(r=>r.json());
    equal(vectors.some(v=>v.attempts.some(a=>a.attempts===10&&a.clear)),true);
    for(const v of vectors) {
      const p=populateRoom(rooms[v.index],v.seed),rng=sourceRandom(v.seed);
      if(v.legacyError)equal(p.actors.length,1);
      for(let i=0;i<v.draws;i++)rng.next();
      equal(p.randomState,v.randomState);equal(p.randomState,rng.state);equal(p.actors,v.actors);
      equal(canStand(p.geometry,rooms[v.index].spawn),true);
    }
  });
  await test('Every fallback anchor keeps staff on the clear side of the counter in all thirteen layouts',()=>{
    for(const room of Object.values(rooms)) {
      const {bounds:b,offset}=room.population,staff={...room,collisionRows:room.counterCollisionRows};
      for(let x=b.left;x<=b.right;x++)for(let y=b.top;y<=b.bottom;y++) {
        const p=roomStaffFallback(room,{x,y});equal(canStand(staff,p),true);
        equal(p.x-offset.x>=b.left&&p.x-offset.x<=b.right&&p.y-offset.y>=b.top&&p.y-offset.y<=b.bottom,true);
        if(canStand(staff,{x:x+offset.x,y:y+offset.y}))equal(p,{x:x+offset.x,y:y+offset.y});
      }
      const p=populateRoom(room,0);equal(p.actors.length,1);equal(canStand(p.geometry,room.spawn),true);
    }
  });
  await test('Occupant pixels block walking, own their collision overlay, and keep the doorway reachable in all eight rooms',()=>{
    for(const room of Object.values(rooms).filter(r=>r.index>=8)) {
      const before=JSON.stringify(room),p=populateRoom(room,12345),reached=cityReachability(p.geometry);
      const visitor=p.actors[0].words,point={x:visitor[5],y:visitor[4]};
      equal(canStand(room,point),true);equal(canStand(p.geometry,point),false);
      equal(reached({x:40,y:50}),true);equal(reached(room.spawn),true);
      equal(JSON.stringify(room),before);p.geometry.backgrounds.ship[0][0]=0;equal(JSON.stringify(room),before);
      equal(populateRoom(room,12345).actors,p.actors);
    }
  });
  await test('Tavern fixtures keep six seats reachable and lodging doors independently open four bedrooms',()=>{
    for(const index of [4,5,6,7]) {
      const room=rooms[index],reached=cityReachability(room);
      equal(room.fixtures.seats.length,6);
      for(const seat of room.fixtures.seats)equal(reached(seat),true);
      for(const x of [23,60,97])equal(canStand(room,{x,y:86}),false);
    }
    const room=rooms[1],before=JSON.stringify(room),closed=cityReachability(room);
    equal(canLeaveRoom(room,room.spawn),true);
    for(let i=0;i<4;i++) {
      const open=roomDoorGeometry(room,Array.from({length:4},(_,j)=>j===i)),reached=cityReachability(open);
      for(let j=0;j<4;j++) {
        const bedroom={x:28+28*j,y:22};
        equal(closed(bedroom),false);equal(reached(bedroom),i===j);
      }
      open.backgrounds.ship[0][0]=0;equal(JSON.stringify(room),before);
    }
    equal(roomDoorGeometry(room,[false,false,false,false]).backgrounds,room.backgrounds);
  });
  await test('Version7 resumes the exact room population and validates its live actors and occupied positions',()=>{
    const state=fresh(),room=rooms[15],seed=state.encounters.randomState,p=populateRoom(room,seed);
    equal(seed,state.start.gameplayRandomState);
    state.ship.position={...SHIP_REENTRY};state.travel={scene:'room',cityPosition:{x:311,y:267},roomPosition:{x:40,y:50}};
    state.encounters={randomState:p.randomState,roomSeed:seed,roomState:initialRoomTraffic(p),counter:{service:'idle',conversation:null}};
    const saved=codec.make(state,0),loaded=codec.parse(JSON.stringify(saved));equal(loaded,saved);
    equal(populateRoom(room,loaded.state.encounters.roomSeed).actors,p.actors);
    const npc=p.actors[0].words;
    for(const mutate of [s=>s.encounters.roomState.active=99,s=>s.encounters.roomSeed=-1,
      s=>s.encounters.roomSeed=1.5,s=>s.encounters.randomState=2**32,s=>s.encounters.actors=p.actors,
      s=>delete s.encounters,s=>s.travel.roomPosition={x:npc[5],y:npc[4]},
      s=>s.travel={scene:'city',cityPosition:{x:311,y:267}}]) {
      const bad=structuredClone(saved);mutate(bad.state);rejects(()=>codec.validate(bad));
    }
    const next=populateRoom(room,p.randomState);
    equal(next.randomState===p.randomState,false);equal(JSON.stringify(next.actors)===JSON.stringify(p.actors),false);
    loaded.state.encounters.roomSeed=null;equal(saved.state.encounters.roomSeed,seed);
  });
  await test('An all-failed placement retains staff, roundtrips live saves and remains invalid as a version6 population',()=>{
    const state=fresh(),room=rooms[15],p=populateRoom(room,0);
    equal(p.actors.length,1);equal(p.actors[0].slot,0);equal(p.randomState,0);
    state.ship.position={...SHIP_REENTRY};state.travel={scene:'room',cityPosition:{x:311,y:267},roomPosition:{...room.spawn}};
    state.encounters={randomState:p.randomState,roomSeed:p.seed,roomState:initialRoomTraffic(p),counter:{service:'idle',conversation:null}};
    const saved=codec.make(state,0);equal(codec.parse(JSON.stringify(saved)),saved);
    const old=structuredClone(saved);old.version=6;delete old.state.pod;delete old.state.economy;old.scope='landed-occupants-1';
    delete old.state.encounters.roomState;delete old.state.encounters.counter;delete old.state.dialogue;
    rejects(()=>codec.validate(old));
    equal(codec.validate(saved),saved); // A cached population cannot bypass the legacy check.
  });
  await test('Version5 occupied-position saves migrate as empty interiors; legacy records cannot smuggle encounter state',()=>{
    const state=fresh();state.ship.position={...SHIP_REENTRY};
    state.travel={scene:'room',cityPosition:{x:311,y:267},roomPosition:{x:46,y:71}};
    const old=codec.make(state,0);old.version=5;delete old.state.pod;delete old.state.economy;old.scope='landed-rooms-1';delete old.state.encounters;delete old.state.dialogue;
    const before=JSON.stringify(old),next=codec.parse(before);
    equal(next.state.travel,old.state.travel);equal(next.state.encounters,{randomState:state.start.gameplayRandomState,roomSeed:null,roomState:null,counter:null});
    equal(JSON.stringify(old),before);old.state.encounters=next.state.encounters;rejects(()=>codec.validate(old));
  });
  await test('Version6 migration verifies the original population RNG tail before adding mutable actors',()=>{
    const state=fresh(),p=populateRoom(rooms[15],state.encounters.randomState);
    state.ship.position={...SHIP_REENTRY};state.travel={scene:'room',cityPosition:{x:311,y:267},roomPosition:{x:40,y:50}};
    state.encounters={randomState:p.randomState,roomSeed:p.seed,roomState:initialRoomTraffic(p),counter:{service:'idle',conversation:null}};
    const old=codec.make(state,0);old.version=6;delete old.state.pod;delete old.state.economy;old.scope='landed-occupants-1';delete old.state.encounters.roomState;delete old.state.encounters.counter;delete old.state.dialogue;
    const before=JSON.stringify(old),next=codec.parse(before);
    equal(next.state.encounters.roomState,initialRoomTraffic(p));equal(next.state.encounters.randomState,p.randomState);
    equal(JSON.stringify(old),before);
    old.state.encounters.randomState++;rejects(()=>codec.validate(old));
    old.state.encounters.randomState=p.randomState;old.state.encounters.roomState=initialRoomTraffic(p);rejects(()=>codec.validate(old));
  });
}
