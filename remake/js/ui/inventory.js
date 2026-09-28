import { itemType, itemCharge } from '../core/inventory.js';
import { CONDITION_FIELDS, conditionSegments, itemEffect } from '../core/condition.js';

export function itemLabel(byte, t) {
  const label = t(`item${itemType(byte)}`), charge = itemCharge(byte);
  return charge ? t('chargedItem', { item: label, charge }) : label;
}

export function inventoryPanel({ inventory, condition, storage, selected, message, assets, t }) {
  const effect = selected?.container === 'carried' ? itemEffect(inventory.carried[selected.index]) : null;
  const hint = effect ? (condition[effect.field] === 255 ? 'inventoryUseFull' : 'inventoryUseHint') : 'inventoryDestination';
  const meters = CONDITION_FIELDS.map(field => `<div class="condition-row"><span>${t(field)}</span><span class="condition-meter" role="meter" aria-label="${t(field)}" aria-valuemin="0" aria-valuemax="255" aria-valuenow="${condition[field]}" title="${t('conditionValue', { condition: t(field), value: condition[field] })}"><span style="width:${conditionSegments(condition[field]) / 32 * 100}%"></span></span></div>`).join('');
  const slots = container => inventory[container].map((byte, index) => {
    const chosen = selected?.container === container && selected.index === index;
    const path = assets.catalog.itemImages[itemType(byte)];
    return `<button id="slot-${container}-${index}" class="item-slot" data-container="${container}" data-slot="${index}" aria-pressed="${chosen}" aria-label="${t('inventorySlot', { container: t(container), number: index + 1, item: itemLabel(byte, t) })}" title="${itemLabel(byte, t)}"><small aria-hidden="true">${index + 1}</small>${path ? `<img src="${path}" alt="" draggable="false">` : '<span aria-hidden="true">·</span>'}</button>`;
  }).join('');
  return `<section id="inventory-panel" role="dialog" aria-modal="true" aria-labelledby="inventory-title">
    <header class="topline"><button id="inventory-close" data-walk="close-inventory">← ${t('backShort')}</button><h2 id="inventory-title">${t('inventoryTitle')}</h2><button id="inventory-language" data-walk="language">${t('language')}</button></header>
    <p class="inventory-note">${t('inventoryNote')}</p>
    <div class="inventory-columns"><section><h3>${t('carried')} <small>4</small></h3><div class="item-grid carried-grid">${slots('carried')}</div><div class="condition-meters" role="group" aria-label="${t('conditionTitle')}">${meters}</div></section>
    <section class="storage-column"><h3>${t(storage || 'shipStorage')}${storage ? ' <small>20</small>' : ''}</h3>${storage ? `<div class="item-grid storage-grid">${slots(storage)}</div>` : `<p class="storage-hint">${t('storageHint')}</p>`}</section></div>
    <div class="inventory-bottom"><p id="inventory-message" role="status">${selected ? t(hint, { item: itemLabel(inventory[selected.container][selected.index], t) }) : t(message || 'inventoryHint')}</p><div class="inventory-item-actions">${effect ? `<button id="inventory-use" data-walk="use-item">${t(effect.action)} <span>+80</span></button>` : ''}<button id="inventory-cancel" data-walk="cancel-item" ${selected ? '' : 'disabled'}>${t('cancelSelection')}</button></div></div>
  </section>`;
}
