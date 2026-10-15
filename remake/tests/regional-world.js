import { regionalIndex,systemDistance,warpRequirement,initialRegional,selectRegionalExchange,validateRegionalCargo,campaignLocation } from '../js/core/regional-world.js';
import { campaignSaveCodec } from '../js/core/campaign-saves.js';
import { createCharacter } from '../js/core/character.js';
import { createCityMaps } from '../js/core/city-map.js';
import { reduceCampaignExchange,validateExchange,exchangeSaleQuote } from '../js/core/campaign-exchange.js';
import { reduceCampaignBank } from '../js/core/banking.js';
import { cityServiceAt,atCityBank } from '../js/core/city-doors.js';
import { createGroundWorld } from '../js/core/campaign-ground.js';
import { canDrivePod,podReachability,podServiceAt,tryPodStep } from '../js/core/city-pod.js';
import { reduceCampaignPod } from '../js/core/campaign-pod.js';

export async function regionalWorldTests(test,equal) {
  const names=['initial-navigation','initial-economy','initial-location','ship-inventory','ship-walk','exchange-defaults','items','maps','surface-walk','city-walk'];
  const [navigation,economy,location,inventory,shipWalk,exchange,items,maps,surfaceWalk,cityWalk]=await Promise.all(names.map(n=>fetch(`../data/${n}.json`).then(r=>r.json())));
  const content={navigation,economy,location,inventory,exchange,items,ground:{maps,surfaceWalk,cityWalk}};
  const codec=campaignSaveCodec(content,shipWalk),base=codec.create({...createCharacter(),name:'Regional pilot'},12345);
  base.regional=initialRegional(base.start);base.ground={worldId:'world-01',cityId:'city-01',podCityId:'city-01'};
  const cityMaps=createCityMaps(maps,navigation,economy),index=regionalIndex(content);
  const reject=(f,code)=>{let error;try{f()}catch(e){error=e.message}equal(error,code)};
  function door(map,service) {
    for(let y=200;y<575;y++)for(let x=280;x<834;x++)if(service==='bank'?atCityBank(map,{x,y}):cityServiceAt(map,{x,y})===service)return {x,y};
    throw Error(`No ${service} in ${map.cityId}`);
  }
  await test('Regional membership agrees across all 12 systems, 18 worlds, 57 ordinary cities and Banville',()=>{
    equal([index.worlds.size,index.cities.size],[18,58]);
    equal(index.cities.get('city-60').systemId,'system-01');
    for(const city of index.cities.values())equal(index.worlds.get(city.worldId).systemId,city.systemId);
    const broken=structuredClone(content);broken.exchange.worlds[0].systemId='system-02';reject(()=>regionalIndex(broken),'invalidRegional');
    broken.exchange.worlds[0].systemId='system-01';broken.ground.surfaceWalk.cities.pop();reject(()=>regionalIndex(broken),'invalidRegional');
  });
  await test('Source jump distances include altitude, floor the square root and enforce the 255-charge range',()=>{
    const systems=[{id:'a',position:{x:0,y:0,z:0}},{id:'b',position:{x:3,y:4,z:12}},{id:'c',position:{x:0,y:0,z:9}},{id:'d',position:{x:0,y:0,z:10}}];
    equal(systemDistance(systems,'a','b'),13);equal(warpRequirement(systems,'a','c'),253);equal(warpRequirement(systems,'a','d'),310);
    const reached=new Set(['system-01']);
    for(let pass=0;pass<12;pass++)for(const a of [...reached])for(const b of base.start.systems)if(warpRequirement(base.start.systems,a,b.id)<=255)reached.add(b.id);
    equal(reached.size,12);
  });
  await test('Dormant regional economies have one owner and restore independent city stock and warehouses',()=>{
    const before=JSON.stringify(base),next=selectRegionalExchange(base,'city-09');
    equal(JSON.stringify(base),before);equal(next.regional.cities.length,56);
    equal(next.economy.exchange.market.cityId,'city-09');
    next.economy.exchange.market.lastUpdateDay=0;next.economy.exchange.market.supply[0]=0;
    const returned=selectRegionalExchange(selectRegionalExchange(next,'city-01'),'city-09');equal(returned.economy.exchange,next.economy.exchange);
    validateRegionalCargo(base.start,returned.economy.exchange,returned.pod,returned.regional);
    const bad=structuredClone(next);bad.regional.cities[0]=bad.regional.cities[1];reject(()=>validateRegionalCargo(base.start,bad.economy.exchange,bad.pod,bad.regional),'invalidRegional');
    reject(()=>selectRegionalExchange(base,'city-60'),'exchangeUnavailable');
  });
  await test('Regional bank operations debit the visited system and reject a mismatched map atomically',()=>{
    const next=structuredClone(base),map=cityMaps['city-09'];next.ground={worldId:'world-03',cityId:'city-09',podCityId:'city-09'};
    next.travel={scene:'bank',cityPosition:door(map,'bank')};
    equal(campaignLocation(next,content).systemId,'system-02');
    const before=JSON.stringify(next),result=reduceCampaignBank(next,map,{type:'withdraw',amount:100},content);
    equal(JSON.stringify(next),before);equal(result.economy.accounts[1].balance,next.economy.accounts[1].balance-100);
    equal(result.economy.accounts[0],next.economy.accounts[0]);equal(result.dialogue.cash,next.dialogue.cash+100);
    reject(()=>reduceCampaignBank(next,cityMaps['city-01'],{type:'withdraw',amount:100},content),'bankUnavailable');
  });
  await test('Regional exchange loads destination stock, preserves origin-based sale quotes and credits its own bank',()=>{
    let state=structuredClone(base),map=cityMaps['city-09'];state.ground={worldId:'world-03',cityId:'city-09',podCityId:'city-09'};
    state.travel={scene:'city',cityPosition:door(map,'exchange')};
    state=reduceCampaignExchange(state,content,map,{type:'enter'});
    equal(state.economy.exchange.market.cityId,'city-09');equal(state.economy.exchange.market.lastUpdateDay,0);
    const slot=state.economy.exchange.warehouse.slots.indexOf(null),cargo={commodityId:'cargo-02',quality:7,originCity:'city-01',pricePaid:100};
    // Declared foreign-lot fixture isolates regional quotation/settlement rules.
    state.economy.exchange.warehouse.slots[slot]=cargo;
    const quote=exchangeSaleQuote(state,content,slot);equal(quote>100,true);
    const before=JSON.stringify(state),sold=reduceCampaignExchange(state,content,map,{type:'sell',slot});
    equal(JSON.stringify(state),before);equal(sold.regional.cargoProceeds,quote);equal(sold.economy.accounts[1].balance,state.economy.accounts[1].balance+quote);
    equal(sold.economy.accounts[0],state.economy.accounts[0]);equal(sold.economy.exchange.warehouse.slots[slot],null);
    equal(validateExchange(state.economy.exchange,state.start,state.ship,state.travel,content,{regional:true,movableCargo:true,auxiliaryFuel:true}),state.economy.exchange);
    reject(()=>validateExchange(state.economy.exchange,state.start,state.ship,state.travel,content,{movableCargo:true,auxiliaryFuel:true}),'invalidCampaign');
    reject(()=>reduceCampaignExchange(state,content,cityMaps['city-01'],{type:'sell',slot}),'exchangeUnavailable');
  });
  await test('All 17 original cryogens remain conserved across dormant warehouses, local stock and pod cargo',()=>{
    const next=structuredClone(base),c=next.regional.cities.find(c=>c.warehouse.slots[0]?.commodityId==='cargo-31');
    next.pod.cargo[0]=c.warehouse.slots[0];c.warehouse.slots[0]=null;
    validateRegionalCargo(base.start,next.economy.exchange,next.pod,next.regional);
    const bad=structuredClone(next);bad.pod.cargo[1]=bad.pod.cargo[0];reject(()=>validateRegionalCargo(base.start,bad.economy.exchange,bad.pod,bad.regional),'invalidRegional');
    bad.pod.cargo=[null,null];reject(()=>validateRegionalCargo(base.start,bad.economy.exchange,bad.pod,bad.regional),'invalidRegional');
  });
  await test('A remote city pod can fetch its own cryogen after entering from the surface',()=>{
    const world=createGroundWorld({...content,...content.ground},base.start),g=world.city('city-02',false).pod;
    const origin=g.podOrigins.find(o=>canDrivePod(g,o.position,o.heading));
    equal(Boolean(origin),true);
    const queue=[origin],seen=new Set([`${origin.position.x}/${origin.position.y}`]);let target=null;
    for(let i=0;i<queue.length&&!target;i++)for(let dy=-1;dy<=1;dy++)for(let dx=-1;dx<=1;dx++)if(dx||dy){
      const moved=tryPodStep(g,queue[i].position,dx,dy);if(!moved)continue;
      const key=`${moved.position.x}/${moved.position.y}`;if(seen.has(key))continue;
      seen.add(key);queue.push(moved);
      if(podServiceAt(g,moved.position,moved.heading)==='exchange'){target=moved;break}
    }
    equal(Boolean(target),true);equal(podReachability(g)(target.position,target.heading),true);
    let s=selectRegionalExchange(structuredClone(base),'city-02');
    s.ground={...s.ground,cityId:'city-02',podCityId:'city-02'};
    s.pod={...s.pod,attached:false,occupied:true,position:target.position,heading:target.heading};
    s.travel={scene:'exchange',cityPosition:target.position};
    equal(s.economy.exchange.warehouse.slots[0]?.commodityId,'cargo-31');
    const moved=reduceCampaignPod(s,g,{type:'fetch',slot:0});
    equal(moved.pod.cargo[0],s.economy.exchange.warehouse.slots[0]);
    equal(moved.economy.exchange.warehouse.slots[0],null);
    validateRegionalCargo(moved.start,moved.economy.exchange,moved.pod,moved.regional);
  });
}
