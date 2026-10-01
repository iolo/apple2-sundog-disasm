import { refreshCityMarket } from './economy.js';
import { sourceRandom } from './random.js';

const integer=(n,min,max)=>Number.isInteger(n)&&n>=min&&n<=max;
const ordinaryCity=id=>/^city-(0[1-9]|[1-4][0-9]|5[0-7])$/.test(id);
const quantities=a=>Array.isArray(a)&&a.length===31&&Object.keys(a).length===31&&Array.from(a).every(n=>integer(n,0,7));
const commodityNumber=id=>/^cargo-(0[1-9]|[12][0-9]|3[01])$/.test(id) ? Number(id.slice(6)) : NaN;
const fail=()=>{throw new Error('invalidExchange')};
const draw=random=>{const n=random.next();if(!integer(n,0,32767))fail();return n};

export function exchangeLocation(content,cityId) {
  if(content?.version!==1||!ordinaryCity(cityId)||!Array.isArray(content.worlds)||!Array.isArray(content.systems))fail();
  const world=content.worlds.find(w=>w.cityIds?.includes(cityId));
  const system=content.systems.find(s=>s.id===world?.systemId);
  if(!world||!system||!integer(system.priceLevel,0,15)||!integer(system.technologyLevel,0,15)||!world.cityIds.includes(world.capitalCityId))fail();
  return {cityId,worldId:world.id,systemId:system.id,capital:cityId===world.capitalCityId,
    priceLevel:system.priceLevel,technologyLevel:system.technologyLevel};
}

// Game20 proc18 guards the intermediate multiplication. The equality case
// deliberately divides first too, losing precision even when the product fits.
export function scaleExchangePrice(value,multiplier,divisor) {
  if(!integer(value,0,32767)||!integer(multiplier,1,23)||!integer(divisor,1,23))fail();
  const result=Math.trunc(32767/multiplier)<=value ? Math.trunc(value/divisor)*multiplier : Math.trunc(value*multiplier/divisor);
  // Unreachable with ordinary source quotes; reject forged high paid prices
  // rather than allowing Pascal signed overflow to become a financial input.
  if(result>32767)throw new Error('exchangePriceOverflow');
  return result;
}
function adjust(value,a,b) {
  const factor=8+Math.abs(a-b);
  return a>=b ? scaleExchangePrice(value,factor,8) : scaleExchangePrice(value,8,factor);
}
function validateContext(market,location) {
  if(!ordinaryCity(market?.cityId)||!quantities(market.demand)||!quantities(market.supply)||
    location?.cityId!==market.cityId||typeof location.capital!=='boolean'||
    !/^world-(0[1-9]|1[0-8])$/.test(location.worldId)||!/^system-(0[1-9]|1[0-2])$/.test(location.systemId)||
    !integer(location.priceLevel,0,15)||!integer(location.technologyLevel,0,15))fail();
}

// Game20 proc16. Internal prices are hundreds of credits, with truncation
// after EACH factor. Proc23 forbids ordinary exchange sales of fuel/cryogens.
export function quoteExchangeCargo(cargo,{market,location,originLocation,items},side='buy') {
  validateContext(market,location);
  const n=commodityNumber(cargo?.commodityId),base=items?.find(i=>i.id===cargo?.commodityId)?.valueByte;
  if(!integer(n,1,31)||!integer(cargo.quality,0,7)||!integer(base,0,255)||!['buy','sell'].includes(side))fail();
  if(side==='sell'&&(n===1||n===31))return null;
  if(side==='buy'&&(n===1||n===31))fail(); // Proc21 offers only commodities2..30.
  let price=adjust(base,market.demand[n-1],market.supply[n-1]);
  price=adjust(price,location.priceLevel,8);
  price=adjust(price,cargo.quality,6);
  if(n>=16&&n<=24)price=adjust(price,8,location.technologyLevel);
  if(!location.capital)price=side==='sell' ? adjust(price,8,6) : adjust(price,6,8);
  let ceiling=price;
  if(side==='sell') {
    if(!ordinaryCity(cargo.originCity)||originLocation?.cityId!==cargo.originCity||
      !/^world-(0[1-9]|1[0-8])$/.test(originLocation.worldId)||!/^system-(0[1-9]|1[0-2])$/.test(originLocation.systemId)||
      !integer(cargo.pricePaid,0,3276700)||cargo.pricePaid%100!==0)fail();
    ceiling=cargo.pricePaid/100;
    if(cargo.originCity!==location.cityId) {
      if(originLocation.worldId===location.worldId)ceiling=adjust(ceiling,8,6);
      else if(originLocation.systemId===location.systemId)ceiling=adjust(ceiling,8,4);
      else ceiling=price;
    }
  }
  // Library22 proc37 uses a lower-bound branch followed by an upper-bound
  // branch; this order matters for a forged zero pricePaid (ceiling0).
  const units=price<1 ? 1 : price>ceiling ? ceiling : price;
  return units*100;
}

// Game20 proc21/22, ordinary-city entry board (eight initially empty rows).
// Quantity is an availability weight, NOT a count of visible lots. Duplicate
// commodity+quality pairs are skipped without consuming the 32 empty probes.
export function createExchangeOffers(market,location,items,random) {
  validateContext(market,location);
  const offers=[];
  for(let slot=0;slot<8;slot++) {
    const quality=draw(random)%4+draw(random)%4+1;
    let candidate=1+draw(random)%31,remaining=32,accepted=false,probes=0;
    do {
      let unique=false;
      do {
        // Source loops may not converge for degenerate RNG/market inputs.
        // Bound the browser work; the visit wrapper owns and discards its RNG.
        if(++probes>4096)throw new Error('exchangeOfferLimit');
        candidate=(candidate+1)%31;if(candidate<2)candidate=2;
        if(market.supply[candidate-1]>0)unique=!offers.some(o=>o&&commodityNumber(o.commodityId)===candidate&&o.quality===quality);
        else remaining--;
      }while(!unique&&remaining>0);
      // The source still draws when remaining reaches zero.
      accepted=market.supply[candidate-1]>draw(random)%7||remaining<=0;
    }while(!accepted);
    if(remaining<=0)offers.push(null);
    else {
      const commodityId=`cargo-${String(candidate).padStart(2,'0')}`;
      offers.push({commodityId,quality,price:quoteExchangeCargo({commodityId,quality},{market,location,items})});
    }
  }
  return offers;
}

// Staged visit result, not yet a campaign reducer. The caller can commit the
// refreshed market, board and continuing RNG together after validating access.
export function prepareExchangeVisit({market,template,day,randomState,content,items}) {
  const location=exchangeLocation(content,market?.cityId),random=sourceRandom(randomState);
  const next=refreshCityMarket(market,template,day,random);
  const offers=createExchangeOffers(next,location,items,random);
  return {market:next,offers,randomState:random.state};
}
