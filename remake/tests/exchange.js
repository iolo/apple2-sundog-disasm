import { exchangeLocation, scaleExchangePrice, quoteExchangeCargo, createExchangeOffers, prepareExchangeVisit } from '../js/core/exchange.js';

export async function exchangeTests(test,equal) {
  const [content,items,economy]=await Promise.all(['exchange-defaults','items','initial-economy'].map(n=>fetch(`../data/${n}.json`).then(r=>r.json())));
  const rejects=(run,message='invalidExchange')=>{let error;try{run()}catch(e){error=e.message}equal(error,message)};
  const market=()=>({cityId:'city-01',templateIndex:10,demand:Array(31).fill(4),supply:Array(31).fill(4),lastUpdateDay:-16});
  const location={cityId:'city-01',worldId:'world-01',systemId:'system-01',capital:true,priceLevel:8,technologyLevel:8};
  const tape=values=>{let count=0;return {next(){return values[count++]??0},get count(){return count}}};
  const quote=(cargo={},context={},side='buy')=>quoteExchangeCargo({commodityId:'cargo-02',quality:6,...cargo},
    {market:market(),location,items,...context},side);
  await test('Exchange geography resolves all 57 ordinary cities and excludes colony and scratch records',()=>{
    for(const city of economy.cities) {
      const at=exchangeLocation(content,city.id),world=content.worlds.find(w=>w.id===city.worldId);
      equal(at.worldId,city.worldId);equal(at.systemId,world.systemId);equal(at.capital,world.capitalCityId===city.id);
    }
    equal(exchangeLocation(content,'city-01'),{...location,technologyLevel:14});
    for(const city of ['city-00','city-58','city-59','city-60','city-1',null])rejects(()=>exchangeLocation(content,city));
  });
  await test('Exchange price factors truncate in source order and return credits in hundreds',()=>{
    equal(quote(),19300);
    const m=market();m.demand[1]=6;m.supply[1]=2;
    equal(quote({}, {market:m}),28900); // 193*12/8 -> 289.
    equal(quote({quality:7},{market:m,location:{...location,priceLevel:10}}),40600); // 289->361->406.
    equal(quote({}, {location:{...location,capital:false}}),15400);
    equal(quote({quality:0}),11000);
    equal(quote({commodityId:'cargo-16'},{location:{...location,technologyLevel:14}}),6200);
    equal(quote({commodityId:'cargo-24'},{location:{...location,technologyLevel:4}}),33300);
    equal(quote({commodityId:'cargo-25'},{location:{...location,technologyLevel:4}}),11400);
    const cheap=items.map(i=>({...i,valueByte:i.id==='cargo-02'?0:i.valueByte}));
    equal(quote({}, {items:cheap}),100);
  });
  await test('Source multiplication guard includes equality and refuses financial overflow',()=>{
    equal(scaleExchangePrice(3275,10,8),4093);
    equal(scaleExchangePrice(3276,10,8),4090);
    equal(scaleExchangePrice(3277,10,8),4090);
    equal(scaleExchangePrice(32767,8,15),17472);
    rejects(()=>scaleExchangePrice(32767,12,8),'exchangePriceOverflow');
    for(const n of [-1,NaN,Infinity,0.5,32768])rejects(()=>scaleExchangePrice(n,8,8));
  });
  await test('Resale ceilings distinguish origin city, world and system and forbid fuel and cryogens',()=>{
    const cargo={originCity:'city-01',pricePaid:10000};
    equal(quote(cargo,{originLocation:location},'sell'),10000);
    equal(quote({...cargo,originCity:'city-02'},{originLocation:{...location,cityId:'city-02'}},'sell'),12500);
    equal(quote({...cargo,originCity:'city-02'},{originLocation:{...location,cityId:'city-02',worldId:'world-02'}},'sell'),15000);
    equal(quote({...cargo,originCity:'city-02'},{originLocation:{...location,cityId:'city-02',worldId:'world-03',systemId:'system-02'}},'sell'),19300);
    equal(quote({...cargo,pricePaid:30000},{location:{...location,capital:false},originLocation:location},'sell'),24100);
    equal(quote({...cargo,pricePaid:0},{originLocation:location},'sell'),0); // Literal proc37 branch order.
    for(const commodityId of ['cargo-01','cargo-31'])equal(quote({commodityId}, {},'sell'),null);
    rejects(()=>quote({...cargo,pricePaid:10001},{originLocation:location},'sell'));
    rejects(()=>quote(cargo,{},'sell'));
  });
  await test('Offer board keeps source quality draws, increment-before-probe, wrap and unique pairs',()=>{
    const m=market();m.supply.fill(7);
    const random=tape([]),before=structuredClone(m),offers=createExchangeOffers(m,location,items,random);
    equal(offers.map(o=>[o.commodityId,o.quality]),Array.from({length:8},(_,i)=>[`cargo-${String(i+2).padStart(2,'0')}`,1]));
    equal(random.count,32);equal(m,before);
    const varied=tape([3,3,29,0, 0,0,30,0, 0,0,0,0]);
    const rows=createExchangeOffers(m,location,items,varied);
    equal(rows.slice(0,3).map(o=>[o.commodityId,o.quality]),[['cargo-02',7],['cargo-02',1],['cargo-03',1]]);
  });
  await test('Empty offers still draw acceptance; sparse stock can show several qualities without consuming stock',()=>{
    const m=market();m.supply.fill(0);
    const random=tape([]);equal(createExchangeOffers(m,location,items,random),Array(8).fill(null));equal(random.count,32);
    m.supply[1]=7;
    const sparse=tape([0,0,0,0, 1,0,0,0]);
    const rows=createExchangeOffers(m,location,items,sparse);
    equal(rows.map(o=>o&&o.quality),[1,2,null,null,null,null,null,null]);equal(m.supply[1],7);
    // First candidate fails supply>draw%7, the next candidate wins. Quality
    // stays fixed and no additional starting-index draw occurs on retry.
    m.supply[1]=1;m.supply[2]=7;
    const retry=tape([0,0,0,6,0]);equal(createExchangeOffers(m,location,items,retry)[0].commodityId,'cargo-03');
  });
  await test('1000 staged exchange visits replay refresh, offer board and continuing RNG with owned results',()=>{
    const m=market(),before=JSON.stringify({m,content,items});
    for(let seed=1;seed<=1000;seed++) {
      const args={market:m,template:economy.templates[10],day:0,randomState:seed,content,items};
      const a=prepareExchangeVisit(args),b=prepareExchangeVisit(args);equal(a,b);
      equal(a.market.lastUpdateDay,0);equal(a.offers.length,8);
      const nonempty=a.offers.filter(Boolean);
      equal(new Set(nonempty.map(o=>`${o.commodityId}/${o.quality}`)).size,nonempty.length);
      equal(nonempty.every(o=>o.price>=100&&o.price%100===0&&a.market.supply[Number(o.commodityId.slice(6))-1]>0),true);
      a.market.supply[0]=99;if(a.offers[0])a.offers[0].price=0;
      equal(b.market.supply[0]!==99,true);
      const revisit=prepareExchangeVisit({...args,market:b.market,randomState:b.randomState});
      equal(revisit.market,b.market);equal(revisit.randomState!==b.randomState,true);
    }
    equal(JSON.stringify({m,content,items}),before);
  });
  await test('Malformed quotes and failed staged visits cannot partially change market or RNG state',()=>{
    for(const cargo of [{quality:8},{quality:-1},{commodityId:'cargo-00'},{commodityId:'cargo-31'},{commodityId:'item-02'}])rejects(()=>quote(cargo));
    const sparse=Array(31);rejects(()=>quote({}, {market:{...market(),demand:sparse}}));
    const args={market:market(),template:economy.templates[10],day:0,randomState:1,content,items:[]};
    const before=JSON.stringify(args);rejects(()=>prepareExchangeVisit(args));equal(JSON.stringify(args),before);
    const m=market();m.supply.fill(1);
    const stuck={next(){return 6}};
    rejects(()=>createExchangeOffers(m,location,items,stuck),'exchangeOfferLimit');
    rejects(()=>createExchangeOffers(m,location,items,{next:()=>32768}));
  });
}
