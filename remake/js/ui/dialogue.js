import { escapeHTML } from './html.js';
import { itemLabel } from './inventory.js';
import { roomDialogueInputAllowed } from '../core/room-counter.js';
import { dialoguePurchase, dialogueSale } from '../core/dialogue-runner.js';

export function dialogueMessage(frame,t,locale) {
  if(locale==='en')return frame.view.text;
  return t(`dialogueMessage${frame.block}_${frame.view.word}`,{
    item:t(`item${frame.state.locals[41]&31}`),price:frame.state.locals[108].replace(/ Cr$/,'')||frame.state.locals[106],
    place:frame.view.chosenPlaces?.[0]??''});
}

export function dialoguePanel({frame,assets,t,locale,message='',encounter=false}) {
  const v=frame.state.locals;
  encounter ||= [15,16,18,19].includes(frame.state.kind);
  const visitor=[17,21,22].includes(frame.state.kind),bartender=frame.state.kind===12;
  const scope=encounter ? 'encounterDialogueScope' : visitor ? (frame.view.replies.some(r=>[2,8,9].includes(r.caption)) ? 'tavernTradeScope' : '') :
    bartender ? 'tavernCounterScope' : frame.state.kind===23 ? 'lodgingScope' : 'dialogueScope';
  const choices=frame.view.replies.map(reply=>`<button id="dialogue-reply-${reply.slot}" data-dialogue-reply="${reply.slot}" ${!roomDialogueInputAllowed(frame,{type:'reply',slot:reply.slot}) ? 'disabled' : ''}>${escapeHTML(t(`dialogueReply${reply.caption}`))}</button>`).join('');
  const purchase=dialoguePurchase(assets.campaignContent.dialogue,frame);
  const sale=dialogueSale(assets.campaignContent.dialogue,frame);
  const selling=sale ? `<div id="dialogue-sale"><p>${escapeHTML(t('dialogueSalePrice',{item:itemLabel(sale.item,t),price:sale.price,cash:sale.cash}))}</p><div class="dialogue-choices">${frame.state.carried.map((item,slot)=>`<button data-dialogue-sale="${slot}" ${!item||(item&31)!==(sale.item&31)||sale.cash+sale.price>32767999 ? 'disabled' : ''}>${escapeHTML(t('dialoguePurchaseSlot',{slot:slot+1,item:item ? itemLabel(item,t) : t('dialogueEmptySlot')}))}</button>`).join('')}</div><p role="status">${t(sale.cash+sale.price>32767999 ? 'dialogueCashOverflow' : 'dialogueSaleConfirm')}</p></div>` : '';
  const slots=purchase ? `<div id="dialogue-purchase"><p>${escapeHTML(t('dialoguePurchasePrice',{item:itemLabel(purchase.item,t),price:purchase.price,cash:purchase.cash}))}</p><div class="dialogue-choices">${frame.state.carried.map((item,slot)=>`<button data-dialogue-purchase="${slot}" ${item!==0||purchase.cash<purchase.price ? 'disabled' : ''}>${escapeHTML(t('dialoguePurchaseSlot',{slot:slot+1,item:item ? itemLabel(item,t) : t('dialogueEmptySlot')}))}</button>`).join('')}</div><p role="status">${t(purchase.cash<purchase.price ? 'dialogueInsufficientCash' : frame.state.carried.every(Boolean) ? 'dialogueSlotOccupied' : 'dialoguePurchaseConfirm')}</p></div>` : '';
  const offers=frame.offerControls ? `<div class="dialogue-choices" role="group" aria-label="${t('dialogueOffer')}"><span>${t('dialogueOfferAmount',{amount:v[100]})}</span>${[-10,-1,1,10].map(n=>`<button data-dialogue-offer="${n>0 ? 'increase' : 'decrease'}" data-step="${Math.abs(n)}">${n>0 ? '+' : '−'}${Math.abs(n)}</button>`).join('')}</div>` : '';
  const items=v[19]&&frame.panel?.items ? frame.panel.items.filter(item=>item>7).map((item,index)=>{
    const path=assets.catalog.itemImages[item&31];
    return `<button id="dialogue-item-${index}" data-dialogue-item="${item}" class="dialogue-item" ${roomDialogueInputAllowed(frame,{type:'item',item}) ? '' : 'disabled'}>${path ? `<img src="${path}" alt="" draggable="false">` : ''}<span>${escapeHTML(itemLabel(item,t))}</span></button>`;
  }).join('') : '';
  return `<div class="help-shade"><section id="dialogue-panel" class="help dialogue-panel" role="dialog" aria-modal="true" aria-labelledby="dialogue-title">
    <header><h2 id="dialogue-title">${t(encounter ? 'encounterDialogueTitle' : visitor ? 'tavernConversationTitle' : bartender ? 'tavernCounterTitle' : 'dialogueTitle')}</h2><button id="dialogue-language" data-walk="language">${t('language')}</button></header>
    <p id="dialogue-text" role="status">${escapeHTML(dialogueMessage(frame,t,locale))}</p>
    ${items ? `<div class="dialogue-items">${items}</div>` : ''}${slots}${selling}${offers}<div class="dialogue-choices">${choices}</div>
    ${message||scope ? `<p class="dialogue-note">${t(message||scope)}</p>` : ''}
    <footer><button id="dialogue-cancel" data-dialogue="cancel">${t('dialogueBack')}</button><button id="dialogue-continue" data-dialogue="timeout">${t('dialogueContinue')}</button><button id="dialogue-saves" data-walk="checkpoints">${t('shipSaves')}</button></footer>
  </section></div>`;
}
