// Source-derived initialization primitives, not a complete campaign constructor.
// Callers supply a private random stream; no global state or existing saves.
const EQUIPMENT = [
  ['warp-drives', 28, 26, 30, 0, 0],
  ['sub-c-engines', 28, 30, 24, 0, 0],
  ['ships-guns', 24, 26, 29, 19, 2],
  ['tactical-display', 27, 25, 26, 20, 2],
  ['force-shields', 24, 28, 28, 21, 1],
  ['pilotage', 25, 27, 25, 22, 2],
];
const draw = random => {
  const value = random.next();
  if (!Number.isInteger(value) || value < 0 || value > 32767) throw new Error('Invalid random result');
  return value;
};
const integer = (n, min, max) => Number.isInteger(n) && n >= min && n <= max;
const clamp = (n, min, max) => Math.max(min, Math.min(max, n));

// Utility19 and the six calls in utility21 ($0A03–$0A31).
export function createInitialEquipment(random) {
  return EQUIPMENT.map(([id, a, b, c, requiredComponent, requiredSocket]) => {
    const rows = [];
    for (let row = 0; row < 5; row++) {
      const components = [31, a, b, c];
      const damageRoll = draw(random); // Pascal LAND evaluates both operands, even for spare row4.
      let performance = 4;
      if (row < 4 && damageRoll % 3 === 0) {
        const socket = draw(random) % 4;
        const missingRoll = draw(random); // LOR also evaluates this when socket0 is selected.
        if (socket === 0 || (missingRoll & 1)) {
          components[socket] = (draw(random) & 1) ? 0 : 7;
          performance = 0;
        } else {
          components[socket] = 23;
          performance = 3;
        }
      }
      rows.push({ components, performance });
    }
    return { id, units:rows.slice(0,4), spares:rows[4].components,
      performance:rows.slice(0,4).reduce((sum,row)=>sum+row.performance,0),
      requiredComponent, requiredSocket };
  });
}

// Utility20 $087B–$088A consumes one draw AFTER the six equipment records.
// Utility21 clears the remaining resource words before this call. These are
// saved utility defaults, not the state after game startup/machinery ticks.
export function createInitialShipResources(random) {
  return {
    hull:13 + draw(random) % 4,
    fuel:0,
    warp:{charge:0,targetCharge:0,targetSystemId:null,charging:false},
    shields:{charge:0,targetCharge:0},
    guns:{charge:0,powered:false},
    enginesPowered:false,
  };
}

// Utility12: one-step jitter from the supplied world defaults. Coordinates are
// three-dimensional (library24 procedure6); spacing checks use only x and y.
export function createInitialSystems(defaults, random, startingSystem = 'system-01') {
  if (!Array.isArray(defaults) || defaults.length !== 12 ||
      defaults.some((s,i) => s?.id !== `system-${String(i+1).padStart(2,'0')}` ||
        !integer(s.position?.x,1,12) || !integer(s.position?.y,1,9) || !integer(s.position?.z,0,10)) ||
      !defaults.some(s=>s.id===startingSystem)) throw new Error('Invalid system defaults');
  const systems = defaults.map(({id, position})=>({id,position:{...position},bankBalance:0}));
  systems[9].position = {x:6,y:5,z:6};
  for (let i = 0; i < systems.length; i++) {
    const system = systems[i];
    system.bankBalance = (system.id === startingSystem ? 29 : 3) * 1000 + (draw(random) % 3) * 1000 + draw(random) % 1000;
    if (i === 9) continue;
    let accepted = false;
    for (let attempts = 0; attempts < 10000; attempts++) {
      // Rejected candidates become the next jitter baseline in the source.
      for (const [key,min,max] of [['x',1,12],['y',1,9],['z',0,10]]) {
        system.position[key] = clamp(system.position[key] + draw(random) % 3 - 1, min, max);
      }
      if (!systems.some((other,j)=>(j<i || j===9) &&
          Math.abs(other.position.x-system.position.x)<2 && Math.abs(other.position.y-system.position.y)<2)) { accepted = true; break; }
    }
    if (!accepted) throw new Error('System initialization did not converge');
  }
  return systems;
}

// Utility13: adjacent generated angles must differ by >15, without wrapping.
// Its first comparison reads an outer local not initialized in procedure9.
// Require that boundary explicitly; the browser development fixture uses0.
export function createInitialOrbits(random, previousAngle) {
  if (!integer(previousAngle,0,255)) throw new Error('Invalid previous orbital angle');
  const worlds = [];
  for (let i = 0; i < 18; i++) {
    let angle, accepted = false;
    for (let attempts = 0; attempts < 10000; attempts++) {
      angle = draw(random) % 256;
      if (Math.abs(angle-previousAngle)>15) { accepted = true; break; }
    }
    if (!accepted) throw new Error('Orbit initialization did not converge');
    worlds.push({id:`world-${String(i+1).padStart(2,'0')}`,orbitalAngle:angle});previousAngle=angle;
  }
  return worlds;
}
