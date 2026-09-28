import { createInventory } from '../js/core/inventory.js';
import { createCondition, conditionSegments, itemEffect, useCarriedItem } from '../js/core/condition.js';

export async function conditionTests(test, equal) {
  const initial = await fetch('../data/ship-inventory.json').then(r => r.json());
  const condition = { vigor: 128, rest: 90, health: 120, nourishment: 100 };
  const inventory = () => ({ ...createInventory(initial), carried: [8, 10, 235, 12] });
  await test('Fresh condition matches source defaults and original 32-segment meter rounding', () => {
    const current = createCondition(initial.condition);
    equal(current, { vigor: 255, rest: 255, health: 255, nourishment: 255 });
    equal([0, 1, 7, 8, 9, 248, 249, 255].map(conditionSegments), [0, 1, 1, 1, 2, 31, 32, 32]);
    current.health = 1; equal(initial.condition.health, 255);
  });
  await test('Food restores only nourishment and consumes exactly one carried item', () => {
    const source = inventory(), before = JSON.stringify(source);
    const result = useCarriedItem(source, condition, 0);
    equal(result.condition, { vigor: 128, rest: 90, health: 120, nourishment: 180 });
    equal(result.inventory.carried, [0, 10, 235, 12]); equal(result.restored, 80);
    equal(JSON.stringify(source), before); equal(condition.nourishment, 100);
    equal(useCarriedItem(result.inventory, result.condition, 0), null);
  });
  await test('Rapidheal restores only health, preserving other carried and stored items', () => {
    const source = inventory(), result = useCarriedItem(source, condition, 1);
    equal(result.condition, { vigor: 128, rest: 90, health: 200, nourishment: 100 });
    equal(result.inventory.carried, [8, 0, 235, 12]);
    equal(result.inventory.stores, source.stores); equal(result.inventory.locker, source.locker);
  });
  await test('Every byte-range starting value clamps recovery and consumes even when full', () => {
    for (const [index, field] of [[0, 'nourishment'], [1, 'health']]) {
      for (let value = 0; value <= 255; value++) {
        const result = useCarriedItem(inventory(), { ...condition, [field]: value }, index);
        equal(result.condition[field], value <= 175 ? value + 80 : 255);
        equal(result.inventory.carried[index], 0);
        equal(result.restored, value <= 175 ? 80 : 255 - value);
      }
    }
  });
  await test('Unsupported items, bad slots and invalid condition never consume anything', () => {
    const source = inventory();
    for (const index of [-1, 4, 0.5, NaN, 2, 3]) equal(useCarriedItem(source, condition, index), null);
    for (const value of [-1, 256, 2.5, NaN]) equal(useCarriedItem(source, { ...condition, health: value }, 0), null);
    for (const byte of [0, 7, 9, 11, 12, 13, 15, 23, -1, 256]) equal(itemEffect(byte), null);
    equal(source.carried, [8, 10, 235, 12]);
  });
}
