import { loadAssets } from './render/assets.js';
import { campaignSaveCodec, openCampaignStore, CAMPAIGN_FORMAT, CAMPAIGN_LIMIT } from './core/campaign-saves.js';
import { checkpointCodec, openCheckpointStore } from './core/checkpoints.js';
import { CONDITION_FIELDS } from './core/condition.js';
import { CAPACITY, itemType, itemCharge } from './core/inventory.js';
import { createSaveEditor, shipState, editingRestriction } from './save-editor-model.js';

const $ = id => document.getElementById(id);
let assets, editor, stores = {}, records = [], loaded = null, original = null, source = null, dirty = false;
let listing = 0, saving = false;

function status(message, error = false) {
  $('status').textContent = message;
  $('status').dataset.error = String(error);
}
function report(error) {
  const messages = {
    campaignChanged: 'This slot changed in another tab. Download your edits, then reopen the slot before saving.',
    checkpointChanged: 'This slot changed in another tab. Download your edits, then reopen the slot before saving.',
    campaignStorageUnavailable: 'Browser storage is unavailable. You can still open and download JSON files.',
    checkpointStorageUnavailable: 'Browser storage is unavailable. You can still open and download JSON files.',
    invalidCampaign: 'The campaign did not pass the game’s save validation. Use a supported save; if editing, finish any active encounter or sleep in the game first.',
    invalidCheckpoint: 'The checkpoint did not pass validation. Vigor and rest must be above 0.',
  };
  status(messages[error.message] || error.message, true);
}
function markDirty(value = true) {
  dirty = value;
  $('edit-state').textContent = value ? 'Unsaved edits' : 'No changes yet.';
}
function canReplace() {
  if (saving) return false;
  return !dirty || window.confirm('Discard the unsaved edits and open another save?');
}
function download(text, name) {
  const url = URL.createObjectURL(new Blob([text], { type: 'application/json' }));
  const link = document.createElement('a');
  link.href = url; link.download = name; link.click();
  setTimeout(() => URL.revokeObjectURL(url), 10000);
}
function filename(suffix) {
  return `sundog-${loaded.format === CAMPAIGN_FORMAT ? 'campaign' : 'checkpoint'}-slot-${loaded.slot + 1}-${suffix}.json`;
}
function displayDate(record) {
  const date = new Date(record.savedAt);
  return Number.isFinite(date.getTime()) ? date.toLocaleString() : 'Unknown date';
}
async function refreshSlots() {
  const generation = ++listing, type = $('save-type').value;
  $('load-slot').disabled = true;
  $('save-slot').disabled = true;
  try {
    const store = stores[type];
    if (!store) throw Error('Browser storage is unavailable. You can still open and download JSON files.');
    const list = await store.list();
    if (generation !== listing) return;
    records = list;
    $('save-slot').replaceChildren(...Array.from({ length: 4 }, (_, slot) => {
      const record = records.find(r => r.slot === slot), option = document.createElement('option');
      option.value = slot;
      option.disabled = !record;
      option.textContent = record ? `${slot + 1} · ${record.state?.start?.character?.name || 'Ship walkthrough'} · ${displayDate(record)}` : `${slot + 1} · Empty`;
      return option;
    }));
    const first = records.find(record => Number.isInteger(record.slot) && record.slot >= 0 && record.slot < 4);
    if (first) $('save-slot').value = first.slot;
    $('load-slot').disabled = !first;
    $('save-slot').disabled = !first;
    if (!loaded) status(first ? 'Choose a slot or open an exported JSON file.' : 'No saves in this browser. Open an exported JSON file, or save a game on this site first.');
  } catch (error) {
    if (generation !== listing) return;
    records = [];
    $('save-slot').replaceChildren(new Option('Unavailable', ''));
    report(error);
  }
}

function renderFields() {
  const ship = shipState(loaded), labels = assets.locales.en;
  $('record-name').textContent = loaded.state.start?.character?.name || 'Ship walkthrough';
  $('record-detail').textContent = `${source ? 'Browser' : 'JSON file'} · ${loaded.format === CAMPAIGN_FORMAT ? 'Campaign' : 'Ship checkpoint'} · Slot ${loaded.slot + 1} · ${displayDate(loaded)}`;
  $('condition-fields').replaceChildren(...CONDITION_FIELDS.map(key => {
    const label = document.createElement('label'), input = document.createElement('input');
    label.textContent = labels[key];
    input.id = `condition-${key}`; input.type = 'number'; input.min = '0'; input.max = '255'; input.step = '1'; input.required = true;
    input.value = ship.condition[key]; label.append(input); return label;
  }));
  const choices = [0, ...Array.from({ length: 25 }, (_, index) => index + 7).filter(type => labels[`item${type}`])]
    .map(type => [11, 13].includes(type) ? type + 224 : type);
  for (const container of Object.keys(CAPACITY)) {
    $(`${container}-slots`).replaceChildren(...ship.inventory[container].map((byte, index) => {
      const wrapper = document.createElement('div'), label = document.createElement('label'), caption = document.createElement('span');
      const icon = document.createElement('img'), select = document.createElement('select');
      wrapper.className = 'item-slot'; caption.className = 'item-caption';
      icon.alt = ''; caption.append(icon, document.createTextNode(`Slot ${index + 1}`)); label.append(caption);
      select.id = `item-${container}-${index}`;
      select.setAttribute('aria-label', `${container} slot ${index + 1}`);
      const options = choices.some(value => itemType(value) === itemType(byte))
        ? choices.map(value => itemType(value) === itemType(byte) ? byte : value) : [...choices, byte];
      for (const value of options) select.add(new Option(labels[`item${itemType(value)}`] || 'Unknown saved item', String(value)));
      select.value = byte; label.append(select);
      const chargeLabel = document.createElement('label'), charge = document.createElement('input');
      chargeLabel.className = 'charge-label'; chargeLabel.append('Charges (0–7)');
      charge.id = `charge-${container}-${index}`; charge.type = 'number'; charge.min = '0'; charge.max = '7'; charge.step = '1'; charge.required = true;
      charge.setAttribute('aria-label', `${container} slot ${index + 1} charges`);
      chargeLabel.append(charge); wrapper.append(label, chargeLabel);
      function updateItem() {
        const value = Number(select.value), charged = itemCharge(value);
        chargeLabel.hidden = charged === null; charge.disabled = charged === null; charge.value = charged ?? 0;
        const path = assets.catalog.itemImages[itemType(value)];
        icon.hidden = !path;
        if (path) icon.src = path;
      }
      select.addEventListener('change', updateItem); updateItem(); return wrapper;
    }));
  }
  const restriction = editingRestriction(loaded);
  $('editable').disabled = !!restriction;
  $('restriction').hidden = !restriction;
  $('restriction').textContent = restriction;
  $('download').disabled = !!restriction;
  $('save').disabled = !!restriction || !source;
  $('save').textContent = source ? `Save to slot ${loaded.slot + 1}` : 'Save to slot';
  $('save-hint').textContent = source
    ? `Replaces ${source.type === 'campaign' ? 'campaign' : 'walkthrough'} slot ${loaded.slot + 1}. Download the original for a backup. Then reload this slot through Saves in the game.`
    : 'Download the edited JSON, import it through Saves in the game, then save to a slot.';
  if (loaded.state.space?.defeat) {
    $('restriction').hidden = false;
    $('restriction').textContent = 'The ship was destroyed. Editing personal condition does not repair the ship; use an earlier save to continue.';
  }
}
function openRecord(raw, nextSource) {
  const parsed = editor.parse(JSON.stringify(raw));
  if (!canReplace()) return;
  loaded = parsed; original = structuredClone(raw); source = nextSource;
  renderFields(); markDirty(false); $('editor').hidden = false;
  status('Save opened. Changes stay here until you save or download them.');
}
function editedRecord() {
  const condition = Object.fromEntries(CONDITION_FIELDS.map(key => [key, $(`condition-${key}`).valueAsNumber]));
  const inventory = Object.fromEntries(Object.entries(CAPACITY).map(([container, size]) => [container,
    Array.from({ length: size }, (_, index) => {
      const value = Number($(`item-${container}-${index}`).value);
      if (itemCharge(value) === null) return value;
      const charge = $(`charge-${container}-${index}`).valueAsNumber;
      if (!Number.isInteger(charge) || charge < 0 || charge > 7) throw Error('Charges must be a whole number from 0 to 7.');
      return itemType(value) + charge * 32;
    }),
  ]));
  return editor.apply(loaded, { condition, inventory });
}

$('save-type').addEventListener('change', refreshSlots);
$('refresh').addEventListener('click', refreshSlots);
$('load-slot').addEventListener('click', () => {
  try {
    const raw = records.find(record => record.slot === Number($('save-slot').value));
    if (raw) openRecord(raw, { type: $('save-type').value });
  } catch (error) { report(error); }
});
$('import-file').addEventListener('change', async event => {
  const file = event.target.files[0];
  if (!file) return;
  try {
    if (file.size > CAMPAIGN_LIMIT * 4) throw Error('The save file is too large.');
    const text = await file.text();
    editor.parse(text);
    openRecord(JSON.parse(text), null);
  } catch (error) { report(error); }
  finally { event.target.value = ''; }
});
$('editor').addEventListener('input', () => markDirty());
$('restore').addEventListener('click', () => {
  for (const key of CONDITION_FIELDS) $(`condition-${key}`).value = 255;
  markDirty(); status('All four condition values set to full. Save or download to apply.');
});
$('reset').addEventListener('click', () => { if (!saving) { renderFields(); markDirty(false); status('Edits reset to the opened save.'); } });
$('original').addEventListener('click', () => download(JSON.stringify(original), filename('original')));
$('download').addEventListener('click', () => {
  if (!$('editor').reportValidity()) return;
  try {
    download(editor.serialize(editedRecord()), filename('edited'));
    status('Edited JSON downloaded. Import it through Saves in the game, then save to a slot.');
  } catch (error) { report(error); }
});
$('editor').addEventListener('submit', async event => {
  event.preventDefault();
  if (saving || !source || !$('editor').reportValidity()) return;
  const button = $('save'); button.disabled = true;
  saving = true;
  $('editable').disabled = true;
  try {
    const record = editedRecord();
    await stores[source.type].save(record, original);
    loaded = record; original = structuredClone(record);
    renderFields(); markDirty(false);
    await refreshSlots();
    status(`Saved to slot ${record.slot + 1}. Load this slot through Saves in the game to use the changes.`);
  } catch (error) { report(error); }
  finally {
    saving = false;
    $('editable').disabled = !!editingRestriction(loaded);
    button.disabled = !source || !!editingRestriction(loaded);
  }
});
window.addEventListener('beforeunload', event => { if (dirty) { event.preventDefault(); event.returnValue = ''; } });

try {
  assets = await loadAssets();
  const campaign = campaignSaveCodec(assets.campaignContent, assets.shipWalk, assets.cityGeometry), checkpoint = checkpointCodec(assets.shipWalk);
  editor = createSaveEditor(campaign, checkpoint);
  const opened = await Promise.allSettled([openCampaignStore(campaign), openCheckpointStore(checkpoint)]);
  opened.forEach((result, index) => { if (result.status === 'fulfilled') stores[index ? 'checkpoint' : 'campaign'] = result.value; });
  $('save-type').disabled = false; $('refresh').disabled = false; $('import-file').disabled = false;
  await refreshSlots();
} catch (error) { status(`Could not start the save editor. Serve this folder over HTTP and reload. ${error.message}`, true); }
