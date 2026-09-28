import { createWalk, advanceWalk, interactionAt } from '../core/ship-walk.js';
import { createInventory, storageAt, transferItem } from '../core/inventory.js';
import { inventoryPanel } from './inventory.js';
import { createCondition, useCarriedItem } from '../core/condition.js';
import { createSurvival, advanceSurvival, startSleep, wakeUp } from '../core/survival.js';
import { checkpointCodec } from '../core/checkpoints.js';
import { checkpointScreen } from './checkpoints.js';

export const WALK_BOUNDS = { x: 32, y: 46, width: 640, height: 384 };
export function shipWalkScreen({ stage, background, assets, t, language, close }) {
  const root = document.createElement('section'); root.id = 'walk-screen'; root.hidden = true; stage.append(root);
  let state = createWalk(assets.shipWalk), open = false, frame, previous = 0, help = false, activePointer = null;
  let inventory = createInventory(assets.shipInventory), inventoryOpen = false, selected = null, inventoryMessage = '';
  let condition = createCondition(assets.shipInventory.condition);
  let survival = createSurvival(condition);
  const timeLabel = () => t('gameTime', { day: Math.floor(survival.minutes / 1440), hour: String(Math.floor(survival.minutes / 60) % 24).padStart(2, '0'), minute: String(survival.minutes % 60).padStart(2, '0') });
  const keys = new Set();
  const directions = { ArrowLeft: [-1, 0], ArrowRight: [1, 0], ArrowUp: [0, -1], ArrowDown: [0, 1] };
  const stop = () => { keys.clear(); activePointer = null; state = { ...state, held: false, pointer: null, elapsed: 0 }; };
  const codec = checkpointCodec(assets.shipWalk);
  const checkpoints = checkpointScreen({ stage, background:root, codec, t, language,
    snapshot: () => {
      if (survival.sleeping || survival.forced || survival.dead) throw new Error('invalidCheckpoint');
      return codec.snapshot({ position:state.position, inventory, condition, minutes:survival.minutes });
    },
    restore: value => {
      const next = codec.snapshot(value); // Validate completely before replacing any live state.
      stop(); state = { ...createWalk(assets.shipWalk), position:next.position, paused:true };
      inventory = next.inventory; condition = next.condition; survival = { ...createSurvival(condition), minutes:next.minutes };
      inventoryOpen = false; selected = null; help = false; previous = 0;
    },
    close: () => { render(); root.querySelector(survival.dead ? '#sleep-saves' : '#walk-saves').focus(); },
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
    const message = storage ? t('storageReached', { storage: t(storage) }) : t(state.paused ? 'walkPaused' : station ? 'walkStation' : 'walkHint');
    const status = root.querySelector('#walk-status');
    if (status.textContent !== message) status.textContent = message;
    const button = root.querySelector('#walk-inventory');
    const label = t(storage || 'inventoryTitle');
    if (button.textContent !== label) button.textContent = label;
    root.dataset.minutes = survival.minutes; root.dataset.sleeping = survival.sleeping; root.dataset.dead = survival.dead;
    const clock = root.querySelector('#walk-clock'); if (clock) clock.textContent = timeLabel();
    const sleepClock = root.querySelector('#sleep-clock'); if (sleepClock) sleepClock.textContent = timeLabel();
    const rest = root.querySelector('#sleep-rest'); if (rest) rest.textContent = t('sleepRest', { value: condition.rest });
  }
  function render() {
    if (!open) return;
    if (checkpoints.active) { checkpoints.render(); return; }
    const focus = document.activeElement?.id;
    root.innerHTML = `<canvas aria-hidden="true"></canvas><header class="topline"><button id="walk-back" data-walk="back">← ${t('backShort')}</button><h1>${t('walkTitle')}</h1><button id="walk-language" data-walk="language">${t('language')}</button></header>
      <p class="walk-note">${t('walkNote')}</p><p id="walk-clock"></p><div id="walk-surface" tabindex="0" role="button" aria-label="${t('walkControls')}"></div>
      <p id="walk-status" role="status"></p><footer class="walk-actions"><button id="walk-pause" data-walk="pause">${t(state.paused ? 'walkResume' : 'walkPause')}</button><button id="walk-inventory" data-walk="inventory">${t('inventoryTitle')}</button><button id="walk-saves" data-walk="checkpoints">${t('shipSaves')}</button><button id="walk-reset" data-walk="reset">${t('walkReset')}</button><button id="walk-help" data-walk="help">${t('help')} ?</button></footer>`;
    if (survival.sleeping || survival.dead) {
      for (const child of root.children) child.inert = true;
      root.insertAdjacentHTML('beforeend', `<div class="help-shade"><section class="help sleep-panel" role="dialog" aria-modal="true" aria-labelledby="sleep-title"><h2 id="sleep-title">${t(survival.dead ? 'conditionDeath' : survival.forced ? 'exhaustedSleep' : 'sleeping')}</h2><p id="sleep-clock">${timeLabel()}</p><p id="sleep-rest">${t('sleepRest', { value: condition.rest })}</p><p>${t(survival.dead ? 'deathScope' : 'sleepHint')}</p>${survival.dead ? `<button id="sleep-restart" data-walk="restart">${t('restartWalk')}</button><button id="sleep-saves" data-walk="checkpoints">${t('shipSaves')}</button>` : `<button id="sleep-pause" data-walk="sleep-pause">${t(state.paused ? 'walkResume' : 'walkPause')}</button><button id="sleep-wake" data-walk="wake" ${survival.forced ? 'disabled' : ''}>${t('wake')}</button>`}</section></div>`);
      const panel = root.querySelector('.sleep-panel');
      (panel.querySelector(`#${focus || 'sleep-pause'}:not(:disabled)`) || panel.querySelector('button')).focus({ preventScroll: true });
    } else if (help) {
      for (const child of root.children) child.inert = true;
      root.insertAdjacentHTML('beforeend', `<div class="help-shade"><section class="help" role="dialog" aria-modal="true" aria-labelledby="walk-help-title"><h2 id="walk-help-title">${t('walkTitle')}</h2><p>${t('walkControls')}</p><p>${t('walkScope')}</p><button id="walk-close-help" data-walk="close-help">${t('close')}</button></section></div>`);
      root.querySelector('#walk-close-help').focus();
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
    survival = advanceSurvival(survival, previous ? now - previous : 0, state.paused || checkpoints.active || help || (inventoryOpen && !survival.sleeping));
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
    if (help) {
      if (event.key === 'Tab') { event.preventDefault(); root.querySelector('#walk-close-help').focus(); }
      if (event.key === 'Escape') { event.preventDefault(); help = false; render(); root.querySelector('#walk-help').focus(); }
      return;
    }
    if (event.key === 'Escape') { event.preventDefault(); api.hide(); close(); return; }
    if (event.target.id === 'walk-surface' && (event.key === 'Enter' || event.key.toLowerCase() === 'i')) { event.preventDefault(); openInventory(); return; }
    if (event.target.id === 'walk-surface' && directions[event.key]) { event.preventDefault(); keys.add(event.key); }
  });
  root.addEventListener('keyup', event => { if (directions[event.key]) { keys.delete(event.key); if (!keys.size) stop(); } });
  root.addEventListener('focusout', event => { if (event.target.id === 'walk-surface') stop(); });
  function openInventory() { stop(); state.paused = true; inventoryOpen = true; selected = null; inventoryMessage = ''; render(); }
  function closeInventory() { inventoryOpen = false; selected = null; inventoryMessage = ''; render(); root.querySelector('#walk-inventory').focus(); }
  function finishSleep() {
    survival = wakeUp(survival);
    if (survival.sleeping || survival.dead) return;
    state.paused = true; inventoryOpen = true; inventoryMessage = 'wokeUp'; previous = 0;
    render(); root.querySelector('#inventory-sleep').focus();
  }
  root.addEventListener('click', event => {
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
    if (action === 'restart') {
      inventory = createInventory(assets.shipInventory); condition = createCondition(assets.shipInventory.condition);
      survival = createSurvival(condition); state = createWalk(assets.shipWalk); inventoryOpen = false; selected = null; previous = 0;
      render(); root.querySelector('#walk-surface').focus(); return;
    }
    if (action === 'back') { api.hide(); close(); return; }
    if (action === 'language') { language(); return; }
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
    if (action === 'reset') { state = createWalk(assets.shipWalk); previous = 0; }
    if (action === 'pause') { state.paused = !state.paused; previous = 0; }
    if (action === 'help') { help = true; state.paused = true; }
    if (action === 'close-help') help = false;
    render();
    if (action === 'reset' || (action === 'pause' && !state.paused)) root.querySelector('#walk-surface').focus();
    if (action === 'close-help') root.querySelector('#walk-help').focus();
  });
  window.addEventListener('blur', () => { if (open) pause(); });
  document.addEventListener('visibilitychange', () => { if (open && document.hidden) pause(); });
  const api = {
    get active() { return open; }, render,
    show() { open = true; root.hidden = false; background.inert = true; previous = 0; render(); root.querySelector('#walk-surface').focus(); frame = requestAnimationFrame(loop); },
    hide() { stop(); open = false; help = false; inventoryOpen = false; selected = null; root.hidden = true; background.inert = false; cancelAnimationFrame(frame); },
  };
  return api;
}
