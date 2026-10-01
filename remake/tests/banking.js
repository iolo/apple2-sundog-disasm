import { initialBanking, validateBanking, adjustBankAmount, transferBankFunds, reduceCampaignBank, MAX_CREDITS } from '../js/core/banking.js';
import { campaignSaveCodec } from '../js/core/campaign-saves.js';
import { createCharacter } from '../js/core/character.js';
import { createCityMaps } from '../js/core/city-map.js';
import { createCityGeometry, SHIP_REENTRY } from '../js/core/city-walk.js';

export async function bankingTests(test,equal) {
  const [navigation,economy,location,inventory,ship,mapData,cityData]=await Promise.all(
    ['initial-navigation','initial-economy','initial-location','ship-inventory','ship-walk','maps','city-walk'].map(n=>fetch(`../data/${n}.json`).then(r=>r.json())));
  const map=createCityMaps(mapData,navigation,economy)['city-01'],city=createCityGeometry(map,cityData,{...location,position:location.shipPosition});
  const codec=campaignSaveCodec({navigation,economy,location,inventory},ship,city);
  const fresh=()=>codec.create({...createCharacter(),name:'Banking pilot'},12345);
  const atBank=()=>{const s=fresh();s.travel={scene:'bank',cityPosition:{x:369,y:299}};s.ship.position={...SHIP_REENTRY};return s};
  const rejects=(run,message)=>{let error;try{run()}catch(e){error=e.message}equal(error,message)};
  const total=(cash,e)=>cash+e.accounts.reduce((sum,a)=>sum+a.balance,0);
  await test('Bank amount controls preserve source increments, ALL remainder and CLEAR without overdrawing',()=>{
    let amount=0;
    for(const step of [100,1000,10000,50000])amount=adjustBankAmount(amount,62099,step);
    equal(amount,61100);equal(adjustBankAmount(amount,62099,'all'),62099);
    rejects(()=>adjustBankAmount(amount,62099,1000),'bankInsufficient');
    equal(adjustBankAmount(62099,62099,'clear'),0);
    equal(adjustBankAmount(0,99,'all'),99);equal(adjustBankAmount(99,99,'all'),99);
    for(const bad of [-1,1.5,NaN,Infinity,'100'])rejects(()=>adjustBankAmount(0,1000,bad),'invalidBankTransaction');
  });
  await test('Deposits and withdrawals use exact credits across decimal carry and conserve cash plus accounts',()=>{
    for(const amount of [1,99,100,999,1000,10000,50000,MAX_CREDITS]) {
      const e=initialBanking(fresh().start);e.accounts[0].balance=0;
      const before=JSON.stringify(e),deposited=transferBankFunds(amount,e,'system-01',{type:'deposit',amount});
      equal(deposited.cash,0);equal(deposited.economy.accounts[0].balance,amount);equal(JSON.stringify(e),before);
      const withdrawn=transferBankFunds(0,deposited.economy,'system-01',{type:'withdraw',amount});
      equal(withdrawn,{cash:amount,economy:e});
    }
    const e=initialBanking(fresh().start);e.accounts[0].balance=999;
    const next=transferBankFunds(101,e,'system-01',{type:'deposit',amount:100});
    equal(next.cash,1);equal(next.economy.accounts[0].balance,1099);equal(total(next.cash,next.economy),total(101,e));
  });
  await test('System transfers have no fee, change only two accounts and exclude the local destination',()=>{
    const e=initialBanking(fresh().start),before=JSON.stringify(e);
    for(const source of e.accounts)for(const target of e.accounts) {
      if(source===target)continue;
      const next=transferBankFunds(153,e,source.systemId,{type:'transfer',targetSystemId:target.systemId,amount:999});
      equal(next.cash,153);equal(total(next.cash,next.economy),total(153,e));
      equal(next.economy.accounts.map(a=>a.balance),e.accounts.map(a=>a.balance+(a===source?-999:a===target?999:0)));
    }
    equal(JSON.stringify(e),before);
    rejects(()=>transferBankFunds(0,e,'system-01',{type:'transfer',targetSystemId:'system-01',amount:1}),'bankInvalidDestination');
  });
  await test('Invalid, insufficient and overflowing bank transactions are atomic',()=>{
    const e=initialBanking(fresh().start),before=JSON.stringify(e);
    for(const amount of [0,-1,0.5,'100',NaN,Infinity,MAX_CREDITS+1])rejects(()=>transferBankFunds(100,e,'system-01',{type:'deposit',amount}),'bankInvalidAmount');
    rejects(()=>transferBankFunds(100,e,'system-01',{type:'deposit',amount:101}),'bankInsufficient');
    rejects(()=>transferBankFunds(100,e,'system-01',{type:'withdraw',amount:e.accounts[0].balance+1}),'bankInsufficient');
    rejects(()=>transferBankFunds(100,e,'system-01',{type:'transfer',amount:1,targetSystemId:'system-13'}),'bankInvalidDestination');
    equal(JSON.stringify(e),before);
    e.accounts[0].balance=MAX_CREDITS;e.accounts[1].balance=MAX_CREDITS;
    const full=JSON.stringify(e);
    for(const action of [{type:'deposit',amount:1},{type:'withdraw',amount:1},{type:'transfer',amount:1,targetSystemId:'system-02'}])
      rejects(()=>transferBankFunds(MAX_CREDITS,e,'system-01',action),'bankOverflow');
    equal(JSON.stringify(e),full);
  });
  await test('Campaign banking requires the matching bank door and preserves RNG, time and other state',()=>{
    const state=atBank(),before=JSON.stringify(state),next=reduceCampaignBank(state,map,{type:'withdraw',amount:1000});
    equal(next.dialogue.cash,state.dialogue.cash+1000);equal(next.economy.accounts[0].balance,state.economy.accounts[0].balance-1000);
    const comparable=structuredClone(next);comparable.dialogue.cash=state.dialogue.cash;comparable.economy=state.economy;
    equal(comparable,state);equal(JSON.stringify(state),before);equal(codec.snapshot(next),next);
    for(const travel of [{scene:'city',cityPosition:state.travel.cityPosition},{scene:'bank',cityPosition:city.spawn}])
      rejects(()=>reduceCampaignBank({...state,travel},map,{type:'withdraw',amount:100}),'bankUnavailable');
  });
  await test('Version12 saves preserve active accounts and migrate version11 without inventing wealth',()=>{
    const state=atBank(),next=reduceCampaignBank(state,map,{type:'withdraw',amount:1000}),saved=codec.make(next,0);
    equal(saved.version,17);equal(codec.parse(JSON.stringify(saved)).state,next);
    const legacy=codec.make(state,0);legacy.version=11;delete legacy.state.pod;legacy.scope='landed-services-1';delete legacy.state.economy;
    equal(codec.validate(legacy).state,state);
    const forged=structuredClone(legacy);forged.state.economy=state.economy;rejects(()=>codec.validate(forged),'invalidCampaign');
    const cash=structuredClone(legacy);cash.state.dialogue.cash++;rejects(()=>codec.validate(cash),'invalidCampaign');
    for(const mutate of [s=>s.economy.accounts[0].balance++,s=>s.economy.accounts[0].balance=-1,
      s=>s.economy.accounts.reverse(),s=>s.economy.accounts[0].systemId='system-02',s=>s.economy.accounts[0].extra=1,
      s=>s.economy.accounts.pop(),s=>s.economy.stock=[],s=>delete s.economy,s=>s.dialogue.cash=MAX_CREDITS+1]) {
      const bad=structuredClone(saved);mutate(bad.state);rejects(()=>codec.validate(bad),'invalidCampaign');
    }
    const owned=validateBanking({accounts:next.economy.accounts});owned.accounts[0].balance=0;equal(next.economy.accounts[0].balance>0,true);
  });
}
