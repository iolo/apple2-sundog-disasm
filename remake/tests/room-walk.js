import { createRoomGeometries, roomAt, canLeaveRoom } from '../js/core/room-walk.js';
import { canStand, tryStep, walkToward } from '../js/core/ship-walk.js';
import { createCityMaps } from '../js/core/city-map.js';
import { createCityGeometry, cityReachability, SHIP_REENTRY } from '../js/core/city-walk.js';
import { campaignSaveCodec } from '../js/core/campaign-saves.js';
import { createCharacter } from '../js/core/character.js';

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
    for(const room of Object.values(rooms)) {
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
    const original=data.layouts[0].rows[0][0];rooms[8].backgrounds.ship[0][0]=0;
    equal(data.layouts[0].rows[0][0],original);rooms[8].backgrounds.ship[0][0]=original;
  });
  await test('Room saves validate both the street door and reachable interior, without accepting invented room metadata',()=>{
    const state=fresh();state.ship.position={...SHIP_REENTRY};state.ship.minutes=135;
    state.travel={scene:'room',cityPosition:{x:311,y:267},roomPosition:{x:40,y:50}};
    const save=codec.make(state,0),loaded=codec.parse(JSON.stringify(save));equal(loaded,save);
    equal(loaded.version,5);equal(loaded.scope,'landed-rooms-1');equal(loaded.state.start,fresh().start);
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
      const old=codec.make(state,0);old.version=4;old.scope='landed-bank-1';
      const before=JSON.stringify(old),loaded=codec.parse(before);equal(loaded.state,old.state);equal(loaded.version,5);equal(JSON.stringify(old),before);
      old.state.travel={scene:'room',cityPosition:{x:311,y:267},roomPosition:{x:12,y:56}};
      rejects(()=>codec.validate(old));
    }
  });
}
