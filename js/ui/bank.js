import { escapeHTML } from './html.js';
import { bankAvailable } from '../core/banking.js';

// Game19 procedure17 displays carried cash and the current system's account.
// Cash has one owner in campaign dialogue; accounts come from active economy.
export function bankPanel({start,cash,economy,navigation,draft=null,message='',t}) {
  const id=start.playerLocation.systemId;
  const system=economy.accounts.find(system=>system.systemId===id);
  const name=navigation.systems.find(system=>system.id===id).name;
  const available=draft ? bankAvailable(cash,economy,id,draft.type) : 0;
  const operations=draft ? `<div class="bank-draft">
    ${draft.type==='transfer' ? '' : `<p id="bank-operation">${t(`bank${draft.type}`)}</p>`}
    ${draft.type==='transfer' ? `<label for="bank-destination">${t('bankDestination')}</label><select id="bank-destination">${navigation.systems.filter(s=>s.id!==id).map(s=>`<option value="${s.id}" ${s.id===draft.targetSystemId?'selected':''}>${escapeHTML(s.name)}</option>`).join('')}</select>` : ''}
    <p id="bank-amount">${t('bankAmount',{amount:draft.amount,available:available-draft.amount})}</p>
    <div class="bank-amount-buttons">${['all',100,1000,10000,50000,'clear'].map(step=>`<button id="bank-step-${step}" data-bank-step="${step}" ${typeof step==='number'&&step>available-draft.amount?'disabled':''}>${typeof step==='number' ? `+${step}` : t(step==='all'?'bankAll':'bankClear')}</button>`).join('')}</div>
  </div>` : `<div class="bank-operations">${['deposit','withdraw','transfer'].map(type=>`<button id="bank-${type}" data-bank-action="${type}" ${bankAvailable(cash,economy,id,type)===0?'disabled':''}>${t(`bank${type}`)}</button>`).join('')}</div>`;
  return `<div class="help-shade"><section id="bank-panel" class="help bank-panel" role="dialog" aria-modal="true" aria-labelledby="bank-title">
    <header><h2 id="bank-title">${escapeHTML(t('bankTitle',{name}))}</h2><button id="bank-language" data-walk="language">${t('language')}</button></header>
    <dl><div><dt>${t('bankCash')}</dt><dd id="bank-cash">${cash}</dd></div><div><dt>${t('bankBalance')}</dt><dd id="bank-balance">${system.balance}</dd></div></dl>
    ${operations}
    <p id="bank-message" role="status">${t(message||(draft?'bankReview':'bankVisitScope'))}</p>
    <footer>${draft ? `<button id="bank-cancel" data-bank-action="cancel">${t('bankCancel')}</button><button id="bank-confirm" data-bank-action="confirm" ${draft.amount===0?'disabled':''}>${t('bankConfirm')}</button>` : `<button id="bank-leave" data-walk="leave-bank">${t('leaveBank')}</button>`}<button id="bank-saves" data-walk="checkpoints">${t('shipSaves')}</button></footer>
  </section></div>`;
}
