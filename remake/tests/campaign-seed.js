import { campaignSeed } from '../js/core/campaign-seed.js';

export async function campaignSeedTests(test,equal) {
  const rejects=fn=>{let threw=false;try{fn()}catch{threw=true}equal(threw,true)};
  await test('Explicit campaign seeds accept unsigned decimal values without drawing entropy',()=>{
    const none={getRandomValues(){throw Error('Unexpected entropy')}};
    for(const [text,value] of [['1',1],[' 12345 ',12345],['4294967295',4294967295],['0001',1]])equal(campaignSeed(text,none),value);
    for(const text of ['0','2147483648','4294967296','-1','1.5','1e2','0xff','NaN','00000000001',null])rejects(()=>campaignSeed(text,none));
  });
  await test('Blank seeds use private entropy, skip degenerate states and fail boundedly',()=>{
    const values=[0,0x80000000,42];let draws=0;
    equal(campaignSeed('',{getRandomValues(data){data[0]=values[draws++]}}),42);equal(draws,3);
    draws=0;rejects(()=>campaignSeed(' ',{getRandomValues(data){draws++;data[0]=0}}));equal(draws,16);
  });
}
