import { interactionAt } from './ship-walk.js';

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
