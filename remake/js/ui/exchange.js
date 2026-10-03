import { escapeHTML } from './html.js';
import { exchangeSaleQuote } from '../core/campaign-exchange.js';

export function exchangePanel({state,content,name,tab='offers',draft=null,message='',t}) {
  if(tab==='cargo'&&state.pod.occupied)return cargoPanel({state,name,draft,message,t});
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
    <nav class="exchange-tabs" aria-label="${t('exchangeTitle',{name})}"><button id="exchange-offers" data-exchange-tab="offers" aria-pressed="${tab==='offers'}">${t('exchangeOffers')}</button><button id="exchange-warehouse" data-exchange-tab="warehouse" aria-pressed="${tab==='warehouse'}">${t('exchangeWarehouse')}</button>${state.pod.occupied?`<button id="exchange-cargo" data-exchange-tab="cargo">${t('cargoLoading')}</button>`:''}</nav>
    <div class="exchange-columns"><span>${t('exchangeCommodity')}</span><span>${t('exchangeGrade')}</span><span>${t('exchangeCredits')}</span></div>
    <div class="exchange-list">${rows.map((c,i)=>`<button id="exchange-row-${i}" data-exchange-slot="${i}" ${!c||price(c,i)===null?'disabled':''}><span>${c?escapeHTML(label(c)):t('exchangeEmpty')}</span><small>${c?quality(c):'—'}</small><strong>${c?(price(c,i)??t('exchangeNotForSale')):'—'}</strong></button>`).join('')}</div>`}
    <p id="exchange-message" role="status">${t(message||(draft?.type==='buy'&&!e.warehouse.slots.includes(null)?'exchangeFull':draft?.type==='buy'&&state.dialogue.cash+account.balance<=amount?'exchangeInsufficient':draft?'exchangeConfirmHint':'exchangeVisitHint'))}</p>
    <footer>${draft?`<button id="exchange-cancel" data-exchange-action="cancel">${t('bankCancel')}</button><button id="exchange-confirm" data-exchange-action="confirm" ${disabled?'disabled':''}>${t('bankConfirm')}</button>`:`<button id="service-leave" data-walk="leave-service">${t('leaveService')}</button>`}<button id="service-saves" data-walk="checkpoints">${t('shipSaves')}</button></footer>
  </section></div>`;
}

function cargoPanel({state,name,draft,message,t}) {
  const warehouse=state.economy.exchange.warehouse.slots,pod=state.pod.cargo;
  const label=c=>c?`${t(`cargo${c.commodityId.slice(6)}`)} · ${t('exchangeQuality',{quality:String.fromCharCode(72-c.quality)})}`:t('exchangeEmpty');
  const swapping=draft?.type==='swap';
  const valid=draft&&(swapping?pod[draft.podSlot]&&warehouse[draft.warehouseSlot]:
    draft.type==='fetch'?warehouse[draft.slot]&&pod.includes(null):pod[draft.slot]&&warehouse.includes(null));
  const reason=draft?.type==='fetch'&&!pod.includes(null)?'cargoPodFull':draft?.type==='store'&&!warehouse.includes(null)?'cargoWarehouseFull':swapping?'cargoSwapHint':draft?'exchangeConfirmHint':'cargoLoadingHint';
  const rows=(slots,container)=>slots.map((c,i)=>`<button id="cargo-${container}-${i}" data-cargo-container="${container}" data-cargo-slot="${i}" ${!c?'disabled':''} aria-pressed="${swapping?draft[`${container}Slot`]===i:draft?.type===(container==='pod'?'store':'fetch')&&draft.slot===i}"><span>${i+1}. ${escapeHTML(label(c))}</span><small>${t(container==='pod'?'cargoStore':'cargoFetch')}</small></button>`).join('');
  return `<div class="help-shade"><section id="service-panel" class="help bank-panel exchange-panel" role="dialog" aria-modal="true" aria-labelledby="service-title">
    <header><h2 id="service-title">${escapeHTML(t('exchangeTitle',{name}))}</h2><button id="service-language" data-walk="language">${t('language')}</button></header>
    <nav class="exchange-tabs"><button id="exchange-offers" data-exchange-tab="offers">${t('exchangeOffers')}</button><button id="exchange-warehouse" data-exchange-tab="warehouse">${t('exchangeWarehouse')}</button><button id="cargo-swap" data-cargo-mode="swap" aria-pressed="${swapping}">${t('cargoSwap')}</button></nav>
    <div class="cargo-columns"><section><h3>${t('cargoPod')}</h3><div class="exchange-list">${rows(pod,'pod')}</div></section>
    <section><h3>${t('exchangeWarehouse')}</h3><div class="exchange-list">${rows(warehouse,'warehouse')}</div></section></div>
    <p id="exchange-message" role="status">${t(message||reason)}</p>
    <footer>${draft?`<button id="exchange-cancel" data-exchange-action="cancel">${t('bankCancel')}</button><button id="exchange-confirm" data-exchange-action="confirm" ${valid?'':'disabled'}>${t('bankConfirm')}</button>`:`<button id="service-leave" data-walk="leave-service">${t('leaveService')}</button>`}<button id="service-saves" data-walk="checkpoints">${t('shipSaves')}</button></footer>
  </section></div>`;
}
