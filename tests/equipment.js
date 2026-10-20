import { equipmentBayAt, inspectEquipment, recalculateEquipment, fitsComponent, exchangeEquipment } from '../js/core/equipment.js';
import { canStand } from '../js/core/ship-walk.js';
import { createInitialEquipment } from '../js/core/initialization.js';

export async function equipmentTests(test, equal) {
  const geometry=await fetch('../data/ship-walk.json').then(r=>r.json());
  const points=[{x:109,y:60},{x:116,y:63},{x:109,y:67},{x:109,y:138},{x:116,y:143},{x:109,y:147}];
  await test('All six source-mapped engineering bays are reachable from the airlock',()=>{
    const seen=new Set(),queue=[geometry.spawn];
    for(let i=0;i<queue.length;i++) {
      const p=queue[i],key=`${p.x},${p.y}`;
      if(seen.has(key))continue;seen.add(key);
      for(const [dx,dy] of [[1,0],[-1,0],[0,1],[0,-1]]) {
        const q={x:p.x+dx,y:p.y+dy};
        if(canStand(geometry,q)&&!seen.has(`${q.x},${q.y}`))queue.push(q);
      }
    }
    for(const [i,p] of points.entries()) {equal(equipmentBayAt(p),i);equal(seen.has(`${p.x},${p.y}`),true)}
    equal(equipmentBayAt(geometry.spawn),null);
    equal(equipmentBayAt({x:56,y:85}),null); // Stores is not an engineering bay.
  });
  await test('Engineering frame cycling stays in its three-system bank and inspection owns its data',()=>{
    const equipment=createInitialEquipment({next:()=>1}),before=JSON.stringify(equipment);
    for(const [bay,p] of points.entries()) {
      const base=Math.floor(bay/3)*3;
      for(const offset of [-4,-1,0,1,2,3,4]) {
        const view=inspectEquipment(equipment,p,offset);
        equal(view.index,base+((bay%3+offset)%3+3)%3);
        equal(view.group,equipment[view.index]);
        view.group.units[0].components[0]=0;view.group.spares[0]=7;view.group.performance=0;
        equal(JSON.stringify(equipment),before);
      }
    }
    equal(inspectEquipment(equipment,geometry.spawn),null);
    equal(inspectEquipment(equipment,points[0],1.5),null);
  });
  const fresh=()=>createInitialEquipment({next:()=>1}).map(recalculateEquipment);
  const pockets=()=>({carried:[0,0,0,0],locker:Array(20).fill(0),stores:Array(20).fill(0)});
  const installed=(unit,socket)=>({container:'installed',unit,socket});
  const carried=index=>({container:'carried',index});
  await test('Performance handles multiple shunts, missing controls and special parts in working units',()=>{
    const groups=fresh();
    let group=groups[0];group.units[0].components=[31,23,23,23];
    let next=recalculateEquipment(group);equal(next.units[0].performance,1);equal(next.performance,13);
    group.units[0].components[0]=23;equal(recalculateEquipment(group).units[0].performance,0);
    for(const index of [2,3,4,5]) {
      group=groups[index];group.units[0].components[group.requiredSocket]=group.requiredComponent;
      next=recalculateEquipment(group);equal(next.performance,16);equal(next.specialAvailable,true);
      group.units[0].components[0]=0;next=recalculateEquipment(group);
      equal(next.performance,12);equal(next.specialAvailable,false);
    }
    group=groups[1];group.units[0].components[1]=25;
    equal(recalculateEquipment(group).units[0].performance,0); // Wrong standard component.
    equal(groups[0].performance,16); // Recalculation did not mutate cached caller data.
  });
  await test('Captured equipment ratings recalculate from components and requirements without changing the reference',async()=>{
    const reference=await fetch('fixtures/equipment-reference.json').then(r=>r.json());
    for(const group of reference.equipment) {
      const next=recalculateEquipment(group),{specialAvailable,...record}=next;
      equal(record,group);equal(specialAvailable,false);
    }
  });
  await test('Exchanges conserve parts, update performance and reject either incompatible destination atomically',()=>{
    let equipment=fresh(),inventory=pockets();
    const before=JSON.stringify({equipment,inventory});
    let result=exchangeEquipment(equipment,inventory,points[0],0,installed(0,1),carried(0));
    equal(result.inventory.carried[0],28);equal(result.equipment[0].units[0].components[1],0);equal(result.equipment[0].performance,12);
    equal(JSON.stringify({equipment,inventory}),before);
    ({equipment,inventory}=result);
    result=exchangeEquipment(equipment,inventory,points[0],0,carried(0),installed(0,1));
    equal(result.equipment[0].performance,16);equal(result.inventory.carried,[0,0,0,0]);
    inventory.carried[1]=23;
    result=exchangeEquipment(equipment,inventory,points[0],0,carried(1),installed(1,1));
    equal(result.inventory.carried[1],28);equal(result.equipment[0].units[1].performance,3);
    result=exchangeEquipment(equipment,inventory,points[0],0,installed(1,1),installed(1,2));
    equal(result.message,'equipmentDoesNotFit');equal(result.equipment===equipment,true);
    result=exchangeEquipment(equipment,inventory,points[0],0,carried(1),installed(0,0));
    equal(result.message,'equipmentDoesNotFit');equal(result.inventory===inventory,true);
    for(const [position,index,slot] of [[geometry.spawn,0,carried(0)],[points[0],3,carried(0)],[points[0],0,{container:'spares',index:0}],[points[0],0,installed(4,0)]]) {
      result=exchangeEquipment(equipment,inventory,position,index,slot,installed(0,1));equal(result.message,'equipmentUnavailable');
    }
  });
  await test('Fit checks exclude encoded damage and preserve every carried byte on rejected installation',()=>{
    for(let groupIndex=0;groupIndex<6;groupIndex++)for(let socket=0;socket<4;socket++)for(let byte=7;byte<256;byte++) {
      const equipment=fresh(),inventory=pockets(),group=equipment[groupIndex];inventory.carried[0]=byte;
      const fits=byte===group.spares[socket]||(byte===23&&socket>0)||(group.requiredComponent>0&&byte===group.requiredComponent&&socket===group.requiredSocket);
      equal(fitsComponent(group,byte,socket),fits);
      const result=exchangeEquipment(equipment,inventory,points[groupIndex],groupIndex,carried(0),installed(0,socket));
      equal(result.message,fits ? 'equipmentExchanged' : 'equipmentDoesNotFit');
      equal(result.inventory.carried[0],fits ? group.spares[socket] : byte);
      equal(inventory.carried[0],byte);
    }
    const equipment=fresh(),inventory=pockets();inventory.carried[0]=235;inventory.carried[1]=7;
    const result=exchangeEquipment(equipment,inventory,points[0],0,carried(0),carried(1));
    equal(result.inventory.carried,[7,235,0,0]);
  });
}
