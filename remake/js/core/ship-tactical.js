import { snapshotShipCombat,fireShipGun,jettisonShipCargo } from './ship-combat.js';
import { sourceRandom } from './random.js';

const integer=(n,a,b)=>Number.isInteger(n)&&n>=a&&n<=b;
const signed=n=>(n<<16)>>16;
const keys=(v,n)=>v&&typeof v==='object'&&!Array.isArray(v)&&Object.keys(v).length===n.length&&n.every(k=>Object.hasOwn(v,k));
const fail=()=>{throw Error('invalidShipTactical')};
// Native viewscreen $0ADF–$0AFE. Low paddle counts mean positive motion.
const PADDLE=Object.freeze([8,7,6,5,5,4,4,3,3,2,2,2,1,1,1,0,0,-1,-1,-1,-2,-2,-2,-3,-3,-4,-4,-5,-5,-6,-7,-8]);
export function shipPaddleMotion(x,y) {
  if(![x,y].every(n=>integer(n,0,255)))fail();
  return {x:PADDLE[Math.min(x,127)>>2],y:PADDLE[Math.min(y,127)>>2]};
}
export function validateShipTactical(value) {
  if(!keys(value,['reticle','contact','visible','grace','focused','firing','sensors','frameLimit','menu','jettisonChoices'])||
    !keys(value.reticle,['angle','radius'])||![value.reticle.angle,value.reticle.radius,value.grace].every(n=>integer(n,-32768,32767))||
    !['contact','visible','focused','firing'].every(k=>typeof value[k]==='boolean')||!integer(value.sensors,0,16)||!integer(value.frameLimit,0,32767)||!integer(value.menu,0,3)||
    value.firing&&value.menu!==3||
    (value.menu===2?!Array.isArray(value.jettisonChoices)||value.jettisonChoices.length!==2||Object.keys(value.jettisonChoices).length!==2||![0,1].every(i=>Object.hasOwn(value.jettisonChoices,i)&&typeof value.jettisonChoices[i]==='boolean'):value.jettisonChoices!==null))fail();
  return structuredClone(value);
}
// Game12 proc9. Three startup machinery calls must be supplied by the host.
export function prepareShipTactical(previous,{worldAngle,frameLimit,grace}) {
  const state=snapshotShipCombat(previous),f=state.flags,w=state.words;
  if(!integer(worldAngle,0,255)||!integer(frameLimit,0,32767)||!integer(grace,-32768,32767)||state.sceneHigh!==1||f[35])fail();
  const random=sourceRandom(state.randomState);let draws=0;
  const reticle={angle:worldAngle,radius:128};
  if(f[19]) {
    w[206]=448+(random.next()&127);w[205]=448+(random.next()&127);draws=2;
    reticle.angle=w[206]>>2;reticle.radius=w[205]>>2;
  }
  f[36]=false;
  if(!f[40])for(let i=41;i<=47;i++)f[i]=false;
  state.randomState=random.state;
  return {state,tactical:{reticle,contact:f[40],visible:false,grace,focused:true,firing:false,
    sensors:state.equipment[3].group.performance,frameLimit,menu:0,jettisonChoices:null},draws,startupCycles:3};
}
export function shipTacticalControls(previous,record) {
  const s=snapshotShipCombat(previous),t=validateShipTactical(record),n=t.sensors;
  return {guns:n>1,jettison:n>0&&s.flags[7],shields:n>2,cloak:n>2&&s.flags[20],
    comm:s.flags[40]&&!s.flags[47],sensorTarget:n>1&&t.contact&&t.visible,rangePlots:n>4};
}
const jettisonChoices=state=>state.cargo.map(lot=>!!lot&&Number(lot.commodityId.slice(6))>0&&Number(lot.commodityId.slice(6))<31);
export function selectShipTacticalMenu(previous,record,menu) {
  const state=snapshotShipCombat(previous),tactical=validateShipTactical(record),controls=shipTacticalControls(state,tactical);
  if(!integer(menu,0,3))fail();
  if(menu===1&&!controls.shields||menu===2&&!controls.jettison||menu===3&&!controls.guns)throw Error('shipTacticalUnavailable');
  if(tactical.firing){state.flags[2]=false;tactical.firing=false}
  tactical.menu=menu;tactical.jettisonChoices=menu===2?jettisonChoices(state):null;
  return {state,tactical};
}
export function confirmShipJettison(previous,record,selection) {
  const state=snapshotShipCombat(previous),tactical=validateShipTactical(record);
  if(![1,2,3].includes(selection))fail();
  if(tactical.menu!==2||!state.flags[7]||!(selection===3?tactical.jettisonChoices.every(Boolean):tactical.jettisonChoices[selection-1]))throw Error('shipCargoUnavailable');
  const result=jettisonShipCargo(state,selection);
  tactical.jettisonChoices=jettisonChoices(result.state);
  return {...result,tactical};
}
export function setShipTacticalGun(previous,record,{firing,focused}) {
  const state=snapshotShipCombat(previous),tactical=validateShipTactical(record);
  if(typeof firing!=='boolean'||typeof focused!=='boolean')fail();
  if(firing&&(tactical.sensors<=1||tactical.menu!==3))throw Error('shipGunUnavailable');
  tactical.firing=firing;tactical.focused=focused;state.flags[2]=firing;
  return {state,tactical};
}
export function shipTacticalAim(previous,record,manual) {
  const s=snapshotShipCombat(previous),t=validateShipTactical(record),w=s.words;
  if(!keys(manual,['x','y'])||![manual.x,manual.y].every(n=>integer(n,-8,8)))fail();
  if(t.firing)return {...manual};
  if(!s.flags[19]||!t.contact)return {x:0,y:0};
  if(t.visible) {
    const scale=Math.max(0,3-(w[217]>>5));
    return {x:signed(-((scale*w[209])>>1)),y:signed(-((scale*w[208])>>1))};
  }
  return {x:8*Math.sign(512-w[206]),y:8*Math.sign(512-w[205])};
}
// Game12 proc10 $088F–$0996, invoked before and again after a due tick.
export function moveShipTactical(previous,record,delta) {
  const state=snapshotShipCombat(previous),tactical=validateShipTactical(record),w=state.words;
  if(!keys(delta,['x','y'])||![delta.x,delta.y].every(n=>integer(n,-8,8)))fail();
  if(tactical.firing||tactical.contact) {
    tactical.reticle.radius=signed(tactical.reticle.radius-delta.x);
    tactical.reticle.angle=signed(tactical.reticle.angle-delta.y);
    if(tactical.contact) {
      if(w[215]>0){w[217]=Math.max(5,signed(w[217]+w[207]));w[215]=signed(w[215]-1)}
      const scale=3-(w[217]>>5); // Negative far-range scaling is intentional.
      w[206]=signed(w[206]+2*delta.x+scale*w[209])&1023;
      w[205]=signed(w[205]+2*delta.y+scale*w[208])&1023;
      if(tactical.sensors>1) {
        tactical.visible=Math.abs((w[206]>>1)-256)<=65&&Math.abs((w[205]>>1)-256)<=45&&w[217]<=108;
        if(!tactical.visible)tactical.grace=2;
      }
    }
  }
  return {state,tactical};
}
export function beginShipTacticalFrame(previous,record,control,{dexterity,worldAngle,polling=false}) {
  let state=snapshotShipCombat(previous),tactical=validateShipTactical(record);
  if(!keys(control,['x','y','fire'])||![control.x,control.y].every(n=>integer(n,-8,8))||typeof control.fire!=='boolean'||
    !integer(dexterity,0,255)||!integer(worldAngle,0,255)||typeof polling!=='boolean')fail();
  let shot=null;
  if(tactical.firing&&control.fire&&state.equipment[2].group.performance>0&&state.words[226]>0) {
    shot=fireShipGun(state,{focused:tactical.focused,dexterity});state=shot.state;
    if(shot.hit&&state.words[216]===0){tactical.contact=tactical.visible=false;tactical.reticle={angle:128,radius:worldAngle}}
  }
  const menu=polling||tactical.menu!==0&&!tactical.firing;
  // Idle main-loop FJP tests bit0; menu polling calls proc12 without the
  // main-loop increment, while the firing loop calls it on every iteration.
  if(!menu)state.words[354]=signed(state.words[354]+1);
  const delta=shipTacticalAim(state,tactical,{x:control.x,y:control.y});
  const called=menu||tactical.firing||!!(state.words[354]&1);
  const redraw=called&&(!tactical.visible||state.words[354]===(tactical.frameLimit>>1)||tactical.grace>0);
  if(redraw)tactical.grace=signed(tactical.grace-1);
  // The false branch at $0AD8 uses table $0BF8, whose target is $0B5D,
  // not the return at $0BF6. It skips drawing but still moves and checks due.
  if(called)({state,tactical}=moveShipTactical(state,tactical,delta));
  return {state,tactical,delta,called,redraw,updated:called,due:called&&state.words[354]>=tactical.frameLimit,shot};
}
export function finishShipTacticalFrame(previous,record,delta) {
  const state=snapshotShipCombat(previous),tactical=validateShipTactical(record);
  // Source refreshes cached sensor output, then moves using the old contact
  // local31 before updating it from flag40. Damage can change the sensor cache.
  tactical.sensors=state.equipment[3].group.performance;
  const refreshed=moveShipTactical(state,tactical,delta);
  refreshed.tactical.contact=refreshed.state.flags[40];
  return refreshed;
}
