import { createInitialEquipment } from '../js/core/initialization.js';
import { recalculateEquipment } from '../js/core/equipment.js';
import { createEquipmentFailureState } from '../js/core/equipment-failures.js';
import { shipPaddleMotion,validateShipTactical,prepareShipTactical,shipTacticalControls,
  selectShipTacticalMenu,confirmShipJettison,setShipTacticalGun,shipTacticalAim,
  moveShipTactical,beginShipTacticalFrame,finishShipTacticalFrame } from '../js/core/ship-tactical.js';
import { stepShipCombat } from '../js/core/ship-combat.js';

const lot=(id=2)=>({commodityId:`cargo-${String(id).padStart(2,'0')}`,quality:7,originCity:'city-01',pricePaid:0});
const fresh=()=>({flags:Array.from({length:128},(_,i)=>[7,40].includes(i)),
  words:{205:512,206:512,207:-1,208:0,209:0,214:1,215:20,216:200,217:40,
    222:100,224:192,225:0,226:100,347:0,354:0},rangeMemory:127,hull:16,sceneHigh:1,shipWorld:false,
  equipment:createInitialEquipment({next:()=>1}).map(recalculateEquipment).map(createEquipmentFailureState),
  cargo:[lot(),lot(3)],randomState:29});
const setup=s=>prepareShipTactical(s,{worldAngle:64,frameLimit:5,grace:2});
const idle={x:0,y:0,fire:false},options={dexterity:30,worldAngle:64};
const gun=s=>{const p=setup(s),menu=selectShipTacticalMenu(p.state,p.tactical,3);return setShipTacticalGun(menu.state,menu.tactical,{firing:true,focused:true})};

export async function shipTacticalTests(test,equal) {
  const reject=(f,expected='invalidShipTactical')=>{let message;try{f()}catch(e){message=e.message}equal(message,expected)};
  await test('Native paddle counters map through all32 signed motion entries with byte saturation',()=>{
    const native=[8,7,6,5,5,4,4,3,3,2,2,2,1,1,1,0,0,-1,-1,-1,-2,-2,-2,-3,-3,-4,-4,-5,-5,-6,-7,-8];
    for(let counter=0;counter<=255;counter++) {
      equal(shipPaddleMotion(counter,127-counter%128),{x:native[Math.min(counter,127)>>2],y:native[(127-counter%128)>>2]});
    }
    equal(shipPaddleMotion(60,64),{x:0,y:0});reject(()=>shipPaddleMotion(256,0));reject(()=>shipPaddleMotion(0.5,0));
  });
  await test('Tactical entry preserves actual contact, clears inhibition and requires three source startup machinery calls',()=>{
    const s=fresh();s.flags[36]=s.flags[47]=true;const before=JSON.stringify(s),p=setup(s);
    equal(p.tactical.reticle,{angle:64,radius:128});equal(p.tactical.contact,true);equal(p.tactical.visible,false);
    equal(p.tactical.sensors,16);equal(p.tactical.frameLimit,5);equal(p.tactical.grace,2);equal(p.startupCycles,3);equal(p.draws,0);
    equal(p.state.flags[36],false);equal(p.state.flags[47],true);equal(p.state.randomState,29);equal(JSON.stringify(s),before);
    s.flags[40]=false;for(let i=41;i<=47;i++)s.flags[i]=true;const empty=setup(s);
    equal(empty.state.flags.slice(41,48),Array(7).fill(false));equal(empty.tactical.contact,false);
    s.flags[35]=true;reject(()=>setup(s));
  });
  await test('Targeting computer entry eagerly draws x then y and derives source reticle from both coordinates',()=>{
    const s=fresh();s.flags[19]=true;s.randomState=12345;const p=setup(s);
    equal(p.draws,2);equal(p.state.randomState,202267833);
    equal([p.state.words[206],p.state.words[205]],[472,462]);equal(p.tactical.reticle,{angle:118,radius:115});
    equal(p.state.words[217],40);equal(p.state.cargo,s.cargo);
  });
  await test('Sensor menu gates use cached output and attachment/special state rather than a substitute capability level',()=>{
    const s=fresh(),p=setup(s);s.flags[20]=true;
    for(let n=0;n<=16;n++) {
      const t={...p.tactical,sensors:n,visible:true};
      equal(shipTacticalControls(s,t),{guns:n>1,jettison:n>0,shields:n>2,cloak:n>2,comm:true,sensorTarget:n>1,rangePlots:n>4});
    }
    s.flags[7]=s.flags[20]=false;s.flags[47]=true;
    const gated=shipTacticalControls(s,p.tactical);equal([gated.jettison,gated.cloak,gated.comm],[false,false,false]);
    reject(()=>selectShipTacticalMenu(s,{...p.tactical,sensors:1},3),'shipTacticalUnavailable');
  });
  await test('Automatic aim reacquires an offscreen contact and uses signed half-velocity correction only when visible',()=>{
    const s=fresh(),p=setup(s);s.flags[19]=true;s.words[206]=480;s.words[205]=560;
    equal(shipTacticalAim(s,p.tactical,{x:3,y:-2}),{x:8,y:-8});
    s.words[209]=-1;s.words[208]=3;s.words[217]=31;
    equal(shipTacticalAim(s,{...p.tactical,visible:true},idleDelta()),{x:2,y:-4});
    s.words[217]=96;equal(shipTacticalAim(s,{...p.tactical,visible:true},idleDelta()),{x:0,y:0});
    equal(shipTacticalAim(s,{...p.tactical,firing:true,menu:3},{x:-7,y:6}),{x:-7,y:6});
    s.flags[19]=false;equal(shipTacticalAim(s,p.tactical,{x:8,y:8}),{x:0,y:0});
    function idleDelta(){return {x:0,y:0}}
  });
  await test('Own movement applies source reticle subtraction, range/cooldown, wrap and signed far-range drift',()=>{
    const s=fresh(),p=setup(s);Object.assign(s.words,{206:1020,205:3,207:-4,208:-2,209:3,217:160,215:1});
    const moved=moveShipTactical(s,p.tactical,{x:8,y:-8});
    equal([moved.state.words[206],moved.state.words[205],moved.state.words[217],moved.state.words[215]],[9,1013,156,0]);
    equal(moved.tactical.reticle,{angle:72,radius:120});equal(moved.tactical.visible,false);equal(moved.tactical.grace,2);
    s.words[217]=5;s.words[215]=2;equal(moveShipTactical(s,p.tactical,{x:0,y:0}).state.words[217],5);
    const edge={...p.tactical,reticle:{angle:32767,radius:-32768}};
    equal(moveShipTactical(s,edge,{x:1,y:-1}).tactical.reticle,{angle:-32768,radius:32767});
  });
  await test('Visibility uses arithmetic half-coordinates and inclusive65/45/108 boundaries, preserving a stale low-sensor local',()=>{
    const s=fresh(),p=setup(s);s.words[207]=s.words[208]=s.words[209]=0;
    for(const [x,y,range,visible] of [[643,603,108,true],[644,603,108,false],[643,604,108,false],[643,603,109,false],[382,422,108,true],[381,422,108,false]]) {
      Object.assign(s.words,{206:x,205:y,217:range});equal(moveShipTactical(s,p.tactical,{x:0,y:0}).tactical.visible,visible);
    }
    s.words[206]=0;equal(moveShipTactical(s,{...p.tactical,sensors:1,visible:true},{x:0,y:0}).tactical.visible,true);
    equal(shipTacticalControls(s,{...p.tactical,sensors:1,visible:true}).sensorTarget,false);
  });
  await test('Main-loop bit0, menu polling, half-counter/grace and machinery thresholds retain distinct source gates',()=>{
    const s=fresh(),p=setup(s);s.words[354]=1;const even=beginShipTacticalFrame(s,p.tactical,idle,options);
    equal([even.state.words[354],even.called,even.updated,even.due],[2,false,false,false]);equal(even.state.words[215],20);
    const odd=beginShipTacticalFrame(even.state,p.tactical,idle,options);equal([odd.called,odd.updated,odd.due],[true,true,false]);
    const visible={...p.tactical,visible:true,grace:0};s.words[354]=4;
    const skipped=beginShipTacticalFrame(s,visible,idle,options);equal([skipped.called,skipped.updated,skipped.due],[true,false,false]);
    const due=beginShipTacticalFrame(s,p.tactical,idle,options);equal(due.due,true);
    const menu=selectShipTacticalMenu(s,visible,1);menu.state.words[354]=2;
    const half=beginShipTacticalFrame(menu.state,menu.tactical,idle,options);equal([half.state.words[354],half.called,half.updated,half.due],[2,true,true,false]);
    const rootPolling=beginShipTacticalFrame(menu.state,{...visible,menu:0},idle,{...options,polling:true});
    equal([rootPolling.state.words[354],rootPolling.called,rootPolling.updated],[2,true,true]);
    const gunFrame=gun(s);gunFrame.state.words[354]=1;
    equal(beginShipTacticalFrame(gunFrame.state,gunFrame.tactical,idle,options).called,true);
  });
  await test('A due frame moves before combat and again after it, refreshing sensor cache before updating source contact',()=>{
    const s=fresh(),p=setup(s);s.words[354]=4;s.words[217]=100;s.flags[44]=false;
    const begun=beginShipTacticalFrame(s,p.tactical,idle,options);equal(begun.due,true);equal(begun.state.words[217],99);
    const combat=stepShipCombat(begun.state).state;equal(combat.words[217],99); // Native high1 prevents Library24 drift.
    const result=finishShipTacticalFrame(combat,begun.tactical,begun.delta);equal(result.state.words[217],98);equal(result.state.words[215],18);
    combat.flags[40]=false;combat.equipment[3].group.performance=1;
    const ended=finishShipTacticalFrame(combat,begun.tactical,begun.delta);
    equal(ended.tactical.sensors,1);equal(ended.state.words[217],98);equal(ended.tactical.contact,false);
  });
  await test('Firing holds source gun power, consumes actual charge before movement and retains kill reticle/counter behavior',()=>{
    const s=fresh(),p=gun(s);equal(p.state.flags[2],true);
    const frame=beginShipTacticalFrame(p.state,p.tactical,{x:8,y:8,fire:true},options);
    equal(frame.shot.hit,true);equal(frame.state.words[226],0);equal(frame.state.words[216],0);equal(frame.state.words[354],2);
    equal(frame.tactical.contact,false);equal(frame.tactical.reticle,{angle:120,radius:56});equal(frame.shot.cooldownIncrement,1);
    const stopped=selectShipTacticalMenu(frame.state,frame.tactical,0);equal(stopped.state.flags[2],false);equal(stopped.tactical.firing,false);
    const empty=gun(s);empty.state.words[226]=0;equal(beginShipTacticalFrame(empty.state,empty.tactical,{...idle,fire:true},options).shot,null);
  });
  await test('Bolts must be armed before jettison; source menu excludes cryogens and preserves stale auxiliary selection draws',()=>{
    const s=fresh(),p=setup(s),before=JSON.stringify(s);
    reject(()=>confirmShipJettison(s,p.tactical,3),'shipCargoUnavailable');
    const armed=selectShipTacticalMenu(s,p.tactical,2);equal(armed.state,s);equal(armed.tactical.jettisonChoices,[true,true]);
    const both=confirmShipJettison(armed.state,armed.tactical,3);equal(both.jettisoned.map(l=>l.slot),[1,0]);equal(both.draws,2);
    equal(both.tactical.jettisonChoices,[false,false]);equal(JSON.stringify(s),before);
    const cancelled=selectShipTacticalMenu(armed.state,armed.tactical,0);equal(cancelled.state,s);reject(()=>confirmShipJettison(cancelled.state,cancelled.tactical,1),'shipCargoUnavailable');
    s.cargo[1]=lot(31);const cryo=selectShipTacticalMenu(s,p.tactical,2);equal(cryo.tactical.jettisonChoices,[true,false]);
    reject(()=>confirmShipJettison(cryo.state,cryo.tactical,2),'shipCargoUnavailable');reject(()=>confirmShipJettison(cryo.state,cryo.tactical,3),'shipCargoUnavailable');
    s.cargo[0]={commodityId:'cargo-01',quality:7,originWorld:'world-01',pricePaid:0};
    const auxiliary=selectShipTacticalMenu(s,p.tactical,2);auxiliary.state.cargo[0]=null;
    const stale=confirmShipJettison(auxiliary.state,auxiliary.tactical,1);equal(stale.draws,1);equal(stale.jettisoned,[]);
  });
  await test('Tactical records and caller controls clone atomically, round-trip exactly and reject sparse or malformed values',()=>{
    const s=fresh(),p=setup(s),before=JSON.stringify({s,p});equal(validateShipTactical(JSON.parse(JSON.stringify(p.tactical))),p.tactical);
    for(const change of [v=>v.extra=1,v=>v.reticle.angle=32768,v=>v.reticle.radius=1.5,v=>v.sensors=17,v=>v.frameLimit=-1,
      v=>v.grace=-32769,v=>v.menu=4,v=>v.firing=true,v=>v.jettisonChoices=[true,true]]) {
      const bad=structuredClone(p.tactical);change(bad);reject(()=>validateShipTactical(bad));
    }
    const sparse=selectShipTacticalMenu(s,p.tactical,2).tactical;delete sparse.jettisonChoices[0];sparse.jettisonChoices.extra=true;reject(()=>validateShipTactical(sparse));
    reject(()=>beginShipTacticalFrame(s,p.tactical,{...idle,x:9},options));reject(()=>shipTacticalAim(s,p.tactical,{x:0,y:0,extra:1}));
    equal(JSON.stringify({s,p}),before);
  });
}
