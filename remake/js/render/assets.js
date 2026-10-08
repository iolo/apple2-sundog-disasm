import { createCityMaps, composeCityMap } from '../core/city-map.js';
import { createPodGeometry } from '../core/city-pod.js';
import { createCityGeometry } from '../core/city-walk.js';
import { createRoomGeometries } from '../core/room-walk.js';

export async function readJSON(path) {
  const response = await fetch(path);
  if (!response.ok) throw new Error(`Could not load ${path}: ${response.status}`);
  return response.json();
}

async function loadImage(path) {
  const image = new Image();
  image.src = path;
  await image.decode();
  return image;
}

export async function loadAssets() {
  const [catalog, locales] = await Promise.all([
    readJSON('data/catalog.json'),
    Promise.all(['en', 'ko'].map(locale => readJSON(`locales/${locale}.json`))),
  ]);
  const paths = [...Object.values(catalog.images), ...Object.values(catalog.itemImages), ...Object.values(catalog.tileBanks).flat()];
  const [maps, images, shipWalk, shipInventory, navigation, economy, location, cityWalk, roomWalk, dialogueData, exchange, surfaceWalk, flight, combatData] = await Promise.all([
    readJSON(catalog.maps),
    Promise.all(paths.map(async path => [path, await loadImage(path)])),
    readJSON(catalog.shipWalk),
    readJSON(catalog.shipInventory),
    readJSON('data/initial-navigation.json'),
    readJSON('data/initial-economy.json'),
    readJSON('data/initial-location.json'),
    readJSON('data/city-walk.json'),
    readJSON('data/room-walk.json'),
    Promise.all(['dialogue','dialogue-text','items','dialogue-systems'].map(name=>readJSON(`data/${name}.json`))),
    readJSON('data/exchange-defaults.json'),
    readJSON('data/surface-walk.json'),
    readJSON('data/flight-defaults.json'),
    Promise.all(['ground-chase','ground-combat'].map(name=>readJSON(`data/${name}.json`))),
  ]);
  await document.fonts.load('16px Mulmaru', 'SunDog 선독');
  const cityMaps=createCityMaps(maps,navigation,economy);
  const colonyMaps=Array.from({length:10},(_,completedPhase)=>({...composeCityMap(maps.cities.find(c=>c.id==='city-60'),
    {systemId:navigation.systems.find(s=>s.worldIds.includes(economy.colonyCity.worldId)).id,worldId:economy.colonyCity.worldId},{completedPhase}),name:economy.colonyCity.name}));
  const cityGeometry=createCityGeometry(cityMaps[location.cityId],cityWalk,{...location,position:location.shipPosition});
  cityGeometry.rooms=createRoomGeometries(roomWalk);
  cityGeometry.pod=createPodGeometry(cityMaps[location.cityId],cityWalk,{...location,position:location.shipPosition});
  const [scripts,text,items,systems]=dialogueData,dialogue={scripts,text,items,systems};
  const [chase,ground]=combatData;
  return { catalog, maps, cityMaps, colonyMaps, cityGeometry, shipWalk, shipInventory, campaignContent:{navigation,economy,location,inventory:shipInventory,dialogue,exchange,flight,regional:true,ground:{maps,cityWalk,surfaceWalk},combat:{chase,ground},space:true,tactical:true}, images: Object.fromEntries(images), locales: { en: locales[0], ko: locales[1] } };
}
