import { initializationTests } from './initialization.js';
import { economyTests } from './economy.js';
import { campaignTests } from './campaign.js';
import { campaignSaveTests } from './campaign-saves.js';
import { campaignDialogueTests } from './campaign-dialogue.js';
import { campaignSeedTests } from './campaign-seed.js';
import { equipmentTests } from './equipment.js';
import { cityMapTests } from './city-map.js';
import { cityWalkTests } from './city-walk.js';
import { cityDoorTests } from './city-doors.js';
import { roomWalkTests } from './room-walk.js';
import { roomTrafficTests } from './room-traffic.js';
import { roomSeatingTests } from './room-seating.js';
import { roomCounterTests } from './room-counter.js';
import { lodgingTests } from './lodging.js';
import { dialogueTests } from './dialogue.js';
import { dialogueTextTests } from './dialogue-text.js';
import { dialogueStateTests } from './dialogue-state.js';
import { dialogueRunnerTests } from './dialogue-runner.js';
import { characterTests } from './character.js';
import { shipWalkTests } from './ship-walk.js';
import { inventoryTests } from './inventory.js';
import { conditionTests } from './condition.js';
import { survivalTests } from './survival.js';
import { checkpointTests } from './checkpoints.js';
import { createPreview, reducePreview, logicalPoint, cellAt } from '../js/core/preview.js';
import { translator } from '../js/ui/i18n.js';

const counts = { ship: 2, cities: 60, worlds: 18 };
const results = [];
function equal(a, b) { if (JSON.stringify(a) !== JSON.stringify(b)) throw new Error(`${JSON.stringify(a)} != ${JSON.stringify(b)}`); }
async function test(name, run) {
  try { await run(); results.push(`PASS ${name}`); }
  catch (e) { results.push(`FAIL ${name}: ${e.message}`); }
}
await test('Reverse navigation wraps and clears a previous selection', () => {
  let state = reducePreview(createPreview(), { type: 'view', view: 'cities' }, counts);
  state = reducePreview(state, { type: 'select', point: { x: 4, y: 2 } }, counts);
  state = reducePreview(state, { type: 'step', delta: -1 }, counts);
  equal(state.indices.cities, 59); equal(state.selection, null);
});
await test('Scene changes retain independent record indices', () => {
  let state = reducePreview(createPreview(), { type: 'view', view: 'worlds' }, counts);
  state = reducePreview(state, { type: 'step', delta: 3 }, counts);
  state = reducePreview(state, { type: 'view', view: 'ship' }, counts);
  equal(state.indices.worlds, 3); equal(state.indices.ship, 0);
});
await test('Scaled, letterboxed pointer coordinates and boundary rejection', () => {
  const rect = { left: 100, top: 50, width: 1280, height: 960 };
  equal(logicalPoint(rect, 740, 530), { x: 320, y: 240 });
  equal(logicalPoint(rect, 99, 530), null);
  equal(logicalPoint(rect, 1380, 530), null);
  equal(cellAt({ x: 20, y: 10 }, { x: 10, y: 10, width: 40, height: 20 }, 4, 2), { x: 1, y: 0 });
  equal(cellAt({ x: 50, y: 10 }, { x: 10, y: 10, width: 40, height: 20 }, 4, 2), null);
});
await test('Actions cannot mutate another preview instance', () => {
  const a = createPreview(), b = createPreview();
  const next = reducePreview(a, { type: 'step', delta: 1 }, counts);
  equal(a, b); equal(next, a); // No active scene on title.
  equal(reducePreview(a, { type: 'bank', bank: 9 }, counts), a);
});
const [en, ko] = await Promise.all(['en', 'ko'].map(lang => fetch(`../locales/${lang}.json`).then(r => r.json())));
await test('Both locales have identical keys and interpolation parameters', () => {
  equal(Object.keys(en).sort(), Object.keys(ko).sort());
  for (const key of Object.keys(en)) equal(en[key].match(/\{\w+\}/g) || [], ko[key].match(/\{\w+\}/g) || []);
  equal(translator({ en, ko }, 'ko')('point', { x: 4, y: 6 }), '위치 4, 6');
});
await test('Missing locale value falls back; unknown keys fail', () => {
  equal(translator({ en: { word: 'value' }, ko: {} }, 'ko')('word'), 'value');
  let threw = false;
  try { translator({ en: {}, ko: {} }, 'ko')('absent'); } catch { threw = true; }
  equal(threw, true);
});
await characterTests(test, equal);
await shipWalkTests(test, equal);
await inventoryTests(test, equal);
await conditionTests(test, equal);
await survivalTests(test, equal);
await checkpointTests(test, equal);
await initializationTests(test, equal);
await economyTests(test, equal);
await campaignTests(test, equal);
await campaignSaveTests(test, equal);
await campaignSeedTests(test, equal);
await equipmentTests(test, equal);
await cityMapTests(test, equal);
await cityWalkTests(test, equal);
await cityDoorTests(test, equal);
await roomWalkTests(test, equal);
await roomTrafficTests(test, equal);
await roomSeatingTests(test, equal);
await dialogueTests(test, equal);
await dialogueTextTests(test, equal);
await dialogueStateTests(test, equal);
await dialogueRunnerTests(test, equal);
await roomCounterTests(test, equal);
await campaignDialogueTests(test, equal);
await lodgingTests(test, equal);
document.querySelector('#results').textContent = results.join('\n');
document.documentElement.dataset.result = results.some(r => r.startsWith('FAIL')) ? 'fail' : 'pass';
