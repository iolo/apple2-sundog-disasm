import { interactionAt } from './ship-walk.js';

export const CAPACITY = Object.freeze({ carried: 4, locker: 20, stores: 20 });
export function createInventory(initial) {
  return Object.fromEntries(Object.keys(CAPACITY).map(key => [key, [...initial[key]]]));
}
export function storageAt(position) {
  return ({ 5: 'locker', 6: 'stores' })[interactionAt(position)] || null;
}
export function itemType(byte) { return byte & 31; }
export function itemCharge(byte) {
  return [11, 13].includes(itemType(byte)) ? byte >> 5 : null;
}

function validSlot(state, slot, accessible) {
  return slot && Object.hasOwn(CAPACITY, slot.container)
    && (slot.container === 'carried' || slot.container === accessible)
    && Array.isArray(state[slot.container]) && state[slot.container].length === CAPACITY[slot.container]
    && Number.isInteger(slot.index) && slot.index >= 0 && slot.index < CAPACITY[slot.container];
}

// Browser adaptation: choose source then destination; an occupied slot swaps
// atomically. Cancelling a selection never removes an item into transient state.
// Preserve the whole item byte, including shield/scattergun charge bits.
export function transferItem(state, from, to, position) {
  const accessible = storageAt(position);
  if (!validSlot(state, from, accessible) || !validSlot(state, to, accessible)
      || (from.container === to.container && from.index === to.index)) return state;
  const source = state[from.container][from.index], target = state[to.container][to.index];
  if (!Number.isInteger(source) || source < 7 || source > 255 || !Number.isInteger(target) || target < 0 || target > 255) return state;
  const next = createInventory(state);
  next[from.container][from.index] = target;
  next[to.container][to.index] = source;
  return next;
}
