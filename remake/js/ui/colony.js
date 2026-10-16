import { colonyDemand } from '../core/colony.js';
import { escapeHTML } from './html.js';

export function colonyPanel({state,content,draft=null,message='',t}) {
  const colony=state.colony,finished=colony.activePhase===10,driving=state.pod.occupied;
  const demand=colonyDemand(colony,content);
  const name=lot=>lot?`${t(`cargo${lot.commodityId.slice(6)}`)} · ${t('exchangeQuality',{quality:String.fromCharCode(72-lot.quality)})}`:t('exchangeEmpty');
  const rows=(lots,container)=>lots.map((lot,i)=>{
    const needed=lot&&demand[Number(lot.commodityId.slice(6))-1]>0;
    return `<div class="colony-lot"><span>${i+1}. ${escapeHTML(name(lot))}</span>${driving&&lot&&!finished?`<button data-colony-container="${container}" data-colony-slot="${i}" data-colony-action="deliver" ${needed?'':'disabled'}>${t('colonyDeliver')}</button>${container==='pod'?`<button data-colony-container="pod" data-colony-slot="${i}" data-colony-action="store" ${colony.warehouse.includes(null)?'':'disabled'}>${t('cargoStore')}</button>`:`<button data-colony-container="warehouse" data-colony-slot="${i}" data-colony-action="fetch" ${state.pod.cargo.includes(null)?'':'disabled'}>${t('cargoFetch')}</button>`}`:''}</div>`;
  }).join('');
  const selected=draft&&(draft.container==='pod'?state.pod.cargo:colony.warehouse)[draft.slot];
  const requirements=finished?`<p id="colony-ending">${t('colonyEnding')}</p><p id="colony-ending-summary">${t('colonyEndingSummary',{receipts:colony.receipts.length})}</p>`:
    `<p id="colony-phase">${t('colonyPhase',{phase:colony.activePhase,remaining:10-colony.activePhase})}</p>
    <div id="colony-requirements" class="exchange-list">${demand.map((n,i)=>n>0?`<div><span>${escapeHTML(t(`cargo${String(i+1).padStart(2,'0')}`))}</span><strong>${n}</strong></div>`:'').join('')||`<p>${t('colonyReady')}</p>`}</div>`;
  return `<div class="help-shade"><section id="service-panel" class="help bank-panel exchange-panel ${finished?'colony-finished':'colony-active'}" role="dialog" aria-modal="true" aria-labelledby="service-title">
    <header><h2 id="service-title">${escapeHTML(t('colonyTitle'))}</h2><button id="service-language" data-walk="language">${t('language')}</button></header>
    ${requirements}
    ${finished?'':`<p>${t(driving?'colonyPodHint':'colonyFootHint')}</p>`}
    ${driving&&!finished?`<div class="cargo-columns"><section><h3>${t('cargoPod')}</h3><div class="exchange-list">${rows(state.pod.cargo,'pod')}</div></section><section><h3>${t('exchangeWarehouse')}</h3><div class="exchange-list">${rows(colony.warehouse,'warehouse')}</div></section></div>`:''}
    ${draft?`<p class="exchange-review">${t(`colony${draft.type[0].toUpperCase()+draft.type.slice(1)}Review`,{item:escapeHTML(name(selected))})}</p>`:''}
    <p id="colony-message" role="status">${t(finished?'colonyEndingSaveHint':message||'colonyVisitHint')}</p>
    <footer>${draft?`<button id="colony-cancel" data-colony-confirm="cancel">${t('bankCancel')}</button><button id="colony-confirm" data-colony-confirm="confirm">${t('bankConfirm')}</button>`:`<button id="service-leave" data-walk="leave-service">${t('leaveService')}</button>`}<button id="service-saves" data-walk="checkpoints">${t('shipSaves')}</button></footer>
  </section></div>`;
}
