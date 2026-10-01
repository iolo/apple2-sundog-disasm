import { prepareExchangeVisit, exchangeLocation, quoteExchangeCargo, replaceExchangeOffer } from './exchange.js';
import { cityServiceAt } from './city-doors.js';
import { sourceRandom } from './random.js';
import { MAX_CREDITS } from './banking.js';
import { validateCargoLot } from './cargo.js';

const fail=()=>{throw new Error('invalidCampaign')};
const keys=(v,names)=>v&&typeof v==='object'&&!Array.isArray(v)&&Object.keys(v).length===names.length&&names.every(k=>Object.hasOwn(v,k));
const array=(v,n)=>Array.isArray(v)&&v.length===n&&Object.keys(v).length===n;
const integer=(n,min,max)=>Number.isInteger(n)&&n>=min&&n<=max;
const number=id=>/^cargo-(0[2-9]|[12][0-9]|30)$/.test(id)?Number(id.slice(6)):NaN;
const items=content=>content.dialogue?.items||content.items;
const day=ship=>Math.floor(ship.minutes/1440)%16384;
const stamp=(offer,market)=>offer&&({...offer,demand:market.demand[number(offer.commodityId)-1],supply:market.supply[number(offer.commodityId)-1]});

// Only the starting city is mutable. R07g moves local lots through active pod
// cargo; other cities and colony delivery retain their later movement scope.
export function initialExchange(start) {
  const id=start.playerLocation.cityId;
  return {market:structuredClone(start.economy.markets.find(m=>m.cityId===id)),
    warehouse:structuredClone(start.economy.warehouses.find(w=>w.cityId===id)),visit:null};
}
export function exchangeSaleQuote(state,content,slot) {
  const {market,warehouse}=state.economy.exchange,cargo=warehouse.slots[slot];
  if(!cargo)return null;
  const location=exchangeLocation(content.exchange,market.cityId);
  return quoteExchangeCargo(cargo,{market,location,originLocation:location,items:items(content)},'sell');
}

export function validateExchange(value,start,ship,travel,content,{movableCargo=false}={}) {
  const initial=initialExchange(start),m=value?.market,w=value?.warehouse;
  if(!keys(value,['market','warehouse','visit'])||!keys(m,['cityId','templateIndex','demand','supply','lastUpdateDay'])||
    m.cityId!==initial.market.cityId||m.templateIndex!==initial.market.templateIndex||
    !keys(w,['cityId','slots'])||w.cityId!==m.cityId||!array(w.slots,4))fail();
  const template=content.economy.templates[m.templateIndex];
  for(const field of ['demand','supply'])if(!array(m[field],31)||!Array.from(m[field]).every((n,i)=>integer(n,0,template[field][i]))||m[field][30]!==initial.market[field][30])fail();
  if(!integer(m.lastUpdateDay,0,16383)&&m.lastUpdateDay!==-16)fail();
  if(m.lastUpdateDay===-16&&['demand','supply'].some(f=>m[f].some((n,i)=>n!==initial.market[f][i])))fail();
  if(ship.minutes<16384*1440&&m.lastUpdateDay>day(ship))fail();
  const slots=w.slots.map((cargo,i)=>{
    if(!movableCargo&&initial.warehouse.slots[i]) {
      if(!keys(cargo,['commodityId','quality','originCity','pricePaid'])||!Object.keys(cargo).every(k=>cargo[k]===initial.warehouse.slots[i][k]))fail();
      return {...initial.warehouse.slots[i]}; // Cryogens cannot be sold/moved here.
    }
    if(cargo===null)return null;
    let lot;try {lot=validateCargoLot(cargo)} catch {fail()}
    if(movableCargo&&lot.commodityId==='cargo-31')return lot;
    if(!integer(number(lot.commodityId),2,30)||lot.originCity!==m.cityId||lot.pricePaid<100||m.lastUpdateDay===-16)fail();
    return lot;
  });
  let visit=null;
  if(value.visit!==null) {
    if(travel.scene!=='exchange'||m.lastUpdateDay===-16||!keys(value.visit,['offers'])||!array(value.visit.offers,8))fail();
    const location=exchangeLocation(content.exchange,m.cityId),seen=new Set();
    const offers=value.visit.offers.map(o=>{
      if(o===null)return null;
      const n=number(o.commodityId),pair=`${o.commodityId}/${o.quality}`;
      if(!keys(o,['commodityId','quality','price','demand','supply'])||!integer(n,2,30)||!integer(o.quality,1,7)||
        !integer(o.demand,0,template.demand[n-1])||!integer(o.supply,1,template.supply[n-1])||seen.has(pair))fail();
      const basis={...m,demand:[...m.demand],supply:[...m.supply]};basis.demand[n-1]=o.demand;basis.supply[n-1]=o.supply;
      if(o.price!==quoteExchangeCargo(o,{market:basis,location,items:items(content)}))fail();
      seen.add(pair);return {commodityId:o.commodityId,quality:o.quality,price:o.price,demand:o.demand,supply:o.supply};
    });
    visit={offers};
  }
  // A null visit in an exchange is the legacy/resume entry boundary. The UI
  // runs entry once before showing quotes, never during an ordinary rerender.
  return {market:{cityId:m.cityId,templateIndex:m.templateIndex,demand:[...m.demand],supply:[...m.supply],lastUpdateDay:m.lastUpdateDay},warehouse:{cityId:w.cityId,slots},visit};
}

export function reduceCampaignExchange(previous,content,map,action) {
  const {travel}=previous;
  if(previous.pod?.attached===false&&(previous.pod.position?.x!==travel.cityPosition?.x||previous.pod.position?.y!==travel.cityPosition?.y))throw new Error('exchangeUnavailable');
  if(!['city','exchange'].includes(travel.scene)||cityServiceAt(map,travel.cityPosition,previous.pod?.attached===false?'pod':'foot')!=='exchange')throw new Error('exchangeUnavailable');
  const next=structuredClone(previous),e=next.economy.exchange;
  if(action.type==='enter') {
    if(e.visit!==null)throw new Error('exchangeUnavailable');
    const prepared=prepareExchangeVisit({market:e.market,template:content.economy.templates[e.market.templateIndex],day:day(next.ship),
      randomState:next.encounters.randomState,content:content.exchange,items:items(content)});
    e.market=prepared.market;e.visit={offers:prepared.offers.map(o=>stamp(o,e.market))};
    next.encounters.randomState=prepared.randomState;next.travel.scene='exchange';return next;
  }
  if(travel.scene!=='exchange'||!e.visit)throw new Error('exchangeUnavailable');
  if(action.type==='leave') {e.visit=null;next.travel.scene='city';return next}
  const random=sourceRandom(next.encounters.randomState),location=exchangeLocation(content.exchange,e.market.cityId);
  const account=next.economy.accounts.find(a=>a.systemId===location.systemId);
  if(action.type==='buy') {
    if(!integer(action.slot,0,7))throw new Error('exchangeInvalidSelection');
    const offer=e.visit.offers[action.slot],free=e.warehouse.slots.indexOf(null);
    if(!offer)throw new Error('exchangeInvalidSelection');
    if(free<0)throw new Error('exchangeFull');
    // Game20 proc23 uses Library28 proc6 (strictly greater, not >=).
    if(next.dialogue.cash+account.balance<=offer.price)throw new Error('exchangeInsufficient');
    const bank=Math.min(account.balance,offer.price);account.balance-=bank;next.dialogue.cash-=offer.price-bank;
    e.warehouse.slots[free]={commodityId:offer.commodityId,quality:offer.quality,originCity:e.market.cityId,pricePaid:offer.price};
    // Proc27 replaces the purchased row before reducing supply.
    const board=replaceExchangeOffer(e.visit.offers,action.slot,e.market,location,items(content),random);
    e.visit.offers[action.slot]=stamp(board[action.slot],e.market);
    const i=number(offer.commodityId)-1;e.market.supply[i]=Math.max(0,e.market.supply[i]-random.next()%3);
  } else if(action.type==='sell') {
    if(!integer(action.slot,0,3))throw new Error('exchangeInvalidSelection');
    const cargo=e.warehouse.slots[action.slot],price=exchangeSaleQuote(next,content,action.slot);
    if(!cargo||price===null||price===0)throw new Error('exchangeNotNegotiable');
    if(account.balance+price>MAX_CREDITS)throw new Error('bankOverflow');
    account.balance+=price;e.warehouse.slots[action.slot]=null;
    const i=number(cargo.commodityId)-1;e.market.demand[i]=Math.max(0,e.market.demand[i]-random.next()%3);
  } else throw new Error('exchangeInvalidSelection');
  next.encounters.randomState=random.state;return next;
}
