import { consumeAuxiliaryFuel, refuelOnPodDock, stepShipPower } from '../js/core/ship-power.js';
import { equipmentDependencyResult } from '../js/core/equipment-failures.js';

export async function shipPowerTests(test,equal) {
  const aux=()=>({commodityId:'cargo-01',quality:7,originWorld:'world-01',pricePaid:0});
  const other=()=>({commodityId:'cargo-31',quality:7,originCity:'city-01',pricePaid:0});
  const fresh=()=>({flags:Array(128).fill(false),words:{222:0,223:0,224:0,225:0,226:0,227:100,349:0,350:0},cargo:[null,null],randomState:12345});
  const perf=[16,16,16,16,16,16];
  const step=(s,phase,p=perf,fuel=s.words[227])=>stepShipPower(s,p,phase,fuel);
  await test('Automatic auxiliary fuel adds255 after a deficit, scans first lot and cannot use a detached pod',()=>{
    for(const fuel of [255,1,0,-1,-255,-256]) {
      const cargo=[aux(),aux()],before=JSON.stringify(cargo),r=consumeAuxiliaryFuel(fuel,cargo,true);
      equal(r.fuel,fuel>0?fuel:Math.max(0,fuel+255));equal(r.consumedSlot,fuel>0?null:0);
      equal(r.cargo[1],aux());equal(JSON.stringify(cargo),before);
      equal(consumeAuxiliaryFuel(fuel,cargo,false),{fuel:Math.max(0,fuel),cargo,consumedSlot:null});
    }
    equal(consumeAuxiliaryFuel(0,[other(),aux()],true),{fuel:255,cargo:[other(),null],consumedSlot:1});
    equal(consumeAuxiliaryFuel(-3,[other(),null],true),{fuel:0,cargo:[other(),null],consumedSlot:null});
  });
  await test('Pod docking refills only below5, sets255 and preserves the second auxiliary load',()=>{
    for(const fuel of [0,1,4,5,16,255]) {
      const r=refuelOnPodDock(fuel,[aux(),aux()]);
      equal(r,{fuel:fuel<5?255:fuel,cargo:fuel<5?[null,aux()]:[aux(),aux()],consumedSlot:fuel<5?0:null});
    }
    equal(refuelOnPodDock(4,[other(),aux()]),{fuel:255,cargo:[other(),null],consumedSlot:1});
    equal(refuelOnPodDock(4,[null,other()]),{fuel:4,cargo:[null,other()],consumedSlot:null});
  });
  await test('Guns use odd machinery phases, performance-scaled gain, bounded charge and cost only when increasing',()=>{
    for(const phase of [1,2,3,4])for(const rating of [0,1,8,15,16]) {
      const s=fresh();s.flags[2]=true;const p=[...perf];p[2]=rating;
      const r=step(s,phase,p);equal(r.state.words[226],phase%2&&rating>0?Math.min(255,(rating+1)*16):0);
      equal(r.state.words[227],phase%2&&rating>0?96:100);equal(r.draws,0);equal(r.state.randomState,12345);
    }
    const full=fresh();full.flags[2]=true;full.words[226]=255;equal(step(full,1).state,full);
    for(const charged of [0,3,8,255]) {
      const off=fresh();off.words[226]=charged;
      equal(step(off,1).state.words[226],Math.max(0,charged-8));equal(step(off,1).state.words[227],100);
    }
  });
  await test('Shield phase uses target-bounded positive steps, immediate lowering and source maintenance bands',()=>{
    for(const target of [0,63,64,127,128,191,192,255]) {
      const s=fresh();s.words[224]=target;
      const r=step(s,2);equal(r.state.words[225],Math.min(128,target));equal(r.state.words[227],100-Math.floor((target+1)/64));
    }
    const lower=fresh();lower.words[225]=255;lower.words[224]=64;
    equal(step(lower,2).state.words[225],64); // Proc14 is not a gradual discharge here.
    const noOutput=fresh();noOutput.words[224]=128;const p=[...perf];p[4]=0;
    equal(step(noOutput,2,p).state.words[225],0);equal(step(noOutput,2,p).state.words[227],98);
    equal(step(lower,1).state,lower);equal(step(lower,4).state,lower);
  });
  await test('Warp draws even for failed output and spends2, bounds +8/-4, and signals only a charging arrival',()=>{
    // Independent bytewise vector: seed12345 -> bytes[185,28,24,0], state1580217;
    // result=(185>>1)*256+24=23576, low nibble8.
    for(const rating of [0,8,9,16]) {
      const s=fresh();s.words[222]=5;s.flags[0]=true;s.words[349]=1;const p=[...perf];p[0]=rating;
      const r=step(s,4,p);equal(r.draws,1);equal(r.state.randomState,1580217);
      equal(r.state.words[223],rating>8?5:0);equal(r.state.words[227],98);equal(r.state.words[350],rating>8?1:0);
    }
    const down=fresh();down.words[223]=9;down.words[222]=7;down.words[349]=1;down.flags[0]=true;
    const r=step(down,4);equal(r.state.words[223],7);equal(r.state.words[350],0);equal(r.draws,0);equal(r.state.words[227],100);
    const steady=fresh();steady.words[222]=steady.words[223]=8;equal(step(steady,4).state,steady);
  });
  await test('Power updates refuel before charge, pay deficits, then shut down specified controls on fuel exhaustion',()=>{
    const s=fresh();s.words[227]=1;s.flags.fill(true);s.cargo=[aux(),other()];
    const r=step(s,1);equal(r.state.words[227],252);equal(r.state.words[226],255);equal(r.consumedSlots,[0]);equal(r.state.cargo,[null,other()]);equal(r.state.flags,s.flags);
    const empty=structuredClone(s);empty.cargo=[null,null];empty.words[222]=64;empty.words[224]=128;
    const out=step(empty,1).state;equal(out.words[226],255);equal(out.words[227],0);equal(out.words[222],0);equal(out.words[224],0);
    for(let i=0;i<128;i++)equal(out.flags[i],![0,1,3,4,8,9,11,12].includes(i));
    const already=fresh();already.words[227]=0;already.flags[1]=true;equal(step(already,4).state.flags[1],true);
    const cloak=fresh();cloak.flags[12]=true;equal(step(cloak,3).state.words[227],88);equal(step(cloak,2).state.words[227],100);
    const detached=structuredClone(s);detached.flags[7]=false;const d=step(detached,1);equal(d.state.words[227],0);equal(d.state.cargo,s.cargo);equal(d.consumedSlots,[]);
    const moved=fresh();moved.flags[7]=true;moved.cargo=[aux(),null];equal(step(moved,2,perf,-2).state.words[227],253);
  });
  await test('Equipment dependency cleanup composes with power ticks without automatically enabling repaired systems',()=>{
    const groups=perf.map((performance,i)=>({performance,specialAvailable:i===4}));
    const s=fresh();s.flags[0]=s.flags[2]=s.flags[4]=s.flags[12]=true;s.words[222]=64;s.words[223]=60;s.words[224]=128;s.words[225]=128;s.words[226]=200;
    groups[0].performance=groups[2].performance=groups[4].performance=0;groups[4].specialAvailable=false;
    const disabled=equipmentDependencyResult(groups,s);equal([disabled.words[222],disabled.words[223],disabled.words[224],disabled.words[225],disabled.words[226]],[0,60,0,128,0]);
    const tick=step(disabled,2,groups.map(g=>g.performance)).state;equal(tick.words[225],0);equal(tick.words[227],100);
    groups.forEach(g=>g.performance=16);const repaired=equipmentDependencyResult(groups,tick);equal([repaired.flags[0],repaired.flags[2],repaired.flags[4],repaired.flags[12]],[false,false,false,false]);
  });
  await test('Power core owns state, preserves unrelated source words and rejects malformed input',()=>{
    const s=fresh();s.words[99]=321;s.flags[72]=true;const before=JSON.stringify(s),r=step(s,1);
    equal(r.state,s);r.state.words[99]=7;r.state.flags[72]=false;equal(JSON.stringify(s),before);
    for(const change of [v=>v.flags.pop(),v=>v.flags[0]=1,v=>v.words[227]=256,v=>v.words[349]=2,v=>v.randomState=-1,v=>v.cargo[0]={commodityId:'cargo-01'}]) {
      const bad=structuredClone(s);change(bad);let threw=false;try{step(bad,1)}catch{threw=true}equal(threw,true);
    }
    for(const phase of [0,5,1.5]){let threw=false;try{step(s,phase)}catch{threw=true}equal(threw,true)}
  });
}
