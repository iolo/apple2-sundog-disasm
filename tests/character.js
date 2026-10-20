import { createCharacter, adjustAttribute, increaseCost, pointsLeft, validateCharacter } from '../js/core/character.js';
import { makeDraft, parseDraft, openDraftStore } from '../js/core/drafts.js';

export async function characterTests(test, equal) {
  const rejects = (run, message) => {
    let error;
    try { run(); } catch (e) { error = e; }
    if (!error || (message && error.message !== message)) throw new Error(`Expected ${message || 'rejection'}`);
  };
  const named = () => ({ ...createCharacter(), name: '선독' });
  await test('Original defaults and independent marginal-cost boundaries', () => {
    equal(createCharacter().attributes, { strength: 30, intelligence: 30, dexterity: 30, charisma: 30, luck: 0 });
    equal(pointsLeft(createCharacter()), 440);
    for (const [value, cost] of [[1, 1], [30, 1], [31, 2], [50, 2], [51, 4], [70, 4], [71, 8], [90, 8], [91, 16], [100, 16], [101, 32], [110, 32]]) equal(increaseCost(value), cost);
  });
  await test('Exactly 440 points buys strength 100; another point is rejected', () => {
    let value = named();
    for (let i = 0; i < 70; i++) value = adjustAttribute(value, 'strength', 1);
    equal(value.attributes.strength, 100); equal(pointsLeft(value), 0);
    equal(adjustAttribute(value, 'strength', 1), value);
    equal(adjustAttribute(value, 'luck', 1), value);
    equal(pointsLeft(adjustAttribute(value, 'strength', -1)), 16);
  });
  await test('Luck reaches 98 for 438 points; reducing across all tiers refunds exactly', () => {
    let value = named();
    for (let i = 0; i < 98; i++) value = adjustAttribute(value, 'luck', 1);
    equal(pointsLeft(value), 2); equal(adjustAttribute(value, 'luck', 1), value);
    for (let i = 0; i < 98; i++) value = adjustAttribute(value, 'luck', -1);
    equal(value, named()); equal(pointsLeft(value), 440);
    equal(adjustAttribute(value, 'luck', -1), value);
    equal(adjustAttribute(value, 'strength', -1), value);
  });
  await test('Actions preserve the prior character and reject unknown attributes', () => {
    const original = named();
    const next = adjustAttribute(original, 'intelligence', 1);
    equal(original, named()); equal(next.attributes.intelligence, 31);
    equal(adjustAttribute(original, '__proto__', 1), original);
    equal(adjustAttribute(original, 'strength', 1.5), original);
  });
  await test('Name normalization, Korean graphemes, limits and unsafe text', () => {
    equal(validateCharacter({ ...named(), name: '  선독  ' }).name, '선독');
    equal(validateCharacter({ ...named(), name: '가'.repeat(15) }).name.length, 15);
    for (const name of ['', '   ', '가'.repeat(16), 'a\nb', 'a\u202eb']) rejects(() => validateCharacter({ ...named(), name }), 'invalidName');
    // Rendering must escape HTML; validation need not alter ordinary punctuation.
    equal(validateCharacter({ ...named(), name: '<b>선독</b>' }).name, '<b>선독</b>');
  });
  await test('Draft imports reject malformed/future/campaign/overspent data', () => {
    const valid = makeDraft(named(), 2);
    equal(parseDraft(JSON.stringify(valid)), valid);
    for (const text of ['{', 'null', 'x'.repeat(8193), JSON.stringify({ ...valid, version: 2 }), JSON.stringify({ ...valid, format: 'sundog-remake' }), JSON.stringify({ ...valid, slot: 4 }), JSON.stringify({ ...valid, savedAt: '' })]) rejects(() => parseDraft(text), 'invalidDraft');
    for (const value of [31.5, -1, 101, 1e100, null]) rejects(() => makeDraft({ ...named(), attributes: { ...named().attributes, strength: value } }, 0), 'invalidDraft');
    rejects(() => makeDraft({ ...named(), attributes: { strength: 100, intelligence: 100, dexterity: 30, charisma: 30, luck: 0 } }, 0), 'invalidDraft');
    const projected = parseDraft(JSON.stringify({ ...valid, points: 999, character: { ...valid.character, extra: '<script>' } }));
    equal(projected, valid);
  });
  await test('Four IndexedDB slots persist after reopening; duplicate write aborts atomically', async () => {
    const name = `sundog-tests-${crypto.randomUUID()}`;
    let store = await openDraftStore(name);
    try {
      for (let slot = 0; slot < 4; slot++) await store.save(makeDraft({ ...named(), name: `선독 ${slot}` }, slot));
      const before = await store.list(); store.close(); store = await openDraftStore(name);
      equal(await store.list(), before);
      let duplicate;
      try { await store.save(makeDraft({ ...named(), name: '선독 0' }, 1)); } catch (e) { duplicate = e.message; }
      equal(duplicate, 'duplicateName'); equal(await store.list(), before);
      rejects(() => store.save({ ...before[0], version: 99 }), 'invalidDraft');
      equal(await store.list(), before);
      await store.save(makeDraft({ ...named(), name: '새 이름' }, 0));
      const after = await store.list(); equal(after[0].character.name, '새 이름'); equal(after.slice(1), before.slice(1));
    } finally {
      store.close();
      await new Promise((resolve, reject) => {
        const request = indexedDB.deleteDatabase(name);
        request.onsuccess = resolve; request.onerror = reject;
      });
    }
  });
}
