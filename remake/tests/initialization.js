import { sourceRandom } from '../js/core/random.js';
import { createInitialEquipment, createInitialSystems, createInitialOrbits } from '../js/core/initialization.js';

export async function initializationTests(test, equal) {
  const [native, captured, defaults] = await Promise.all([
    'fixtures/random-reference.json','fixtures/equipment-reference.json','../data/initial-navigation.json',
  ].map(path=>fetch(path).then(r=>r.json())));
  const rejects = run => { let threw=false;try{run()}catch{threw=true}equal(threw,true); };
  const tape = values => { let index=0;return {get count(){return index},next(){return values[index++] ?? 1}}; };
  await test('Native RNG matches 112 sim65 transitions including result byte order and zero states', () => {
    for(const vector of native) {
      const random=sourceRandom(vector.seed);
      for(const expected of vector.draws) { equal(random.next(),expected.value);equal(random.state,expected.state); }
    }
    const a=sourceRandom(0x53444f47);a.next();const b=sourceRandom(a.state);
    for(let i=0;i<32;i++)equal(a.next(),b.next());
    for(const value of [-1,0x100000000,1.5,NaN,'1'])rejects(()=>sourceRandom(value));
  });
  await test('Equipment initialization reproduces all six observed records with explicit compatible draws', () => {
    const random=tape(captured.draws);
    equal(createInitialEquipment(random),captured.equipment);equal(random.count,captured.draws.length);
    // No captured save is used by the generator; this tape is only a test witness.
  });
  await test('Damage preserves Pascal low-bit booleans, eager draws, spare protection and totals', () => {
    for(let socket=0;socket<4;socket++)for(const missingRoll of [0,1,2,3])for(const missingKind of [0,1]) {
      const missing=socket===0 || !!(missingRoll&1);
      const random=tape(missing ? [0,socket,missingRoll,missingKind] : [0,socket,missingRoll]);
      const result=createInitialEquipment(random),first=result[0];
      equal(first.units[0].components[socket],missing ? (missingKind ? 0 : 7) : 23);
      equal(first.units[0].performance,missing ? 0 : 3);equal(first.performance,missing ? 12 : 15);
      equal(first.spares,[31,28,26,30]);equal(random.count,missing ? 33 : 32);
      equal(result[5].performance,16);
    }
    const random=tape([1,1,1,1,0]);equal(createInitialEquipment(random)[0].performance,16);equal(random.count,30);
    const a=createInitialEquipment(tape([])),b=createInitialEquipment(tape([]));
    a[0].units[0].components[0]=0;equal(a[0].units[1].components[0],31);equal(b[0].units[0].components[0],31);
  });
  await test('System initialization resets bank balances, pins Woremed and keeps independent defaults', () => {
    const before=JSON.stringify(defaults),systems=createInitialSystems(defaults.systems,tape([]));
    equal(systems.map(s=>s.position),defaults.systems.map(s=>s.position));
    equal(systems[9].position,{x:6,y:5,z:6});equal(systems[0].bankBalance,30001);
    equal(systems.slice(1).every(s=>s.bankBalance===4001),true);
    equal(JSON.stringify(defaults),before);systems[0].position.x=1;equal(JSON.stringify(defaults),before);
    const alternate=createInitialSystems(defaults.systems,tape([]),'system-12');
    equal(alternate[0].bankBalance,4001);equal(alternate[11].bankBalance,30001);
    const collision=structuredClone(defaults.systems);collision[0].position={x:6,y:5,z:6};
    const random=tape([2,2,2,2,2,2,2,2]);
    equal(createInitialSystems(collision,random)[0].position,{x:8,y:7,z:8});
  });
  await test('Orbit rejection uses explicit previous angle and linear distance, with bounded failure', () => {
    const random=tape([0,15,16,31,32,...Array.from({length:16},(_,i)=>i%2 ? 255 : 0)]);
    const worlds=createInitialOrbits(random,0);equal(worlds[0].orbitalAngle,16);equal(worlds[1].orbitalAngle,32);
    equal(worlds[2].orbitalAngle,0);equal(worlds[3].orbitalAngle,255);equal(random.count,21);
    rejects(()=>createInitialOrbits({next:()=>0},0));rejects(()=>createInitialOrbits(tape([])));
    const stalled=structuredClone(defaults.systems);stalled[0].position={x:6,y:5,z:6};
    rejects(()=>createInitialSystems(stalled,{next:()=>1}));
    rejects(()=>createInitialSystems(defaults.systems,tape([]),'unknown'));
    rejects(()=>createInitialEquipment({next:()=>-1}));rejects(()=>createInitialEquipment({next:()=>32768}));
  });
  await test('1000 seeded initializations converge with source bounds, spacing and isolated replay', () => {
    for(let seed=1;seed<=1000;seed++) {
      const run=()=>{const random=sourceRandom(seed);return {equipment:createInitialEquipment(random),systems:createInitialSystems(defaults.systems,random),worlds:createInitialOrbits(random,0),randomState:random.state}};
      const a=run();equal(a,run());
      equal(a.systems.every((s,i)=>s.position.x>=1&&s.position.x<=12&&s.position.y>=1&&s.position.y<=9&&s.position.z>=0&&s.position.z<=10&&
        (i===0 ? s.bankBalance>=29000&&s.bankBalance<=31999 : s.bankBalance>=3000&&s.bankBalance<=5999)&&
        a.systems.every((other,j)=>i===j||Math.abs(other.position.x-s.position.x)>=2||Math.abs(other.position.y-s.position.y)>=2)),true);
      equal(a.worlds.every((w,i)=>w.orbitalAngle>=0&&w.orbitalAngle<=255&&Math.abs(w.orbitalAngle-(i ? a.worlds[i-1].orbitalAngle : 0))>15),true);
      equal(a.equipment.every(s=>s.performance>=0&&s.performance<=16&&s.units.length===4&&s.spares.length===4),true);
    }
  });
}
