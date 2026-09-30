import { cityOrigin } from './city-map.js';

// Preview state is intentionally distinct from campaign/save state.
export function createPreview() {
  return { view: 'title', indices: { ship: 0, cities: 0, worlds: 0 }, bank: 0, selection: null,
    cityMode:'stored',cityOrigin:cityOrigin(),colonyPhase:0 };
}

export function reducePreview(state, action, counts) {
  switch (action.type) {
    case 'view':
      if (!['title', 'ship', 'cities', 'worlds'].includes(action.view)) return state;
      return { ...state, view: action.view, selection: null };
    case 'step': {
      const count = counts[state.view];
      if (!count || !Number.isInteger(action.delta)) return state;
      const index = ((state.indices[state.view] + action.delta) % count + count) % count;
      return { ...state, indices: { ...state.indices, [state.view]: index }, selection: null,
        cityOrigin:state.view==='cities' ? cityOrigin() : state.cityOrigin };
    }
    case 'city-mode':
      return ['stored','composed'].includes(action.mode) ? {...state,cityMode:action.mode,selection:null} : state;
    case 'colony-phase':
      return state.view==='cities'&&state.indices.cities===59&&Number.isInteger(action.phase)&&action.phase>=0&&action.phase<=9
        ? {...state,colonyPhase:action.phase,selection:null} : state;
    case 'city-pan':
      if(state.view!=='cities'||state.cityMode!=='composed'||
        !Number.isInteger(action.dx)||!Number.isInteger(action.dy)||Math.abs(action.dx)+Math.abs(action.dy)!==1) return state;
      return {...state,selection:null,cityOrigin:{x:(state.cityOrigin.x+action.dx+40)%40,y:Math.min(18,Math.max(0,state.cityOrigin.y+action.dy))}};
    case 'bank':
      return Number.isInteger(action.bank) && action.bank >= 0 && action.bank < 4
        ? { ...state, bank: action.bank } : state;
    case 'select':
      return { ...state, selection: action.point ? { ...action.point } : null };
    default: return state;
  }
}

export function logicalPoint(rect, clientX, clientY, width = 640, height = 480) {
  if (rect.width <= 0 || rect.height <= 0) return null;
  const x = (clientX - rect.left) * width / rect.width;
  const y = (clientY - rect.top) * height / rect.height;
  return x >= 0 && x < width && y >= 0 && y < height ? { x, y } : null;
}

export function cellAt(point, bounds, columns, rows) {
  if (!point) return null;
  const x = Math.floor((point.x - bounds.x) * columns / bounds.width);
  const y = Math.floor((point.y - bounds.y) * rows / bounds.height);
  return x >= 0 && y >= 0 && x < columns && y < rows ? { x, y } : null;
}
