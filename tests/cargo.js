import { CARGO_CAPACITY, validateCargoLot, validateCargoSlots, initialPodCargo,
  warehouseCargoSnapshot, reduceWarehouseCargo } from '../js/core/cargo.js';

export async function cargoTests(test,equal) {
  const lot=(n=2,originCity='city-01')=>({commodityId:`cargo-${String(n).padStart(2,'0')}`,quality:7,originCity,pricePaid:n===31 ? 0 : n*100});
  const visit={cityId:'city-01',transport:'pod'};
  const state=()=>({warehouse:{cityId:'city-01',slots:[lot(31),null,lot(2,'city-57'),null]},pod:[lot(3),null]});
  const run=(s,a,v=visit)=>reduceWarehouseCargo(s,v,a);
  const rejects=(fn,want)=>{let error;try{fn()}catch(e){error=e.message}equal(error,want)};
  const manifest=s=>[...s.warehouse.slots,...s.pod].filter(Boolean).map(l=>JSON.stringify(l)).sort();

  await test('Cargo ownership has four warehouse slots and two shared pod/ship slots, with independent snapshots',()=>{
    equal(CARGO_CAPACITY,{warehouse:4,pod:2});equal(initialPodCargo(),[null,null]);
    const a=initialPodCargo(),b=initialPodCargo();a[0]=lot();equal(b,[null,null]);
    const original=state(),before=JSON.stringify(original),owned=warehouseCargoSnapshot(original);
    equal(owned,original);owned.pod[0].quality=1;owned.warehouse.slots[0].originCity='city-02';equal(JSON.stringify(original),before);
    const reversed=JSON.parse(JSON.stringify(original),(key,value)=>value&&typeof value==='object'&&!Array.isArray(value) ? Object.fromEntries(Object.entries(value).reverse()) : value);
    equal(warehouseCargoSnapshot(reversed),original);
  });
  await test('Store and Fetch use the first empty destination and preserve full lots, including cryogens',()=>{
    const original=state(),before=JSON.stringify(original),stored=run(original,{type:'store',slot:0});
    equal(stored.warehouse.slots,[lot(31),lot(3),lot(2,'city-57'),null]);equal(stored.pod,[null,null]);
    const fetched=run(stored,{type:'fetch',slot:0});
    equal(fetched.warehouse.slots,[null,lot(3),lot(2,'city-57'),null]);equal(fetched.pod,[lot(31),null]);
    const second=run(fetched,{type:'fetch',slot:2});equal(second.pod,[lot(31),lot(2,'city-57')]);
    equal(manifest(second),manifest(original));equal(JSON.stringify(original),before);
    second.pod[1].pricePaid=900;equal(original.warehouse.slots[2].pricePaid,200);
  });
  await test('Swap exchanges two occupied lots even at full capacity and is reversible without repricing',()=>{
    const full={warehouse:{cityId:'city-01',slots:[lot(31),lot(4),lot(5),lot(6)]},pod:[lot(2,'city-57'),lot(3,'city-02')]};
    const before=JSON.stringify(full),action={type:'swap',podSlot:1,warehouseSlot:0},swapped=run(full,action);
    equal(swapped.pod,[lot(2,'city-57'),lot(31)]);equal(swapped.warehouse.slots,[lot(3,'city-02'),lot(4),lot(5),lot(6)]);
    equal(run(swapped,action),full);equal(manifest(swapped),manifest(full));equal(JSON.stringify(full),before);
  });
  await test('Full destinations and empty, invalid or ambiguous cargo selections reject atomically',()=>{
    const full={warehouse:{cityId:'city-01',slots:[lot(31),lot(4),lot(5),lot(6)]},pod:[lot(2),lot(3)]},before=JSON.stringify(full);
    rejects(()=>run(full,{type:'store',slot:0}),'cargoWarehouseFull');rejects(()=>run(full,{type:'fetch',slot:0}),'cargoPodFull');
    equal(JSON.stringify(full),before);
    for(const action of [{type:'store',slot:1},{type:'fetch',slot:1},{type:'swap',podSlot:0,warehouseSlot:1},
      {type:'swap',podSlot:1,warehouseSlot:0},{type:'store',slot:2},{type:'fetch',slot:4},{type:'fetch',slot:-1},
      {type:'store',slot:0.5},{type:'fetch',slot:'0'},{type:'swap',podSlot:0,warehouseSlot:0,price:0},
      {type:'store',slot:0,to:2},{type:'sell',slot:0},null]) {
      const s=state(),saved=JSON.stringify(s);rejects(()=>run(s,action),'cargoInvalidSelection');equal(JSON.stringify(s),saved);
    }
  });
  await test('Warehouse loading requires a matching pod visit and never permits foot or remote access',()=>{
    for(const v of [null,{}, {cityId:'city-01',transport:'foot'},{cityId:'city-02',transport:'pod'},
      {cityId:'city-01',transport:'ship'},{cityId:'city-01',transport:'pod',remote:true}]) {
      const s=state(),before=JSON.stringify(s);rejects(()=>run(s,{type:'fetch',slot:0},v),'cargoUnavailable');equal(JSON.stringify(s),before);
    }
  });
  await test('Cargo validation rejects unsupported records, sparse containers and malformed encoded fields',()=>{
    for(const bad of [null,{}, {...lot(),extra:1}, {...lot(),commodityId:'cargo-01'}, {...lot(),commodityId:'cargo-00'},
      {...lot(),commodityId:'cargo-32'}, {...lot(),quality:0},{...lot(),quality:8},{...lot(),quality:1.5},
      {...lot(),originCity:'city-58'},{...lot(),originCity:'city-60'},{...lot(),originCity:'city-00'},
      {...lot(),pricePaid:101},{...lot(),pricePaid:-100},{...lot(),pricePaid:3276800},{...lot(),pricePaid:'100'},
      {...lot(31),pricePaid:100},{...lot(31),quality:6}])rejects(()=>validateCargoLot(bad),'invalidCargo');
    equal(validateCargoLot({...lot(),pricePaid:3276700}),{...lot(),pricePaid:3276700});
    for(const slots of [[],[null],Array(2),[undefined,null],{0:null,1:null,length:2},[null,null,null]])
      rejects(()=>validateCargoSlots(slots,'pod'),'invalidCargo');
    const sparse=Array(2);sparse[0]=null;sparse.extra=null;rejects(()=>validateCargoSlots(sparse,'pod'),'invalidCargo');
    rejects(()=>validateCargoSlots([null,null],'ship'),'invalidCargo');
    for(const change of [s=>s.ship=[],s=>s.warehouse.cityId='city-58',s=>s.warehouse.extra=0,s=>s.pod.push(null)]) {
      const s=state();change(s);rejects(()=>warehouseCargoSnapshot(s),'invalidCargo');
    }
  });
  await test('Every pod/warehouse occupancy pattern conserves lots across all successful loading operations',()=>{
    let successes=0;
    for(let mask=0;mask<64;mask++) {
      const slots=Array.from({length:6},(_,i)=>(mask>>i)&1 ? lot(i===0 ? 31 : i+2) : null);
      const s={warehouse:{cityId:'city-01',slots:slots.slice(0,4)},pod:slots.slice(4)},before=JSON.stringify(s),expected=manifest(s);
      const actions=[...Array.from({length:2},(_,slot)=>({type:'store',slot})),...Array.from({length:4},(_,slot)=>({type:'fetch',slot})),
        ...Array.from({length:8},(_,i)=>({type:'swap',podSlot:i>>2,warehouseSlot:i%4}))];
      for(const action of actions) {
        const source=action.type==='store' ? s.pod[action.slot] : action.type==='fetch' ? s.warehouse.slots[action.slot] : s.pod[action.podSlot]&&s.warehouse.slots[action.warehouseSlot];
        const space=action.type==='swap'||(action.type==='store' ? s.warehouse.slots : s.pod).includes(null);
        if(source&&space) {
          const next=run(s,action);equal(manifest(next),expected);equal(warehouseCargoSnapshot(next),next);
          equal(JSON.stringify(next)!==before,true);successes++;
        } else rejects(()=>run(s,action),!source ? 'cargoInvalidSelection' : action.type==='store' ? 'cargoWarehouseFull' : 'cargoPodFull');
        equal(JSON.stringify(s),before);
      }
    }
    equal(successes,284);
  });
}
