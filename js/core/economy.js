// Utility14/16 city initialization and game20 procedures5/6 ordinary markets.
// Quantity index0 is cargo-01; index30 is cryogens (cargo-31).
const integer = (n, min, max) => Number.isInteger(n) && n >= min && n <= max;
const quantities = values => Array.isArray(values) && values.length === 31 &&
  values.every(n => integer(n,0,7));
const validTemplate = template => quantities(template?.demand) && quantities(template?.supply);
const cityId = number => `city-${String(number).padStart(2,'0')}`;
const draw = random => {
  const value = random.next();
  if (!integer(value,0,32767)) throw new Error('Invalid random result');
  return value;
};

export function createInitialEconomy(content, random) {
  if (content?.version !== 1 || !integer(content.selector,0,255) ||
      !Array.isArray(content.templates) || content.templates.length !== 18 ||
      !content.templates.every(validTemplate) || content.colonyCityId !== 'city-60' ||
      !Array.isArray(content.cities) || content.cities.length !== 57 ||
      content.cities.some((city,i) => city?.id !== cityId(i+1) ||
        !/^world-(0[1-9]|1[0-8])$/.test(city.worldId))) throw new Error('Invalid economy defaults');
  const selector = (content.selector+5)%18;
  const markets = content.cities.map(city => {
    const templateIndex = (selector + Number(city.worldId.slice(6))-1)%18;
    const template = content.templates[templateIndex];
    return {cityId:city.id,templateIndex,demand:[...template.demand],supply:[...template.supply],lastUpdateDay:-16};
  });
  markets.push({cityId:'city-60',templateIndex:null,demand:Array(31).fill(0),supply:Array(31).fill(0),lastUpdateDay:-16});
  const warehouses = [...content.cities.map(city=>city.id),'city-60'].map(id=>({cityId:id,slots:Array(4).fill(null)}));
  let cursor = 1+draw(random)%57, placed = 0;
  for (let attempts=0; placed<17 && attempts<10000; attempts++) {
    // Keep the original 1-based expression: effective step is 2..5, not 1..4.
    cursor = (cursor+draw(random)%4+1)%57+1;
    const warehouse = warehouses[cursor-1];
    if (warehouse.slots[0] !== null) continue;
    warehouse.slots[0] = {commodityId:'cargo-31',quality:7,originCity:warehouse.cityId,pricePaid:0};
    placed++;
  }
  if (placed !== 17) throw new Error('Cryogen initialization did not converge');
  return {selector,markets,warehouses,colony:{completedPhase:0,activePhase:0}};
}

// Pure refresh for ordinary cities. Colony visits additionally advance phases
// and award money; that transaction is deliberately outside this helper.
export function refreshCityMarket(market, template, day, random) {
  if (!/^city-(0[1-9]|[1-4][0-9]|5[0-7])$/.test(market?.cityId) ||
      !validTemplate(market) || !validTemplate(template) ||
      !integer(market.lastUpdateDay,-16,16383) || !integer(day,0,16383)) {
    throw new Error('Invalid ordinary market');
  }
  const next = {...market,demand:[...market.demand],supply:[...market.supply]};
  if (next.lastUpdateDay < 0) {
    for (let i=0;i<30;i++) {
      next.supply[i] = draw(random)%(next.supply[i]+1);
      next.demand[i] = draw(random)%(next.demand[i]+1);
    }
    next.lastUpdateDay = day;
  } else {
    const weeks = Math.trunc((day-next.lastUpdateDay)/7);
    if (weeks>0) {
      for (const field of ['demand','supply']) for (let i=0;i<30;i++) {
        next[field][i] = Math.min(next[field][i]+weeks,template[field][i]);
      }
      next.lastUpdateDay = day;
    }
  }
  return next;
}
