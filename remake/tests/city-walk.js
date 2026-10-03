import { createCityMaps } from '../js/core/city-map.js';
import { createCityGeometry,cityReachability,canBoardShip,cityCamera,SHIP_REENTRY } from '../js/core/city-walk.js';
import { canStand,tryStep } from '../js/core/ship-walk.js';
import { campaignSaveCodec } from '../js/core/campaign-saves.js';
import { createCharacter } from '../js/core/character.js';
import { exchangeEquipment } from '../js/core/equipment.js';

export async function cityWalkTests(test,equal) {
  const [maps,navigation,economy,location,cityContent,inventory,shipGeometry]=await Promise.all([
    'maps','initial-navigation','initial-economy','initial-location','city-walk','ship-inventory','ship-walk',
  ].map(name=>fetch(`../data/${name}.json`).then(r=>r.json())));
  const cityMaps=createCityMaps(maps,navigation,economy);
  const geometry=createCityGeometry(cityMaps['city-01'],cityContent,{...location,position:location.shipPosition});
  const reachable=cityReachability(geometry);
  const codec=campaignSaveCodec({navigation,economy,location,inventory},shipGeometry,geometry);
  const fresh=()=>codec.create({...createCharacter(),name:'City pilot'},12345);
  const rejects=run=>{let error;try{run()}catch(e){error=e.message}equal(error,'invalidCampaign')};
  await test('Foot exit and boarding use different source glyphs, anchors and proximity rules',()=>{
    equal(geometry.shipAnchor,{x:287,y:211});equal(geometry.spawn,{x:287,y:217});
    equal(geometry.collisionRows,[0,0,0,12,12,0,0,0]);
    equal(canStand(geometry,geometry.spawn),true);equal(canStand(shipGeometry,SHIP_REENTRY),true);
    equal(canBoardShip(geometry,geometry.spawn),false);
    let p=tryStep(geometry,geometry.spawn,-2,0);p=tryStep(geometry,p,0,-2);
    equal(p,{x:285,y:215});equal(canBoardShip(geometry,p),true);equal(reachable(p),true);
    equal(canBoardShip(geometry,{x:300,y:215}),false);
    equal(canBoardShip(geometry,{x:287,y:211}),false); // Occupied ship silhouette.
  });
  await test('City collision ignores pattern9 background columns but blocks solid pixels across byte boundaries',()=>{
    for(let x=350;x<364;x++) {
      const rows=Array.from({length:192},()=>Array(80).fill(0));
      const p={x,y:100};
      const g={width:560,height:192,backgrounds:{ship:rows},collisionRows:cityContent.collisionRows};
      for(let px=x+2;px<=x+3;px++) {
        const byte=Math.floor(px/7),bit=1<<(px%7);
        rows[96][byte]=bit&cityContent.collisionByteMasks[byte%2];
        equal(canStand(g,p),px%2===1);rows[96][byte]=0;
      }
    }
    equal(cityContent.collisionByteMasks,[85,42]);
  });
  await test('Reachability excludes walls and unsupported surface travel, and includes all legal step destinations',()=>{
    equal(reachable({x:100,y:100}),false);equal(reachable({x:287,y:211}),false);
    equal(reachable({x:287.5,y:217}),false);equal(reachable({x:1120,y:768}),false);
    for(const p of [geometry.spawn,{x:285,y:215},{x:310,y:220}]) {
      if(!reachable(p))continue;
      for(let dy=-2;dy<=2;dy++)for(let dx=-2;dx<=2;dx++)equal(reachable(tryStep(geometry,p,dx,dy)),true);
    }
    equal(canStand(geometry,{x:279,y:217}),false);equal(canStand(geometry,{x:834,y:217}),false);
    equal(canStand(geometry,{x:400,y:198}),false);equal(canStand(geometry,{x:400,y:576}),false);
    equal(cityCamera(geometry.spawn),{x:5,y:3});equal(cityCamera({x:833,y:575}),{x:24,y:14});
  });
  await test('Version7 city saves own their active position and preserve ship state, equipment and creation',()=>{
    const state=fresh();
    const moved=exchangeEquipment(state.equipment,state.ship.inventory,{x:109,y:60},0,
      {container:'installed',unit:0,socket:0},{container:'carried',index:0});
    state.equipment=moved.equipment;state.ship.inventory=moved.inventory;
    state.ship.position={...SHIP_REENTRY};state.travel={scene:'city',cityPosition:{...geometry.spawn}};
    state.ship.minutes=321;
    const saved=codec.make(state,0),loaded=codec.parse(JSON.stringify(saved));
    equal(loaded,saved);equal(loaded.version,18);equal(loaded.scope,'landed-depot-1');
    loaded.state.travel.cityPosition.x++;equal(saved.state.travel.cityPosition,geometry.spawn);
    equal(saved.state.start,fresh().start);equal(saved.state.ship.inventory.carried[0],31);
    equal(saved.state.equipment[0].units[0].performance,0);
    equal(saved.state.ship.minutes,321);equal(saved.state.equipment,state.equipment);
    for(const mutate of [s=>s.travel.scene='world',s=>s.travel.cityId='city-02',s=>s.travel.cityPosition={x:287,y:211},
      s=>s.travel.cityPosition={x:100,y:100},s=>s.travel.cityPosition.extra=1,s=>s.ship.position={x:54,y:110},
      s=>s.travel.scene='ship',s=>s.travel.cityPosition=null]) {
      const bad=structuredClone(saved);mutate(bad.state);rejects(()=>codec.validate(bad));
    }
  });
  await test('Version2 migration preserves active equipment and creates only an interior scene',()=>{
    const old=codec.make(fresh(),0);old.version=2;delete old.state.resources;delete old.state.pod;delete old.state.economy;old.scope='landed-engineering-1';delete old.state.travel;delete old.state.encounters;delete old.state.dialogue;
    old.state.ship.minutes=456;
    const before=JSON.stringify(old),next=codec.parse(before);
    equal(next.state.travel,{scene:'ship',cityPosition:null});equal(next.state.equipment,old.state.equipment);
    equal(next.state.ship,old.state.ship);equal(JSON.stringify(old),before);
    old.state.travel={scene:'city',cityPosition:geometry.spawn};rejects(()=>codec.validate(old));
  });
}
