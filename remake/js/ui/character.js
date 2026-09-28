import { ATTRIBUTES, createCharacter, adjustAttribute, increaseCost, minimum, pointsLeft, validateCharacter } from '../core/character.js';
import { openDraftStore, makeDraft, validateDraft, parseDraft } from '../core/drafts.js';

const escape = value => String(value).replace(/[&<>"']/g, c => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' })[c]);

export function characterScreen({ stage, background, t, language, close, start }) {
  const root = document.createElement('section');
  root.id = 'character-screen'; root.hidden = true;
  stage.append(root);
  let character = createCharacter(), tab = 'character', slots = [], store, busy = false, message = '', open = false;
  let seed='';
  const showError = error => { message = ['invalidName', 'invalidDraft', 'duplicateName','invalidSeed','campaignCreateFailed'].includes(error.message) ? error.message : 'storageUnavailable'; };
  function render() {
    if (!open) return;
    const focus = document.activeElement?.id;
    const left = pointsLeft(character);
    root.innerHTML = `<header class="topline"><button id="character-back" data-do="close">← ${t('backShort')}</button><h1>${t('characterTitle')}</h1><button id="character-language" data-do="language">${t('language')}</button></header>
      <p class="draft-note">${t('draftNote')}</p>
      ${tab === 'character' ? `<div class="character-form"><label for="character-name">${t('characterName')}</label><input id="character-name" type="text" autocomplete="off" spellcheck="false" aria-describedby="name-hint" value="${escape(character.name)}"><span id="name-hint">${t('nameHint')}</span>
      <div class="attributes">${ATTRIBUTES.map(key => {
        const value = character.attributes[key];
        return `<div class="attribute-row"><span>${t(key)}</span><span class="attribute-cost">${t('pointCost', { cost: increaseCost(value + 1) })}</span><button id="minus-${key}" data-do="adjust" data-key="${key}" data-delta="-1" aria-label="${t('decrease', { attribute: t(key) })}" ${value === minimum(key) ? 'disabled' : ''}>−</button><output id="value-${key}">${value}</output><button id="plus-${key}" data-do="adjust" data-key="${key}" data-delta="1" aria-label="${t('increase', { attribute: t(key) })}" ${increaseCost(value + 1) > left ? 'disabled' : ''}>+</button></div>`;
      }).join('')}</div><p id="points-left">${t('pointsLeft', { points: left })}</p></div>
      <div class="draft-actions"><button id="reset-character" data-do="reset">${t('resetCharacter')}</button><button id="show-drafts" data-do="drafts">${t('draftSlots')}</button><button id="prepare-campaign" class="primary" data-do="prepare">${t('boardShip')} →</button></div>`
        : tab === 'launch' ? `<div class="launch-form enter"><h2>${escape(character.name)}</h2><p>${t('campaignLaunchScope')}</p><label for="campaign-seed">${t('campaignSeed')}</label><input id="campaign-seed" inputmode="numeric" type="text" maxlength="10" value="${escape(seed)}" aria-describedby="seed-hint"><p id="seed-hint">${t('campaignSeedHint')}</p><p>${t('campaignSaveReminder')}</p></div><div class="draft-actions"><button id="edit-character" data-do="edit">← ${t('editCharacter')}</button><button id="start-campaign" class="primary" data-do="start">${t('boardShip')} →</button></div>`
        : `<div class="draft-list">${[0, 1, 2, 3].map(slot => {
          const raw = slots.find(value => value.slot === slot);
          let draft;
          try { if (raw) draft = validateDraft(raw); } catch { /* Preserve incompatible records until explicitly replaced. */ }
          return `<div class="draft-row"><span class="slot-number">0${slot + 1}</span><span class="slot-name">${escape(draft?.character.name ?? t(raw ? 'unreadableDraft' : 'emptySlot'))}</span><button id="load-draft-${slot}" data-do="load" data-slot="${slot}" ${!draft || busy ? 'disabled' : ''}>${t('loadDraft')}</button><button id="save-draft-${slot}" data-do="save" data-slot="${slot}" ${!store || busy ? 'disabled' : ''}>${t('saveDraft')}</button></div>`;
        }).join('')}</div><div class="draft-actions"><button id="edit-character" data-do="edit">← ${t('editCharacter')}</button><button id="import-draft" data-do="import" ${busy ? 'disabled' : ''}>${t('importDraft')}</button><button id="export-draft" data-do="export">${t('exportDraft')}</button><input id="draft-file" type="file" accept="application/json,.json" hidden></div>`}
      <p id="character-message" role="status">${message ? t(message) : ''}</p>`;
    document.getElementById(focus)?.focus({ preventScroll: true });
  }
  root.addEventListener('input', event => {
    if (event.target.id === 'character-name') character = { ...character, name: event.target.value };
    if (event.target.id === 'campaign-seed') seed=event.target.value;
  });
  root.addEventListener('click', async event => {
    const button = event.target.closest('[data-do]');
    if (!button || busy) return;
    const action = button.dataset.do, slot = Number(button.dataset.slot);
    message = '';
    try {
      if (action === 'close') { api.hide(); close(); return; }
      if (action === 'language') { language(); return; }
      if (action === 'prepare') {character=validateCharacter(character);tab='launch'}
      if (action === 'start') {
        character=validateCharacter(character);
        if(pointsLeft(character)>0 && !confirm(t('unspentConfirm',{points:pointsLeft(character)})))return;
        start(character,seed);
      }
      if (action === 'adjust') character = adjustAttribute(character, button.dataset.key, Number(button.dataset.delta));
      if (action === 'reset' && confirm(t('resetConfirm'))) character = createCharacter();
      if (action === 'drafts') { tab = 'drafts'; if (store) slots = await store.list(); }
      if (action === 'edit') tab = 'character';
      if (action === 'load') {
        const draft = validateDraft(slots.find(value => value.slot === slot));
        if (confirm(t('loadConfirm'))) { character = draft.character; tab = 'character'; message = 'draftLoaded'; }
      }
      if (action === 'save') {
        const draft = makeDraft(character, slot);
        if (slots.some(value => value.slot === slot) && !confirm(t('overwriteConfirm', { slot: slot + 1 }))) return;
        busy = true; render();
        await store.save(draft); slots = await store.list(); message = 'draftSaved';
      }
      if (action === 'import') { document.querySelector('#draft-file').click(); return; }
      if (action === 'export') {
        const draft = makeDraft(character, 0);
        const url = URL.createObjectURL(new Blob([JSON.stringify(draft, null, 2) + '\n'], { type: 'application/json' }));
        const link = document.createElement('a'); link.href = url; link.download = 'sundog-character.json';
        link.click(); setTimeout(() => URL.revokeObjectURL(url), 1000); message = 'draftExported';
      }
    } catch (error) { showError(error); }
    finally { busy = false; }
    render();
    if (action === 'drafts') document.querySelector('#edit-character')?.focus();
    if (action === 'edit' || action === 'load') document.querySelector('#character-name')?.focus();
    if (action === 'prepare') document.querySelector('#campaign-seed')?.focus();
  });
  root.addEventListener('change', async event => {
    if (event.target.id !== 'draft-file') return;
    const file = event.target.files[0]; if (!file) return;
    busy = true;
    try {
      if (file.size > 8192) throw new Error('invalidDraft');
      const draft = parseDraft(await file.text());
      if (confirm(t('loadConfirm'))) { character = draft.character; tab = 'character'; message = 'draftImported'; }
    } catch (error) { showError(error); }
    finally { busy = false; render(); }
    document.querySelector('#character-name')?.focus();
  });
  const api = {
    get active() { return open; },
    async show() {
      open = true; root.hidden = false; background.inert = true; render();
      root.querySelector(tab==='character' ? '#character-name' : tab==='launch' ? '#campaign-seed' : '#edit-character')?.focus();
      if (!store) {
        try { store = await openDraftStore(); slots = await store.list(); }
        catch (error) { store?.close(); store = undefined; showError(error); }
        render();
      }
    },
    hide() { open = false; root.hidden = true; background.inert = false; },
    render,
  };
  return api;
}
