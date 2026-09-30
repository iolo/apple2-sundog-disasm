import { escapeHTML } from './html.js';

// Game19 procedure17 displays carried cash and the current system's account.
// Account balances retain creation values; carried cash includes lodging debits.
export function bankPanel({start,cash=start.credits,navigation,t}) {
  const id=start.playerLocation.systemId;
  const system=start.systems.find(system=>system.id===id);
  const name=navigation.systems.find(system=>system.id===id).name;
  return `<div class="help-shade"><section id="bank-panel" class="help bank-panel" role="dialog" aria-modal="true" aria-labelledby="bank-title">
    <header><h2 id="bank-title">${escapeHTML(t('bankTitle',{name}))}</h2><button id="bank-language" data-walk="language">${t('language')}</button></header>
    <p class="bank-teller">${t('bankTeller')}</p>
    <dl><div><dt>${t('bankCash')}</dt><dd id="bank-cash">${cash}</dd></div><div><dt>${t('bankBalance')}</dt><dd id="bank-balance">${system.bankBalance}</dd></div></dl>
    <p>${t('bankVisitScope')}</p>
    <footer><button id="bank-leave" data-walk="leave-bank">${t('leaveBank')}</button><button id="bank-saves" data-walk="checkpoints">${t('shipSaves')}</button></footer>
  </section></div>`;
}
