import { itemLabel } from './inventory.js';

export function equipmentPanel({ view, selected, assets, t }) {
  const { group, index } = view;
  const rows = [...group.units.map(unit => unit.components), group.spares];
  const rowName = row => row === 4 ? t('equipmentSpares') : t('equipmentUnit', { number: row + 1 });
  const cell = (byte, row, socket) => {
    const chosen = selected?.row === row && selected.socket === socket;
    const image = assets.catalog.itemImages[byte];
    return `<td><button id="equipment-slot-${row}-${socket}" class="equipment-slot" data-equipment-row="${row}" data-equipment-socket="${socket}" aria-pressed="${chosen}" aria-label="${t('equipmentSlot', { row: rowName(row), socket: socket + 1, item: itemLabel(byte, t) })}">${image ? `<img src="${image}" alt="" draggable="false">` : '<span aria-hidden="true">·</span>'}</button></td>`;
  };
  const detail = selected ? t('equipmentDetail', {
    row: rowName(selected.row), socket: selected.socket + 1,
    item: itemLabel(rows[selected.row][selected.socket], t),
  }) : t('equipmentSelect');
  return `<section id="equipment-panel" role="dialog" aria-modal="true" aria-labelledby="equipment-title" data-group="${group.id}">
    <header class="topline"><button id="equipment-close" data-walk="close-equipment">← ${t('backShort')}</button><h2 id="equipment-title">${t('equipmentTitle')}</h2><button id="equipment-language" data-walk="language">${t('language')}</button></header>
    <div class="equipment-heading"><h3>${t(`equipment${index}`)}</h3><div class="pager"><button id="equipment-previous" data-walk="equipment-previous" aria-label="${t('equipmentPrevious')}">←</button><span>${index % 3 + 1} / 3</span><button id="equipment-next" data-walk="equipment-next" aria-label="${t('equipmentNext')}">→</button></div></div>
    <p class="equipment-rating">${t('equipmentPerformance', { value: group.performance, max: 16 })}</p>
    <table class="equipment-table"><thead><tr><th scope="col">${t('equipmentAssembly')}</th>${[1,2,3,4].map(n=>`<th scope="col">${t('equipmentSocket', { number: n })}</th>`).join('')}<th scope="col">${t('equipmentOutput')}</th></tr></thead><tbody>${rows.map((row, i)=>`<tr><th scope="row">${rowName(i)}</th>${row.map((byte,socket)=>cell(byte,i,socket)).join('')}<td>${i === 4 ? '—' : `${group.units[i].performance} / 4`}</td></tr>`).join('')}</tbody></table>
    <div class="equipment-bottom"><p id="equipment-detail" role="status">${detail}</p><p>${t('equipmentReadOnly')}</p></div>
  </section>`;
}
