// Game13 map records, Library24 proc6 and the shipped ordinary-city membership.
// Creation stays immutable. The regional companion owns the moving ship and
// dormant city economies; economy.exchange owns exactly one active ordinary city.
export const ordinaryCity=id=>/^city-(0[1-9]|[1-4][0-9]|5[0-7])$/.test(id);
export const currentShipLocation=state=>state.regional?.shipLocation??state.start.shipLocation;
const fail=()=>{throw Error('invalidRegional')};
const keys=(v,n)=>v&&typeof v==='object'&&!Array.isArray(v)&&Object.keys(v).length===n.length&&n.every(k=>Object.hasOwn(v,k));

export function regionalIndex(content) {
  const {navigation,economy,exchange,ground}=content;
  if(navigation?.systems?.length!==12||navigation.worlds?.length!==18||economy?.cities?.length!==57||exchange?.worlds?.length!==18)fail();
  const worlds=new Map(),cities=new Map();
  for(const [i,w] of navigation.worlds.entries()) {
    const id=`world-${String(i+1).padStart(2,'0')}`,parents=navigation.systems.filter(s=>s.worldIds.includes(id)),e=exchange.worlds.find(e=>e.id===id);
    if(w.id!==id||parents.length!==1||!e||e.systemId!==parents[0].id||!e.cityIds.includes(e.capitalCityId))fail();
    const members=economy.cities.filter(c=>c.worldId===id);
    if(JSON.stringify(members.map(c=>c.id))!==JSON.stringify(e.cityIds)||!ground?.maps.worlds.some(m=>m.id===id))fail();
    worlds.set(id,{...w,systemId:parents[0].id,cityIds:[...e.cityIds],capitalCityId:e.capitalCityId});
    for(const c of members) {
      if(cities.has(c.id)||!ground.maps.cities.some(m=>m.id===c.id)||!ground.surfaceWalk.cities.some(m=>m.cityId===c.id&&m.worldId===id))fail();
      cities.set(c.id,{...c,systemId:parents[0].id});
    }
  }
  if(cities.size!==57||economy.colonyCity?.worldId!=='world-01')fail();
  cities.set('city-60',{...economy.colonyCity,systemId:worlds.get('world-01').systemId});
  return {worlds,cities};
}

// Library24 proc6 uses integer square root of the THREE packed coordinates.
export function systemDistance(systems,from,to) {
  const a=systems.find(s=>s.id===from)?.position,b=systems.find(s=>s.id===to)?.position;
  if(!a||!b||!['x','y','z'].every(k=>Number.isInteger(a[k])&&Number.isInteger(b[k])))fail();
  return Math.floor(Math.sqrt(['x','y','z'].reduce((n,k)=>n+(a[k]-b[k])**2,0)));
}
export const warpRequirement=(systems,from,to)=>3*systemDistance(systems,from,to)**2+10;

export function campaignLocation(state,content) {
  if(!state.regional)return state.start.playerLocation;
  const ship=currentShipLocation(state),cityId=state.ground?.cityId??ship.cityId;
  const city=content.economy.cities.find(c=>c.id===cityId)??content.economy.colonyCity;
  const worldId=state.ground?.worldId??ship.worldId;
  if(cityId&&city?.id!==cityId)fail();
  const system=content.navigation.systems.find(s=>s.worldIds.includes(worldId));
  return {...ship,systemId:system?.id??ship.systemId,worldId,cityId,
    surfacePosition:state.travel?.cityPosition?{x:Math.floor(state.travel.cityPosition.x/28),y:Math.floor(state.travel.cityPosition.y/(state.travel.scene==='surface'?24:32))}:ship.surfacePosition};
}

export function regionalGroundStart(state) {
  const ship=currentShipLocation(state);
  return {...state.start,shipLocation:ship,playerLocation:{...ship,worldId:state.ground?.worldId??ship.worldId}};
}

export function initialRegional(start) {
  const active=start.playerLocation.cityId;
  return {shipLocation:structuredClone(start.shipLocation),podWorldId:start.shipLocation.worldId,colonyPosition:null,
    cities:start.economy.markets.filter(m=>ordinaryCity(m.cityId)&&m.cityId!==active).map(m=>({market:structuredClone(m),warehouse:structuredClone(start.economy.warehouses.find(w=>w.cityId===m.cityId))})),
    cargoProceeds:0,legacyDialogueSurface:null};
}

export function selectRegionalExchange(previous,cityId) {
  if(!previous.regional||!ordinaryCity(cityId))throw Error('exchangeUnavailable');
  const next=structuredClone(previous),e=next.economy.exchange;
  if(e.visit!==null)throw Error('exchangeUnavailable');
  if(e.market.cityId===cityId)return next;
  const i=next.regional.cities.findIndex(c=>c.market.cityId===cityId);
  if(i<0)throw Error('exchangeUnavailable');
  const selected=next.regional.cities[i];
  next.regional.cities[i]={market:e.market,warehouse:e.warehouse};
  next.regional.cities.sort((a,b)=>a.market.cityId.localeCompare(b.market.cityId));
  next.economy.exchange={...selected,visit:null};return next;
}

export function validateRegionalCargo(start,exchange,pod,regional,losses=[],{salvage=false}={}) {
  if(!keys(regional,['shipLocation','podWorldId','colonyPosition','cities','cargoProceeds','legacyDialogueSurface'])||!Array.isArray(regional.cities)||regional.cities.length!==56||
    !Number.isSafeInteger(regional.cargoProceeds)||regional.cargoProceeds<0||regional.cargoProceeds>32767999)fail();
  const ids=[exchange.market.cityId,...regional.cities.map(c=>c.market.cityId)].sort();
  if(JSON.stringify(ids)!==JSON.stringify(start.economy.markets.filter(m=>ordinaryCity(m.cityId)).map(m=>m.cityId)))fail();
  if(regional.cities.some(c=>!keys(c,['market','warehouse'])||c.market.cityId!==c.warehouse.cityId)||
    regional.cities.some((c,i)=>i&&c.market.cityId<=regional.cities[i-1].market.cityId))fail();
  const all=[...exchange.warehouse.slots,...regional.cities.flatMap(c=>c.warehouse.slots),...pod.cargo].filter(Boolean);
  const signature=c=>[c.commodityId,c.quality,c.originCity,c.pricePaid].join('/');
  const initial=start.economy.warehouses.flatMap(w=>w.slots).filter(c=>c?.commodityId==='cargo-31');
  const lostCryogens=losses.filter(e=>e.lot.commodityId==='cargo-31').flatMap(e=>Array(e.count).fill(signature(e.lot)));
  if(JSON.stringify([...all.filter(c=>c.commodityId==='cargo-31').map(signature),...lostCryogens].sort())!==JSON.stringify(initial.map(signature).sort()))fail();
  if([...all,...losses.map(e=>e.lot)].some(c=>salvage&&c.originCity===null?false:c.commodityId==='cargo-01'? !start.worlds.some(w=>w.id===c.originWorld):c.commodityId!=='cargo-31'&&(!ordinaryCity(c.originCity)||c.pricePaid<100)))fail();
  // Destroyed purchases retain their cost in the wealth bound. A loss receipt
  // cannot be used as a new income allowance or to duplicate a cryogen.
  return all.reduce((sum,c)=>sum+c.pricePaid,0)+losses.reduce((sum,e)=>sum+e.count*e.lot.pricePaid,0);
}
