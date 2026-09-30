import { escapeHTML } from './html.js';
import { itemLabel } from './inventory.js';

export function dialogueMessage(frame,t,locale) {
  if(locale==='en')return frame.view.text;
  return t(`dialogueMessage${frame.block}_${frame.view.word}`,{
    item:t(`item${frame.state.locals[41]&31}`),price:frame.state.locals[106]});
}

export function dialoguePanel({frame,assets,t,locale,message=''}) {
  const v=frame.state.locals;
  const choices=frame.view.replies.map(reply=>`<button id="dialogue-reply-${reply.slot}" data-dialogue-reply="${reply.slot}" ${[8,9].includes(reply.caption) ? 'disabled' : ''}>${escapeHTML(t(`dialogueReply${reply.caption}`))}</button>`).join('');
  const items=v[19]&&frame.panel?.items ? frame.panel.items.filter(item=>item>7).map((item,index)=>{
    const path=assets.catalog.itemImages[item&31];
    return `<button id="dialogue-item-${index}" data-dialogue-item="${item}" class="dialogue-item">${path ? `<img src="${path}" alt="" draggable="false">` : ''}<span>${escapeHTML(itemLabel(item,t))}</span></button>`;
  }).join('') : '';
  return `<div class="help-shade"><section id="dialogue-panel" class="help dialogue-panel" role="dialog" aria-modal="true" aria-labelledby="dialogue-title">
    <header><h2 id="dialogue-title">${t('dialogueTitle')}</h2><button id="dialogue-language" data-walk="language">${t('language')}</button></header>
    <p id="dialogue-text" role="status">${escapeHTML(dialogueMessage(frame,t,locale))}</p>
    ${items ? `<div class="dialogue-items">${items}</div>` : ''}<div class="dialogue-choices">${choices}</div>
    <p class="dialogue-note">${t(message||'dialogueScope')}</p>
    <footer><button id="dialogue-cancel" data-dialogue="cancel">${t('dialogueBack')}</button><button id="dialogue-continue" data-dialogue="timeout">${t('dialogueContinue')}</button><button id="dialogue-saves" data-walk="checkpoints">${t('shipSaves')}</button></footer>
  </section></div>`;
}
