import { createWalk, advanceWalk, interactionAt } from '../core/ship-walk.js';
import { createInventory, storageAt, transferItem } from '../core/inventory.js';
import { inventoryPanel } from './inventory.js';
import { createCondition, useCarriedItem } from '../core/condition.js';
import { createSurvival, advanceSurvival, startSleep, wakeUp } from '../core/survival.js';
import { checkpointCodec, openCheckpointStore, CHECKPOINT_LIMIT } from '../core/checkpoints.js';
import { campaignSaveCodec, openCampaignStore, CAMPAIGN_LIMIT } from '../core/campaign-saves.js';
import { checkpointScreen } from './checkpoints.js';
import { escapeHTML } from './html.js';
import { equipmentBayAt, inspectEquipment } from '../core/equipment.js';
import { equipmentPanel } from './equipment.js';

export const WALK_BOUNDS = { x: 32, y: 46, width: 640, height: 384 };
export function shipWalkScreen({ stage, background, assets, t, language, close }) {
  const root = document.createElement('section'); root.id = 'walk-screen'; root.hidden = true; stage.append(root);
  let state = createWalk(assets.shipWalk), open = false, frame, previous = 0, help = false, activePointer = null;
  let inventory = createInventory(assets.shipInventory), inventoryOpen = false, selected = null, inventoryMessage = '';
  let condition = createCondition(assets.shipInventory.condition);
  let survival = createSurvival(condition);
  let campaignMode=false, campaignStart=null;
  let equipmentOpen=false, equipmentOffset=0, equipmentSelected=null;
  const sessions=new Map();
  const campaignCodec=campaignSaveCodec(assets.campaignContent,assets.shipWalk);
  const campaignKeys = Object.fromEntries(['checkpointTitle','checkpointScope','checkpointHint','checkpointLoadOnly',
    'checkpointSaved','checkpointDeleted','checkpointLoaded','checkpointImported','checkpointExported',
    'invalidCheckpoint','replaceCheckpointConfirm','deleteCheckpointConfirm','loadCheckpointConfirm']
    .map(key=>[key,key.replace('checkpoint','campaign').replace('Checkpoint','Campaign')]));
  const timeLabel = () => t('gameTime', { day: Math.floor(survival.minutes / 1440), hour: String(Math.floor(survival.minutes / 60) % 24).padStart(2, '0'), minute: String(survival.minutes % 60).padStart(2, '0') });
  const keys = new Set();
  const directions = { ArrowLeft: [-1, 0], ArrowRight: [1, 0], ArrowUp: [0, -1], ArrowDown: [0, 1] };
  const stop = () => { keys.clear(); activePointer = null; state = { ...state, held: false, pointer: null, elapsed: 0 }; };
  const codec = checkpointCodec(assets.shipWalk);
  const selectedCodec=()=>campaignMode ? campaignCodec : codec;
  const liveShip=()=>({position:state.position,inventory,condition,minutes:survival.minutes});
  function restoreShip(next) {
    stop();state={...createWalk(assets.shipWalk),position:next.position,paused:true};
    inventory=next.inventory;condition=next.condition;survival={...createSurvival(condition),minutes:next.minutes};
    inventoryOpen=false;selected=null;equipmentOpen=false;help=false;previous=0;
  }
  const checkpoints = checkpointScreen({ stage, background:root,
    codec:Object.fromEntries(['validate','make','parse'].map(key=>[key,(...args)=>selectedCodec()[key](...args)])),
    t:(key,params)=>t(campaignMode ? campaignKeys[key] || key : key,params),language,
    storeKey:()=>campaignMode ? 'campaign' : 'checkpoint',
    openStore:()=>campaignMode ? openCampaignStore(campaignCodec) : openCheckpointStore(codec),
    limit:()=>campaignMode ? CAMPAIGN_LIMIT : CHECKPOINT_LIMIT,
    filename:()=>campaignMode ? 'sundog-campaign.json' : 'sundog-ship-checkpoint.json',
    describe:value=>campaignMode ? t('campaignSummary',{name:value.state.start.character.name,day:Math.floor(value.state.ship.minutes/1440)}) :
      t('checkpointSummary',{hours:Math.floor(value.state.minutes/60),minute:String(value.state.minutes%60).padStart(2,'0'),x:value.state.position.x,y:value.state.position.y}),
    snapshot: () => {
      if (survival.sleeping || survival.forced || survival.dead) throw new Error('invalidCheckpoint');
      if(campaignMode) {
        if(!campaignStart)throw new Error('invalidCampaign');
        return {start:campaignStart,ship:codec.snapshot(liveShip())};
      }
      return codec.snapshot(liveShip());
    },
    restore: value => {
      const next=selectedCodec().snapshot(value); // Validate before replacing live state.
      if(campaignMode) {campaignStart=next.start;restoreShip(next.ship)}
      else restoreShip(next);
    },
    close: () => {
      if(campaignMode && !campaignStart) {api.hide();close();return}
      render(); root.querySelector(survival.dead ? '#sleep-saves' : '#walk-saves').focus();
    },
  });
  function pause() { stop(); state.paused = true; if (open) render(); }
  function draw() {
    if (!open) return;
    const canvas = root.querySelector('canvas'), context = canvas.getContext('2d');
    const scale = stage.getBoundingClientRect().width / 640 * Math.min(devicePixelRatio || 1, 3);
    const width = Math.round(640 * scale), height = Math.round(480 * scale);
    if (canvas.width !== width || canvas.height !== height) { canvas.width = width; canvas.height = height; }
    context.setTransform(width / 640, 0, 0, height / 480, 0, 0);
    context.fillStyle = '#101411'; context.fillRect(0, 0, 640, 480); context.imageSmoothingEnabled = false;
    const b = WALK_BOUNDS;
    context.drawImage(assets.images[assets.catalog.images.ship], b.x, b.y, b.width, b.height);
    const sx = b.width / 280, sy = b.height / 192;
    const x = b.x + state.position.x * sx, y = b.y + (state.position.y - 7) * sy;
    context.strokeStyle = '#eab975'; context.lineWidth = 1;
    context.beginPath(); context.arc(x + 3 * sx, y + 4 * sy, 11, 0, Math.PI * 2); context.stroke();
    context.drawImage(assets.images[assets.catalog.images.player], x, y, 7 * sx, 8 * sy);
    root.dataset.x = state.position.x; root.dataset.y = state.position.y; root.dataset.paused = state.paused;
    const station = interactionAt(state.position);
    const storage = storageAt(state.position);
    const bay = campaignMode && campaignStart ? equipmentBayAt(state.position) : null;
    const message = bay !== null ? t('equipmentReached', { name:t(`equipment${bay}`) }) : storage ? t('storageReached', { storage: t(storage) }) : t(state.paused ? 'walkPaused' : station ? 'walkStation' : 'walkHint');
    const status = root.querySelector('#walk-status');
    if (status.textContent !== message) status.textContent = message;
    const button = root.querySelector('#walk-inventory');
    const label = t(storage || 'inventoryTitle');
    if (button.textContent !== label) button.textContent = label;
    const engineering = root.querySelector('#walk-equipment');
    if (engineering) engineering.disabled = bay === null;
    root.dataset.minutes = survival.minutes; root.dataset.sleeping = survival.sleeping; root.dataset.dead = survival.dead;
    root.dataset.mode=campaignMode ? 'campaign' : 'walk';
    root.dataset.seed=campaignStart && campaignMode ? campaignStart.creation.seed : '';
    const clock = root.querySelector('#walk-clock'); if (clock) clock.textContent = timeLabel();
    const sleepClock = root.querySelector('#sleep-clock'); if (sleepClock) sleepClock.textContent = timeLabel();
    const rest = root.querySelector('#sleep-rest'); if (rest) rest.textContent = t('sleepRest', { value: condition.rest });
  }
  function render() {
    if (!open) return;
    if (checkpoints.active) { checkpoints.render(); return; }
    const focus = document.activeElement?.id;
    root.innerHTML = `<canvas aria-hidden="true"></canvas><header class="topline"><button id="walk-back" data-walk="back">← ${t('backShort')}</button><h1>${t('walkTitle')}</h1><button id="walk-language" data-walk="language">${t('language')}</button></header>
      <p class="walk-note">${campaignMode && campaignStart ? escapeHTML(t('campaignIdentity',{name:campaignStart.character.name,seed:campaignStart.creation.seed})) : t('walkNote')}</p><p id="walk-clock"></p><div id="walk-surface" tabindex="0" role="button" aria-label="${t(campaignMode ? 'campaignControls' : 'walkControls')}"></div>
      <p id="walk-status" role="status"></p><footer class="walk-actions"><button id="walk-pause" data-walk="pause">${t(state.paused ? 'walkResume' : 'walkPause')}</button><button id="walk-inventory" data-walk="inventory">${t('inventoryTitle')}</button>${campaignMode ? `<button id="walk-equipment" data-walk="equipment" disabled>${t('equipmentTitle')}</button>` : ''}<button id="walk-saves" data-walk="checkpoints">${t('shipSaves')}</button>${campaignMode ? '' : `<button id="walk-reset" data-walk="reset">${t('walkReset')}</button>`}<button id="walk-help" data-walk="help">${t('help')} ?</button></footer>`;
    if (survival.sleeping || survival.dead) {
      for (const child of root.children) child.inert = true;
      root.insertAdjacentHTML('beforeend', `<div class="help-shade"><section class="help sleep-panel" role="dialog" aria-modal="true" aria-labelledby="sleep-title"><h2 id="sleep-title">${t(survival.dead ? 'conditionDeath' : survival.forced ? 'exhaustedSleep' : 'sleeping')}</h2><p id="sleep-clock">${timeLabel()}</p><p id="sleep-rest">${t('sleepRest', { value: condition.rest })}</p><p>${t(survival.dead ? (campaignMode ? 'campaignDeath' : 'deathScope') : 'sleepHint')}</p>${survival.dead ? `${campaignMode ? `<button id="sleep-back" data-walk="back">${t('backShort')}</button>` : `<button id="sleep-restart" data-walk="restart">${t('restartWalk')}</button>`}<button id="sleep-saves" data-walk="checkpoints">${t('shipSaves')}</button>` : `<button id="sleep-pause" data-walk="sleep-pause">${t(state.paused ? 'walkResume' : 'walkPause')}</button><button id="sleep-wake" data-walk="wake" ${survival.forced ? 'disabled' : ''}>${t('wake')}</button>`}</section></div>`);
      const panel = root.querySelector('.sleep-panel');
      (panel.querySelector(`#${focus || 'sleep-pause'}:not(:disabled)`) || panel.querySelector('button')).focus({ preventScroll: true });
    } else if (help) {
      for (const child of root.children) child.inert = true;
      root.insertAdjacentHTML('beforeend', `<div class="help-shade"><section class="help" role="dialog" aria-modal="true" aria-labelledby="walk-help-title"><h2 id="walk-help-title">${t('walkTitle')}</h2><p>${t(campaignMode ? 'campaignControls' : 'walkControls')}</p><p>${t(campaignMode ? 'campaignPlayScope' : 'walkScope')}</p><button id="walk-close-help" data-walk="close-help">${t('close')}</button></section></div>`);
      root.querySelector('#walk-close-help').focus();
    } else if (equipmentOpen) {
      for (const child of root.children) child.inert = true;
      root.insertAdjacentHTML('beforeend', equipmentPanel({ view:inspectEquipment(campaignStart.equipment,state.position,equipmentOffset), selected:equipmentSelected, assets, t }));
      (root.querySelector('#equipment-panel').querySelector(`[id="${focus || ''}"]`) || root.querySelector('#equipment-close')).focus({ preventScroll:true });
    } else if (inventoryOpen) {
      for (const child of root.children) child.inert = true;
      root.insertAdjacentHTML('beforeend', inventoryPanel({ inventory, condition, time: timeLabel(), storage: storageAt(state.position), selected, message: inventoryMessage, assets, t }));
      (root.querySelector('#inventory-panel').querySelector(`[id="${focus || ''}"]:not(:disabled)`) || root.querySelector('#inventory-close')).focus({ preventScroll: true });
    } else if (focus) document.getElementById(focus)?.focus({ preventScroll: true });
    draw();
  }
  function loop(now) {
    if (!open) return;
    const before = `${survival.sleeping}/${survival.forced}/${survival.dead}`;
    survival = advanceSurvival(survival, previous ? now - previous : 0, state.paused || checkpoints.active || help || equipmentOpen || (inventoryOpen && !survival.sleeping));
    condition = survival.condition;
    if (before !== `${survival.sleeping}/${survival.forced}/${survival.dead}`) { stop(); selected = null; render(); }
    if (keys.size && !state.paused) {
      let dx = 0, dy = 0;
      for (const key of keys) { dx += directions[key][0]; dy += directions[key][1]; }
      state.held = !!(dx || dy);
      state.pointer = { x: state.position.x + 3 + Math.sign(dx) * 2, y: state.position.y - 3 + Math.sign(dy) * 2 };
    }
    if (!survival.sleeping && !survival.dead) state = advanceWalk(state, previous ? now - previous : 0, assets.shipWalk);
    previous = now;
    draw(); frame = requestAnimationFrame(loop);
  }
  function point(event) {
    const box = stage.getBoundingClientRect(), b = WALK_BOUNDS;
    return { x: ((event.clientX - box.left) * 640 / box.width - b.x) * 280 / b.width,
      y: ((event.clientY - box.top) * 480 / box.height - b.y) * 192 / b.height };
  }
  root.addEventListener('pointerdown', event => {
    if (event.target.id !== 'walk-surface' || event.button !== 0 || state.paused || help || activePointer !== null) return;
    event.preventDefault(); keys.clear(); activePointer = event.pointerId;
    event.target.setPointerCapture(event.pointerId); event.target.focus();
    state = { ...state, pointer: point(event), held: true };
  });
  root.addEventListener('pointermove', event => { if (event.pointerId === activePointer) state.pointer = point(event); });
  for (const name of ['pointerup', 'pointercancel', 'lostpointercapture']) root.addEventListener(name, event => { if (event.pointerId === activePointer) stop(); });
  root.addEventListener('keydown', event => {
    if (event.isComposing) return;
    if (survival.sleeping || survival.dead) {
      if (event.key === 'Tab') {
        const buttons = [...root.querySelectorAll('.sleep-panel button:not(:disabled)')];
        const index = buttons.indexOf(document.activeElement); event.preventDefault();
        buttons[(index + (event.shiftKey ? -1 : 1) + buttons.length) % buttons.length].focus();
      }
      if (event.key === 'Escape' && survival.sleeping) { event.preventDefault(); finishSleep(); }
      return;
    }
    if (inventoryOpen) {
      if (event.key === 'Escape') {
        event.preventDefault();
        if (selected) { selected = null; inventoryMessage = 'selectionCancelled'; render(); }
        else closeInventory();
      }
      if (event.key === 'Tab') {
        const buttons = [...root.querySelectorAll('#inventory-panel button:not(:disabled)')];
        const index = buttons.indexOf(document.activeElement);
        event.preventDefault(); buttons[(index + (event.shiftKey ? -1 : 1) + buttons.length) % buttons.length].focus();
      }
      return;
    }
    if (equipmentOpen) {
      if (event.key === 'Escape') { event.preventDefault(); closeEquipment(); }
      if (event.key === 'Tab') {
        const buttons = [...root.querySelectorAll('#equipment-panel button:not(:disabled)')];
        const index = buttons.indexOf(document.activeElement);
        event.preventDefault(); buttons[(index + (event.shiftKey ? -1 : 1) + buttons.length) % buttons.length].focus();
      }
      return;
    }
    if (help) {
      if (event.key === 'Tab') { event.preventDefault(); root.querySelector('#walk-close-help').focus(); }
      if (event.key === 'Escape') { event.preventDefault(); help = false; render(); root.querySelector('#walk-help').focus(); }
      return;
    }
    if (event.key === 'Escape') { event.preventDefault(); api.hide(); close(); return; }
    if (event.target.id === 'walk-surface' && event.key === 'Enter' && campaignMode && equipmentBayAt(state.position) !== null) { event.preventDefault(); openEquipment(); return; }
    if (event.target.id === 'walk-surface' && (event.key === 'Enter' || event.key.toLowerCase() === 'i')) { event.preventDefault(); openInventory(); return; }
    if (event.target.id === 'walk-surface' && directions[event.key]) { event.preventDefault(); keys.add(event.key); }
  });
  root.addEventListener('keyup', event => { if (directions[event.key]) { keys.delete(event.key); if (!keys.size) stop(); } });
  root.addEventListener('focusout', event => { if (event.target.id === 'walk-surface') stop(); });
  function openInventory() { stop(); state.paused = true; inventoryOpen = true; selected = null; inventoryMessage = ''; render(); }
  function closeInventory() { inventoryOpen = false; selected = null; inventoryMessage = ''; render(); root.querySelector('#walk-inventory').focus(); }
  function openEquipment() {
    if (!campaignMode || !campaignStart || equipmentBayAt(state.position) === null || survival.sleeping || survival.dead) return;
    stop(); state.paused=true; equipmentOpen=true; equipmentOffset=0; equipmentSelected=null; render();
  }
  function closeEquipment() { equipmentOpen=false; equipmentSelected=null; render(); root.querySelector('#walk-equipment').focus(); }
  function finishSleep() {
    survival = wakeUp(survival);
    if (survival.sleeping || survival.dead) return;
    state.paused = true; inventoryOpen = true; inventoryMessage = 'wokeUp'; previous = 0;
    render(); root.querySelector('#inventory-sleep').focus();
  }
  root.addEventListener('click', event => {
    const component = event.target.closest('[data-equipment-row]');
    if (equipmentOpen && component) {
      equipmentSelected={row:Number(component.dataset.equipmentRow),socket:Number(component.dataset.equipmentSocket)};
      render(); return;
    }
    const slotButton = event.target.closest('[data-slot]');
    if (inventoryOpen && slotButton) {
      const slot = { container: slotButton.dataset.container, index: Number(slotButton.dataset.slot) };
      if (selected) {
        const next = transferItem(inventory, selected, slot, state.position);
        inventoryMessage = next === inventory ? 'selectionCancelled' : 'inventoryTransferred';
        inventory = next; selected = null;
      } else if (inventory[slot.container][slot.index]) { selected = slot; inventoryMessage = ''; }
      else inventoryMessage = 'inventoryEmpty';
      render(); return;
    }
    const action = event.target.closest('[data-walk]')?.dataset.walk;
    if (!action) return;
    stop();
    if (action === 'checkpoints') {
      state.paused = true; survival = { ...survival, elapsed:0 }; selected = null;
      void checkpoints.show(); return;
    }
    if (action === 'sleep') { selected = null; survival = startSleep(survival); state.paused = false; previous = 0; render(); return; }
    if (action === 'wake') { finishSleep(); return; }
    if (action === 'sleep-pause') { state.paused = !state.paused; previous = 0; render(); return; }
    if (action === 'restart' && !campaignMode) {
      inventory = createInventory(assets.shipInventory); condition = createCondition(assets.shipInventory.condition);
      survival = createSurvival(condition); state = createWalk(assets.shipWalk); inventoryOpen = false; selected = null; previous = 0;
      render(); root.querySelector('#walk-surface').focus(); return;
    }
    if (action === 'back') { api.hide(); close(); return; }
    if (action === 'language') { language(); return; }
    if (action === 'equipment') { openEquipment(); return; }
    if (action === 'close-equipment') { closeEquipment(); return; }
    if (equipmentOpen && ['equipment-next','equipment-previous'].includes(action)) {
      equipmentOffset=(equipmentOffset + (action==='equipment-next' ? 1 : 2)) % 3;
      equipmentSelected=null; render(); return;
    }
    if (action === 'inventory') { openInventory(); return; }
    if (action === 'close-inventory') { closeInventory(); return; }
    if (action === 'cancel-item') { selected = null; inventoryMessage = 'selectionCancelled'; }
    if (action === 'use-item' && inventoryOpen && selected?.container === 'carried') {
      const result = useCarriedItem(inventory, condition, selected.index);
      if (result) {
        inventory = result.inventory; condition = result.condition;
        survival = { ...survival, condition };
        inventoryMessage = result.restored ? (result.field === 'health' ? 'rapidhealApplied' : 'foodEaten') : 'itemUsedAtFull';
        const index = selected.index; selected = null; render(); root.querySelector(`#slot-carried-${index}`).focus(); return;
      }
    }
    if (action === 'reset' && !campaignMode) { state = createWalk(assets.shipWalk); previous = 0; }
    if (action === 'pause') { state.paused = !state.paused; previous = 0; }
    if (action === 'help') { help = true; state.paused = true; }
    if (action === 'close-help') help = false;
    render();
    if (action === 'reset' || (action === 'pause' && !state.paused)) root.querySelector('#walk-surface').focus();
    if (action === 'close-help') root.querySelector('#walk-help').focus();
  });
  window.addEventListener('blur', () => { if (open) pause(); });
  document.addEventListener('visibilitychange', () => { if (open && document.hidden) pause(); });
  function switchMode(next) {
    if(next===campaignMode)return;
    stop();
    sessions.set(campaignMode,{state,inventory,condition,survival});
    campaignMode=next;
    const saved=sessions.get(next);
    if(saved) ({state,inventory,condition,survival}=saved);
    else {
      state=createWalk(assets.shipWalk);inventory=createInventory(assets.shipInventory);
      condition=createCondition(assets.shipInventory.condition);survival=createSurvival(condition);
    }
    state={...state,paused:true};previous=0;
  }
  function show() {
    if(open)return;
    open=true;root.hidden=false;background.inert=true;previous=0;render();
    root.querySelector('#walk-surface').focus();frame=requestAnimationFrame(loop);
  }
  const api = {
    get active() { return open; }, render,
    get hasCampaign() {return !!campaignStart},
    show() {switchMode(false);show()},
    showCampaign(value) {
      const next=value ? campaignCodec.snapshot(value) : null;
      switchMode(true);
      if(next) {campaignStart=next.start;restoreShip(next.ship)}
      if(campaignStart)show();
    },
    showCampaignSaves() {switchMode(true);state.paused=true;show();void checkpoints.show()},
    hide() { stop();state.paused=true; open = false; help = false; equipmentOpen=false; inventoryOpen = false; selected = null; root.hidden = true; background.inert = false; cancelAnimationFrame(frame); },
  };
  return api;
}
