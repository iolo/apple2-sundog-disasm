import { createCityMaps } from '../js/core/city-map.js';
import { createCityGeometry } from '../js/core/city-walk.js';
import { canStand } from '../js/core/ship-walk.js';
import { createPodGeometry, podHeading, canDrivePod, tryPodStep, drivePodToward, canDockPod, podExchangeAt, podReachability } from '../js/core/city-pod.js';
import { campaignSaveCodec } from '../js/core/campaign-saves.js';
import { reduceCampaignPod, POD_REENTRY } from '../js/core/campaign-pod.js';
import { reduceCampaignExchange } from '../js/core/campaign-exchange.js';
import { createCharacter } from '../js/core/character.js';

export async function cityPodTests(test,equal) {
  const [maps,navigation,economy,location,cityData,inventory,ship,exchange,items]=await Promise.all(
    ['maps','initial-navigation','initial-economy','initial-location','city-walk','ship-inventory','ship-walk','exchange-defaults','items'].map(n=>fetch(`../data/${n}.json`).then(r=>r.json())));
  const map=createCityMaps(maps,navigation,economy)['city-01'],anchor={...location,position:location.shipPosition};
  const city=createCityGeometry(map,cityData,anchor),g=city.pod=createPodGeometry(map,cityData,anchor);
  const content={navigation,economy,location,inventory,exchange,items},codec=campaignSaveCodec(content,ship,city);
  const fresh=(seed=12345)=>codec.create({...createCharacter(),name:'Cargo pilot'},seed);
  const run=(s,a)=>reduceCampaignPod(s,g,a),trade=(s,a)=>reduceCampaignExchange(s,content,map,a);
  const reject=(f,want)=>{let e;try{f()}catch(error){e=error.message}equal(e,want)};
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
  const outbound=route(g.spawn,(p,h)=>podExchangeAt(g,p,h));
  const depart=s=>{s.ship.position={...POD_REENTRY};return run(s,{type:'depart'})};
  const arrive=s=>outbound.reduce(run,depart(s));
  await test('Pod departure, directional collision and docking reproduce the source masks and anchors',()=>{
    equal(g.spawn,{x:296,y:211});equal(canDrivePod(g,g.spawn,16),true);equal(canStand(ship,POD_REENTRY),true);
    equal([[-1,-1],[-1,0],[-1,1],[0,-1],[0,1],[1,-1],[1,0],[1,1]].map(([x,y])=>podHeading(x,y)),[20,16,18,14,14,18,16,20]);
    equal(canDockPod(g,g.spawn,16),true);equal(canDockPod(g,g.spawn,14),false);equal(canDockPod(g,{x:310,y:211},16),false);
    equal(canDrivePod(g,{x:279,y:211},16),false);equal(canDrivePod(g,{x:500,y:580},16),false);
    // Movement uses collision glyphs15/17/19/21 rather than the foot glyph11.
    for(const h of [14,16,18,20])for(let y=210;y<260;y++)for(let x=290;x<340;x++)
      equal(canDrivePod(g,{x,y},h),canStand({...g,collisionRows:cityData.podGlyphs[h+1]},{x,y}));
    const empty={...g,backgrounds:{ship:Array.from({length:g.height},()=>Array(g.width/7).fill(0))}};
    const base={position:{x:400,y:300},heading:16},pointer={x:423,y:297};
    const once=drivePodToward(empty,base,pointer),twice=drivePodToward(empty,once,pointer);
    equal(once.position,{x:401,y:300});equal(twice.position,{x:403,y:300});equal(base.position,{x:400,y:300});
    equal(drivePodToward(empty,base,{x:410,y:297}),base); // Positive delta7 shifts to0.
    equal(drivePodToward(empty,base,{x:402,y:297}).position,{x:399,y:300}); // Negative delta−1 shifts to−1.
  });
  await test('The pod reaches the cargo entrance and returns through actual collision-checked movement',()=>{
    const s=fresh(),before=JSON.stringify(s);reject(()=>run(s,{type:'depart'}),'podUnavailable');
    let next=arrive(s);equal(podExchangeAt(g,next.pod.position,next.pod.heading),true);
    const reached=podReachability(g);equal(reached(next.pod.position,next.pod.heading),true);
    equal(reached({x:100,y:100},16),false);equal(reached({x:296.5,y:211},16),false);
    equal(codec.snapshot(next),next);const saved=codec.make(next,0);equal(codec.parse(JSON.stringify(saved)).state,next);
    for(const action of route(next.pod.position,(p,h)=>canDockPod(g,p,h)))next=run(next,action);
    next=run(next,{type:'dock'});equal(next.pod.attached,true);equal(next.ship.position,POD_REENTRY);
    equal(next.start,s.start);equal(next.economy,s.economy);equal(next.encounters,s.encounters);
    // depart() sets the test's starting interior position only; reducers own all output.
    equal(JSON.parse(before).pod,s.pod);equal(codec.snapshot(next),next);
  });
  await test('Loading, saving, docking, fetching and selling conserve paid cargo and all money',()=>{
    let s=trade(arrive(fresh()),{type:'enter'});
    const slot=s.economy.exchange.visit.offers.findIndex(o=>o&&o.price<s.dialogue.cash+s.economy.accounts[0].balance);
    s=trade(s,{type:'buy',slot});const lot=s.economy.exchange.warehouse.slots.find(c=>c&&c.commodityId!=='cargo-31');
    const index=s.economy.exchange.warehouse.slots.indexOf(lot),before=JSON.stringify(s);
    const loaded=run(s,{type:'fetch',slot:index});equal(loaded.pod.cargo[0],lot);equal(loaded.economy.exchange.warehouse.slots[index],null);
    equal(loaded.economy.accounts,s.economy.accounts);equal(loaded.dialogue,s.dialogue);equal(loaded.encounters,s.encounters);equal(JSON.stringify(s),before);
    equal(codec.parse(JSON.stringify(codec.make(loaded,0))).state,loaded);
    const duplicate=structuredClone(loaded);duplicate.economy.exchange.warehouse.slots[index]=lot;reject(()=>codec.snapshot(duplicate),'invalidCampaign');
    let back=trade(loaded,{type:'leave'});for(const a of route(back.pod.position,(p,h)=>canDockPod(g,p,h)))back=run(back,a);
    back=run(back,{type:'dock'});equal(back.pod.cargo[0],lot);equal(codec.snapshot(back),back);
    let returned=trade(arrive(back),{type:'enter'});returned=run(returned,{type:'store',slot:0});
    const sold=trade(returned,{type:'sell',slot:returned.economy.exchange.warehouse.slots.findIndex(c=>c?.commodityId===lot.commodityId)});
    equal(sold.pod.cargo,[null,null]);equal(codec.snapshot(sold),sold);
  });
  await test('Actual pod docking consumes one auxiliary load for an empty ship and persists without repeat consumption',()=>{
    const s=fresh(),aux={commodityId:'cargo-01',quality:7,originWorld:'world-01',pricePaid:0};
    s.pod.cargo=[structuredClone(aux),structuredClone(aux)];const outside=depart(s),before=JSON.stringify(outside);
    const docked=run(outside,{type:'dock'});equal(docked.resources.fuel,255);equal(docked.pod.cargo,[null,aux]);
    equal(docked.start,outside.start);equal(docked.economy,outside.economy);equal(docked.encounters,outside.encounters);equal(docked.ship.inventory,outside.ship.inventory);
    equal(JSON.stringify(outside),before);equal(codec.parse(JSON.stringify(codec.make(docked,0))).state,docked);
    const again=run(depart(structuredClone(docked)),{type:'dock'});equal(again.resources,docked.resources);equal(again.pod.cargo,docked.pod.cargo);
    reject(()=>run(docked,{type:'dock'}),'podUnavailable');
    const remote=arrive(structuredClone(s)),unchanged=JSON.stringify(remote);reject(()=>run(remote,{type:'dock'}),'podUnavailable');equal(JSON.stringify(remote),unchanged);
  });
  await test('Cryogens move between pod and warehouse but cannot vanish, multiply or be sold',()=>{
    let s;for(let seed=1;seed<200;seed++){s=fresh(seed);if(s.economy.exchange.warehouse.slots.some(Boolean))break}
    equal(s.economy.exchange.warehouse.slots[0]?.commodityId,'cargo-31');s=trade(arrive(s),{type:'enter'});
    const loaded=run(s,{type:'fetch',slot:0});equal(codec.snapshot(loaded),loaded);
    for(const mutate of [v=>v.pod.cargo[0]=null,v=>v.pod.cargo[1]=structuredClone(v.pod.cargo[0]),v=>v.pod.cargo[0].originCity='city-57']) {
      const bad=structuredClone(loaded);mutate(bad);reject(()=>codec.snapshot(bad),'invalidCampaign');
    }
    const stored=run(loaded,{type:'store',slot:0});reject(()=>trade(stored,{type:'sell',slot:0}),'exchangeNotNegotiable');
    equal(codec.snapshot(stored),stored);
  });
  await test('Version16 migration preserves detached pod, loaded cargo, accounts and market progress',()=>{
    let s=trade(arrive(fresh()),{type:'enter'});
    const index=s.economy.exchange.visit.offers.findIndex(o=>o&&o.price<s.dialogue.cash+s.economy.accounts[0].balance);
    equal(index>=0,true);s=trade(s,{type:'buy',slot:index});
    const slot=s.economy.exchange.warehouse.slots.findIndex(c=>c&&c.commodityId!=='cargo-31');
    s=run(s,{type:'fetch',slot});
    const current=codec.make(s,0),old=structuredClone(current);old.version=16;delete old.state.pod?.occupied;delete old.state.machinery;delete old.state.engineering;delete old.state.resources;old.scope='landed-local-cargo-1';
    equal(codec.validate(old),current);
  });
  await test('Version15 migrates with an attached empty pod and rejects injected transport fields',()=>{
    const current=codec.make(fresh(),0),old=structuredClone(current);old.version=15;delete old.state.pod?.occupied;delete old.state.machinery;delete old.state.engineering;delete old.state.resources;old.scope='landed-personal-trade-1';delete old.state.pod;
    equal(codec.validate(old),current);old.state.pod=current.state.pod;reject(()=>codec.validate(old),'invalidCampaign');
    const s=arrive(fresh());for(const mutate of [v=>v.pod.position.x++,v=>v.pod.heading=15,v=>v.travel.scene='bank',v=>v.pod.attached=true,v=>v.pod.cargo.push(null)]) {
      const bad=structuredClone(s);mutate(bad);reject(()=>codec.snapshot(bad),'invalidCampaign');
    }
    const foot=fresh();foot.travel={scene:'exchange',cityPosition:{x:551,y:238}};
    reject(()=>run(foot,{type:'fetch',slot:0}),'cargoUnavailable');
  });
}
