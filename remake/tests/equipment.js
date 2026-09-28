import { equipmentBayAt, inspectEquipment } from '../js/core/equipment.js';
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
}
