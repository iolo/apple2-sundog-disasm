import { equipmentBayAt, fitsComponent, recalculateEquipment, exchangeEquipment } from './equipment.js';
import { installEquipmentComponent, enterEquipmentFrame, resolveEquipmentFailures } from './equipment-failures.js';
import { reconcileMachinery } from './campaign-machinery.js';

// Presentation cadence for the source's next engineering update, not a repair
// duration or a simulation of CPU cycles. Paused panels do not charge game time.
export const ENGINEERING_UPDATE_MS=250;
export const initialEngineering=()=>({pendingFailures:Array(6).fill(31)});
const offset=n=>Number.isInteger(n)&&n>=0&&n<19&&n%5<4;
export function validateEngineering(value) {
  if(!value||Object.keys(value).length!==1||!Array.isArray(value.pendingFailures)||value.pendingFailures.length!==6||
    Object.keys(value.pendingFailures).length!==6||!Array.from(value.pendingFailures).every(n=>n===31||offset(n)))throw new Error('invalidEngineering');
  return {pendingFailures:[...value.pendingFailures]};
}

// Only the currently reachable installation producer is accepted. Combat will
// need its own state boundary: its failed-output cache differs from installation.
export function canonicalEngineeringGroup(group,initial,pending) {
  if(!Array.isArray(group?.units)||group.units.length!==4)throw new Error('invalidEngineering');
  const units=group.units.map((u,i)=>{
    if(!Array.isArray(u?.components)||u.components.length!==4)throw new Error('invalidEngineering');
    return {components:Array.from(u.components,(b,s)=>{
      const marked=i*5+s===pending;
      if(!Number.isInteger(b)||b<0||b>255||
        (marked ? b<=127||!fitsComponent(initial,b&31,s) : b!==0&&b!==7&&!fitsComponent(initial,b,s)))throw new Error('invalidEngineering');
      return marked?b&31:b;
    })};
  });
  const expected=recalculateEquipment({...initial,units});
  if(pending!==31)expected.units[Math.floor(pending/5)].components[pending%5]=group.units[Math.floor(pending/5)].components[pending%5];
  return expected;
}

export function reduceCampaignEngineering(previous,{type,groupIndex,from,to}) {
  const bay=equipmentBayAt(previous.ship.position);
  if(previous.travel.scene!=='ship'||previous.space?.defeat||previous.combat?.defeat||bay===null||!Number.isInteger(groupIndex)||groupIndex<0||groupIndex>5||
    Math.floor(groupIndex/3)!==Math.floor(bay/3))throw new Error('equipmentUnavailable');
  const engineering=validateEngineering(previous.engineering),pending=engineering.pendingFailures[groupIndex];
  const next=structuredClone(previous),session={group:next.equipment[groupIndex],pendingFailure:pending};
  let message='',result;
  if(type==='enter') {
    result=enterEquipmentFrame(session);
    // Deliberate browser adaptation: frame entry never leaves stale saved output.
    result.group=recalculateEquipment(result.group);
    if(pending!==31)message='equipmentFailed';
  } else if(type==='tick') {
    const resolved=resolveEquipmentFailures(session);result=resolved.state;
    if(resolved.destroyed.length)message='equipmentFailed';
  } else if(type==='exchange') {
    if(pending!==31)return {state:previous,message:'equipmentPending'};
    const pocket=from?.container==='carried'&&to?.container==='installed'?from:
      to?.container==='carried'&&from?.container==='installed'?to:null;
    const destination=pocket===from?to:from;
    const byte=pocket&&Number.isInteger(pocket.index)&&pocket.index>=0&&pocket.index<4 ? previous.ship.inventory.carried[pocket.index] : null;
    const inventory=structuredClone(previous.ship.inventory);
    if(byte!==null)inventory.carried[pocket.index]=byte&31;
    const exchanged=exchangeEquipment(previous.equipment,inventory,previous.ship.position,groupIndex,from,to);
    if(exchanged.message!=='equipmentExchanged')return {state:previous,message:exchanged.message};
    next.equipment=exchanged.equipment;next.ship.inventory=exchanged.inventory;
    result={group:next.equipment[groupIndex],pendingFailure:31};
    if(byte>127)result=installEquipmentComponent(result,destination.unit*5+destination.socket,byte);
    message=byte>127?'equipmentPending':exchanged.message;
  } else throw new Error('equipmentUnavailable');
  next.equipment[groupIndex]=result.group;next.engineering.pendingFailures[groupIndex]=result.pendingFailure;
  if(next.space)next.space.combatFailures[groupIndex]=false;
  return {state:reconcileMachinery(next),message};
}

// A status report, not a launch permission. Flight still needs R09 conditions.
export function engineeringStatus(equipment,resources) {
  return {hull:resources.hull,fuel:resources.fuel,
    inoperative:equipment.filter(g=>g.performance===0).map(g=>g.id),
    unitsOffline:equipment.reduce((n,g)=>n+g.units.filter(u=>u.performance===0).length,0)};
}
