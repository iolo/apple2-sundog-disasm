import { createGroundWorld,initialGround,reduceCampaignGround } from '../js/core/campaign-ground.js';
import { groundCameraAt,scrollGroundCamera,groundWindow } from '../js/core/ground-camera.js';
import { createCampaignStart } from '../js/core/campaign.js';
import { createCharacter } from '../js/core/character.js';
import { canStand,tryStep } from '../js/core/ship-walk.js';
import { canBoardShip,createCityGeometry } from '../js/core/city-walk.js';
import { tryPodStep,canDockPod } from '../js/core/city-pod.js';
import { trySurfaceStep,surfaceCityAt } from '../js/core/surface-walk.js';

export async function campaignGroundTests(test,equal) {
  const names=['maps','initial-navigation','initial-economy','initial-location','ship-inventory','city-walk','surface-walk'];
  const [maps,navigation,economy,location,inventory,cityWalk,surfaceWalk]=await Promise.all(names.map(n=>fetch(`../data/${n}.json`).then(r=>r.json())));
  const content={maps,navigation,economy,location,inventory,cityWalk,surfaceWalk};
  const start=createCampaignStart({...createCharacter(),name:'Ground pilot'},content,12345),world=createGroundWorld(content,start);
  const city=world.city('city-01',false),spawn=city.pod.spawn;
  // Loaded cargo fixture isolates transport conservation from R07's separately
  // verified purchase journey. Every subsequent movement uses collision steps.
  const cargo=[{commodityId:'cargo-01',quality:7,originWorld:'world-01',pricePaid:0},null];
  const fresh=()=>({start,ship:{position:{x:54,y:118}},resources:{fuel:123},
    ground:initialGround(start,spawn),travel:{scene:'city',cityPosition:{...spawn}},
    pod:{attached:false,occupied:true,position:{...spawn},heading:16,cargo:structuredClone(cargo)},
    encounters:{randomState:start.gameplayRandomState},economy:{accounts:[{balance:1000}]}});
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
    reject(()=>run(s,{type:'board'}),'podUnavailable');
    const foot=world.foot(s);
    const outbound=route(foot,s.travel.cityPosition,p=>p.x<130,tryStep);
    for(const a of outbound){s=run(s,a);if(s.travel.scene==='surface')break}
    equal(s.travel.scene,'surface');equal(s.encounters.randomState,randomState);equal(s.pod,parked);
    const back=route(g,s.travel.cityPosition,p=>p.x===parked.position.x&&p.y===parked.position.y,trySurfaceStep);
    for(const a of back)s=run(s,a);
    s=run(s,{type:'board'});equal(s.pod,{...parked,occupied:true});equal(s.pod.cargo,cargo);
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
}
