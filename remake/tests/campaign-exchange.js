import { campaignSaveCodec } from '../js/core/campaign-saves.js';
import { reduceCampaignExchange, exchangeSaleQuote } from '../js/core/campaign-exchange.js';
import { createCharacter } from '../js/core/character.js';
import { createCityMaps } from '../js/core/city-map.js';
import { createCityGeometry, cityReachability, SHIP_REENTRY } from '../js/core/city-walk.js';
import { cityServiceAt } from '../js/core/city-doors.js';
import { reduceCampaignBank, MAX_CREDITS } from '../js/core/banking.js';
import { initialPodCargo, reduceWarehouseCargo } from '../js/core/cargo.js';

export async function campaignExchangeTests(test,equal) {
  const [navigation,economy,location,inventory,ship,maps,cityData,exchange,items]=await Promise.all(
    ['initial-navigation','initial-economy','initial-location','ship-inventory','ship-walk','maps','city-walk','exchange-defaults','items'].map(n=>fetch(`../data/${n}.json`).then(r=>r.json())));
  const content={navigation,economy,location,inventory,exchange,items};
  const map=createCityMaps(maps,navigation,economy)['city-01'],city=createCityGeometry(map,cityData,{...location,position:location.shipPosition}),reached=cityReachability(city);
  let door;for(let y=192;y<576&&!door;y++)for(let x=280;x<840;x++)if(cityServiceAt(map,{x,y})==='exchange'&&reached({x,y})){door={x,y};break}
  const codec=campaignSaveCodec(content,ship,city);
  const fresh=()=>{const s=codec.create({...createCharacter(),name:'Trader'},12345);s.ship.position={...SHIP_REENTRY};s.travel={scene:'city',cityPosition:{...door}};return s};
  const run=(s,a)=>reduceCampaignExchange(s,content,map,a),enter=s=>run(s,{type:'enter'});
  const funds=s=>s.dialogue.cash+s.economy.accounts[0].balance;
  const wealth=s=>s.dialogue.cash+s.economy.accounts.reduce((n,a)=>n+a.balance,0)+s.economy.exchange.warehouse.slots.reduce((n,c)=>n+(c?.pricePaid||0),0);
  const affordable=s=>s.economy.exchange.visit.offers.findIndex(o=>o&&o.price<funds(s));
  const rejects=(fn,message)=>{let error;try{fn()}catch(e){error=e.message}equal(error,message)};
  await test('A purchased lot survives a core loading round trip without repricing; campaign saves reject misplaced cargo fields',()=>{
    const entered=enter(fresh()),bought=run(entered,{type:'buy',slot:affordable(entered)}),before=structuredClone(bought);
    const session={warehouse:bought.economy.exchange.warehouse,pod:initialPodCargo()},visit={cityId:'city-01',transport:'pod'};
    const fetched=reduceWarehouseCargo(session,visit,{type:'fetch',slot:0});
    equal(fetched.pod[0],bought.economy.exchange.warehouse.slots[0]);equal(fetched.warehouse.slots[0],null);
    const stored=reduceWarehouseCargo(fetched,visit,{type:'store',slot:0});equal(stored,session);equal(bought,before);
    const restored={...bought,economy:{...bought.economy,exchange:{...bought.economy.exchange,warehouse:stored.warehouse}}};
    equal(exchangeSaleQuote(restored,content,0),exchangeSaleQuote(bought,content,0));equal(codec.snapshot(restored),bought);
    equal(run(restored,{type:'sell',slot:0}),run(bought,{type:'sell',slot:0}));
    for(const inject of [s=>s.economy.pod=fetched.pod,s=>s.economy.exchange.pod=fetched.pod,s=>s.ship.cargo=fetched.pod,
      s=>s.travel.transport='pod',s=>s.economy.exchange.warehouse.slots[0].pricePaid=0]) {
      const bad=structuredClone(bought);inject(bad);rejects(()=>codec.snapshot(bad),'invalidCampaign');
    }
    rejects(()=>run(bought,{type:'fetch',slot:0}),'exchangeInvalidSelection');equal(bought,before);
    equal(codec.make(bought,0).version,21);
  });
  await test('Exchange entry validates the door and commits market, eight offers and RNG together',()=>{
    const s=fresh(),before=structuredClone(s),e=enter(s);equal(s,before);
    equal(e.travel.scene,'exchange');equal(e.economy.exchange.market.lastUpdateDay,0);equal(e.economy.exchange.visit.offers.length,8);
    equal(e.encounters.randomState!==s.encounters.randomState,true);equal(e.dialogue,s.dialogue);equal(e.economy.accounts,s.economy.accounts);
    equal(codec.snapshot(e),e);equal(enter(s),e);
    rejects(()=>enter({...s,travel:{scene:'city',cityPosition:city.spawn}}),'exchangeUnavailable');
    rejects(()=>enter(e),'exchangeUnavailable');
    const left=run(e,{type:'leave'});equal(left.economy.exchange.visit,null);equal(left.economy.exchange.market,e.economy.exchange.market);
    const again=enter(left);equal(again.economy.exchange.market,e.economy.exchange.market);equal(again.encounters.randomState!==e.encounters.randomState,true);
  });
  await test('Purchases use bank first, store an owned lot and replace only its offer before stock reduction',()=>{
    const s=enter(fresh()),slot=affordable(s),offer=s.economy.exchange.visit.offers[slot],before=structuredClone(s),next=run(s,{type:'buy',slot});
    equal(s,before);equal(next.dialogue.cash,s.dialogue.cash);equal(next.economy.accounts[0].balance,s.economy.accounts[0].balance-offer.price);equal(wealth(next),wealth(s));
    equal(next.economy.exchange.warehouse.slots[0],{commodityId:offer.commodityId,quality:offer.quality,originCity:'city-01',pricePaid:offer.price});
    next.economy.exchange.visit.offers.forEach((o,i)=>{if(i!==slot)equal(o,s.economy.exchange.visit.offers[i])});
    const n=Number(offer.commodityId.slice(6))-1,drop=s.economy.exchange.market.supply[n]-next.economy.exchange.market.supply[n];
    equal([0,1,2].includes(drop),true);equal(codec.snapshot(next),next);
    const cash=structuredClone(s);cash.dialogue.cash=offer.price;cash.economy.accounts[0].balance=1;
    const spill=run(cash,{type:'buy',slot});equal(spill.dialogue.cash,1);equal(spill.economy.accounts[0].balance,0);
  });
  await test('Exact funds, empty selection and full warehouses reject without spending credits or RNG',()=>{
    const s=enter(fresh()),slot=affordable(s),offer=s.economy.exchange.visit.offers[slot];
    s.dialogue.cash=offer.price;s.economy.accounts[0].balance=0;
    let before=structuredClone(s);rejects(()=>run(s,{type:'buy',slot}),'exchangeInsufficient');equal(s,before);
    s.dialogue.cash++;equal(run(s,{type:'buy',slot}).dialogue.cash,1);
    s.economy.exchange.warehouse.slots.fill({commodityId:'cargo-02',quality:1,originCity:'city-01',pricePaid:100});
    before=structuredClone(s);rejects(()=>run(s,{type:'buy',slot}),'exchangeFull');equal(s,before);
    for(const slot of [-1,8,0.5])rejects(()=>run(s,{type:'buy',slot}),'exchangeInvalidSelection');
  });
  await test('Warehouse sales credit the local bank, clear one slot and respect the local purchase-price ceiling',()=>{
    const entered=enter(fresh()),bought=run(entered,{type:'buy',slot:affordable(entered)}),price=exchangeSaleQuote(bought,content,0);
    const before=structuredClone(bought),sold=run(bought,{type:'sell',slot:0});equal(bought,before);
    equal(sold.dialogue.cash,bought.dialogue.cash);equal(sold.economy.accounts[0].balance,bought.economy.accounts[0].balance+price);
    equal(sold.economy.exchange.warehouse.slots[0],null);equal(wealth(sold)<=wealth(bought),true);equal(codec.snapshot(sold),sold);
    rejects(()=>run(sold,{type:'sell',slot:0}),'exchangeNotNegotiable');
    const full=structuredClone(bought);full.economy.accounts[0].balance=MAX_CREDITS;
    const unchanged=structuredClone(full);rejects(()=>run(full,{type:'sell',slot:0}),'bankOverflow');equal(full,unchanged);
    full.economy.exchange.warehouse.slots[0]={commodityId:'cargo-31',quality:7,originCity:'city-01',pricePaid:0};
    rejects(()=>run(full,{type:'sell',slot:0}),'exchangeNotNegotiable');
  });
  await test('Version13 resumes bought cargo and stale offer prices exactly, rejecting inconsistent progress',()=>{
    const e=enter(fresh()),b=run(e,{type:'buy',slot:affordable(e)}),save=codec.make(b,0);
    equal(save.version,21);equal(save.scope,'landed-parking-1');equal(codec.parse(JSON.stringify(save)).state,b);
    const offer=b.economy.exchange.visit.offers.findIndex(Boolean);
    for(const mutate of [s=>s.economy.exchange.visit.offers[offer].price++,s=>s.economy.exchange.visit.offers[offer].supply=8,
      s=>s.economy.exchange.market.supply[0]=8,s=>s.economy.exchange.market.lastUpdateDay=1,
      s=>s.economy.exchange.warehouse.slots[0].originCity='city-02',s=>s.economy.exchange.warehouse.slots[0].pricePaid=3276700,
      s=>s.economy.exchange.warehouse.slots[0].quality=8,s=>s.economy.exchange.warehouse.slots.push(null),
      s=>s.economy.exchange.extra=true,s=>s.travel.scene='city']) {
      const bad=structuredClone(save);mutate(bad.state);rejects(()=>codec.validate(bad),'invalidCampaign');
    }
    const reverse=v=>Array.isArray(v)?v.map(reverse):v&&typeof v==='object'?Object.fromEntries(Object.entries(v).reverse().map(([k,x])=>[k,reverse(x)])):v;
    equal(codec.validate(reverse(save)),save);
    const restored=codec.parse(JSON.stringify(save)).state;
    equal(run(restored,{type:'sell',slot:0}),run(b,{type:'sell',slot:0}));
  });
  await test('Version12 initializes local economy after historical validation; bank transfers preserve traded state',()=>{
    const f=fresh(),legacy=codec.make(f,0);legacy.version=12;delete legacy.state.pod?.occupied;delete legacy.state.machinery;delete legacy.state.engineering;delete legacy.state.resources;delete legacy.state.pod;delete legacy.state.economy.personalTrade;legacy.scope='landed-banking-1';delete legacy.state.economy.exchange;
    equal(codec.validate(legacy).state,f);
    const injected=structuredClone(legacy);injected.state.economy.exchange=f.economy.exchange;rejects(()=>codec.validate(injected),'invalidCampaign');
    const e=enter(f),b=run(e,{type:'buy',slot:affordable(e)}),left=run(b,{type:'leave'});
    left.travel={scene:'bank',cityPosition:{x:369,y:299}};
    const next=reduceCampaignBank(left,map,{type:'withdraw',amount:100});equal(next.economy.exchange,left.economy.exchange);equal(codec.snapshot(next),next);
  });
  await test('Entry refills weekly stock, preserves initial cryogens and rolls back a failed offer replacement',()=>{
    const e=enter(fresh()),left=run(e,{type:'leave'});left.ship.minutes=7*1440;
    const week=enter(left),template=economy.templates[e.economy.exchange.market.templateIndex];
    for(const field of ['demand','supply'])equal(week.economy.exchange.market[field].slice(0,30),e.economy.exchange.market[field].slice(0,30).map((v,i)=>Math.min(v+1,template[field][i])));
    equal(week.economy.exchange.market.lastUpdateDay,7);equal(codec.snapshot(week),week);
    const before=structuredClone(e);
    rejects(()=>reduceCampaignExchange(e,{...content,items:[]},map,{type:'buy',slot:affordable(e)}),'invalidExchange');equal(e,before);
    let cryo;
    for(let seed=1;seed<=100&&!cryo;seed++) {
      const s=codec.create({...createCharacter(),name:'Cryogen keeper'},seed);
      if(s.economy.exchange.warehouse.slots[0])cryo=s;
    }
    equal(!!cryo,true);equal(codec.snapshot(cryo),cryo);
    const saved=codec.make(cryo,0);saved.state.economy.exchange.warehouse.slots[0]=null;
    rejects(()=>codec.validate(saved),'invalidCampaign');
  });
}
