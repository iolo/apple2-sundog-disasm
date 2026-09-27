import { validateCharacter } from './character.js';

export const DRAFT_FORMAT = 'sundog-character-draft';
const VERSION = 1;
export function validateDraft(value) {
  if (value?.format !== DRAFT_FORMAT || value.version !== VERSION || !Number.isInteger(value.slot) || value.slot < 0 || value.slot > 3 ||
      typeof value.savedAt !== 'string' || !Number.isFinite(Date.parse(value.savedAt))) throw new Error('invalidDraft');
  return { format: DRAFT_FORMAT, version: VERSION, slot: value.slot, savedAt: value.savedAt, character: validateCharacter(value.character) };
}
export function makeDraft(character, slot) {
  return validateDraft({ format: DRAFT_FORMAT, version: VERSION, slot, savedAt: new Date().toISOString(), character });
}
export function parseDraft(text) {
  if (typeof text !== 'string' || text.length > 8192) throw new Error('invalidDraft');
  let value;
  try { value = JSON.parse(text); } catch { throw new Error('invalidDraft'); }
  return validateDraft(value);
}

// Separate database and format: these are editable characters, never campaign saves.
export async function openDraftStore(name = 'sundog-character-drafts') {
  const db = await new Promise((resolve, reject) => {
    const request = indexedDB.open(name, VERSION);
    let blocked = false;
    request.onupgradeneeded = () => request.result.createObjectStore('drafts', { keyPath: 'slot' });
    request.onsuccess = () => { if (blocked) request.result.close(); else resolve(request.result); };
    request.onerror = () => reject(new Error('storageUnavailable'));
    request.onblocked = () => { blocked = true; reject(new Error('storageUnavailable')); };
  });
  db.onversionchange = () => db.close();
  return {
    list: () => new Promise((resolve, reject) => {
      const tx = db.transaction('drafts');
      const request = tx.objectStore('drafts').getAll();
      tx.oncomplete = () => resolve(request.result);
      tx.onabort = () => reject(new Error('storageUnavailable'));
    }),
    save: value => {
      const draft = validateDraft(value);
      return new Promise((resolve, reject) => {
        const tx = db.transaction('drafts', 'readwrite');
        const store = tx.objectStore('drafts');
        let duplicate = false;
        const request = store.getAll();
        request.onsuccess = () => {
          duplicate = request.result.some(other => other.slot !== draft.slot && other.character?.name === draft.character.name);
          if (duplicate) tx.abort(); else store.put(draft);
        };
        tx.oncomplete = () => resolve(draft);
        tx.onabort = () => reject(new Error(duplicate ? 'duplicateName' : 'storageUnavailable'));
      });
    },
    close: () => db.close(),
  };
}
