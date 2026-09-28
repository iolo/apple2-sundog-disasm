import { createInitialEconomy, refreshCityMarket } from '../js/core/economy.js';
import { sourceRandom } from '../js/core/random.js';

export async function economyTests(test,equal) {
  const [content,captured] = await Promise.all(['../data/initial-economy.json','fixtures/economy-reference.json'].map(path=>fetch(path).then(r=>r.json())));
  const tape = values => {let count=0;return {get count(){return count},next(){return values[count++] ?? 0}}};
  const rejects = run => {let threw=false;try{run()}catch{threw=true}equal(threw,true)};
  const empty = () => ({cityId:'city-01',templateIndex:0,demand:Array(31).fill(0),supply:Array(31).fill(0),lastUpdateDay:-16});
  const template = () => ({demand:Array(31).fill(7),supply:Array(31).fill(7)});
  await test('Initial markets reproduce 58 captured records without phase/scratch records',()=>{
    const state=createInitialEconomy(content,tape([]));
    equal(state.selector,captured.selector);
    equal(state.markets.map(({templateIndex,...market})=>market),captured.markets);
    equal(state.colony,{completedPhase:0,activePhase:0});
    equal(content.colonyRequirements,captured.colonyRequirements);
    equal(content.colonyRequirements.map(phase=>phase[30]),[0,2,4,1,2,3,2,2,1]);
    equal(state.markets.map(m=>m.cityId),[...content.cities.map(c=>c.id),'city-60']);
    const changed=structuredClone(content);changed.selector=17;
    equal(createInitialEconomy(changed,tape([])).selector,4);
    const before=JSON.stringify(content);state.markets[0].demand[0]=99;
    equal(JSON.stringify(content),before);equal(state.markets[1].demand,captured.markets[1].demand);
  });
  await test('Cryogen placement preserves source cursor arithmetic, wrapping and occupied retries',()=>{
    const random=tape([]),state=createInitialEconomy(content,random);
    equal(random.count,18);
    equal(state.warehouses.filter(w=>w.slots[0]).map(w=>w.cityId),Array.from({length:17},(_,i)=>`city-${String(3+i*2).padStart(2,'0')}`));
    // Explicit wrap witness: cursor57 +1 -> city02.
    equal(createInitialEconomy(content,tape([56])).warehouses[1].slots[0]?.originCity,'city-02');
    // A 12-city cycle totals57 (nine5s, three4s), then repeats occupied cities.
    const cycle=[...Array(9).fill(3),...Array(3).fill(2)];
    const retry=tape([0,...cycle,...cycle]);
    const retried=createInitialEconomy(content,retry);
    equal(retry.count>18,true);equal(retried.warehouses.filter(w=>w.slots[0]).length,17);
    let n=0;
    rejects(()=>createInitialEconomy(content,{next(){return n++===0 ? 0 : cycle[(n-2)%cycle.length]}}));
    for(const warehouses of [state.warehouses,captured.warehouses]) {
      const cargo=warehouses.flatMap(w=>w.slots.filter(Boolean));equal(cargo.length,17);
      equal(warehouses.every(w=>w.slots.length===4 && w.slots.slice(1).every(s=>s===null)),true);
      equal(warehouses.every(w=>w.slots[0]===null || JSON.stringify(w.slots[0])===JSON.stringify({commodityId:'cargo-31',quality:7,originCity:w.cityId,pricePaid:0})),true);
      equal(warehouses.at(-1),{cityId:'city-60',slots:[null,null,null,null]});
    }
  });
  await test('First market visit draws supply then demand for 30 goods; day zero is initialized',()=>{
    const market={...empty(),...template()},before=structuredClone(market),random=tape([5,2,4,3]);
    const first=refreshCityMarket(market,template(),0,random);
    equal(first.supply.slice(0,2),[5,4]);equal(first.demand.slice(0,2),[2,3]);equal(random.count,60);
    equal(first.demand[30],7);equal(first.supply[30],7);equal(market,before);
    const again=refreshCityMarket(first,template(),0,random);equal(again,first);equal(random.count,60);
    const zero=tape([]);refreshCityMarket(empty(),template(),1,zero);equal(zero.count,60);
    first.demand[0]=6;equal(again.demand[0],2);
  });
  await test('Weekly refill caps both tables, leaves cryogens alone and discards partial weeks',()=>{
    const market={...empty(),lastUpdateDay:1};market.demand[30]=4;market.supply[30]=5;
    const random={next(){throw new Error('Unexpected draw')}};
    equal(refreshCityMarket(market,template(),7,random),market);
    const week=refreshCityMarket(market,template(),8,random);
    equal(week.demand.slice(0,30),Array(30).fill(1));equal(week.supply.slice(0,30),Array(30).fill(1));
    equal([week.demand[30],week.supply[30],week.lastUpdateDay],[4,5,8]);
    const late=refreshCityMarket(market,template(),17,random);equal(late.demand[0],2);equal(late.lastUpdateDay,17);
    equal(refreshCityMarket(late,template(),23,random),late);
    equal(refreshCityMarket(late,template(),24,random).supply[0],3);
    equal(refreshCityMarket(late,template(),100,random).supply[0],7);
    equal(refreshCityMarket(late,empty(),24,random).supply[0],0);
    equal(refreshCityMarket(late,template(),0,random),late); // Source subtraction does not wrap days.
  });
  await test('Invalid economy inputs and failed draws leave caller state intact',()=>{
    for(const value of [-1,32768,NaN,1.5]) rejects(()=>createInitialEconomy(content,{next:()=>value}));
    rejects(()=>createInitialEconomy({...content,selector:256},tape([])));
    rejects(()=>createInitialEconomy({...content,cities:[]},tape([])));
    const market=empty(),before=structuredClone(market);
    rejects(()=>refreshCityMarket(market,template(),0,{next:()=>-1}));equal(market,before);
    for(const day of [-1,16384,0.5]) rejects(()=>refreshCityMarket(market,template(),day,tape([])));
    rejects(()=>refreshCityMarket({...market,cityId:'city-60'},template(),0,tape([])));
    rejects(()=>refreshCityMarket({...market,demand:[0]},template(),0,tape([])));
    rejects(()=>refreshCityMarket(market,{demand:Array(31).fill(8),supply:Array(31).fill(0)},0,tape([])));
  });
  await test('1000 seeded economies replay with 17 distinct cargo origins and independent state',()=>{
    const before=JSON.stringify(content);
    for(let seed=1;seed<=1000;seed++) {
      const run=()=>{const random=sourceRandom(seed);return {economy:createInitialEconomy(content,random),randomState:random.state}};
      const a=run(),b=run();equal(a,b);
      const cargo=a.economy.warehouses.flatMap(w=>w.slots.filter(Boolean));
      equal(new Set(cargo.map(c=>c.originCity)).size,17);
      a.economy.warehouses.find(w=>w.slots[0]).slots[0].quality=0;
      equal(b.economy.warehouses.flatMap(w=>w.slots.filter(Boolean)).every(c=>c.quality===7),true);
    }
    equal(JSON.stringify(content),before);
  });
}
