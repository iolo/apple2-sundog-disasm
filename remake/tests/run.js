import { regionalSaveTests } from './regional-saves.js';
import { campaignEngineeringTests } from './campaign-engineering.js';
import { shipPowerTests } from './ship-power.js';
import { shipCombatTests } from './ship-combat.js';
import { shipTacticalTests } from './ship-tactical.js';
import { campaignSpaceTests } from './campaign-space.js';
import { campaignTacticalTests } from './campaign-tactical.js';
import { groundCombatTests } from './ground-combat.js';
import { groundChaseTests } from './ground-chase.js';
import { encounterDialogueTests } from './encounter-dialogue.js';
import { groundHostTests } from './ground-host.js';
import { campaignMachineryTests } from './campaign-machinery.js';
import { equipmentFailureTests } from './equipment-failures.js';
import { campaignDepotTests } from './campaign-depot.js';
import { depotTests } from './depot.js';
import { cityPodTests } from './city-pod.js';
import { parkedPodTests } from './parked-pod.js';
import { campaignParkingTests } from './campaign-parking.js';
import { surfaceTests } from './surface.js';
import { campaignGroundTests } from './campaign-ground.js';
import { regionalWorldTests } from './regional-world.js';
import { campaignFlightTests } from './campaign-flight.js';
import { initializationTests } from './initialization.js';
import { economyTests } from './economy.js';
import { cargoTests } from './cargo.js';
import { personalTradeTests } from './personal-trade.js';
import { exchangeTests } from './exchange.js';
import { campaignExchangeTests } from './campaign-exchange.js';
import { bankingTests } from './banking.js';
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
import { tavernDialogueTests } from './tavern-dialogue.js';
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
await cargoTests(test, equal);
await personalTradeTests(test, equal);
await exchangeTests(test, equal);
await campaignExchangeTests(test, equal);
await bankingTests(test, equal);
await campaignTests(test, equal);
await campaignSaveTests(test, equal);
await campaignSeedTests(test, equal);
await equipmentTests(test, equal);
await equipmentFailureTests(test, equal);
await campaignEngineeringTests(test, equal);
await shipPowerTests(test, equal);
await shipCombatTests(test, equal);
await shipTacticalTests(test, equal);
await campaignSpaceTests(test, equal);
await campaignTacticalTests(test, equal);
await groundCombatTests(test, equal);
await groundChaseTests(test, equal);
await campaignMachineryTests(test, equal);
await depotTests(test, equal);
await campaignDepotTests(test, equal);
await cityMapTests(test, equal);
await cityWalkTests(test, equal);
await cityPodTests(test, equal);
await parkedPodTests(test, equal);
await campaignParkingTests(test, equal);
await surfaceTests(test, equal);
await campaignGroundTests(test, equal);
await regionalWorldTests(test, equal);
await campaignFlightTests(test, equal);
await cityDoorTests(test, equal);
await roomWalkTests(test, equal);
await roomTrafficTests(test, equal);
await roomSeatingTests(test, equal);
await dialogueTests(test, equal);
await dialogueTextTests(test, equal);
await dialogueStateTests(test, equal);
await dialogueRunnerTests(test, equal);
await encounterDialogueTests(test, equal);
await groundHostTests(test,equal);
await roomCounterTests(test, equal);
await campaignDialogueTests(test, equal);
await lodgingTests(test, equal);
await tavernDialogueTests(test, equal);
await regionalSaveTests(test,equal);

document.querySelector('#results').textContent = results.join('\n');
document.documentElement.dataset.result = results.some(r => r.startsWith('FAIL')) ? 'fail' : 'pass';
