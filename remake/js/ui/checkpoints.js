import { CHECKPOINT_LIMIT, openCheckpointStore } from '../core/checkpoints.js';

export function checkpointScreen({ stage, background, codec, t, language, snapshot, restore, close }) {
  const root = document.createElement('section'); root.id = 'checkpoint-screen'; root.hidden = true; root.tabIndex = -1; stage.append(root);
  let open = false, busy = false, store, slots = [], message = '';
  const current = () => { try { return snapshot(); } catch { return null; } };
  const errorMessage = error => ['invalidCheckpoint', 'checkpointChanged'].includes(error.message) ? error.message : 'checkpointStorageUnavailable';
  function render() {
    if (!open) return;
    const focus = document.activeElement?.id, canSave = !!current();
    root.innerHTML = `<header class="topline"><button id="checkpoint-back" data-checkpoint="close" ${busy ? 'disabled' : ''}>← ${t('backShort')}</button><h2 id="checkpoint-title">${t('checkpointTitle')}</h2><button id="checkpoint-language" data-checkpoint="language" ${busy ? 'disabled' : ''}>${t('language')}</button></header>
      <p class="checkpoint-note">${t('checkpointScope')}</p><div class="checkpoint-list">${[0,1,2,3].map(slot => {
        const raw = slots.find(item => item.slot === slot); let value;
        try { if (raw) value = codec.validate(raw); } catch { /* Preserve unreadable records until explicit replacement/deletion. */ }
        const summary = value ? t('checkpointSummary', { hours:Math.floor(value.state.minutes / 60), minute:String(value.state.minutes % 60).padStart(2,'0'), x:value.state.position.x, y:value.state.position.y }) : t(raw ? 'unreadableCheckpoint' : 'emptySlot');
        return `<div class="checkpoint-row"><span class="slot-number">0${slot+1}</span><span class="checkpoint-summary">${summary}</span><button id="load-checkpoint-${slot}" data-checkpoint="load" data-slot="${slot}" ${!value || busy ? 'disabled' : ''}>${t('loadDraft')}</button><button id="save-checkpoint-${slot}" data-checkpoint="save" data-slot="${slot}" ${!store || !canSave || busy ? 'disabled' : ''}>${t('saveDraft')}</button><button id="delete-checkpoint-${slot}" data-checkpoint="delete" data-slot="${slot}" aria-label="${t('deleteCheckpoint', { slot:slot+1 })}" ${!store || !raw || busy ? 'disabled' : ''}>×</button></div>`;
      }).join('')}</div><p id="checkpoint-message" role="status">${t(message || (canSave ? 'checkpointHint' : 'checkpointLoadOnly'))}</p>
      <footer class="checkpoint-actions"><button id="import-checkpoint" data-checkpoint="import" ${busy ? 'disabled' : ''}>${t('importDraft')}</button><button id="export-checkpoint" data-checkpoint="export" ${!canSave || busy ? 'disabled' : ''}>${t('exportDraft')}</button>${!store ? `<button id="retry-checkpoints" data-checkpoint="retry" ${busy ? 'disabled' : ''}>${t('checkpointRetry')}</button>` : ''}<input id="checkpoint-file" type="file" accept="application/json,.json" hidden></footer>`;
    (root.querySelector(`[id="${focus || ''}"]:not(:disabled)`) || root.querySelector('button:not(:disabled)') || root).focus({ preventScroll:true });
  }
  async function refresh() {
    if (!store) store = await openCheckpointStore(codec);
    slots = await store.list();
  }
  function hide() { if (busy) return; open = false; root.hidden = true; background.inert = false; close(); }
  async function perform(run) {
    if (busy) return;
    busy = true; render();
    try { await run(); }
    catch (error) {
      message = errorMessage(error);
      if (message === 'checkpointStorageUnavailable') { store?.close(); store = undefined; }
      if (message === 'checkpointChanged') { try { await refresh(); } catch { store?.close(); store = undefined; } }
    } finally { busy = false; render(); }
  }
  root.addEventListener('keydown', event => {
    if (event.isComposing) return;
    if (event.key === 'Escape') { event.preventDefault(); hide(); }
    if (event.key === 'Tab') {
      event.preventDefault(); const buttons = [...root.querySelectorAll('button:not(:disabled)')];
      const i = buttons.indexOf(document.activeElement);
      buttons[(i+(event.shiftKey ? -1 : 1)+buttons.length)%buttons.length]?.focus();
    }
  });
  root.addEventListener('click', event => {
    const button = event.target.closest('[data-checkpoint]'); if (!button || busy) return;
    const action = button.dataset.checkpoint, slot = Number(button.dataset.slot);
    if (action === 'close') { hide(); return; }
    if (action === 'language') { language(); return; }
    if (action === 'import') { root.querySelector('#checkpoint-file').click(); return; }
    void perform(async () => {
      const raw = slots.find(item => item.slot === slot);
      if (action === 'retry') { await refresh(); message = ''; }
      if (action === 'save') {
        const value = codec.make(snapshot(), slot);
        if (raw && !confirm(t('replaceCheckpointConfirm', { slot:slot+1 }))) return;
        await store.save(value, raw); slots = await store.list(); message = 'checkpointSaved';
      }
      if (action === 'delete') {
        if (!confirm(t('deleteCheckpointConfirm', { slot:slot+1 }))) return;
        await store.delete(slot, raw); slots = await store.list(); message = 'checkpointDeleted';
      }
      if (action === 'load') {
        if (store) {
          const fresh = await store.list();
          if (JSON.stringify(fresh.find(item => item.slot === slot) ?? null) !== JSON.stringify(raw ?? null)) {
            slots = fresh; throw new Error('checkpointChanged');
          }
        }
        const value = codec.validate(raw);
        if (confirm(t('loadCheckpointConfirm'))) { restore(value.state); message = 'checkpointLoaded'; }
      }
      if (action === 'export') {
        const value = codec.make(snapshot(), 0), url = URL.createObjectURL(new Blob([JSON.stringify(value,null,2)+'\n'], { type:'application/json' }));
        const link = document.createElement('a'); link.href = url; link.download = 'sundog-ship-checkpoint.json'; link.click();
        setTimeout(() => URL.revokeObjectURL(url), 1000); message = 'checkpointExported';
      }
    });
  });
  root.addEventListener('change', event => {
    if (event.target.id !== 'checkpoint-file') return;
    const file = event.target.files?.[0]; if (!file) return;
    void perform(async () => {
      if (file.size > CHECKPOINT_LIMIT) throw new Error('invalidCheckpoint');
      const value = codec.parse(await file.text());
      if (confirm(t('loadCheckpointConfirm'))) { restore(value.state); message = 'checkpointImported'; }
    });
  });
  return {
    get active() { return open; }, render,
    async show() {
      open = true; root.hidden = false; root.setAttribute('role','dialog'); root.setAttribute('aria-modal','true'); root.setAttribute('aria-labelledby','checkpoint-title');
      background.inert = true; message = ''; render();
      await perform(refresh);
    },
  };
}
