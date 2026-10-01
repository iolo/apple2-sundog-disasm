import { escapeHTML } from './html.js';
import { exchangeSaleQuote } from '../core/campaign-exchange.js';

export function exchangePanel({state,content,name,tab='offers',draft=null,message='',t}) {
  const e=state.economy.exchange,account=state.economy.accounts.find(a=>a.systemId===state.start.playerLocation.systemId);
  const label=c=>t(`cargo${c.commodityId.slice(6)}`),quality=c=>String.fromCharCode(72-c.quality);
  const rows=tab==='offers' ? e.visit.offers : e.warehouse.slots;
  const price=(c,i)=>tab==='offers' ? c.price : exchangeSaleQuote(state,content,i);
  const selected=draft&&(draft.type==='buy'?e.visit.offers[draft.slot]:e.warehouse.slots[draft.slot]);
  const amount=selected ? draft.type==='buy'?selected.price:exchangeSaleQuote(state,content,draft.slot) : null;
  const disabled=!selected||amount===null||amount===0||(draft.type==='buy'&&(state.dialogue.cash+account.balance<=amount||!e.warehouse.slots.includes(null)));
  return `<div class="help-shade"><section id="service-panel" class="help bank-panel exchange-panel" role="dialog" aria-modal="true" aria-labelledby="service-title">
    <header><h2 id="service-title">${escapeHTML(t('exchangeTitle',{name}))}</h2><button id="service-language" data-walk="language">${t('language')}</button></header>
    <p id="exchange-funds">${t('exchangeFunds',{cash:state.dialogue.cash,balance:account.balance,used:e.warehouse.slots.filter(Boolean).length})}</p>
    ${draft ? `<div class="exchange-review"><h3>${t(draft.type==='buy'?'exchangeBuy':'exchangeSell')}</h3><p>${escapeHTML(label(selected))} · ${t('exchangeQuality',{quality:quality(selected)})}</p><p id="exchange-price">${t('exchangePrice',{price:amount??'—'})}</p><p>${t(draft.type==='buy'?'exchangeBuyHint':'exchangeSellHint')}</p></div>` : `
    <nav class="exchange-tabs" aria-label="${t('exchangeTitle',{name})}"><button id="exchange-offers" data-exchange-tab="offers" aria-pressed="${tab==='offers'}">${t('exchangeOffers')}</button><button id="exchange-warehouse" data-exchange-tab="warehouse" aria-pressed="${tab==='warehouse'}">${t('exchangeWarehouse')}</button></nav>
    <div class="exchange-columns"><span>${t('exchangeCommodity')}</span><span>${t('exchangeGrade')}</span><span>${t('exchangeCredits')}</span></div>
    <div class="exchange-list">${rows.map((c,i)=>`<button id="exchange-row-${i}" data-exchange-slot="${i}" ${!c||price(c,i)===null?'disabled':''}><span>${c?escapeHTML(label(c)):t('exchangeEmpty')}</span><small>${c?quality(c):'—'}</small><strong>${c?(price(c,i)??t('exchangeNotForSale')):'—'}</strong></button>`).join('')}</div>`}
    <p id="exchange-message" role="status">${t(message||(draft?.type==='buy'&&!e.warehouse.slots.includes(null)?'exchangeFull':draft?.type==='buy'&&state.dialogue.cash+account.balance<=amount?'exchangeInsufficient':draft?'exchangeConfirmHint':'exchangeVisitHint'))}</p>
    <footer>${draft?`<button id="exchange-cancel" data-exchange-action="cancel">${t('bankCancel')}</button><button id="exchange-confirm" data-exchange-action="confirm" ${disabled?'disabled':''}>${t('bankConfirm')}</button>`:`<button id="service-leave" data-walk="leave-service">${t('leaveService')}</button>`}<button id="service-saves" data-walk="checkpoints">${t('shipSaves')}</button></footer>
  </section></div>`;
}
