import { createCityMaps } from '../core/city-map.js';
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
  const [maps, images, shipWalk, shipInventory, navigation, economy, location, cityWalk, roomWalk] = await Promise.all([
    readJSON(catalog.maps),
    Promise.all(paths.map(async path => [path, await loadImage(path)])),
    readJSON(catalog.shipWalk),
    readJSON(catalog.shipInventory),
    readJSON('data/initial-navigation.json'),
    readJSON('data/initial-economy.json'),
    readJSON('data/initial-location.json'),
    readJSON('data/city-walk.json'),
    readJSON('data/room-walk.json'),
  ]);
  await document.fonts.load('16px Mulmaru', 'SunDog 선독');
  const cityMaps=createCityMaps(maps,navigation,economy);
  const cityGeometry=createCityGeometry(cityMaps[location.cityId],cityWalk,{...location,position:location.shipPosition});
  cityGeometry.rooms=createRoomGeometries(roomWalk);
  return { catalog, maps, cityMaps, cityGeometry, shipWalk, shipInventory, campaignContent:{navigation,economy,location,inventory:shipInventory}, images: Object.fromEntries(images), locales: { en: locales[0], ko: locales[1] } };
}
