import { interactionAt } from './ship-walk.js';
import { createInventory } from './inventory.js';

// Game15 procedure14 IDs8–13; game14 procedures3/7 select and cycle
// three frames per bay bank. These are inspection views of validated state.
export function equipmentBayAt(position) {
  const station = interactionAt(position);
  return station >= 8 && station <= 13 ? station - 8 : null;
}

export function inspectEquipment(equipment, position, offset = 0) {
  const bay = equipmentBayAt(position);
  if (bay === null || !Number.isInteger(offset)) return null;
  const index = Math.floor(bay / 3) * 3 + ((bay % 3 + offset) % 3 + 3) % 3;
  const group = equipment[index];
  return { index, group: structuredClone(group) };
}

// The legacy creation field `spares` is bytes20–23: immutable socket
// requirements, not inventory. Keep its serialized name for recipe2 replay.
export function fitsComponent(group, byte, socket) {
  return byte === group.spares[socket] || (byte === 23 && socket > 0) ||
    (group.requiredComponent > 0 && byte === group.requiredComponent && socket === group.requiredSocket);
}

// Library24 procedure8: shunts outside socket0 each cost one point; a wrong
// component stops that unit. A special part counts only in a working unit.
export function recalculateEquipment(group) {
  let specialAvailable = false;
  const units = group.units.map(({ components }) => {
    let performance = 4, special = false;
    for (let socket = 0; socket < 4 && performance > 0; socket++) {
      const byte = components[socket];
      if (byte === 23 && socket > 0) performance--;
      else if (socket === group.requiredSocket) {
        if (group.requiredComponent > 0 && byte === group.requiredComponent) special = true;
        else if (byte !== group.spares[socket]) performance = 0;
      } else if (byte <= 23 || byte !== group.spares[socket]) performance = 0;
    }
    if (special && performance > 0) specialAvailable = true;
    return { components:[...components], performance };
  });
  return { id:group.id, units, spares:[...group.spares],
    performance:units.reduce((sum,unit)=>sum+unit.performance,0),
    requiredComponent:group.requiredComponent, requiredSocket:group.requiredSocket, specialAvailable };
}

// Browser atomic exchange: neither selection nor cancellation removes a part.
// Both destinations must accept the exchanged parts before either is changed.
export function exchangeEquipment(equipment, inventory, position, groupIndex, from, to) {
  const bay = equipmentBayAt(position), group = equipment[groupIndex];
  const invalid = message => ({ equipment, inventory, message });
  if (bay === null || !Number.isInteger(groupIndex) || !group || Math.floor(bay/3)!==Math.floor(groupIndex/3)) return invalid('equipmentUnavailable');
  const valid = slot => slot && (slot.container === 'carried'
    ? Number.isInteger(slot.index) && slot.index>=0 && slot.index<4
    : slot.container === 'installed' && Number.isInteger(slot.unit) && slot.unit>=0 && slot.unit<4 && Number.isInteger(slot.socket) && slot.socket>=0 && slot.socket<4);
  if (!valid(from) || !valid(to)) return invalid('equipmentUnavailable');
  const read = slot => slot.container === 'carried' ? inventory.carried[slot.index] : group.units[slot.unit].components[slot.socket];
  const accepts = (slot,byte) => slot.container === 'carried' || byte === 0 || fitsComponent(group,byte,slot.socket);
  const a=read(from), b=read(to);
  if (a===0 || (from.container===to.container && (from.container==='carried' ? from.index===to.index : from.unit===to.unit && from.socket===to.socket))) return invalid('selectionCancelled');
  if (!accepts(to,a) || !accepts(from,b)) return invalid('equipmentDoesNotFit');
  const nextEquipment=structuredClone(equipment), nextInventory=createInventory(inventory);
  const write = (slot,byte) => {
    if (slot.container==='carried') nextInventory.carried[slot.index]=byte;
    else nextEquipment[groupIndex].units[slot.unit].components[slot.socket]=byte;
  };
  write(from,b);write(to,a);
  nextEquipment[groupIndex]=recalculateEquipment(nextEquipment[groupIndex]);
  return {equipment:nextEquipment,inventory:nextInventory,message:'equipmentExchanged'};
}
