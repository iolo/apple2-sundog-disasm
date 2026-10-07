import { createInitialEquipment } from '../js/core/initialization.js';
import { recalculateEquipment } from '../js/core/equipment.js';
import { createEquipmentFailureState } from '../js/core/equipment-failures.js';
import { produceShipEncounter, stepShipCombat, fireShipGun, jettisonShipCargo,
  prepareShipCommunication, resumeShipCommunication, stepShipCommunication } from '../js/core/ship-combat.js';

const lot=(id=2)=>({commodityId:`cargo-${String(id).padStart(2,'0')}`,quality:7,originCity:'city-01',pricePaid:0});
const fresh=(seed=29)=>({flags:Array(128).fill(false),
  words:{205:512,206:512,207:0,208:0,209:0,214:1,215:20,216:200,217:20,
    222:100,224:192,225:0,226:100,347:0,354:0},
  rangeMemory:127,hull:16,sceneHigh:2,shipWorld:false,
  equipment:createInitialEquipment({next:()=>1}).map(recalculateEquipment).map(createEquipmentFailureState),
  cargo:[lot(),null],randomState:seed});

// Independent little-endian byte/carry oracle. This does not import or call
// the production integer-shift RNG; vectors below also retain literal values.
function byteStream(seed,count) {
  const bytes=[seed%256,Math.floor(seed/256)%256,Math.floor(seed/65536)%256,Math.floor(seed/16777216)];
  const rolls=[];
  for(let n=0;n<count;n++) {
    for(let shift=0;shift<7;shift++) {
      let carry=(Math.floor(bytes[0]/64)%2+Math.floor(bytes[3]/64)%2)%2;
      for(let i=0;i<4;i++) {const next=Math.floor(bytes[i]/128);bytes[i]=(bytes[i]*2+carry)%256;carry=next}
    }
    rolls.push(Math.floor(bytes[0]/2)*256+bytes[2]);
  }
  return {rolls,state:bytes.reduce((sum,b,i)=>sum+b*256**i,0)};
}

export async function shipCombatTests(test,equal) {
  const verifyStream=(seed,result)=>equal(result.state.randomState,byteStream(seed,result.draws).state);
  await test('Source Comm prepares kind19, resets only48–50 and rejects missing or repeated contacts',()=>{
    const s=fresh();s.flags[40]=s.flags[48]=s.flags[49]=s.flags[50]=s.flags[51]=true;
    const before=JSON.stringify(s),r=prepareShipCommunication(s);
    equal([r.kind,r.sceneMiddle,r.workspace],[19,1,{item:0,mood:0,quantity:2}]);
    equal([35,44,48,49,50,51].map(n=>r.state.flags[n]),[true,true,false,false,false,true]);
    equal(r.state.randomState,s.randomState);equal(r.state.cargo,s.cargo);equal(JSON.stringify(s),before);
    for(const flag of [40,47]) {
      const next=structuredClone(s);next.flags[flag]=flag===47;
      let error;try{prepareShipCommunication(next)}catch(e){error=e.message}equal(error,'shipCommunicationUnavailable');
    }
  });
  await test('Source Comm return prioritizes retreat, clears handshake and closes repeat communication',()=>{
    const s=fresh();s.flags[40]=true;const prepared=prepareShipCommunication(s).state;
    const flags=[...prepared.flags];flags[49]=flags[51]=true;
    const r=resumeShipCommunication(prepared,flags,12345);
    equal([r.state.words[215],r.state.words[207]],[128,2]);equal(r.communication,{pending:false,ticks:0});
    equal([35,41,44,47,49,51].map(n=>r.state.flags[n]),[false,false,false,true,false,true]);
    equal(r.state.randomState,12345);equal(r.state.cargo,s.cargo);
    let error;try{resumeShipCommunication(r.state,r.state.flags,12345)}catch(e){error=e.message}
    equal(error,'shipCommunicationUnavailable');
  });
  await test('Accepted cargo demand grants six source ticks and resumes aggression on the seventh',()=>{
    const s=fresh();s.flags[40]=true;const prepared=prepareShipCommunication(s).state;
    const flags=[...prepared.flags];flags[51]=true;
    let r=resumeShipCommunication(prepared,flags,12345);
    equal(r.communication,{pending:true,ticks:6});equal(r.state.flags[44],false);equal(r.state.flags[51],false);
    for(let tick=1;tick<=6;tick++) {
      r=stepShipCommunication(r.state,JSON.parse(JSON.stringify(r.communication)));
      equal(r.communication,{pending:true,ticks:6-tick});equal(r.state.flags[44],false);
      equal(r.state.randomState,12345);equal(r.state.cargo,s.cargo);
    }
    r=stepShipCommunication(r.state,r.communication);equal(r.communication,{pending:false,ticks:0});equal(r.state.flags[44],true);
    equal(stepShipCommunication(r.state,r.communication),r);
    const hostile=resumeShipCommunication(prepared,prepared.flags,12345);
    equal(hostile.communication,{pending:false,ticks:0});equal(hostile.state.flags[44],true);
    let error;try{stepShipCommunication(r.state,{pending:false,ticks:1})}catch(e){error=e.message}
    equal(error,'invalidShipCommunication');
  });
  await test('Arrival encounter reproduces the seven-draw source vector, including cryogen cargo',()=>{
    for(const id of [2,30,31]) {
      const s=fresh(2536397490),before=JSON.stringify(s);s.cargo=[lot(id),null];
      const result=produceShipEncounter(s,{cityPresent:false,system:{piracy:12,cooldown:1}});
      equal(result.produced,true);equal(result.draws,7);equal(result.state.randomState,1314226212);
      equal([214,215,216,217,206,205,207,208,209].map(n=>result.state.words[n]),[0,40,179,127,841,156,-1,0,0]);
      equal([40,41,44,45,46,47].map(n=>result.state.flags[n]),[true,true,true,false,false,false]);
      equal(result.state.rangeMemory,127);verifyStream(s.randomState,result);
      // Reading and producing the encounter cannot take ownership of cargo.
      equal(result.state.cargo,s.cargo);equal(s.words[216],200);
      if(id===2)equal(JSON.stringify(s),before);
    }
  });
  await test('Encounter gate preserves eager RNG ordering, piracy equality and packed cooldown decrement',()=>{
    const seed=2536397490;
    for(const flag of [40,12,36]) {const s=fresh(seed);s.flags[flag]=true;const r=produceShipEncounter(s,{cityPresent:false,system:{piracy:15,cooldown:0}});equal([r.produced,r.draws,r.state.randomState],[false,0,seed])}
    const cases=[
      {cityPresent:true,piracy:15,cooldown:0,cargo:[lot(),null],draws:1,next:0},
      {cityPresent:false,piracy:15,cooldown:0,cargo:[null,null],draws:1,next:0},
      {cityPresent:false,piracy:11,cooldown:0,cargo:[lot(),null],draws:2,next:0},
      {cityPresent:false,piracy:12,cooldown:2,cargo:[lot(),null],draws:3,next:1},
      {cityPresent:false,piracy:15,cooldown:0,cargo:[{commodityId:'cargo-01',quality:7,originWorld:'world-01',pricePaid:0},null],draws:1,next:0},
    ];
    for(const c of cases) {const s=fresh(seed);s.cargo=c.cargo;const r=produceShipEncounter(s,{cityPresent:c.cityPresent,system:{piracy:c.piracy,cooldown:c.cooldown}});equal([r.produced,r.draws,r.system.cooldown],[false,c.draws,c.next]);verifyStream(seed,r)}
  });
  await test('Contact motion wraps coordinates, clamps range and pauses movement while aiming',()=>{
    const s=fresh();s.words[206]=1020;s.words[205]=3;s.words[209]=2;s.words[208]=-1;s.words[207]=-4;s.words[217]=10;
    const r=stepShipCombat(s);equal([206,205,217,215].map(n=>r.state.words[n]),[12,1019,5,16]);equal(r.draws,0);
    s.sceneHigh=1;const aimed=stepShipCombat(s);equal(aimed.state,s);equal(aimed.draws,0);
    s.words[217]=129;s.flags[40]=true;equal(stepShipCombat(s).state.flags[40],false);
    s.words[217]=128;equal(stepShipCombat(s).state.flags[40],true);
    s.words[216]=0;equal(stepShipCombat(s).state.flags[40],false);
  });
  await test('Movement cooldown and paused aim still resolve pending shots through the source jump table',()=>{
    for(const sceneHigh of [1,2]) {
      const s=fresh();s.sceneHigh=sceneHigh;s.flags[40]=s.flags[44]=s.flags[45]=true;
      const r=stepShipCombat(s);equal(r.draws,5);equal(r.state.randomState,3550957389);
      equal(r.hit,{kind:'hull',damage:2});equal(r.state.hull,14);equal(r.state.flags[45],false);equal(r.state.flags[43],true);
      equal(r.state.words[215],sceneHigh===1?20:16);verifyStream(s.randomState,r);
    }
  });
  await test('Enemy shot tests use strict range comparison and raw RNG bit0 with two eager draws',()=>{
    for(const seed of [2573,1]) {
      const s=fresh(seed);s.flags[45]=true;const r=stepShipCombat(s);
      equal([r.draws,r.hit,r.state.hull,r.state.flags[43]],[2,null,16,true]);verifyStream(seed,r);
    }
    const s=fresh();s.flags[44]=true;const armed=stepShipCombat(s);
    equal([armed.draws,armed.state.flags[45],armed.hit],[2,true,null]);
    s.flags[12]=true;equal(stepShipCombat(s).draws,0);
  });
  await test('Source drift, tactical range decisions and type0 shifts use the documented fixed vector',()=>{
    const s=fresh(28);s.words[215]=0;s.words[214]=0;s.words[225]=255;s.flags[45]=true;
    const r=stepShipCombat(s);equal([209,208,207,215,225].map(n=>r.state.words[n]),[2,-1,2,4,153]);
    equal([r.draws,r.state.rangeMemory,r.state.randomState],[8,83,4219989535]);equal(r.hit,{kind:'shield',damage:102});
    equal(r.state.words[216],200);verifyStream(28,r);
  });
  await test('Retreat consumes the eager cloak draw and still resolves an already pending shot',()=>{
    for(const reason of ['health','world','cloak','flag']) {
      const s=fresh();s.words[215]=0;s.flags[45]=true;
      if(reason==='health')s.words[216]=1;if(reason==='world')s.shipWorld=true;
      if(reason==='cloak')s.flags[12]=true;if(reason==='flag')s.flags[29]=true;
      const r=stepShipCombat(s);equal([r.state.words[207],r.state.words[215],r.draws,r.state.hull],[2,130,9,15]);
      equal(r.state.flags[44],false);equal(r.state.flags[29],false);equal(r.state.flags[46],reason==='cloak');verifyStream(s.randomState,r);
    }
  });
  await test('Signed16 enemy strength overflow and repeated hull penetration preserve the source loop',()=>{
    for(const type of [2,3]) {
      const s=fresh();s.words[214]=type;s.flags[45]=true;
      const r=stepShipCombat(s);equal(r.draws,11);equal(r.hits,[{kind:'hull',damage:2},{kind:'hull',damage:1},{kind:'hull',damage:1},{kind:'hull',damage:2}]);
      equal([r.state.hull,r.state.words[347]],[10,0]);verifyStream(s.randomState,r);
      s.hull=1;const fatal=stepShipCombat(s);equal([fatal.state.hull,fatal.state.words[347],fatal.state.sceneHigh,fatal.draws],[0,1,12,5]);
    }
  });
  await test('A zero-output hit retains its original native pointer and causes defeat without rewriting hull',()=>{
    const s=fresh(4);s.flags[45]=true;s.equipment[1].group.performance=0;
    const r=stepShipCombat(s);equal(r.hit,{kind:'hull',damage:0,redirectedFrom:1});
    equal([r.state.hull,r.state.words[347],r.state.sceneHigh,r.draws],[16,1,12,5]);verifyStream(4,r);
  });
  await test('Component selection uses the source five-byte stride, immediate failure and dependency flags',()=>{
    const s=fresh(4);s.flags[45]=true;const r=stepShipCombat(s);
    equal(r.hit,{kind:'component',group:1,offset:6});equal(r.draws,6);equal(r.state.randomState,1082204676);
    equal(r.state.equipment[1].pendingFailure,6);equal(r.state.equipment[1].group.performance,12);
    equal(r.state.equipment[1].group.units[1].components,[31,156,30,24]);
    equal(s.equipment[1].group.units[1].components,[31,28,30,24]);verifyStream(4,r);
    // The source skips dependency recalculation for a selected destroyed byte.
    s.equipment[1].group.units[1].components[1]=7;s.flags[16]=true;
    equal(stepShipCombat(s).state.flags[16],true);
  });
  await test('Selected shunts advance20 additional draws including performance bytes and keep stream ownership',()=>{
    const s=fresh(4);s.flags[45]=true;
    s.equipment[1].group.units[1].components[1]=23;
    s.equipment[1].group=recalculateEquipment(s.equipment[1].group);
    const r=stepShipCombat(s);equal(r.draws,26);verifyStream(4,r);
    equal(r.state.equipment[1].group.units[1].components[1],151);equal(r.state.equipment[1].pendingFailure,6);
  });
  await test('Laser and cannon use source dexterity, range denominators, charge and hit-cycle updates',()=>{
    const s=fresh();s.flags[40]=true;s.words[206]=514;s.words[226]=9;s.words[217]=32;s.rangeMemory=31;
    const laser=fireShipGun(s,{focused:true,dexterity:45});
    equal([laser.hit,laser.damage,laser.state.words[216],laser.state.words[226],laser.state.words[354],laser.state.rangeMemory],[true,5,195,0,1,79]);
    const cannon=fireShipGun(s,{focused:false,dexterity:45});equal([cannon.hit,cannon.damage,cannon.state.words[216]],[true,2,198]);
    s.flags[18]=true;equal(fireShipGun(s,{focused:true,dexterity:45}).damage,10);
    s.flags[18]=false;s.words[206]=512;s.words[226]=255;const destroyed=fireShipGun(s,{focused:true,dexterity:45});
    equal([destroyed.damage,destroyed.state.words[216],destroyed.state.flags[40],destroyed.cooldownIncrement],[4096,0,true,1]);
    equal(destroyed.state.flags.slice(41,48),Array(7).fill(false));equal(stepShipCombat(destroyed.state).state.flags[40],false);
    equal(s.words[226],255);
  });
  await test('Misses consume charge; only a strict near miss resets cooldown and unavailable guns reject atomically',()=>{
    const s=fresh();s.flags[40]=true;s.words[206]=518;s.words[217]=32;
    const near=fireShipGun(s,{focused:true,dexterity:45});equal([near.hit,near.state.words[215],near.state.words[226]],[false,0,0]);
    s.words[206]=532;const far=fireShipGun(s,{focused:true,dexterity:45});equal([far.hit,far.state.words[215]],[false,20]);
    s.flags[40]=false;equal(fireShipGun(s,{focused:true,dexterity:45}).state.rangeMemory,127);
    for(const what of ['charge','performance']) {
      const v=fresh();if(what==='charge')v.words[226]=0;else v.equipment[2].group.performance=0;
      const before=JSON.stringify(v);let error;try{fireShipGun(v,{focused:true,dexterity:45})}catch(e){error=e.message}
      equal(error,'shipGunUnavailable');equal(JSON.stringify(v),before);
    }
  });
  await test('Jettison handles both slots in reverse order and draws even for empty or auxiliary selections',()=>{
    const s=fresh(28);s.cargo=[lot(2),lot(3)];s.flags[44]=true;
    const r=jettisonShipCargo(s,3);equal(r.jettisoned.map(l=>[l.slot,l.lot.commodityId]),[[1,'cargo-03'],[0,'cargo-02']]);
    equal([r.state.cargo,r.draws,r.state.randomState,r.resetSystemCooldown],[[null,null],2,462364,true]);
    equal([r.state.words[215],r.state.words[207],r.state.flags[44],r.state.flags[46],r.state.flags[47]],[128,1,false,true,true]);
    equal(s.cargo,[lot(2),lot(3)]);
    for(const cargo of [[null,null],[{commodityId:'cargo-01',quality:7,originWorld:'world-01',pricePaid:0},null]]) {
      const v=fresh(28);v.cargo=cargo;const empty=jettisonShipCargo(v,1);
      equal([empty.draws,empty.resetSystemCooldown,empty.state.words[215]],[1,false,20]);verifyStream(28,empty);
    }
    const v=fresh(28);v.cargo=[lot(31),null];equal(jettisonShipCargo(v,1).resetSystemCooldown,true);
    v.cargo=[lot(2),lot(3)];equal(jettisonShipCargo(v,1).resetSystemCooldown,false);
  });
  await test('Malformed combat inputs reject without mutating caller-owned state',()=>{
    const changes=[s=>s.flags.pop(),s=>delete s.flags[1],s=>s.words[214]=4,s=>s.words[215]=32768,
      s=>s.words[206]=-1,s=>s.hull=17,s=>s.rangeMemory=256,s=>s.words[225]=-1,
      s=>s.randomState=-1,s=>delete s.equipment[0],s=>delete s.equipment[0].group.units[0].components[0],s=>s.cargo=[null]];
    for(const change of changes) {const s=fresh();change(s);const before=JSON.stringify(s);let error;
      try{stepShipCombat(s)}catch(e){error=e.message}equal(!!error,true);equal(JSON.stringify(s),before)}
    for(const selection of [0,4,-1,null]) {const s=fresh(),before=JSON.stringify(s);let error;try{jettisonShipCargo(s,selection)}catch(e){error=e.message}equal(error,'invalidShipCombat');equal(JSON.stringify(s),before)}
  });
}
