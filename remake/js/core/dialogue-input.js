const keys=(value,names)=>value&&typeof value==='object'&&!Array.isArray(value)&&
  Object.keys(value).length===names.length&&names.every(name=>Object.hasOwn(value,name));
const integer=(value,min,max)=>Number.isInteger(value)&&value>=min&&value<=max;
export const MAX_DIALOGUE_INPUTS=1024;

export function validateDialogueInput(input) {
  const fail=()=>{throw Error('invalidDialogueInput')};
  const fields={sale:['type','slot'],purchase:['type','slot'],reply:['type','slot'],item:['type','item'],
    offer:['type','direction','step'],cancel:['type'],timeout:['type']};
  if(!Object.hasOwn(fields,input?.type)||!keys(input,fields[input.type]))fail();
  if(input.type==='reply'&&!integer(input.slot,0,2))fail();
  if(['purchase','sale'].includes(input.type)&&!integer(input.slot,0,3))fail();
  if(input.type==='item'&&!integer(input.item,8,255))fail();
  if(input.type==='offer'&&(!['increase','decrease'].includes(input.direction)||![1,10,100,1000,10000].includes(input.step)))fail();
  return Object.fromEntries(fields[input.type].map(key=>[key,input[key]]));
}
