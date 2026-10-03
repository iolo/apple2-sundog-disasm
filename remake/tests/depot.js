import { depotPrices, scaleDepotPrice, depotRefuelResult, quoteDepotService, purchaseDepotService } from '../js/core/depot.js';

export async function depotTests(test,equal) {
  const visit={local12:14,local13:8,local14:12,cityId:'city-01',worldId:'world-01',shipPresent:true,podPresent:true};
  const fresh=()=>({hull:13,fuel:0,cash:153,bankBalance:29474,pod:[null,null]});
  const reject=(fn,message)=>{let error;try{fn()}catch(e){error=e.message}equal(error,message)};
  await test('Depot source price vectors distinguish fuel units, hull points and auxiliary loads',()=>{
    // Jondd: factor12+8+16-14=22. Hull13:250*8/10 ->200*8/11 ->145.
    equal(depotPrices(visit,13),{refuel:157,repair:145,auxiliary:2200});
    equal(depotPrices(visit,12).repair,290);equal(depotPrices(visit,8).repair,436);
    equal(depotPrices(visit,0).repair,727);
    // The second adjustment divides before multiplying once its product exceeds32767.
    equal(depotPrices({local12:0,local13:15,local14:15},0),{refuel:328,repair:4680,auxiliary:4600});
    equal(depotPrices({local12:15,local13:0,local14:0},16),{refuel:7,repair:76,auxiliary:100});
    equal(scaleDepotPrice(16383,2,3),10922);equal(scaleDepotPrice(16382,2,3),10921);
    reject(()=>scaleDepotPrice(32767,23,1),'depotPriceOverflow');
    reject(()=>depotPrices({...visit,local12:16},13),'invalidDepot');
  });
  await test('All source system nibbles and hull conditions produce positive bounded service prices',()=>{
    for(let local12=0;local12<16;local12++)for(let local13=0;local13<16;local13++)for(let local14=0;local14<16;local14++) {
      let previous=Infinity;
      for(let hull=0;hull<=16;hull++) {
        const q=depotPrices({local12,local13,local14},hull);
        equal(q.refuel>=7&&q.refuel<=328&&q.auxiliary>=100&&q.auxiliary<=4600,true);
        equal(Number.isInteger(q.repair)&&q.repair>0&&q.repair<=previous,true);previous=q.repair;
      }
    }
  });
  await test('Refueling follows source remainder reconstruction, caps at255 and never changes a cancelled quote',()=>{
    equal([0,1,14,15,16,30,31,239,240,254].map(n=>depotRefuelResult(n,1)),[16,17,30,47,32,46,63,255,255,255]);
    for(let fuel=0;fuel<=255;fuel++) {
      equal(depotRefuelResult(fuel,0),fuel);
      const maximum=16-Math.trunc((fuel+1)/16);
      if(maximum)equal(depotRefuelResult(fuel,maximum),255);
      reject(()=>depotRefuelResult(fuel,maximum+1),'invalidDepot');
      const state={...fresh(),fuel},before=JSON.stringify(state);
      if(maximum)quoteDepotService(state,visit,'refuel',maximum);
      equal(JSON.stringify(state),before);
    }
    reject(()=>quoteDepotService({...fresh(),fuel:255},visit,'refuel'),'depotCapacity');
  });
  await test('Depot payments use the local account first, spill into cash and allow exact funds',()=>{
    const state=fresh(),before=JSON.stringify(state),quote=quoteDepotService(state,visit,'refuel',16);
    equal(quote.price,2512);equal(quote.unitPrice,157);
    const filled=purchaseDepotService(state,visit,{type:'refuel',units:16});
    equal(filled.fuel,255);equal(filled.cash,153);equal(filled.bankBalance,26962);equal(filled.hull,13);
    const exact={...state,cash:57,bankBalance:100},paid=purchaseDepotService(exact,visit,{type:'refuel'});
    equal([paid.cash,paid.bankBalance,paid.fuel],[0,0,16]);equal(JSON.stringify(state),before);
    const poor={...exact,cash:56},snapshot=JSON.stringify(poor);
    reject(()=>purchaseDepotService(poor,visit,{type:'refuel'}),'depotInsufficient');equal(JSON.stringify(poor),snapshot);
  });
  await test('Hull repair charges the opening quote per point and leaves fuel and cargo unchanged',()=>{
    const state=fresh();state.hull=8;
    const q=quoteDepotService(state,visit,'repair',8);equal([q.unitPrice,q.price,q.hull],[436,3488,16]);
    const repaired=purchaseDepotService(state,visit,{type:'repair',units:8});
    equal(repaired.hull,16);equal(repaired.fuel,state.fuel);equal(repaired.pod,state.pod);
    equal(state.cash+state.bankBalance-repaired.cash-repaired.bankBalance,3488);
    reject(()=>purchaseDepotService(repaired,visit,{type:'repair'}),'depotCapacity');
    equal(state.hull,8);
  });
  await test('Auxiliary fuel fills only empty pod slots and records the source world field, not a city',()=>{
    const state=fresh(),local={...visit,cityId:'city-23',worldId:'world-09'};
    state.pod[0]={commodityId:'cargo-12',quality:3,originCity:'city-01',pricePaid:900};
    const before=JSON.stringify(state),loaded=purchaseDepotService(state,local,{type:'auxiliary'});
    equal(loaded.pod[0],state.pod[0]);equal(loaded.pod[1],{commodityId:'cargo-01',quality:7,originWorld:'world-09',pricePaid:0});
    equal(loaded.bankBalance,state.bankBalance-2200);equal([loaded.hull,loaded.fuel],[13,0]);equal(JSON.stringify(state),before);
    reject(()=>purchaseDepotService(loaded,local,{type:'auxiliary'}),'depotCapacity');
    const both=purchaseDepotService(fresh(),local,{type:'auxiliary',units:2});
    equal(both.bankBalance,fresh().bankBalance-4400);equal(both.pod[0],both.pod[1]);
    both.pod[0].quality=1;equal(both.pod[1].quality,7);equal(loaded.pod[1].quality,7);
  });
  await test('Vehicle presence, capacity and malformed service inputs reject without partial writes',()=>{
    const state=fresh(),before=JSON.stringify(state);
    for(const type of ['refuel','repair'])reject(()=>purchaseDepotService(state,{...visit,shipPresent:false},{type}),'depotVehicleAbsent');
    reject(()=>purchaseDepotService(state,{...visit,podPresent:false},{type:'auxiliary'}),'depotVehicleAbsent');
    for(const units of [0,-1,0.5,17,NaN])reject(()=>purchaseDepotService(state,visit,{type:'refuel',units}),'depotCapacity');
    reject(()=>purchaseDepotService(state,visit,{type:'unknown'}),'invalidDepot');
    reject(()=>purchaseDepotService({...state,fuel:256},visit,{type:'refuel'}),'invalidDepot');
    reject(()=>purchaseDepotService({...state,pod:[null]},visit,{type:'repair'}),'invalidDepot');
    reject(()=>purchaseDepotService(state,{...visit,worldId:'world-99'},{type:'repair'}),'invalidDepot');
    equal(JSON.stringify(state),before);
    const full={...state,pod:[{commodityId:'cargo-31',quality:7,originCity:'city-01',pricePaid:0},null]};
    reject(()=>purchaseDepotService(full,visit,{type:'auxiliary',units:2}),'depotCapacity');
    equal(full.pod[1],null);
  });
}
