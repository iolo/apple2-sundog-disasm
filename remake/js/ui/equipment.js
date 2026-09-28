import { itemLabel } from './inventory.js';
import { itemType } from '../core/inventory.js';

export function equipmentPanel({ view, inventory, selected, moving, message, assets, t }) {
  const { group, index } = view;
  const rows = [...group.units.map(unit => unit.components), inventory.carried];
  const rowName = row => row === 4 ? t('carried') : t('equipmentUnit', { number: row + 1 });
  const cell = (byte, row, socket) => {
    const carried=row===4;
    const chosen = carried ? selected?.container==='carried' && selected.index===socket : selected?.container==='installed' && selected.unit===row && selected.socket===socket;
    const image = assets.catalog.itemImages[itemType(byte)];
    const label=carried ? t('inventorySlot',{container:t('carried'),number:socket+1,item:itemLabel(byte,t)}) : t('equipmentSlot', { row:rowName(row),socket:socket+1,item:itemLabel(byte,t) });
    return `<td><button id="${carried ? `equipment-carried-${socket}` : `equipment-slot-${row}-${socket}`}" class="equipment-slot" data-equipment-container="${carried ? 'carried' : 'installed'}" data-equipment-index="${socket}" data-equipment-row="${row}" data-equipment-socket="${socket}" aria-pressed="${chosen}" aria-label="${label}">${image ? `<img src="${image}" alt="" draggable="false">` : '<span aria-hidden="true">·</span>'}</button></td>`;
  };
  const row=selected?.container==='carried' ? 4 : selected?.unit;
  const socket=selected?.container==='carried' ? selected.index : selected?.socket;
  const byte=selected ? rows[row][socket] : 0;
  const detail = selected ? row===4 ? t('inventorySlot',{container:t('carried'),number:socket+1,item:itemLabel(byte,t)}) : t('equipmentDetail', {
    row: rowName(row), socket: socket + 1, item: itemLabel(byte, t),
  }) : t('equipmentSelect');
  const hint=moving ? t('equipmentDestination') : message ? t(message) : selected?.container==='installed' ?
    t('equipmentStandard',{item:itemLabel(group.spares[socket],t)}) : t('equipmentMoveHint');
  return `<section id="equipment-panel" role="dialog" aria-modal="true" aria-labelledby="equipment-title" data-group="${group.id}">
    <header class="topline"><button id="equipment-close" data-walk="close-equipment">← ${t('backShort')}</button><h2 id="equipment-title">${t('equipmentTitle')}</h2><button id="equipment-language" data-walk="language">${t('language')}</button></header>
    <div class="equipment-heading"><h3>${t(`equipment${index}`)}</h3><div class="pager"><button id="equipment-previous" data-walk="equipment-previous" aria-label="${t('equipmentPrevious')}">←</button><span>${index % 3 + 1} / 3</span><button id="equipment-next" data-walk="equipment-next" aria-label="${t('equipmentNext')}">→</button></div></div>
    <p class="equipment-rating">${t('equipmentPerformance', { value: group.performance, max: 16 })}</p>
    <table class="equipment-table"><thead><tr><th scope="col">${t('equipmentAssembly')}</th>${[1,2,3,4].map(n=>`<th scope="col">${t('equipmentSocket', { number: n })}</th>`).join('')}<th scope="col">${t('equipmentOutput')}</th></tr></thead><tbody>${rows.map((row, i)=>`<tr><th scope="row">${rowName(i)}</th>${row.map((byte,socket)=>cell(byte,i,socket)).join('')}<td>${i === 4 ? '—' : `${group.units[i].performance} / 4`}</td></tr>`).join('')}</tbody></table>
    <div class="equipment-bottom"><p id="equipment-detail">${detail}</p><p id="equipment-message" role="status">${hint}</p></div>
    <footer class="equipment-actions"><button id="equipment-move" data-walk="equipment-move" ${!byte || moving ? 'disabled' : ''}>${t('equipmentMove')}</button><button id="equipment-cancel" data-walk="equipment-cancel" ${moving ? '' : 'disabled'}>${t('cancelSelection')}</button></footer>
  </section>`;
}
