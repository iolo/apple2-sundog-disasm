import { canStand } from './ship-walk.js';
import { CAPACITY, createInventory, itemType } from './inventory.js';
import { CONDITION_FIELDS, createCondition } from './condition.js';

export const CHECKPOINT_FORMAT = 'sundog-ship-checkpoint';
export const CHECKPOINT_LIMIT = 16384;
const VERSION = 1, CONTENT = 'landed-ship-1';
const fail = () => { throw new Error('invalidCheckpoint'); };
const integer = (value, min, max) => Number.isSafeInteger(value) && value >= min && value <= max;

// Only positions connected to the actual spawn are importable. Clear pixels
// outside the ship are not valid locations. Compute once per loaded geometry.
export function checkpointCodec(geometry) {
  const reachable = new Set(), queue = [{ ...geometry.spawn }];
  for (let i = 0; i < queue.length; i++) {
    const point = queue[i], key = `${point.x},${point.y}`;
    if (reachable.has(key)) continue;
    reachable.add(key);
    for (const [dx, dy] of [[1,0],[-1,0],[0,1],[0,-1]]) {
      const next = { x:point.x + dx, y:point.y + dy };
      if (canStand(geometry, next) && !reachable.has(`${next.x},${next.y}`)) queue.push(next);
    }
  }
  function snapshot(value,{allowInactiveCondition=false}={}) {
    if (!value || !integer(value.position?.x, 0, geometry.width - 7) || !integer(value.position?.y, 7, geometry.height - 1) ||
        !reachable.has(`${value.position.x},${value.position.y}`) || !integer(value.minutes, 0, Number.MAX_SAFE_INTEGER - 1440)) fail();
    if (typeof allowInactiveCondition!=='boolean'||CONDITION_FIELDS.some(key => !integer(value.condition?.[key], 0, 255)) ||
      !allowInactiveCondition&&(value.condition.vigor === 0 || value.condition.rest === 0)) fail();
    for (const [key, size] of Object.entries(CAPACITY)) {
      const items = value.inventory?.[key];
      if (!Array.isArray(items) || items.length !== size || Array.from(items).some(byte => !integer(byte, 0, 255) || (byte !== 0 && itemType(byte) < 7))) fail();
    }
    return { position: { x:value.position.x, y:value.position.y }, inventory:createInventory(value.inventory),
      condition:createCondition(value.condition), minutes:value.minutes };
  }
  function validate(value) {
    if (value?.format !== CHECKPOINT_FORMAT || value.version !== VERSION || value.content !== CONTENT || !integer(value.slot, 0, 3) ||
        typeof value.savedAt !== 'string' || value.savedAt.length > 30 || !Number.isFinite(Date.parse(value.savedAt))) fail();
    return { format:CHECKPOINT_FORMAT, version:VERSION, content:CONTENT, slot:value.slot, savedAt:value.savedAt, state:snapshot(value.state) };
  }
  return {
    snapshot, validate,
    make: (state, slot) => validate({ format:CHECKPOINT_FORMAT, version:VERSION, content:CONTENT, slot, savedAt:new Date().toISOString(), state }),
    parse: text => {
      if (typeof text !== 'string' || text.length > CHECKPOINT_LIMIT) fail();
      let value; try { value = JSON.parse(text); } catch { fail(); }
      return validate(value);
    },
  };
}

// Independent of character drafts and the future campaign database. Compare
// the displayed record inside the write transaction to avoid stale-tab loss.
export async function openCheckpointStore(codec, name = 'sundog-ship-checkpoints') {
  const db = await new Promise((resolve, reject) => {
    const request = indexedDB.open(name, VERSION);
    let blocked = false;
    request.onupgradeneeded = () => request.result.createObjectStore('checkpoints', { keyPath:'slot' });
    request.onsuccess = () => { if (blocked) request.result.close(); else resolve(request.result); };
    request.onerror = () => reject(new Error('checkpointStorageUnavailable'));
    request.onblocked = () => { blocked = true; reject(new Error('checkpointStorageUnavailable')); };
  });
  db.onversionchange = () => db.close();
  function write(slot, value, expected) {
    if (!integer(slot, 0, 3)) fail();
    const expectedJSON = JSON.stringify(expected ?? null);
    return new Promise((resolve, reject) => {
      const tx = db.transaction('checkpoints', 'readwrite'), store = tx.objectStore('checkpoints');
      let changed = false;
      const request = store.get(slot);
      request.onsuccess = () => {
        changed = JSON.stringify(request.result ?? null) !== expectedJSON;
        if (changed) tx.abort(); else if (value) store.put(value); else store.delete(slot);
      };
      tx.oncomplete = () => resolve(value);
      tx.onabort = () => reject(new Error(changed ? 'checkpointChanged' : 'checkpointStorageUnavailable'));
    });
  }
  return {
    list: () => new Promise((resolve, reject) => {
      const tx = db.transaction('checkpoints'), request = tx.objectStore('checkpoints').getAll();
      tx.oncomplete = () => resolve(request.result);
      tx.onabort = () => reject(new Error('checkpointStorageUnavailable'));
    }),
    save: (value, expected = null) => { const valid = codec.validate(value); return write(valid.slot, valid, expected); },
    delete: (slot, expected) => write(slot, null, expected),
    close: () => db.close(),
  };
}
