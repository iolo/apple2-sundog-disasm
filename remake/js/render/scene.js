import { cityWindow } from '../core/city-map.js';

export const MAP_BOUNDS = { x: 68, y: 145, width: 504, height: 216 };
export const CITY_BOUNDS = {x:145,y:136,width:350,height:240};
export const SHIP_BOUNDS = { x: 0, y: 46, width: 640, height: 384 };

export function previewCity(state,assets) {
  if(state.view!=='cities'||state.cityMode!=='composed')return null;
  const id=assets.maps.cities[state.indices.cities].id;
  return id==='city-60' ? assets.colonyMaps[state.colonyPhase] : assets.cityMaps[id];
}

export function drawScene(canvas, state, assets, displayScale = 1) {
  const ratio = Math.min(window.devicePixelRatio || 1, 3) * displayScale;
  const width = Math.max(1, Math.round(640 * ratio));
  const height = Math.max(1, Math.round(480 * ratio));
  if (canvas.width !== width || canvas.height !== height) {
    canvas.width = width; canvas.height = height;
  }
  const ctx = canvas.getContext('2d');
  ctx.setTransform(width / 640, 0, 0, height / 480, 0, 0);
  ctx.fillStyle = '#101411'; ctx.fillRect(0, 0, 640, 480);
  ctx.imageSmoothingEnabled = false;
  if (state.view === 'title') {
    ctx.fillStyle = '#59604d';
    for (let i = 0; i < 62; i++) {
      const x = (i * 149 + 37) % 640, y = (i * i * 19 + 61) % 420;
      if (x > 270 || y < 70) ctx.fillRect(x, y, 1, 1);
    }
    ctx.globalAlpha = .72;
    ctx.drawImage(assets.images[assets.catalog.images.title], 208, 118, 432, 296);
    ctx.globalAlpha = 1;
    return;
  }
  const city=previewCity(state,assets);
  if(city) {
    cityWindow(city,state.cityOrigin).forEach((row,y)=>row.forEach((cell,x)=>{
      const path=assets.catalog.tileBanks[`city-${cell.bank}`][cell.index];
      ctx.drawImage(assets.images[path],CITY_BOUNDS.x+x*35,CITY_BOUNDS.y+y*40,35,40);
    }));
    if(state.selection) {
      ctx.strokeStyle='#eab975';ctx.lineWidth=1;
      ctx.strokeRect(CITY_BOUNDS.x+state.selection.x*35,CITY_BOUNDS.y+state.selection.y*40,35,40);
    }
    return;
  }
  ctx.strokeStyle = '#252e25'; ctx.lineWidth = .5;
  for (let x = 32; x <= 608; x += 24) {
    ctx.beginPath(); ctx.moveTo(x, 138); ctx.lineTo(x, 371); ctx.stroke();
  }
  for (let y = 138; y <= 371; y += 24) {
    ctx.beginPath(); ctx.moveTo(32, y); ctx.lineTo(608, y); ctx.stroke();
  }
  if (state.view === 'ship') {
    const path = assets.catalog.images[state.indices.ship ? 'ship-section' : 'ship'];
    // Draw the entire source page with explicit dimensions; no intrinsic SVG-size assumptions.
    ctx.drawImage(assets.images[path], 0, 46, 640, 384);
  } else {
    const record = assets.maps[state.view][state.indices[state.view]];
    const rows = record.tiles.length, columns = record.tiles[0].length;
    const bank = assets.catalog.tileBanks[state.view === 'cities' ? `city-${state.bank}` : 'world'];
    const cw = MAP_BOUNDS.width / columns, ch = MAP_BOUNDS.height / rows;
    ctx.fillStyle = '#101411';
    ctx.fillRect(MAP_BOUNDS.x, MAP_BOUNDS.y, MAP_BOUNDS.width, MAP_BOUNDS.height);
    record.tiles.forEach((row, y) => row.forEach((tile, x) => {
      ctx.drawImage(assets.images[bank[tile]], MAP_BOUNDS.x + x * cw, MAP_BOUNDS.y + y * ch, cw, ch);
    }));
  }
  if (state.selection) {
    let { x, y } = state.selection;
    if (state.view !== 'ship') {
      const map = assets.maps[state.view][state.indices[state.view]].tiles;
      x = MAP_BOUNDS.x + (x + .5) * MAP_BOUNDS.width / map[0].length;
      y = MAP_BOUNDS.y + (y + .5) * MAP_BOUNDS.height / map.length;
    } else {
      x = SHIP_BOUNDS.x + x * SHIP_BOUNDS.width / 280;
      y = SHIP_BOUNDS.y + y * SHIP_BOUNDS.height / 192;
    }
    ctx.strokeStyle = '#eab975'; ctx.lineWidth = 1;
    ctx.strokeRect(x - 7, y - 7, 14, 14);
    ctx.beginPath(); ctx.moveTo(x - 12, y); ctx.lineTo(x + 12, y);
    ctx.moveTo(x, y - 12); ctx.lineTo(x, y + 12); ctx.stroke();
  }
}
