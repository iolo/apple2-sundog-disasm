import { createPreview, reducePreview, logicalPoint, cellAt } from './core/preview.js';
import { loadAssets } from './render/assets.js';
import { drawScene, MAP_BOUNDS, SHIP_BOUNDS, CITY_BOUNDS, previewCity } from './render/scene.js';
import { cityWindow } from './core/city-map.js';
import { readLocale, saveLocale, translator } from './ui/i18n.js';
import { characterScreen } from './ui/character.js';
import { shipWalkScreen } from './ui/ship-walk.js';
import { campaignSaveCodec } from './core/campaign-saves.js';
import { campaignSeed } from './core/campaign-seed.js';

const viewport = document.querySelector('#viewport');
const stage = document.querySelector('#stage');
const canvas = document.querySelector('#scene');
const ui = document.querySelector('#interface');
const announcement = document.querySelector('#announcement');
let state = createPreview(), locale = readLocale(), assets, scale = 1, help = false;
let returnFocus = null;
let counts, walker, campaignCodec;
const t = (key, parameters) => translator(assets.locales, locale)(key, parameters);
const creator = characterScreen({ stage, background: ui, t,
  language: () => { locale = locale === 'en' ? 'ko' : 'en'; saveLocale(locale); render(); },
  close: () => document.querySelector('#create-character')?.focus(),
  start: (character,seedText) => {
    let next;
    try {next=campaignCodec.create(character,campaignSeed(seedText))}
    catch(error) {throw new Error(error.message==='invalidSeed' ? 'invalidSeed' : 'campaignCreateFailed')}
    if(walker.hasCampaign && !confirm(t('replaceActiveCampaign')))return;
    creator.hide();walker.showCampaign(next);render();
  },
});

function resize() {
  scale = Math.min(window.innerWidth / 640, window.innerHeight / 480);
  viewport.style.width = `${640 * scale}px`;
  viewport.style.height = `${480 * scale}px`;
  stage.style.transform = `scale(${scale})`;
  if (assets) drawScene(canvas, state, assets, scale);
}

function describeSelection() {
  if (!state.selection) return t('selectHint');
  const { x, y } = state.selection;
  const city=previewCity(state,assets);
  if(city) {
    const cell=cityWindow(city,state.cityOrigin)[y][x];
    return t('cityTile',{x:cell.x+1,y:cell.y+1,tile:cell.index,bank:cell.bank+1});
  }
  return state.view === 'ship' ? t('point', { x, y })
    : t('tile', { x: x + 1, y: y + 1, tile: assets.maps[state.view][state.indices[state.view]].tiles[y][x] });
}

function inspectGeometry() {
  if(previewCity(state,assets)) return {bounds:CITY_BOUNDS,width:10,height:6};
  const map=state.view==='ship' ? null : assets.maps[state.view][state.indices[state.view]].tiles;
  return {bounds:map ? MAP_BOUNDS : SHIP_BOUNDS,width:map ? map[0].length : 280,height:map ? map.length : 192};
}

function render() {
  const focused = document.activeElement?.id;
  const city=previewCity(state,assets);
  const availableCity=state.view==='cities' && assets.cityMaps[assets.maps.cities[state.indices.cities].id];
  document.documentElement.lang = locale;
  const language = `<button id="language" data-action="language" lang="${locale === 'en' ? 'ko' : 'en'}">${t('language')}</button>`;
  const footer = `<footer class="bottomline"><button id="about" data-action="help">${t('about')}</button><span>${t('previewNote')}</span></footer>`;
  if (state.view === 'title') {
    ui.innerHTML = `<header class="topline"><span class="edition">${t('edition')}</span>${language}</header>
      <section class="hero enter"><h1>SunDog</h1><div class="subtitle">${t('subtitle')}</div><p>${t('intro')}</p></section>
      <div class="hero-actions"><button id="create-character" class="primary" data-action="character">${t('createCharacter')} →</button>
      <div>${walker?.hasCampaign ? `<button id="resume-campaign" data-action="resume-campaign">${t('resumeCampaign')}</button>` : ''}<button id="campaign-saves" data-action="campaign-saves">${t('campaignTitle')}</button></div>
      <button id="explore" data-action="view" data-view="ship">${t('explore')} ↗</button></div>${footer}`;
  } else {
    ui.innerHTML = `<header class="topline"><button id="home" class="brand" data-action="view" data-view="title" aria-label="${t('homeLabel')}">SunDog</button>
      <nav>${['ship', 'cities', 'worlds'].map(view => `<button id="nav-${view}" data-action="view" data-view="${view}" aria-pressed="${state.view === view}">${t(view)}</button>`).join('')}</nav>${language}</header>
      <section class="scene-heading${city ? ' city-heading' : ''}"><div><h1>${city ? city.name : t(`${state.view}Title`)}</h1><p>${city ? t('cityViewDescription') : state.view==='cities'&&!availableCity ? t('cityStoredOnly') : t(`${state.view}Description`)}</p></div>
      <div class="pager"><button id="previous" data-action="step" data-delta="-1" aria-label="${t('previous')}">‹</button>
      <span>${String(state.indices[state.view] + 1).padStart(2, '0')} / ${counts[state.view]}</span>
      <button id="next" data-action="step" data-delta="1" aria-label="${t('next')}">›</button></div></section>
      <div id="inspect" class="inspect-surface${city ? ' city-surface' : ''}" role="button" tabindex="0" aria-label="${t('surface')}"></div>
      ${city ? `<div class="city-pan" aria-label="${t('cityPan')}">${[['left',-1,0,'←'],['up',0,-1,'↑'],['down',0,1,'↓'],['right',1,0,'→']].map(([direction,dx,dy,glyph])=>`<button id="city-${direction}" data-action="city-pan" data-dx="${dx}" data-dy="${dy}" aria-label="${t(`cityPan-${direction}`)}">${glyph}</button>`).join('')}</div>` : ''}
      <div class="scene-controls${state.view==='cities' ? ' city-controls' : ''}"><p class="selection">${describeSelection()}</p>
      ${state.view === 'cities' ? `<div class="city-view-controls">${city ? '' : `<label class="sr-only" for="bank">${t('bank')}</label><select id="bank">${[0, 1, 2, 3].map(bank => `<option value="${bank}" ${state.bank === bank ? 'selected' : ''}>${t('bankOption', { number: bank + 1 })}</option>`).join('')}</select>`}<button id="city-mode" data-action="city-mode" ${!availableCity ? 'disabled' : ''}>${t(city ? 'cityStoredView' : 'cityComposedView')}</button></div>` : `<div>${state.view === 'ship' ? `<button id="begin-walk" data-action="walk">${t('beginWalk')} →</button>` : ''}<button id="help" data-action="help">${t('help')} ?</button></div>`}</div>
      <footer class="bottomline"><span>${t('controls')}</span><span>${t('preview')}</span></footer>`;
  }
  if (help) {
    // Only the dialog is interactive while it is visible.
    for (const child of ui.children) child.inert = true;
    ui.insertAdjacentHTML('beforeend', `<div class="help-shade"><section class="help enter" role="dialog" aria-modal="true" aria-labelledby="help-title"><h2 id="help-title">${t('helpTitle')}</h2><p>${t('helpBody')}</p><p>${t('helpScope')}</p><button id="close-help" data-action="close-help">${t('close')} · Esc</button></section></div>`);
    document.querySelector('#close-help').focus();
  } else if (focused) {
    document.getElementById(focused)?.focus({ preventScroll: true });
  }
  drawScene(canvas, state, assets, scale);
  creator.render();
  walker?.render();
}

function dispatch(action) {
  const before = state.view;
  state = reducePreview(state, action, counts);
  render();
  if (before !== state.view) {
    document.getElementById(state.view === 'title' ? 'explore' : `nav-${state.view}`)?.focus();
  }
  announcement.textContent = state.selection ? describeSelection()
    : state.view === 'title' ? t('preview') : `${t(`${state.view}Title`)} ${state.indices[state.view] + 1} / ${counts[state.view]}`;
}

function closeHelp() {
  help = false; render();
  document.getElementById(returnFocus)?.focus();
}

ui.addEventListener('click', event => {
  const button = event.target.closest('[data-action]');
  if (!button || !assets) return;
  const action = button.dataset.action;
  if (action === 'character') { creator.show(); return; }
  if (action === 'walk') { walker.show(); return; }
  if (action === 'resume-campaign') {walker.showCampaign();return}
  if (action === 'campaign-saves') {walker.showCampaignSaves();return}
  if (action === 'language') {
    locale = locale === 'en' ? 'ko' : 'en'; saveLocale(locale); render();
  } else if (action === 'help') {
    returnFocus = button.id; help = true; render();
  } else if (action === 'close-help') closeHelp();
  else if (action === 'view') dispatch({ type: 'view', view: button.dataset.view });
  else if (action === 'step') dispatch({ type: 'step', delta: Number(button.dataset.delta) });
  else if (action === 'city-mode') dispatch({type:'city-mode',mode:previewCity(state,assets) ? 'stored' : 'composed'});
  else if (action === 'city-pan') dispatch({type:'city-pan',dx:Number(button.dataset.dx),dy:Number(button.dataset.dy)});
});

ui.addEventListener('change', event => {
  if (event.target.id === 'bank') dispatch({ type: 'bank', bank: Number(event.target.value) });
});

ui.addEventListener('pointerdown', event => {
  if (event.target.id !== 'inspect' || help) return;
  const point = logicalPoint(stage.getBoundingClientRect(), event.clientX, event.clientY);
  const {bounds,width,height}=inspectGeometry();
  const cell = cellAt(point,bounds,width,height);
  if (cell) {
    event.preventDefault();
    dispatch({ type: 'select', point: cell });
    document.querySelector('#inspect').focus();
  }
});

document.addEventListener('keydown', event => {
  if (!assets) return;
  if (walker?.active || event.target.closest?.('#walk-screen')) return;
  if (creator.active) {
    if (event.key === 'Escape' && !event.isComposing) {
      event.preventDefault(); creator.hide(); document.querySelector('#create-character').focus();
    }
    return;
  }
  if (help) {
    if (event.key === 'Escape') { event.preventDefault(); closeHelp(); }
    if (event.key === 'Tab') { event.preventDefault(); document.querySelector('#close-help').focus(); }
    return;
  }
  if (event.target.tagName === 'SELECT') return;
  if (event.key === 'Escape') {
    event.preventDefault(); dispatch({ type: 'view', view: 'title' }); return;
  }
  if (state.view === 'title') return;
  if (event.target.id === 'inspect' && (['Enter', ' '].includes(event.key) || event.key.startsWith('Arrow'))) {
    event.preventDefault();
    const {width,height}=inspectGeometry();
    const point = state.selection ? { ...state.selection } : { x: Math.floor(width / 2), y: Math.floor(height / 2) };
    if (event.key === 'ArrowLeft') point.x--;
    if (event.key === 'ArrowRight') point.x++;
    if (event.key === 'ArrowUp') point.y--;
    if (event.key === 'ArrowDown') point.y++;
    point.x = Math.min(width - 1, Math.max(0, point.x));
    point.y = Math.min(height - 1, Math.max(0, point.y));
    dispatch({ type: 'select', point });
  } else if (['ArrowLeft', 'ArrowRight'].includes(event.key)) {
    event.preventDefault(); dispatch({ type: 'step', delta: event.key === 'ArrowLeft' ? -1 : 1 });
  }
});

window.addEventListener('resize', resize);
resize();
try {
  assets = await loadAssets();
  campaignCodec=campaignSaveCodec(assets.campaignContent,assets.shipWalk,assets.cityGeometry);
  walker = shipWalkScreen({ stage, background: ui, assets, t,
    language: () => { locale = locale === 'en' ? 'ko' : 'en'; saveLocale(locale); render(); },
    close: () => {render();document.querySelector(state.view==='title' ? (walker.hasCampaign ? '#resume-campaign' : '#campaign-saves') : '#begin-walk')?.focus()},
  });
  counts = { ship: 2, cities: assets.maps.cities.length, worlds: assets.maps.worlds.length };
  render();
  document.querySelector('#create-character').focus({ preventScroll: true });
  document.documentElement.dataset.ready = 'true';
} catch (error) {
  console.error(error);
  ui.replaceChildren();
  const panel = document.createElement('div'); panel.className = 'loading';
  const message = document.createElement('p');
  message.textContent = 'Unable to load SunDog. Serve the complete remake folder over HTTP. / 선독을 불러오지 못했습니다. remake 폴더를 HTTP 서버로 열어 주세요.';
  const retry = document.createElement('button'); retry.textContent = 'Retry / 다시 시도';
  retry.onclick = () => location.reload(); panel.append(message, retry); ui.append(panel);
}
