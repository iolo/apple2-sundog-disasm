const keys=(v,names)=>v&&typeof v==='object'&&!Array.isArray(v)&&Object.keys(v).length===names.length&&names.every(k=>Object.hasOwn(v,k));
const fail=()=>{throw new Error('invalidShipResources')};

export const initialShipResources=start=>structuredClone(start.shipResources);

// R08b activates depot hull/fuel. Charges, destinations and power remain off
// until the machinery/flight producers and their dependent rules are connected.
export function validateShipResources(value,start) {
  if(!keys(value,['hull','fuel','warp','shields','guns','enginesPowered'])||
    !Number.isInteger(value.hull)||value.hull<start.shipResources.hull||value.hull>16||
    !Number.isInteger(value.fuel)||value.fuel<0||value.fuel>255||
    (value.fuel!==255&&value.fuel%16!==0)||
    !keys(value.warp,['charge','targetCharge','targetSystemId','charging'])||
    value.warp.charge!==0||value.warp.targetCharge!==0||value.warp.targetSystemId!==null||value.warp.charging!==false||
    !keys(value.shields,['charge','targetCharge'])||value.shields.charge!==0||value.shields.targetCharge!==0||
    !keys(value.guns,['charge','powered'])||value.guns.charge!==0||value.guns.powered!==false||value.enginesPowered!==false)fail();
  return {hull:value.hull,fuel:value.fuel,warp:{charge:0,targetCharge:0,targetSystemId:null,charging:false},
    shields:{charge:0,targetCharge:0},guns:{charge:0,powered:false},enginesPowered:false};
}
