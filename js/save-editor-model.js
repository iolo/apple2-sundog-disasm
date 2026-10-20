import { CAMPAIGN_FORMAT, CAMPAIGN_LIMIT } from './core/campaign-saves.js';
import { CHECKPOINT_FORMAT, CHECKPOINT_LIMIT } from './core/checkpoints.js';
import { CONDITION_FIELDS } from './core/condition.js';
import { CAPACITY, itemType } from './core/inventory.js';

export function shipState(record) {
  return record.format === CAMPAIGN_FORMAT ? record.state.ship : record.state;
}

export function editingRestriction(record) {
  const state = record.state;
  if (state.combat?.ground || state.encounters?.counter?.conversation || state.space?.communication?.conversation) {
    return 'This save has an unfinished encounter or conversation. Finish it in the game and save again before editing.';
  }
  return '';
}

// Keep all edits outside the game. Its codecs remain the authority for imports.
export function createSaveEditor(campaignCodec, checkpointCodec) {
  function codecFor(record) {
    if (record?.format === CAMPAIGN_FORMAT) return campaignCodec;
    if (record?.format === CHECKPOINT_FORMAT) return checkpointCodec;
    throw Error('Choose a campaign or ship checkpoint JSON file. Character drafts are not supported.');
  }
  function parse(text) {
    if (typeof text !== 'string' || text.length > CAMPAIGN_LIMIT) throw Error('The save file is too large.');
    let record;
    try { record = JSON.parse(text); } catch { throw Error('This file is not valid JSON.'); }
    return codecFor(record).parse(text);
  }
  function apply(record, { condition, inventory }) {
    const restriction = editingRestriction(record);
    if (restriction) throw Error(restriction);
    const next = structuredClone(record), ship = shipState(next);
    for (const key of CONDITION_FIELDS) {
      const value = condition[key];
      if (!Number.isInteger(value) || value < 0 || value > 255) throw Error('Condition values must be whole numbers from 0 to 255.');
      ship.condition[key] = value;
    }
    for (const [container, size] of Object.entries(CAPACITY)) {
      const items = inventory[container];
      if (!Array.isArray(items) || items.length !== size || Array.from(items).some(byte =>
        !Number.isInteger(byte) || byte < 0 || byte > 255 || (byte !== 0 && itemType(byte) < 7))) {
        throw Error('Each inventory slot must contain a valid item.');
      }
      ship.inventory[container] = [...items];
    }
    if (next.format === CAMPAIGN_FORMAT) {
      if (next.state.combat.defeat && ship.condition.vigor > 0) {
        next.state.combat.defeat = null;
        // A terminal tactical view has no live controller to resume.
        if (!next.state.space.defeat && next.state.space.view === 'tactical') next.state.space.view = 'ship';
      } else if (!next.state.combat.defeat && ship.condition.vigor === 0) {
        throw Error('Set vigor above 0 to keep the character alive.');
      }
      if (ship.condition.rest > 128) next.state.space.activity.forced = false;
    }
    next.savedAt = new Date().toISOString();
    return codecFor(next).validate(next);
  }
  function serialize(record) {
    const valid = codecFor(record).validate(record), text = JSON.stringify(valid, null, 2);
    const limit = valid.format === CAMPAIGN_FORMAT ? CAMPAIGN_LIMIT : CHECKPOINT_LIMIT;
    // Large saves can exceed the import limit when pretty-printed.
    const output = text.length <= limit ? text : JSON.stringify(valid);
    codecFor(valid).parse(output);
    return output;
  }
  return { parse, apply, serialize };
}
