import { campaignLocation } from '../core/regional-world.js';
import { campaignDepotOffers, campaignDepotQuote } from '../core/campaign-depot.js';
import { escapeHTML } from './html.js';

export function depotPanel({state,content,geometry,name,draft=null,message='',t}) {
  const offers=campaignDepotOffers(state,content,geometry),account=state.economy.accounts.find(a=>a.systemId===campaignLocation(state,content).systemId);
  const offer=draft&&offers.find(o=>o.type===draft.type);
  let quote=null;
  if(draft)try {quote=campaignDepotQuote(state,content,geometry,draft.type,draft.units)}catch {}
  return `<div class="help-shade"><section id="service-panel" class="help bank-panel depot-panel" role="dialog" aria-modal="true" aria-labelledby="service-title">
    <header><h2 id="service-title">${escapeHTML(t('depotTitle',{name}))}</h2><button id="service-language" data-walk="language">${t('language')}</button></header>
    <p id="depot-resources">${t('depotResources',{hull:state.resources.hull,fuel:state.resources.fuel,slots:state.pod.cargo.filter(c=>c===null).length})}</p>
    <p id="depot-funds">${t('depotFunds',{cash:state.dialogue.cash,balance:account.balance})}</p>
    ${draft?`<div class="depot-review"><h3>${t('depot'+draft.type)}</h3><p>${t('depotQuantity',{units:draft.units,price:offer.unitPrice})}</p>
      <div class="depot-quantity"><button id="depot-less" data-depot-units="-1" aria-label="${t('depotLess')}" ${draft.units<=1?'disabled':''}>-</button><button id="depot-more" data-depot-units="1" aria-label="${t('depotMore')}" ${draft.units>=offer.affordable?'disabled':''}>+</button><button id="depot-all" data-depot-units="all" ${draft.units>=offer.affordable?'disabled':''}>${t('depotAll')}</button></div>
      <p id="depot-price">${t('exchangePrice',{price:quote?.price??'—'})}</p>
      <p>${quote?t(draft.type==='refuel'?'depotFuelResult':draft.type==='repair'?'depotHullResult':'depotAuxResult',{value:quote.fuel??quote.hull??draft.units}):t(offer.reason||'depotUnavailable')}</p></div>`:
      `<div class="depot-services">${offers.map(o=>`<button id="depot-${o.type}" data-depot-service="${o.type}" ${o.reason?'disabled':''}><span>${t('depot'+o.type)}</span><strong>${t('depotUnitPrice',{price:o.unitPrice})}</strong><small>${t(o.reason||'depotAvailable',{value:o.maximum})}</small></button>`).join('')}</div>`}
    <p id="depot-message" role="status">${t(message||'depotPaymentHint')}</p>
    <footer>${draft?`<button id="depot-cancel" data-depot-action="cancel">${t('bankCancel')}</button><button id="depot-confirm" data-depot-action="confirm" ${quote?'':'disabled'}>${t('bankConfirm')}</button>`:`<button id="service-leave" data-walk="leave-service">${t('leaveService')}</button>`}<button id="service-saves" data-walk="checkpoints">${t('shipSaves')}</button></footer>
  </section></div>`;
}
