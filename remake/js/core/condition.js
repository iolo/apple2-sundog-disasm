import { createInventory, itemType } from './inventory.js';

// Game8 procedures2/7: four bytes at segment29 word60, in this order.
export const CONDITION_FIELDS = Object.freeze(['vigor', 'rest', 'health', 'nourishment']);
export function createCondition(initial) {
  return Object.fromEntries(CONDITION_FIELDS.map(key => [key, initial[key]]));
}
export function conditionSegments(value) { return Math.ceil(value / 8); }
export function itemEffect(byte) {
  if (!Number.isInteger(byte) || byte < 0 || byte > 255) return null;
  const field = ({ 8: 'nourishment', 10: 'health' })[itemType(byte)];
  return field ? { field, amount: 80, action: field === 'health' ? 'applyRapidheal' : 'eatFood' } : null;
}

// Library27 procedures11/14: consume even at the cap; clamp the one affected
// condition byte. Time-dependent survival and other consumables are separate.
export function useCarriedItem(inventory, condition, index) {
  if (!Number.isInteger(index) || index < 0 || index >= 4) return null;
  const effect = itemEffect(inventory.carried[index]);
  if (!effect || CONDITION_FIELDS.some(key => !Number.isInteger(condition[key]) || condition[key] < 0 || condition[key] > 255)) return null;
  const nextInventory = createInventory(inventory), nextCondition = createCondition(condition);
  nextInventory.carried[index] = 0;
  nextCondition[effect.field] = Math.min(255, condition[effect.field] + effect.amount);
  return { inventory: nextInventory, condition: nextCondition, restored: nextCondition[effect.field] - condition[effect.field], field: effect.field };
}
