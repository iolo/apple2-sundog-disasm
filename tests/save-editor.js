import { loadAssets } from '../js/render/assets.js';
import { campaignSaveCodec, openCampaignStore } from '../js/core/campaign-saves.js';
import { checkpointCodec } from '../js/core/checkpoints.js';
import { createCharacter } from '../js/core/character.js';
import { createSaveEditor, shipState, editingRestriction } from '../js/save-editor-model.js';

export async function saveEditorTests(test, equal) {
  // Asset URLs are relative to the document, whereas the normal suite is in /tests/.
  const base = document.createElement('base'); base.href = new URL('../', location.href).href;
  document.head.prepend(base);
  let assets;
  try { assets = await loadAssets(); } finally { base.remove(); }
  const campaign = campaignSaveCodec(assets.campaignContent, assets.shipWalk, assets.cityGeometry);
  const checkpoint = checkpointCodec(assets.shipWalk), editor = createSaveEditor(campaign, checkpoint);
  const fresh = () => campaign.make(campaign.create({ ...createCharacter(), name: 'Rescue pilot' }, 12345), 0);
  const full = { vigor: 255, rest: 255, health: 255, nourishment: 255 };
  const reject = (action, message) => {
    let error; try { action(); } catch (caught) { error = caught.message; }
    equal(message ? error === message : !!error, true);
  };

  await test('save editor revives starvation saves without changing campaign progress or its input', () => {
    const record = fresh();
    record.state.ship.condition = { vigor: 0, rest: 10, health: 20, nourishment: 0 };
    record.state.combat.defeat = { reason: 'conditionDeath', minutes: record.state.ship.minutes };
    const original = structuredClone(record), opened = editor.parse(JSON.stringify(record));
    const edited = editor.apply(opened, { condition: full, inventory: opened.state.ship.inventory });
    equal(edited.state.ship.condition, full); equal(edited.state.combat.defeat, null);
    equal(editor.parse(editor.serialize(edited)), edited); equal(record, original);
    const expected = structuredClone(original);
    expected.state.ship.condition = full; expected.state.combat.defeat = null; expected.savedAt = edited.savedAt;
    equal(edited, expected);
  });
  await test('save editor preserves charged and unusual saved item bytes across a no-op round trip', () => {
    const record = fresh(); record.state.ship.inventory.carried = [43, 237, 72, 14];
    const opened = editor.parse(JSON.stringify(record));
    const edited = editor.apply(opened, shipState(opened));
    equal(edited.state.ship.inventory, record.state.ship.inventory);
    const changed = structuredClone(shipState(opened));
    changed.inventory.carried = [8, 8, 10, 235]; changed.inventory.locker[19] = 237; changed.inventory.stores[19] = 8;
    const output = editor.parse(editor.serialize(editor.apply(opened, changed)));
    equal(output.state.ship.inventory, changed.inventory);
  });
  await test('save editor revives terminal tactical views and clears forced rest after recovery', () => {
    const record = fresh(); record.state.ship.condition.vigor = 0;
    record.state.combat.defeat = { reason: 'conditionDeath', minutes: record.state.ship.minutes };
    record.state.space.view = 'tactical';
    const edited = editor.apply(editor.parse(JSON.stringify(record)), { condition: full, inventory: record.state.ship.inventory });
    equal(edited.state.space.view, 'ship'); equal(edited.state.combat.defeat, null);
    const sleeping = fresh(); sleeping.state.ship.condition.rest = 10;
    sleeping.state.space.activity = { sleeping: true, forced: true, sleepPhase: 0 };
    const awake = editor.apply(editor.parse(JSON.stringify(sleeping)), { condition: full, inventory: sleeping.state.ship.inventory });
    equal(awake.state.space.activity.forced, false);
  });
  await test('save editor rejects malformed files, invalid condition and inventory without changing the source', () => {
    const record = fresh(), original = structuredClone(record);
    reject(() => editor.parse('{'));
    reject(() => editor.parse(JSON.stringify({ format: 'sundog-character' })));
    reject(() => editor.parse(' '.repeat(262145)));
    for (const value of [-1, 256, 1.5, NaN]) reject(() => editor.apply(record, { condition: { ...full, health: value }, inventory: record.state.ship.inventory }));
    const bad = structuredClone(record.state.ship.inventory); bad.carried[0] = 1;
    reject(() => editor.apply(record, { condition: full, inventory: bad }));
    reject(() => editor.apply(record, { condition: { ...full, vigor: 0 }, inventory: record.state.ship.inventory }));
    equal(record, original);
  });
  await test('save editor refuses frozen encounters and conversations instead of invalidating replay', () => {
    for (const mutate of [s => { s.combat.ground = {}; }, s => { s.encounters.counter = { conversation: {} }; }, s => { s.space.communication.conversation = {}; }]) {
      const record = fresh(); mutate(record.state);
      equal(!!editingRestriction(record), true);
      reject(() => editor.apply(record, { condition: full, inventory: record.state.ship.inventory }), editingRestriction(record));
    }
  });
  await test('save editor supports walkthrough imports and enforces living checkpoint conditions', () => {
    const record = checkpoint.make(fresh().state.ship, 2);
    const changed = editor.apply(editor.parse(JSON.stringify(record)), { condition: full, inventory: record.state.inventory });
    equal(checkpoint.parse(editor.serialize(changed)).state.condition, full);
    reject(() => editor.apply(record, { condition: { ...full, rest: 0 }, inventory: record.state.inventory }));
  });
  await test('save editor uses the original browser record for stale-slot protection', async () => {
    const name = `sundog-editor-test-${crypto.randomUUID()}`, store = await openCampaignStore(campaign, name);
    try {
      const record = fresh(); await store.save(record);
      const other = structuredClone(record); other.state.ship.inventory.carried[0] = 8;
      await store.save(other, record);
      const edited = editor.apply(record, { condition: full, inventory: record.state.ship.inventory });
      let message; try { await store.save(edited, record); } catch (error) { message = error.message; }
      equal(message, 'campaignChanged'); equal(await store.list(), [other]);
      await store.save(edited, other); equal(await store.list(), [edited]);
    } finally { store.close(); indexedDB.deleteDatabase(name); }
  });
}
