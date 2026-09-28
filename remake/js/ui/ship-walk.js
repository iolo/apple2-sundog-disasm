import { createWalk, advanceWalk, interactionAt } from '../core/ship-walk.js';
import { createInventory, storageAt, transferItem } from '../core/inventory.js';
import { inventoryPanel } from './inventory.js';
import { createCondition, useCarriedItem } from '../core/condition.js';

export const WALK_BOUNDS = { x: 32, y: 46, width: 640, height: 384 };
export function shipWalkScreen({ stage, background, assets, t, language, close }) {
  const root = document.createElement('section'); root.id = 'walk-screen'; root.hidden = true; stage.append(root);
  let state = createWalk(assets.shipWalk), open = false, frame, previous = 0, help = false, activePointer = null;
  let inventory = createInventory(assets.shipInventory), inventoryOpen = false, selected = null, inventoryMessage = '';
  let condition = createCondition(assets.shipInventory.condition);
  const keys = new Set();
  const directions = { ArrowLeft: [-1, 0], ArrowRight: [1, 0], ArrowUp: [0, -1], ArrowDown: [0, 1] };
  const stop = () => { keys.clear(); activePointer = null; state = { ...state, held: false, pointer: null, elapsed: 0 }; };
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
  }
  function render() {
    if (!open) return;
    const focus = document.activeElement?.id;
    root.innerHTML = `<canvas aria-hidden="true"></canvas><header class="topline"><button id="walk-back" data-walk="back">← ${t('backShort')}</button><h1>${t('walkTitle')}</h1><button id="walk-language" data-walk="language">${t('language')}</button></header>
      <p class="walk-note">${t('walkNote')}</p><div id="walk-surface" tabindex="0" role="button" aria-label="${t('walkControls')}"></div>
      <p id="walk-status" role="status"></p><footer class="walk-actions"><button id="walk-pause" data-walk="pause">${t(state.paused ? 'walkResume' : 'walkPause')}</button><button id="walk-inventory" data-walk="inventory">${t('inventoryTitle')}</button><button id="walk-reset" data-walk="reset">${t('walkReset')}</button><button id="walk-help" data-walk="help">${t('help')} ?</button></footer>`;
    if (help) {
      for (const child of root.children) child.inert = true;
      root.insertAdjacentHTML('beforeend', `<div class="help-shade"><section class="help" role="dialog" aria-modal="true" aria-labelledby="walk-help-title"><h2 id="walk-help-title">${t('walkTitle')}</h2><p>${t('walkControls')}</p><p>${t('walkScope')}</p><button id="walk-close-help" data-walk="close-help">${t('close')}</button></section></div>`);
      root.querySelector('#walk-close-help').focus();
    } else if (inventoryOpen) {
      for (const child of root.children) child.inert = true;
      root.insertAdjacentHTML('beforeend', inventoryPanel({ inventory, condition, storage: storageAt(state.position), selected, message: inventoryMessage, assets, t }));
      (root.querySelector('#inventory-panel').querySelector(`[id="${focus || ''}"]:not(:disabled)`) || root.querySelector('#inventory-close')).focus({ preventScroll: true });
    } else if (focus) document.getElementById(focus)?.focus({ preventScroll: true });
    draw();
  }
  function loop(now) {
    if (!open) return;
    if (keys.size && !state.paused) {
      let dx = 0, dy = 0;
      for (const key of keys) { dx += directions[key][0]; dy += directions[key][1]; }
      state.held = !!(dx || dy);
      state.pointer = { x: state.position.x + 3 + Math.sign(dx) * 2, y: state.position.y - 3 + Math.sign(dy) * 2 };
    }
    state = advanceWalk(state, previous ? now - previous : 0, assets.shipWalk); previous = now;
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
    if (action === 'back') { api.hide(); close(); return; }
    if (action === 'language') { language(); return; }
    if (action === 'inventory') { openInventory(); return; }
    if (action === 'close-inventory') { closeInventory(); return; }
    if (action === 'cancel-item') { selected = null; inventoryMessage = 'selectionCancelled'; }
    if (action === 'use-item' && inventoryOpen && selected?.container === 'carried') {
      const result = useCarriedItem(inventory, condition, selected.index);
      if (result) {
        inventory = result.inventory; condition = result.condition;
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
