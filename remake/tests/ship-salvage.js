import { createInitialEquipment } from '../js/core/initialization.js';
import { recalculateEquipment } from '../js/core/equipment.js';
import { createEquipmentFailureState } from '../js/core/equipment-failures.js';
import { shipBounty,produceShipWreck,moveShipWreck,beginShipTractor,finishShipTractor,validateShipWreck } from '../js/core/ship-salvage.js';
import { prepareShipTactical,beginShipTacticalFrame,startShipTacticalTractor } from '../js/core/ship-tactical.js';
import { produceShipEncounter } from '../js/core/ship-combat.js';
import { validateCargoLot,reduceWarehouseCargo } from '../js/core/cargo.js';
import { consumeAuxiliaryFuel,refuelOnPodDock } from '../js/core/ship-power.js';
import { quoteExchangeCargo } from '../js/core/exchange.js';

const fresh=()=>({flags:Array.from({length:128},(_,i)=>[7,40].includes(i)),
  words:{205:512,206:512,207:0,208:0,209:0,214:1,215:4,216:0,217:20,
    222:0,224:0,225:0,226:0,347:0,354:0},rangeMemory:127,hull:16,sceneHigh:1,shipWorld:false,
  equipment:createInitialEquipment({next:()=>1}).map(recalculateEquipment).map(createEquipmentFailureState),
  cargo:[null,null],randomState:29});
const fuel={commodityId:'cargo-01',quality:4,originCity:null,pricePaid:0};
export async function shipSalvageTests(test,equal) {
  const reject=(f,code)=>{let message;try{f()}catch(e){message=e.message}equal(message,code)};
  await test('Bounties use the strict source threshold, right shift, minimum thousand and current-system coefficient',()=>{
    equal(shipBounty(1,{piracy:11,coefficient:15}),0);
    equal(shipBounty(0,{piracy:12,coefficient:15}),0);
    equal(shipBounty(0,{piracy:13,coefficient:0}),1000);
    equal(shipBounty(1,{piracy:12,coefficient:8}),2000);
    equal(shipBounty(1,{piracy:13,coefficient:14}),3000);
    equal(shipBounty(3,{piracy:10,coefficient:15}),7000);
    reject(()=>shipBounty(4,{piracy:15,coefficient:15}),'invalidShipSalvage');
  });
  await test('Native R10n kill RNG and packed local34 reproduce cargo25, quality6 and the exact four bytes',()=>{
    const s=fresh();s.randomState=0x18608550;const before=structuredClone(s),result=produceShipWreck(s);
    equal(result.draws,3);equal(result.state.randomState,0xaa123c59);
    equal(result.wreck,{lot:{commodityId:'cargo-25',quality:6,originCity:null,pricePaid:0},present:true,tractorSlot:null});
    equal(25+(result.wreck.lot.quality<<5),217);equal(result.state.flags[36],true);equal(result.state.words[207],1);
    equal(result.state.words[217],20);equal(s,before);
    const empty=fresh();empty.words[214]=0;empty.randomState=1;
    const missed=produceShipWreck(empty);equal([missed.draws,missed.wreck,missed.state.randomState],[1,null,129]);equal(missed.state.flags[36],false);
  });
  await test('Source wrecks include low-quality fuel, exclude cryogens, and suppress even the producer gate RNG',()=>{
    const s=fresh();s.randomState=0;s.flags[1]=true;const born=produceShipWreck(s);
    equal(born.wreck.lot,fuel);equal(born.state.words[207],2);
    born.state.flags[40]=false;const before=structuredClone(born.state);
    const inhibited=produceShipEncounter(born.state,{cityPresent:false,system:{piracy:0,cooldown:0}});
    equal(inhibited.draws,0);equal(inhibited.produced,false);equal(inhibited.state,before);
    for(const change of [v=>v.commodityId='cargo-31',v=>v.quality=3,v=>v.pricePaid=100,v=>v.originWorld='world-01']) {
      const bad=structuredClone(fuel);change(bad);reject(()=>validateCargoLot(bad,{salvage:true}),'invalidCargo');
    }
    reject(()=>validateCargoLot(fuel),'invalidCargo');
    equal(consumeAuxiliaryFuel(-3,[null,fuel],true),{fuel:252,cargo:[null,null],consumedSlot:1});
    equal(refuelOnPodDock(4,[null,fuel]),{fuel:255,cargo:[null,null],consumedSlot:1});
  });
  await test('Wreck drift runs on each actual proc12 call, keeps128, clamps below3 to1 and releases inhibition past128',()=>{
    const p=produceShipWreck(fresh()),t=prepareShipTactical(p.state,{worldAngle:16,frameLimit:5,grace:0}).tactical;
    t.wreck=p.wreck;t.contact=false;p.state.words[354]=1;
    const even=beginShipTacticalFrame(p.state,t,{x:0,y:0,fire:false},{dexterity:30,worldAngle:16});
    equal(even.called,false);equal(even.state.words[217],20);
    const odd=beginShipTacticalFrame(even.state,t,{x:0,y:0,fire:false},{dexterity:30,worldAngle:16});equal(odd.state.words[217],21);
    p.state.words[217]=127;const edge=moveShipWreck(p.state,p.wreck);equal(edge.state.words[217],128);equal(edge.wreck.present,true);
    const lost=moveShipWreck(edge.state,edge.wreck);equal(lost.wreck,null);equal(lost.state.flags[36],false);
    p.state.words[217]=5;p.state.words[207]=-4;const near=moveShipWreck(p.state,p.wreck);equal(near.state.words[217],1);
    const active=beginShipTractor(edge.state,edge.wreck);active.state.words[207]=2;
    const stalled=moveShipWreck(active.state,active.wreck);equal(stalled.wreck.present,false);equal(stalled.wreck.tractorSlot,1);
    equal(finishShipTractor(stalled.state,stalled.wreck).loaded,null);
  });
  await test('Tractor checks wreck before room, scans slot2 first, and copies the unknown lot only after reaching1',()=>{
    const p=produceShipWreck(fresh()),before=structuredClone(p),pull=beginShipTractor(p.state,p.wreck);
    equal(p,before);equal(pull.wreck.tractorSlot,1);equal(pull.state.words[207],-4);equal(pull.state.cargo,[null,null]);
    pull.state.words[217]=1;const loaded=finishShipTractor(pull.state,pull.wreck);
    equal(loaded.loaded,{slot:1,lot:p.wreck.lot});equal(loaded.state.cargo,[null,p.wreck.lot]);equal(loaded.wreck,null);equal(loaded.state.flags[36],false);
    p.state.cargo[1]=fuel;equal(beginShipTractor(p.state,p.wreck).wreck.tractorSlot,0);
    p.state.cargo[0]=fuel;const full=structuredClone(p.state);
    reject(()=>beginShipTractor(p.state,null),'shipTractorOutOfRange');reject(()=>beginShipTractor(p.state,p.wreck),'shipTractorNoRoom');equal(p.state,full);
    const noPod=fresh();noPod.flags[7]=false;equal(beginShipTractor(noPod,p.wreck).wreck.tractorSlot,1);
    const t=prepareShipTactical(noPod,{worldAngle:16,frameLimit:5,grace:0}).tactical;t.wreck=p.wreck;
    reject(()=>startShipTacticalTractor(noPod,t),'shipTacticalUnavailable');t.menu=3;
    equal(startShipTacticalTractor(noPod,t).tactical.wreck.tractorSlot,1);
    reject(()=>validateShipWreck({...p.wreck,present:false}),'invalidShipSalvage');
  });
  await test('Unknown-origin salvage loads and stores unchanged and gets the source foreign-origin sale ceiling',()=>{
    const lot={commodityId:'cargo-25',quality:6,originCity:null,pricePaid:0};
    const warehouse={cityId:'city-01',slots:[null,null,null,null]},visit={cityId:'city-01',transport:'pod'};
    const stored=reduceWarehouseCargo({warehouse,pod:[null,lot]},visit,{type:'store',slot:1},{salvage:true});
    equal(stored.warehouse.slots[0],lot);equal(stored.pod,[null,null]);
    equal(reduceWarehouseCargo(stored,visit,{type:'fetch',slot:0},{salvage:true}),{warehouse,pod:[lot,null]});
    const market={cityId:'city-01',demand:Array(31).fill(4),supply:Array(31).fill(4)},
      location={cityId:'city-01',worldId:'world-01',systemId:'system-01',capital:true,priceLevel:8,technologyLevel:8},
      context={market,location,originLocation:location,items:[{id:'cargo-25',valueByte:80},{id:'cargo-01',valueByte:0}]};
    equal(quoteExchangeCargo(lot,context,'sell'),8000);
    equal(quoteExchangeCargo({...lot,originCity:'city-01'},context,'sell'),0);
    equal(quoteExchangeCargo(fuel,context,'sell'),null);
  });
}
