import { createCityMaps } from '../js/core/city-map.js';
import { createCityGeometry, SHIP_REENTRY } from '../js/core/city-walk.js';
import { createPodGeometry, tryPodStep } from '../js/core/city-pod.js';
import { canStand, detachedShipGeometry } from '../js/core/ship-walk.js';
import { createRoomGeometries, roomAt } from '../js/core/room-walk.js';
import { cityServiceAt } from '../js/core/city-doors.js';
import { campaignSaveCodec } from '../js/core/campaign-saves.js';
import { reduceCampaignPod, campaignFootGeometry, POD_REENTRY } from '../js/core/campaign-pod.js';
import { canBoardParkedPod } from '../js/core/parked-pod.js';
import { reduceCampaignExchange } from '../js/core/campaign-exchange.js';
import { campaignDepotOffers, reduceCampaignDepot } from '../js/core/campaign-depot.js';
import { advanceCampaignMachinery } from '../js/core/campaign-machinery.js';
import { createSurvival } from '../js/core/survival.js';
import { createCharacter } from '../js/core/character.js';

export async function campaignParkingTests(test,equal) {
  const names=['maps','initial-navigation','initial-economy','initial-location','city-walk','ship-inventory','ship-walk','exchange-defaults','items','room-walk','dialogue','dialogue-text','dialogue-systems'];
  const [maps,navigation,economy,location,data,inventory,ship,exchange,items,rooms,scripts,text,systems]=await Promise.all(names.map(n=>fetch(`../data/${n}.json`).then(r=>r.json())));
  const map=createCityMaps(maps,navigation,economy)['city-01'],anchor={...location,position:location.shipPosition};
  const city=createCityGeometry(map,data,anchor);city.pod=createPodGeometry(map,data,anchor);city.rooms=createRoomGeometries(rooms);
  const content={navigation,economy,location,inventory,exchange,dialogue:{items,scripts,text,systems}},codec=campaignSaveCodec(content,ship,city);
  const fresh=()=>codec.create({...createCharacter(),name:'Parking pilot'},12345);
  const run=(s,a)=>reduceCampaignPod(s,city.pod,a,city);
  const reject=(f,code)=>{let got;try{f()}catch(e){got=e.message}equal(got,code)};
  const driving=()=>{const s=fresh();s.ship.position={...POD_REENTRY};return run(s,{type:'depart'})};
  function driveStreet() {
    let s=driving();const g=city.pod,first=s.pod.position.y*g.width+s.pod.position.x,queue=[first],seen=new Map([[first,null]]);let end;
    for(let i=0;i<queue.length&&end===undefined;i++) {
      const k=queue[i],p={x:k%g.width,y:Math.floor(k/g.width)};
      if(p.x===360&&p.y===215){end=k;break}
      for(let y=-1;y<=1;y++)for(let x=-1;x<=1;x++)if(x||y){const moved=tryPodStep(g,p,x,y);if(!moved)continue;const n=moved.position.y*g.width+moved.position.x;if(!seen.has(n)){seen.set(n,{k,x,y});queue.push(n)}}
    }
    if(end===undefined)throw Error('No street route');
    const path=[];for(let k=end;k!==first;){const p=seen.get(k);path.unshift({type:'move',dx:p.x,dy:p.y});k=p.k}
    for(const a of path)s=run(s,a);return s;
  }
  const street=driveStreet();
  function footPoint(state,predicate) {
    const g=campaignFootGeometry(city,state.pod),seen=new Set(),queue=[state.travel.cityPosition];
    for(let i=0;i<queue.length;i++) {
      const p=queue[i],key=`${p.x}/${p.y}`;if(seen.has(key))continue;seen.add(key);
      if(predicate(p))return p;
      for(const [dx,dy] of [[1,0],[-1,0],[0,1],[0,-1]]){const n={x:p.x+dx,y:p.y+dy};if(canStand(g,n)&&!seen.has(`${n.x}/${n.y}`))queue.push(n)}
    }
    throw Error('No foot route');
  }
  await test('Parking separates player and loaded pod ownership and boarding restores driving atomically',()=>{
    const s=structuredClone(street);s.pod.cargo=[{commodityId:'cargo-01',quality:7,originWorld:'world-01',pricePaid:0},null];const before=JSON.stringify(s);
    const parked=run(s,{type:'park'});equal(parked.pod,{...s.pod,occupied:false});equal(parked.pod.position,s.pod.position);
    equal(parked.travel.cityPosition.x!==parked.pod.position.x,true);equal(codec.snapshot(parked),parked);equal(JSON.stringify(s),before);
    const away=structuredClone(parked);away.travel.cityPosition=footPoint(away,p=>Math.abs(p.x-away.pod.position.x)>20);
    const untouched=JSON.stringify(away);reject(()=>run(away,{type:'board'}),'podUnavailable');reject(()=>run(away,{type:'dock'}),'podUnavailable');reject(()=>run(away,{type:'move',dx:1,dy:0}),'podUnavailable');equal(JSON.stringify(away),untouched);
    equal(codec.parse(JSON.stringify(codec.make(away,0))).state,away);
    const returned=run(parked,{type:'board'});equal(returned,s);equal(canBoardParkedPod(campaignFootGeometry(city,parked.pod),parked.travel.cityPosition,parked.pod.position),true);
    const blocked={...city,walkBounds:{left:100,right:99,top:0,bottom:0}};
    reject(()=>reduceCampaignPod(s,city.pod,{type:'park'},blocked),'podExitBlocked');equal(JSON.stringify(s),before);
  });
  await test('Foot service and room visits retain parked cargo and reject remote loading or auxiliary purchases',()=>{
    const parked=run(street,{type:'park'}),manifest=JSON.stringify(parked.pod);
    for(const service of ['bank','exchange','depot']) {
      const s=structuredClone(parked);s.travel.cityPosition=footPoint(s,p=>cityServiceAt(map,p)===service);
      if(service==='exchange') {
        const visit=reduceCampaignExchange(s,content,map,{type:'enter'});equal(codec.snapshot(visit),visit);
        for(const type of ['store','fetch','swap'])reject(()=>run(visit,{type,slot:0,podSlot:0,warehouseSlot:0}),'cargoUnavailable');
        equal(JSON.stringify(visit.pod),manifest);
      }else {
        s.travel.scene=service;equal(codec.snapshot(s),s);
        if(service==='depot') {
          equal(campaignDepotOffers(s,content,city).find(o=>o.type==='auxiliary').reason,'depotVehicleAbsent');
          reject(()=>reduceCampaignDepot(s,content,city,{type:'auxiliary',units:1}),'depotVehicleAbsent');
        }
      }
    }
    const s=structuredClone(parked);s.travel.cityPosition=footPoint(s,p=>roomAt(city.rooms,map,p)?.index===9);
    const room=roomAt(city.rooms,map,s.travel.cityPosition);s.travel={...s.travel,scene:'room',roomPosition:{...room.spawn}};
    equal(codec.snapshot(s),s);equal(JSON.stringify(s.pod),manifest);
  });
  await test('Detached ship saves use the original section collision and cannot consume unattended auxiliary cargo',()=>{
    const s=run(street,{type:'park'});s.travel={scene:'ship',cityPosition:null};s.ship.position={...SHIP_REENTRY};
    s.pod.cargo=[{commodityId:'cargo-01',quality:7,originWorld:'world-01',pricePaid:0},null];
    equal(codec.snapshot(s),s);reject(()=>run(s,{type:'depart'}),'podUnavailable');
    const v={...createSurvival(s.ship.condition),minutes:s.ship.minutes},next=advanceCampaignMachinery(s,v,250).state;
    equal(next.pod,s.pod);equal(next.resources.fuel,0);
    const detached=detachedShipGeometry(ship);let found;
    for(let y=80;y<130&&!found;y++)for(let x=80;x<140;x++)if(canStand(detached,{x,y})&&!canStand(ship,{x,y})){found={x,y};break}
    equal(!!found,true);equal(codec.parse(JSON.stringify(codec.make(s,0))).state,s);
    // Removing the pod clears pixels, but they are outside the connected ship
    // interior. A save must not place the player in that empty exterior space.
    const bad=structuredClone(s);bad.ship.position=found;reject(()=>codec.snapshot(bad),'invalidCampaign');
  });
  await test('Version20 migration derives occupancy while preserving active power and loaded pod progress',()=>{
    for(const s of [fresh(),driving()]) {
      s.resources.fuel=19;s.resources.guns.powered=true;s.resources.guns.charge=100;s.machinery.phase=2;
      const current=codec.make(s,0),old=structuredClone(current);old.version=20;old.scope='landed-power-1';delete old.state.pod.occupied;
      const before=JSON.stringify(old);equal(codec.validate(old),current);equal(JSON.stringify(old),before);
      old.state.pod.occupied=false;reject(()=>codec.validate(old),'invalidCampaign');
    }
  });
  await test('Parking saves reject overlap, invalid occupancy and historical independent positions without partial replacement',()=>{
    const parked=run(street,{type:'park'}),before=JSON.stringify(parked),g=campaignFootGeometry(city,parked.pod);
    for(const mutate of [s=>s.pod.occupied=true,s=>s.pod.occupied=1,s=>delete s.pod.occupied,s=>s.pod.heading=15,s=>s.pod.position={x:0,y:0},s=>s.pod.attached=true]) {
      const bad=structuredClone(parked);mutate(bad);reject(()=>codec.snapshot(bad),'invalidCampaign');
    }
    let blocked;for(let y=208;y<=215&&!blocked;y++)for(let x=354;x<=369;x++)if(!canStand(g,{x,y})){blocked={x,y};break}
    const bad=structuredClone(parked);bad.travel.cityPosition=blocked;reject(()=>codec.snapshot(bad),'invalidCampaign');
    const old=codec.make(parked,0);old.version=20;old.scope='landed-power-1';delete old.state.pod.occupied;reject(()=>codec.validate(old),'invalidCampaign');
    equal(JSON.stringify(parked),before);
  });
}
