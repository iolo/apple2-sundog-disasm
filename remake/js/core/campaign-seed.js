// Explicit decimal seeds replay creation; blank requests browser entropy once.
export function campaignSeed(text, entropy = globalThis.crypto) {
  if (typeof text!=='string') throw new Error('invalidSeed');
  const value=text.trim(), valid=n=>Number.isInteger(n) && n>0 && n<=0xffffffff && n!==0x80000000;
  if (value) {
    if (!/^\d{1,10}$/.test(value) || !valid(Number(value))) throw new Error('invalidSeed');
    return Number(value);
  }
  for(let i=0;i<16;i++) {
    const data=new Uint32Array(1);entropy.getRandomValues(data);
    if(valid(data[0]))return data[0];
  }
  throw new Error('campaignCreateFailed');
}
