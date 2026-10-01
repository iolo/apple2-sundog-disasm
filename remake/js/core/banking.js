import { atCityBank } from './city-doors.js';

// Library28 stores credits as signed thousands + a canonical 0..999 remainder.
// Reachable bank-only progress stays nonnegative; overflow is rejected atomically.
export const MAX_CREDITS=32767999;
const integer=n=>Number.isInteger(n)&&n>=0&&n<=MAX_CREDITS;
const keys=(v,names)=>v&&typeof v==='object'&&!Array.isArray(v)&&Object.keys(v).length===names.length&&names.every(k=>Object.hasOwn(v,k));
export function initialBanking(start) {
  return {accounts:start.systems.map(s=>({systemId:s.id,balance:s.bankBalance}))};
}
export function validateBanking(value) {
  if(!keys(value,['accounts'])||!Array.isArray(value.accounts)||value.accounts.length!==12||Object.keys(value.accounts).length!==12||
    !Array.from(value.accounts).every((a,i)=>keys(a,['systemId','balance'])&&a.systemId===`system-${String(i+1).padStart(2,'0')}`&&integer(a.balance)))throw new Error('invalidCampaign');
  return {accounts:value.accounts.map(a=>({systemId:a.systemId,balance:a.balance}))};
}

export function bankAvailable(cash,economy,systemId,type) {
  if(!integer(cash))throw new Error('invalidBankTransaction');
  const owned=validateBanking({accounts:economy?.accounts}),account=owned.accounts.find(a=>a.systemId===systemId);
  if(!account||!['deposit','withdraw','transfer'].includes(type))throw new Error('invalidBankTransaction');
  return type==='deposit' ? cash : account.balance;
}

// Game19 proc7: ALL, +100, +1000, +10000, +50000, CLEAR. ALL consumes the
// remaining available amount; an oversized increment is rejected, not clamped.
export function adjustBankAmount(amount,available,step) {
  if(!integer(amount)||!integer(available)||amount>available)throw new Error('invalidBankTransaction');
  if(step==='all')return available;
  if(step==='clear')return 0;
  if(![100,1000,10000,50000].includes(step))throw new Error('invalidBankTransaction');
  if(amount+step>available)throw new Error('bankInsufficient');
  return amount+step;
}

// Game19 proc17 deposit/withdraw and proc16 inter-system transfers share proc7.
// This pure operation owns its result and never changes the caller on failure.
export function transferBankFunds(cash,economy,systemId,{type,amount,targetSystemId}={}) {
  const available=bankAvailable(cash,economy,systemId,type);
  if(!integer(amount)||amount===0)throw new Error('bankInvalidAmount');
  if(amount>available)throw new Error('bankInsufficient');
  const next={...structuredClone(economy),...validateBanking({accounts:economy?.accounts})},source=next.accounts.find(a=>a.systemId===systemId);
  if(type==='transfer') {
    const target=next.accounts.find(a=>a.systemId===targetSystemId);
    if(!target||target===source)throw new Error('bankInvalidDestination');
    if(target.balance+amount>MAX_CREDITS)throw new Error('bankOverflow');
    source.balance-=amount;target.balance+=amount;
  } else {
    if(targetSystemId!==undefined)throw new Error('bankInvalidDestination');
    if(type==='deposit') {
      if(source.balance+amount>MAX_CREDITS)throw new Error('bankOverflow');
      cash-=amount;source.balance+=amount;
    } else {
      if(cash+amount>MAX_CREDITS)throw new Error('bankOverflow');
      source.balance-=amount;cash+=amount;
    }
  }
  return {cash,economy:next};
}

export function reduceCampaignBank(previous,map,action) {
  if(previous.travel.scene!=='bank'||!atCityBank(map,previous.travel.cityPosition))throw new Error('bankUnavailable');
  const next=transferBankFunds(previous.dialogue.cash,previous.economy,previous.start.playerLocation.systemId,action);
  return {...previous,dialogue:{...previous.dialogue,cash:next.cash},economy:next.economy};
}
