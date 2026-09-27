import { createInventory, transferItem, storageAt, itemType, itemCharge } from '../js/core/inventory.js';
import { canStand, walkToward } from '../js/core/ship-walk.js';
import { itemLabel } from '../js/ui/inventory.js';
import { translator } from '../js/ui/i18n.js';

export async function inventoryTests(test, equal) {
  const initial = await fetch('../data/ship-inventory.json').then(r => r.json());
  const stores = { x: 54, y: 86 }, locker = { x: 83, y: 110 };
  const slot = (container, index) => ({ container, index });
  const contents = state => Object.values(state).flat().filter(Boolean).sort((a, b) => a - b);
  await test('Four carried slots and twenty per container match clean initialization', () => {
    const a = createInventory(initial), b = createInventory(initial);
    equal(a.carried, [0, 0, 0, 0]); equal(a.locker.length, 20); equal(a.stores.length, 20);
    equal(contents(a), [8, 8, 8, 8, 8, 10, 10, 10, 10, 10, 12, 23, 23, 23, 23, 23, 235]);
    a.stores[0] = 0; equal(b.stores[0], 10); equal(initial.stores[0], 10);
  });
  await test('Store pickup, occupied-slot swap and locker deposit conserve complete bytes', () => {
    const start = createInventory(initial);
    const picked = transferItem(start, slot('stores', 10), slot('carried', 0), stores);
    equal(picked.carried[0], 235); equal(picked.stores[10], 0); equal(start.stores[10], 235);
    const swapped = transferItem(picked, slot('stores', 5), slot('carried', 0), stores);
    equal(swapped.carried[0], 8); equal(swapped.stores[5], 235);
    const deposited = transferItem(swapped, slot('carried', 0), slot('locker', 0), locker);
    equal(deposited.locker[0], 8); equal(deposited.carried[0], 0);
    equal(contents(start), contents(deposited));
  });
  await test('Remote containers, empty sources and invalid slot references cannot mutate items', () => {
    const start = createInventory(initial);
    for (const [from, to, position] of [
      [slot('stores', 0), slot('carried', 0), { x: 54, y: 110 }],
      [slot('stores', 0), slot('locker', 0), stores],
      [slot('carried', 0), slot('stores', 0), stores],
      [slot('stores', 0), slot('stores', 0), stores],
      [slot('stores', -1), slot('carried', 0), stores],
      [slot('stores', 0), slot('carried', 4), stores],
      [slot('stores', 0.5), slot('carried', 0), stores],
      [slot('__proto__', 0), slot('carried', 0), stores],
    ]) equal(transferItem(start, from, to, position) === start, true);
  });
  await test('All occupied inventory transfers conserve slots and charges, including full pockets', () => {
    let state = createInventory(initial);
    for (let i = 0; i < 4; i++) state = transferItem(state, slot('stores', i), slot('carried', i), stores);
    const before = contents(state);
    for (const container of ['carried', 'stores']) for (let i = 0; i < state[container].length; i++) {
      for (const target of ['carried', 'stores']) for (let j = 0; j < state[target].length; j++) {
        const next = transferItem(state, slot(container, i), slot(target, j), stores);
        equal(contents(next), before); equal(next.carried.length, 4); equal(next.stores.length, 20);
      }
    }
  });
  await test('Both storage interaction regions are reachable through the original collision rule', async () => {
    const geometry = await fetch('../data/ship-walk.json').then(r => r.json());
    equal(storageAt(geometry.spawn), null);
    for (const [target, expected] of [[stores, 'stores'], [locker, 'locker']]) {
      let position = { ...geometry.spawn };
      for (let i = 0; i < 50; i++) position = walkToward(geometry, position, { x: target.x + 3, y: target.y - 3 });
      equal(position, target); equal(canStand(geometry, position), true); equal(storageAt(position), expected);
    }
  });
  await test('Item labels decode charged shields without treating upper bits as separate types', async () => {
    equal(itemType(235), 11); equal(itemCharge(235), 7); equal(itemCharge(12), null);
    const locales = Object.fromEntries(await Promise.all(['en', 'ko'].map(async lang => [lang, await fetch(`../locales/${lang}.json`).then(r => r.json())])));
    equal(itemLabel(235, translator(locales, 'en')), 'Shield (7)');
    equal(itemLabel(235, translator(locales, 'ko')), '방어막 (7)');
    for (const byte of Object.values(createInventory(initial)).flat()) for (const lang of ['en', 'ko']) equal(typeof itemLabel(byte, translator(locales, lang)), 'string');
  });
}
