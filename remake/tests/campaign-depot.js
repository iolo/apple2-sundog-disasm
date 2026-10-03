import { createCityMaps } from '../js/core/city-map.js';
import { createCityGeometry, cityReachability, SHIP_REENTRY } from '../js/core/city-walk.js';
import { createPodGeometry, tryPodStep, canDockPod, podServiceAt } from '../js/core/city-pod.js';
import { cityServiceAt } from '../js/core/city-doors.js';
import { campaignSaveCodec } from '../js/core/campaign-saves.js';
import { reduceCampaignPod, POD_REENTRY } from '../js/core/campaign-pod.js';
import { reduceCampaignExchange, exchangeSaleQuote } from '../js/core/campaign-exchange.js';
import { campaignDepotOffers, campaignDepotQuote, reduceCampaignDepot } from '../js/core/campaign-depot.js';
import { createCharacter } from '../js/core/character.js';

export async function campaignDepotTests(test,equal) {
  const [maps,navigation,economy,location,cityData,inventory,ship,exchange,items,systems]=await Promise.all(
    ['maps','initial-navigation','initial-economy','initial-location','city-walk','ship-inventory','ship-walk','exchange-defaults','items','dialogue-systems'].map(n=>fetch(`../data/${n}.json`).then(r=>r.json())));
  const map=createCityMaps(maps,navigation,economy)['city-01'],anchor={...location,position:location.shipPosition};
  const city=createCityGeometry(map,cityData,anchor),g=city.pod=createPodGeometry(map,cityData,anchor);
  const content={navigation,economy,location,inventory,exchange,items,dialogue:{systems}},codec=campaignSaveCodec(content,ship,city);
  const fresh=()=>codec.create({...createCharacter(),name:'Depot pilot'},12345);
  const run=(s,a)=>reduceCampaignPod(s,g,a),trade=(s,a)=>reduceCampaignExchange(s,content,map,a);
  const service=(s,type,units=1)=>reduceCampaignDepot(s,content,city,{type,units});
  const reject=(f,want='invalidCampaign')=>{let e;try{f()}catch(error){e=error.message}equal(e,want)};
  function route(from,goal) {
    const first=from.y*g.width+from.x,queue=[first],seen=new Map([[first,null]]);let end;
    for(let i=0;i<queue.length&&end===undefined;i++) {
      const k=queue[i],p={x:k%g.width,y:Math.floor(k/g.width)};
      for(let y=-1;y<=1;y++)for(let x=-1;x<=1;x++)if(x||y) {
        const step=tryPodStep(g,p,x,y);if(!step)continue;
        const n=step.position.y*g.width+step.position.x;
        if(seen.has(n))continue;seen.set(n,{from:k,dx:x,dy:y});queue.push(n);
        if(goal(step.position,step.heading)){end=n;break}
      }
    }
    if(end===undefined)throw new Error('No pod route');
    const path=[];for(let k=end;k!==first;) {const n=seen.get(k);path.unshift({type:'move',dx:n.dx,dy:n.dy});k=n.from}
    return path;
  }

  const outbound=route(g.spawn,(p,h)=>podServiceAt(g,p,h)==='depot');
  function arrive() {let s=fresh();s.ship.position={...POD_REENTRY};s=outbound.reduce(run,run(s,{type:'depart'}));s.travel.scene='depot';return s}
  const leave=s=>({...s,travel:{...s.travel,scene:'city'}});
  await test('A reachable pod depot services hull and fuel, preserving creation, time and RNG',()=>{
    const s=arrive(),before=JSON.stringify(s);equal(codec.snapshot(s),s);
    const offers=campaignDepotOffers(s,content,city);equal(offers.map(o=>o.unitPrice),[157,145,2200]);
    equal(s.resources.hull,15);equal(s.resources.fuel,0);
    const q=campaignDepotQuote(s,content,city,'repair',1);equal(q.price,145);
    const fixed=service(s,'repair',1);equal(fixed.resources.hull,16);equal(fixed.economy.accounts[0].balance,s.economy.accounts[0].balance-145);
    const filled=service(fixed,'refuel',16);equal(filled.resources.fuel,255);
    equal(filled.dialogue.cash,s.dialogue.cash);equal(filled.ship,s.ship);equal(filled.encounters,s.encounters);equal(filled.start,s.start);
    equal(codec.parse(JSON.stringify(codec.make(filled,0))).state,filled);equal(JSON.stringify(s),before);
    equal(campaignDepotOffers(filled,content,city).slice(0,2).map(o=>o.reason),['depotCapacity','depotCapacity']);
    reject(()=>service(filled,'refuel'),'depotCapacity');reject(()=>service(filled,'repair'),'depotCapacity');
  });
  await test('Depot payment is bank-first, accepts exact funds and rolls back insufficient/full requests',()=>{
    const s=arrive();s.economy.accounts[0].balance=100;s.dialogue.cash=57;
    const paid=service(s,'refuel');equal(paid.economy.accounts[0].balance,0);equal(paid.dialogue.cash,0);equal(paid.resources.fuel,16);
    equal(codec.snapshot(paid),paid);const before=JSON.stringify(s);
    reject(()=>service(s,'refuel',2),'depotInsufficient');equal(JSON.stringify(s),before);
    reject(()=>service(s,'refuel',0),'depotCapacity');reject(()=>service(s,'refuel',17),'depotCapacity');
    const loaded=service(arrive(),'auxiliary',2);reject(()=>service(loaded,'auxiliary'),'depotCapacity');equal(codec.snapshot(loaded),loaded);
  });
  await test('Foot depot visits service the local ship but cannot remotely load the attached pod',()=>{
    const reachable=cityReachability(city);let position;for(let y=0;y<city.height&&!position;y++)for(let x=0;x<city.width;x++)if(cityServiceAt(map,{x,y})==='depot'&&reachable({x,y})){position={x,y};break}
    const s=fresh();s.ship.position={...SHIP_REENTRY};s.travel={scene:'depot',cityPosition:position};equal(codec.snapshot(s),s);
    const offers=campaignDepotOffers(s,content,city);equal(offers[2].reason,'depotVehicleAbsent');equal(offers[0].reason,'');
    equal(codec.snapshot(service(s,'repair')),service(s,'repair'));reject(()=>service(s,'auxiliary'),'depotVehicleAbsent');
    reject(()=>service(fresh(),'refuel'),'depotUnavailable');reject(()=>service(leave(arrive()),'refuel'),'depotUnavailable');
  });
  await test('Auxiliary fuel survives warehouse Store/Fetch and fills the empty tank on docking without being sold',()=>{
    const s=service(arrive(),'auxiliary',2),lots=structuredClone(s.pod.cargo);
    equal(lots[0],{commodityId:'cargo-01',quality:7,originWorld:'world-01',pricePaid:0});
    let e=leave(s);for(const a of route(e.pod.position,(p,h)=>podServiceAt(g,p,h)==='exchange'))e=run(e,a);
    e=trade(e,{type:'enter'});e=run(e,{type:'store',slot:0});
    const slot=e.economy.exchange.warehouse.slots.findIndex(c=>c?.commodityId==='cargo-01');equal(slot>=0,true);
    equal(exchangeSaleQuote(e,content,slot),null);reject(()=>trade(e,{type:'sell',slot}),'exchangeNotNegotiable');equal(codec.snapshot(e),e);
    e=run(e,{type:'fetch',slot});e=trade(e,{type:'leave'});
    for(const a of route(e.pod.position,(p,h)=>canDockPod(g,p,h)))e=run(e,a);e=run(e,{type:'dock'});
    equal(e.pod.cargo,[null,lots[1]]);equal(e.resources,{...s.resources,fuel:255});equal(codec.snapshot(e),e);
  });
  await test('Version17 migration preserves prior state and rejects injected R08 resource/cargo fields',()=>{
    const current=codec.make(fresh(),0),old=structuredClone(current);old.version=17;delete old.state.pod?.occupied;delete old.state.machinery;delete old.state.engineering;old.scope='landed-trader-matching-1';delete old.state.resources;
    equal(codec.validate(old),current);old.state.resources=current.state.resources;reject(()=>codec.validate(old));
    delete old.state.resources;old.state.pod.cargo[0]={commodityId:'cargo-01',quality:7,originWorld:'world-01',pricePaid:0};reject(()=>codec.validate(old));
    const depot=codec.make(arrive(),0);depot.version=17;delete depot.state.pod?.occupied;delete depot.state.machinery;delete depot.state.engineering;depot.scope='landed-trader-matching-1';delete depot.state.resources;reject(()=>codec.validate(depot));
  });
  await test('Resource and auxiliary cargo validation reject unsupported machinery and malformed saves',()=>{
    const s=service(arrive(),'auxiliary');
    for(const mutate of [v=>delete v.resources,v=>v.resources.hull=12,v=>v.resources.hull=17,v=>v.resources.shields.targetCharge=1,
      v=>v.resources.fuel=256,v=>v.resources.enginesPowered=true,v=>v.resources.warp.charge=1,v=>v.resources.extra=0,
      v=>v.pod.cargo[0].quality=6,v=>v.pod.cargo[0].originWorld='world-02',v=>v.pod.cargo[0].pricePaid=2200,
      v=>v.pod.cargo[0].originCity='city-01']) {const bad=structuredClone(s);mutate(bad);reject(()=>codec.snapshot(bad))}
  });
}
