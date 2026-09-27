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
  const paths = [...Object.values(catalog.images), ...Object.values(catalog.tileBanks).flat()];
  const [maps, images, shipWalk] = await Promise.all([
    readJSON(catalog.maps),
    Promise.all(paths.map(async path => [path, await loadImage(path)])),
    readJSON(catalog.shipWalk),
  ]);
  await document.fonts.load('16px Mulmaru', 'SunDog 선독');
  return { catalog, maps, shipWalk, images: Object.fromEntries(images), locales: { en: locales[0], ko: locales[1] } };
}
