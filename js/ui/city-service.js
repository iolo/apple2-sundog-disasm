import { escapeHTML } from './html.js';

// Read-only visits: financial/resource actions require the later active economy.
// Titles follow Game19 proc15/25 and Game20 proc31. No walking layout exists.
export function cityServicePanel({service,name,t}) {
  return `<div class="help-shade"><section id="service-panel" class="help bank-panel" role="dialog" aria-modal="true" aria-labelledby="service-title">
    <header><h2 id="service-title">${escapeHTML(t(`${service}Title`,{name}))}</h2><button id="service-language" data-walk="language">${t('language')}</button></header>
    <p>${t(`${service}Description`)}</p>
    <p>${t(`${service}Unavailable`)}</p>
    <footer><button id="service-leave" data-walk="leave-service">${t('leaveService')}</button><button id="service-saves" data-walk="checkpoints">${t('shipSaves')}</button></footer>
  </section></div>`;
}
