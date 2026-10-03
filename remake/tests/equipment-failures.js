import { createInitialEquipment } from '../js/core/initialization.js';
import { recalculateEquipment } from '../js/core/equipment.js';
import { createEquipmentFailureState, installEquipmentComponent, enterEquipmentFrame, resolveEquipmentFailures, hitEquipmentComponent, equipmentDependencyResult } from '../js/core/equipment-failures.js';
import { dialogueEffects } from '../js/core/dialogue-effects.js';

export async function equipmentFailureTests(test,equal) {
  const groups=()=>createInitialEquipment({next:()=>1}).map(recalculateEquipment);
  const fresh=(i=0)=>createEquipmentFailureState(groups()[i]);
  const reject=fn=>{let code;try{fn()}catch(e){code=e.message}equal(code,'invalidEquipmentFailure')};
  await test('Encoded installation computes transient output before the next engineering update destroys the part',()=>{
    const empty=installEquipmentComponent(fresh(),1,0),before=JSON.stringify(empty);
    equal(empty.group.performance,12);
    const installed=installEquipmentComponent(empty,1,156); //128 + warp socket1 type28.
    equal(installed.pendingFailure,1);equal(installed.group.units[0].components,[31,156,26,30]);
    equal(installed.group.units[0].performance,4);equal(installed.group.performance,16);
    const result=resolveEquipmentFailures(installed);
    equal(result.destroyed,[1]);equal(result.state.pendingFailure,31);
    equal(result.state.group.units[0].components,[31,7,26,30]);equal(result.state.group.performance,12);
    equal(resolveEquipmentFailures(result.state),{state:result.state,destroyed:[]});
    equal(JSON.stringify(empty),before);equal(installed.group.units[0].components[1],156);
    const repaired=installEquipmentComponent(result.state,1,28);equal(repaired.group.performance,16);
    const shunted=installEquipmentComponent(result.state,1,23);equal(shunted.group.performance,15);
  });
  await test('Component installation masks low type bits and follows standard, shunt and special socket fit',()=>{
    for(let i=0;i<6;i++)for(let unit=0;unit<4;unit++)for(let socket=0;socket<4;socket++) {
      const s=fresh(i),offset=unit*5+socket,type=s.group.spares[socket];
      const plain=installEquipmentComponent(s,offset,type+32);equal(plain.group.units[unit].components[socket],type);equal(plain.pendingFailure,31);
      const encoded=installEquipmentComponent(s,offset,type+128);equal(encoded.pendingFailure,offset);
      equal(resolveEquipmentFailures(encoded).state.group.units[unit].components[socket],7);
      if(socket>0)equal(installEquipmentComponent(s,offset,151).group.units[unit].performance,3);
      else reject(()=>installEquipmentComponent(s,offset,151));
    }
    const s=fresh(2),special=installEquipmentComponent(s,2,147); // Faulty enhanced guns part19.
    equal(special.group.specialAvailable,true);equal(special.group.performance,16);
    equal(resolveEquipmentFailures(special).state.group.specialAvailable,false);
    for(const [offset,byte] of [[4,28],[19,31],[-1,31],[20,31],[0,7],[0,256],[0,1],[1,25]])reject(()=>installEquipmentComponent(s,offset,byte));
  });
  await test('Failure sweep processes the marked slot first then other encoded components in reverse order',()=>{
    let s=installEquipmentComponent(fresh(),18,158);
    s=installEquipmentComponent(s,1,156);s=installEquipmentComponent(s,7,154);
    const before=JSON.stringify(s),result=resolveEquipmentFailures(s);
    equal(result.destroyed,[7,18,1]);equal(result.state.group.performance,4);equal(JSON.stringify(s),before);
    // Native offset25 is a target, not a timer: overwriting it does not clear it.
    const overwritten=installEquipmentComponent(s,7,26);
    equal(resolveEquipmentFailures(overwritten).state.group.units[1].components[2],7);
  });
  await test('Frame entry applies the strict144 boundary and preserves the original cache ordering',()=>{
    const s=fresh();s.group.units[0].components=[144,145,156,143];s.pendingFailure=1;
    const next=enterEquipmentFrame(s);
    equal(next.group.units[0].components,[144,7,7,143]);equal(next.pendingFailure,31);
    equal(next.group.performance,16);equal(next.group.units[0].performance,4);
    equal(resolveEquipmentFailures(next),{state:next,destroyed:[]});equal(s.pendingFailure,1);
  });
  await test('Selected component hits mark immediate failed output; shunt propagation uses20 eager source draws',()=>{
    const hit=hitEquipmentComponent(fresh(),1,12345);
    equal(hit.draws,0);equal(hit.randomState,12345);equal(hit.state.group.performance,12);
    equal(hit.state.group.units[0].components[1],156);equal(hit.state.pendingFailure,1);
    const s=fresh();for(const u of s.group.units)u.components=[31,23,23,23];s.group=recalculateEquipment(s.group);
    const spread=hitEquipmentComponent(s,1,12345);
    equal(spread.draws,20);
    // Fixed vectors independently obtained from the documented seven-shift RNG.
    equal(spread.randomState,2553372812);
    equal(spread.state.group.units.map(u=>u.components),[[31,151,23,23],[31,151,23,151],[31,23,151,23],[31,151,23,23]]);
    equal(resolveEquipmentFailures(spread.state).state.group.units.every(u=>u.components.every(b=>b<128)),true);
    for(const byte of [0,7,156]) {const v=fresh();v.group.units[0].components[1]=byte;equal(hitEquipmentComponent(v,1,12345).state,v)}
  });
  await test('Zero output clears only source-dependent power/target flags; losing a special clears its control',()=>{
    const g=groups(),previous={flags:Array(128).fill(true),words:{222:160,223:100,224:192,225:80,226:90,227:255}};
    const before=JSON.stringify(previous);
    for(let i=0;i<6;i++) {
      const e=structuredClone(g);e.forEach(group=>group.specialAvailable=true);e[i].performance=0;e[i].specialAvailable=false;
      const next=equipmentDependencyResult(e,previous);
      for(let j=0;j<6;j++){equal(next.flags[j],j!==i);equal(next.flags[8+j],j!==i);equal(next.flags[16+j],j!==i)}
      for(const [group,word] of [[0,222],[2,226],[4,224]])equal(next.words[word],group===i?0:previous.words[word]);
      equal([next.words[223],next.words[225],next.words[227]],[100,80,255]);
    }
    const ordinary=equipmentDependencyResult(g,previous);equal(ordinary.flags.slice(0,6),Array(6).fill(true));equal(ordinary.flags.slice(8,14),Array(6).fill(false));
    equal(JSON.stringify(previous),before);
  });
  await test('Existing trader appraisal can produce a faulty component that the engineering failure core consumes',async()=>{
    const items=await fetch('../data/items.json').then(r=>r.json());let offered;
    for(let seed=1;seed<500&&!offered;seed++) {
      const frame={randomState:seed,state:{kind:22,attributes:[0,0,0,0,0],carried:[0,0,0,0],flags:Array(128).fill(true),workspace:{quantity:1},locals:{4:1,5:1,6:0,7:0,29:0,30:8,33:0,41:28,18:false,20:false,100:0,102:0,104:10000,106:0}}};
      dialogueEffects(frame,items.items??items).controls(32);
      if(frame.state.locals[41]===156)offered=frame;
    }
    equal(!!offered,true);
    const installed=installEquipmentComponent(fresh(),1,offered.state.locals[41]);
    equal(installed.group.performance,16);equal(resolveEquipmentFailures(installed).state.group.performance,12);
  });
}
