const keys=(v,names)=>v&&typeof v==='object'&&!Array.isArray(v)&&Object.keys(v).length===names.length&&names.every(k=>Object.hasOwn(v,k));
const fail=()=>{throw new Error('invalidShipResources')};

export const initialShipResources=start=>structuredClone(start.shipResources);

// Version20 activates landed guns/shields and permits consumed fuel levels.
// Historical18/19 validation keeps all charges off and depot-only fuel values.
// Warp destinations/charging and engine motion retain their R09 boundary.
export function validateShipResources(value,start,{machinery=true}={}) {
  if(!keys(value,['hull','fuel','warp','shields','guns','enginesPowered'])||
    !Number.isInteger(value.hull)||value.hull<start.shipResources.hull||value.hull>16||
    !Number.isInteger(value.fuel)||value.fuel<0||value.fuel>255||
    (!machinery&&value.fuel!==255&&value.fuel%16!==0)||
    !keys(value.warp,['charge','targetCharge','targetSystemId','charging'])||
    value.warp.charge!==0||value.warp.targetCharge!==0||value.warp.targetSystemId!==null||value.warp.charging!==false||
    !keys(value.shields,['charge','targetCharge'])||!Number.isInteger(value.shields.charge)||value.shields.charge<0||value.shields.charge>255||
    ![0,63,64,127,128,191,192,255].includes(value.shields.targetCharge)||
    !keys(value.guns,['charge','powered'])||!Number.isInteger(value.guns.charge)||value.guns.charge<0||value.guns.charge>255||typeof value.guns.powered!=='boolean'||value.enginesPowered!==false||
    (!machinery&&(value.shields.charge!==0||value.shields.targetCharge!==0||value.guns.charge!==0||value.guns.powered)))fail();
  return {hull:value.hull,fuel:value.fuel,warp:{charge:0,targetCharge:0,targetSystemId:null,charging:false},
    shields:{charge:value.shields.charge,targetCharge:value.shields.targetCharge},guns:{charge:value.guns.charge,powered:value.guns.powered},enginesPowered:false};
}
