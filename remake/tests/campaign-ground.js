import { createGroundWorld,initialGround,reduceCampaignGround } from '../js/core/campaign-ground.js';
import { groundCameraAt,scrollGroundCamera,groundWindow,groundPointerDelta } from '../js/core/ground-camera.js';
import { createCampaignStart } from '../js/core/campaign.js';
import { createCharacter } from '../js/core/character.js';
import { canStand,tryStep } from '../js/core/ship-walk.js';
import { canBoardShip,createCityGeometry } from '../js/core/city-walk.js';
import { tryPodStep,canDockPod } from '../js/core/city-pod.js';
import { trySurfaceStep,surfaceCityAt,canStandSurface,citySurfaceExit } from '../js/core/surface-walk.js';
import { campaignSaveCodec } from '../js/core/campaign-saves.js';
import { campaignDepotOffers,reduceCampaignDepot } from '../js/core/campaign-depot.js';
import { reduceCampaignBank } from '../js/core/banking.js';
import { reduceCampaignExchange } from '../js/core/campaign-exchange.js';
import { reduceCampaignPod } from '../js/core/campaign-pod.js';
import { cityServiceAt } from '../js/core/city-doors.js';
import { createPodGeometry } from '../js/core/city-pod.js';

export async function campaignGroundTests(test,equal) {
  const names=['maps','initial-navigation','initial-economy','initial-location','ship-inventory','city-walk','surface-walk','ship-walk','dialogue-systems'];
  const [maps,navigation,economy,location,inventory,cityWalk,surfaceWalk,shipWalk,systems]=await Promise.all(names.map(n=>fetch(`../data/${n}.json`).then(r=>r.json())));
  const content={maps,navigation,economy,location,inventory,cityWalk,surfaceWalk,dialogue:{systems}};
  const start=createCampaignStart({...createCharacter(),name:'Ground pilot'},content,12345),world=createGroundWorld(content,start);
  const city=world.city('city-01',false),spawn=city.pod.spawn;
  const legacyGeometry=createCityGeometry(city.map,cityWalk,start.shipLocation);
  legacyGeometry.pod=createPodGeometry(city.map,cityWalk,start.shipLocation);
  const codec=campaignSaveCodec({...content,ground:{maps,cityWalk,surfaceWalk}},shipWalk,legacyGeometry);
  const oldCodec=campaignSaveCodec(content,shipWalk,legacyGeometry);
  const roundtrip=s=>{const saved=codec.make(s,0);equal(saved.version,22);equal(saved.scope,'landed-ground-1');equal(codec.parse(JSON.stringify(saved)).state,s);return s};
  // Loaded cargo fixture isolates transport conservation from R07's separately
  // verified purchase journey. Every subsequent movement uses collision steps.
  const cargo=[{commodityId:'cargo-01',quality:7,originWorld:'world-01',pricePaid:0},null];
  const fresh=()=>{
    const s=codec.create({...createCharacter(),name:'Ground pilot'},12345);
    s.ship.position={x:54,y:118};s.resources.fuel=123;s.ground=initialGround(start,spawn);
    s.travel={scene:'city',cityPosition:{...spawn}};
    s.pod={attached:false,position:{...spawn},heading:16,cargo:structuredClone(cargo),occupied:true};
    return s;
  };
  const run=(s,a)=>reduceCampaignGround(s,world,a);
  const reject=(f,code)=>{let error;try{f()}catch(e){error=e.message}equal(error,code)};
  function route(geometry,position,predicate,step) {
    const w=geometry.width,n=w*geometry.height,parent=new Int32Array(n).fill(-1),moves=new Int8Array(n),queue=new Int32Array(n);
    const directions=[[-1,0],[1,0],[0,-1],[0,1],[-1,-1],[-1,1],[1,-1],[1,1]];
    const first=position.y*w+position.x;parent[first]=first;queue[0]=first;let head=0,tail=1,end=-1;
    while(head<tail) {
      const k=queue[head++],p={x:k%w,y:Math.floor(k/w)};
      if(predicate(p)){end=k;break}
      for(const [index,[dx,dy]] of directions.entries()) {
        const point=step(geometry,p,dx,dy);if(!point)continue;
        const key=point.y*w+point.x;if(parent[key]!==-1)continue;
        parent[key]=k;moves[key]=index;queue[tail++]=key;
      }
    }
    if(end<0)throw new Error('No ground route');
    const result=[];for(let k=end;k!==first;k=parent[k]){const [dx,dy]=directions[moves[k]];result.push({type:'move',dx,dy})}
    return result.reverse();
  }
  const cityRoute=route(city.pod,spawn,p=>p.x<130,(g,p,x,y)=>tryPodStep(g,p,x,y)?.position);
  function depart(state=fresh()) {
    for(const action of cityRoute){state=run(state,action);if(state.travel.scene==='surface')return state}
    throw new Error('City boundary did not transition');
  }
  const surface=depart();
  await test('Ground camera preserves source scroll hysteresis, strict thresholds and X-before-Y priority',()=>{
    const c={x:5,y:3};
    equal(groundCameraAt({x:296,y:211}),c);
    equal(groundCameraAt({x:0,y:24},true),{x:35,y:0});
    equal(groundCameraAt({x:0,y:0},true),{x:35,y:20});
    equal(groundPointerDelta({x:1,y:1},{x:1119,y:570},true),{x:-5,y:-4});
    equal(groundPointerDelta({x:1118,y:575},{x:4,y:0},true),{x:3,y:4});
    equal(scrollGroundCamera(c,{x:186,y:155}),{attempted:{x:5,y:3},camera:c,scrolled:false});
    equal(scrollGroundCamera(c,{x:185,y:153}).attempted,{x:4,y:3});
    equal(scrollGroundCamera(c,{x:200,y:155}).attempted,c);
    equal(scrollGroundCamera(c,{x:200,y:154}).attempted,{x:5,y:2});
    equal(scrollGroundCamera(c,{x:367,y:220}).attempted,c);
    equal(scrollGroundCamera(c,{x:368,y:220}).attempted,{x:6,y:3});
    const w=groundWindow(world.surface(surface.ground.colonyPosition).map,{x:39,y:23},true);
    equal([w.length,w[0].length,w[0][1].x,w[1][0].y],[8,10,0,0]);
  });
  await test('Expanded city geometry preserves legacy bounds and draws the ship only in its own city',()=>{
    const legacy=createCityGeometry(city.map,cityWalk,start.shipLocation);
    equal(canStand(legacy,{x:272,y:364}),false);equal(canStand(city,{x:272,y:364}),true);
    equal(canStand(city,{x:412,y:588}),true);
    const other=world.city('city-02',false);
    equal(other.shipAnchor,null);equal(other.spawn,null);equal(other.pod.spawn,null);
    equal(canBoardShip(other,{x:287,y:211}),false);equal(canDockPod(other.pod,{x:294,y:211},16),false);
    reject(()=>world.city('city-06',false),'groundUnavailable');
  });
  await test('Loaded pod crosses a real city boundary without moving the ship or changing cargo/resources',()=>{
    const original=fresh(),before=JSON.stringify(original),result=depart(original);
    equal(JSON.stringify(original),before);equal(result.travel.scene,'surface');equal(result.ground.cityId,null);
    equal(result.ground.podCityId,null);equal(result.pod.position,result.travel.cityPosition);equal(result.pod.heading,26);
    equal(result.pod.cargo,cargo);equal(result.ship,original.ship);equal(result.resources,original.resources);equal(result.economy,original.economy);
    equal(result.ground.colonyPosition,{x:30,y:9});
    equal(result.encounters.randomState!==original.encounters.randomState,true);
    roundtrip(result);
  });
  await test('Surface parking and foot city return keep the remote pod independently owned',()=>{
    // Move away from an original overlapping arrival before parking.
    const g=world.surface(surface.ground.colonyPosition);
    let s=surface;
    const path=route(g,s.travel.cityPosition,p=>surfaceCityAt(g.map,p)?.cityId==='city-01'&&canClear(g,p),trySurfaceStep);
    for(const a of path)s=run(s,a);
    s=run(s,{type:'park'});equal(s.pod.occupied,false);equal(s.travel.cityPosition,s.pod.position);
    const parked=structuredClone(s.pod),randomState=s.encounters.randomState;
    s=run(s,{type:'enterCity'});equal(s.ground.cityId,'city-01');equal(s.ground.podCityId,null);equal(s.pod,parked);
    roundtrip(s);
    reject(()=>run(s,{type:'board'}),'podUnavailable');
    const foot=world.foot(s);
    const outbound=route(foot,s.travel.cityPosition,p=>p.x<130,tryStep);
    for(const a of outbound){s=run(s,a);if(s.travel.scene==='surface')break}
    equal(s.travel.scene,'surface');equal(s.encounters.randomState,randomState);equal(s.pod,parked);
    const back=route(g,s.travel.cityPosition,p=>p.x===parked.position.x&&p.y===parked.position.y,trySurfaceStep);
    for(const a of back)s=run(s,a);
    s=run(s,{type:'board'});equal(s.pod,{...parked,occupied:true});equal(s.pod.cargo,cargo);
    roundtrip(s);
  });
  await test('Local foot depot servicing preserves a surface pod and rejects remote-city financial actions',()=>{
    let s=run(surface,{type:'park'});s=run(s,{type:'enterCity'});
    const parked=structuredClone(s.pod),foot=world.foot(s);
    for(const a of route(foot,s.travel.cityPosition,p=>cityServiceAt(city.map,p)==='depot',tryStep))s=run(s,a);
    s.travel.scene='depot';roundtrip(s);
    equal(campaignDepotOffers(s,content,city)[2].reason,'depotVehicleAbsent');
    const fixed=reduceCampaignDepot(s,content,city,{type:'repair',units:1});
    equal(fixed.resources.hull,16);equal(fixed.pod,parked);
    equal(fixed.economy.accounts[0].balance,s.economy.accounts[0].balance-145);roundtrip(fixed);
    reject(()=>reduceCampaignDepot(s,content,city,{type:'auxiliary',units:1}),'depotVehicleAbsent');
    const remote=structuredClone(s);remote.ground.cityId='city-02';const before=JSON.stringify(remote);
    reject(()=>reduceCampaignDepot(remote,content,city,{type:'repair',units:1}),'depotUnavailable');
    reject(()=>reduceCampaignBank(remote,city.map,{type:'deposit',amount:1}),'bankUnavailable');
    reject(()=>reduceCampaignExchange(remote,content,city.map,{type:'enter'}),'exchangeUnavailable');
    reject(()=>reduceCampaignPod(remote,city.pod,{type:'dock'}),'podUnavailable');
    equal(JSON.stringify(remote),before);
  });
  function canClear(g,p) {
    // A zero delta is not movement. Probe whether a legal neighboring movement
    // can return to this point, covering an actual clear boarding location.
    for(const [x,y] of [[1,0],[-1,0],[0,1],[0,-1]]) {
      const n=trySurfaceStep(g,p,x,y),back=trySurfaceStep(g,n,-x,-y);
      if((n.x!==p.x||n.y!==p.y)&&back.x===p.x&&back.y===p.y)return true;
    }
    return false;
  }
  await test('Ground transport reaches another source city and returns with cargo and colony RNG intact',()=>{
    let s=surface;const g=world.surface(s.ground.colonyPosition),savedRandom=s.encounters.randomState;
    for(const id of ['city-02','city-01']) {
      const path=route(g,s.travel.cityPosition,p=>surfaceCityAt(g.map,p)?.cityId===id,trySurfaceStep);
      for(const a of path)s=run(s,a);
      s=run(s,{type:'enterCity'});equal(s.ground.cityId,id);equal(s.ground.podCityId,id);equal(s.pod.cargo,cargo);
      roundtrip(s);
      equal([14,16,18,20].includes(s.pod.heading),true);
      if(id==='city-02') {
        const other=world.city(id,false).pod,out=route(other,s.travel.cityPosition,p=>p.x<130,(g,p,x,y)=>tryPodStep(g,p,x,y)?.position);
        for(const a of out){s=run(s,a);if(s.travel.scene==='surface')break}
        equal(s.travel.scene,'surface');
      }
    }
    equal(s.encounters.randomState,savedRandom);equal(s.resources.fuel,123);equal(s.ship,fresh().ship);
    const before=JSON.stringify(s);reject(()=>run(s,{type:'enterCity'}),'groundUnavailable');
    reject(()=>run(s,{type:'move',dx:3,dy:0}),'groundUnavailable');equal(JSON.stringify(s),before);
  });
  await test('Ground saves validate21 and20 historically before adding independent location metadata',()=>{
    const s=fresh();delete s.ground;
    const original=oldCodec.make(s,0),before=JSON.stringify(original),migrated=codec.validate(original);
    equal(migrated.version,22);equal(migrated.state.ground,initialGround(start,spawn));
    equal(migrated.state.pod,s.pod);equal(JSON.stringify(original),before);roundtrip(migrated.state);
    const power=structuredClone(original);power.version=20;power.scope='landed-power-1';delete power.state.pod.occupied;
    equal(codec.validate(power).state,migrated.state);
    const injected=structuredClone(original);injected.state.ground=initialGround(start,spawn);
    reject(()=>codec.validate(injected),'invalidCampaign');
    const expanded=structuredClone(original);expanded.state.travel.cityPosition={x:272,y:364};expanded.state.pod.position={x:272,y:364};
    reject(()=>codec.validate(expanded),'invalidCampaign');
    reject(()=>oldCodec.parse(JSON.stringify(codec.make(surface,0))),'invalidCampaign');
  });
  await test('All21 legacy schemas migrate to ground saves without inventing surface or colony progress',()=>{
    const initial=oldCodec.create({...createCharacter(),name:'Ground pilot'},12345);
    const scopes=['landed-ship-1','landed-engineering-1','landed-city-1','landed-bank-1','landed-rooms-1','landed-occupants-1','landed-traffic-1','landed-dialogue-1','landed-lodging-1','landed-taverns-1','landed-services-1','landed-banking-1','landed-exchange-1','landed-purchases-1','landed-personal-trade-1','landed-local-cargo-1','landed-trader-matching-1','landed-depot-1','landed-failures-1','landed-power-1','landed-parking-1'];
    for(let version=1;version<=21;version++) {
      const old=oldCodec.make(initial,0);old.version=version;old.scope=scopes[version-1];
      const s=old.state;
      if(version<2)delete s.equipment;if(version<3)delete s.travel;
      if(version<6)delete s.encounters;else {if(version<7)delete s.encounters.roomState;if(version<8)delete s.encounters.counter}
      if(version<8)delete s.dialogue;else if(version===8)delete s.dialogue.cash;
      if(version<12)delete s.economy;
      else {if(version<13)delete s.economy.exchange;if(version<15)delete s.economy.personalTrade}
      if(version<16)delete s.pod;else if(version<21)delete s.pod.occupied;
      if(version<18)delete s.resources;if(version<19)delete s.engineering;if(version<20)delete s.machinery;
      const migrated=codec.validate(old);equal(migrated.state,codec.create(initial.start.character,12345));
      roundtrip(migrated.state);
    }
  });
  await test('Ground saves preserve original overlapping arrivals and immediate surface park/board recovery',()=>{
    // Explicit native north-arrival fixture; the routed journey above exits west.
    const arrival=structuredClone(surface),position=citySurfaceExit({x:10,y:1},world.surfaceBase.cities[0]);
    arrival.travel.cityPosition={...position};arrival.pod.position={...position};arrival.ground.camera=groundCameraAt(position,true);
    equal(canStandSurface(world.surface(arrival.ground.colonyPosition),position),false);
    const parked=run(arrival,{type:'park'});roundtrip(parked);equal(run(parked,{type:'board'}),arrival);
    const reverse=v=>Array.isArray(v)?v.map(reverse):v&&typeof v==='object'?Object.fromEntries(Object.entries(v).reverse().map(([k,x])=>[k,reverse(x)])):v;
    const saved=codec.make(surface,0);equal(codec.parse(JSON.stringify(reverse(saved))),saved);
  });
  await test('Ground imports reject malformed domains, remote services, blocked positions and cargo duplication atomically',()=>{
    const saved=codec.make(surface,0),before=JSON.stringify(saved);
    const mutations=[s=>s.ground.worldId='world-02',s=>s.ground.podCityId='city-01',
      s=>s.ground.colonyPosition=null,s=>s.ground.colonyPosition={x:12,y:7},
      s=>s.ground.camera={x:40,y:3},s=>s.ground.camera={x:0,y:0},
      s=>s.ground.extra=true,s=>s.pod.heading=16,s=>s.pod.position.x++,
      s=>s.pod.attached=true,s=>s.travel.scene='ship',s=>s.travel.cityPosition.extra=true,
      s=>{s.pod.cargo[1]={commodityId:'cargo-31',quality:7,originCity:'city-01',pricePaid:0}}];
    for(const change of mutations){const bad=structuredClone(saved);change(bad.state);reject(()=>codec.validate(bad),'invalidCampaign')}
    const solid=structuredClone(saved);
    // Locate a real blocked point and keep all other location fields coherent.
    const g=world.surface(surface.ground.colonyPosition);
    let found;
    for(let y=100;y<140&&!found;y++)for(let x=100;x<140;x++)if(!canStandSurface(g,{x,y})){found={x,y};break}
    if(!found)throw new Error('Missing blocked surface fixture');
    solid.state.travel.cityPosition={...found};solid.state.pod.position={...found};solid.state.ground.camera=groundCameraAt(found,true);
    reject(()=>codec.validate(solid),'invalidCampaign');
    const remote=structuredClone(saved);remote.state.ground.cityId='city-02';remote.state.ground.podCityId='city-02';remote.state.travel.scene='exchange';
    reject(()=>codec.validate(remote),'invalidCampaign');equal(JSON.stringify(saved),before);
  });
}
