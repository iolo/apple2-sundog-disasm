import { sourceRandom } from './random.js';
import { tryStep } from './ship-walk.js';
import { drawRoomGlyph } from './room-actors.js';
import { createGroundCombat } from './ground-combat.js';

const integer=(n,lo,hi)=>Number.isInteger(n)&&n>=lo&&n<=hi;
const keys=(v,n)=>v&&typeof v==='object'&&!Array.isArray(v)&&Object.keys(v).length===n.length&&n.every(k=>Object.hasOwn(v,k));
const point=p=>keys(p,['x','y'])&&integer(p.x,0,273)&&integer(p.y,7,191);
const wrap=(n,size)=>((n%size)+size)%size;
const clamp=(n,lo,hi)=>Math.min(hi,Math.max(lo,n));
const signed=n=>((n&65535)^32768)-32768;
const fail=()=>{throw Error('invalidGroundChase')};
const same=(a,b)=>a.x===b.x&&a.y===b.y;
const dense=(v,n,test)=>Array.isArray(v)&&v.length===n&&Object.keys(v).length===n&&v.every(test);

// Game21 proc1 $1EFD–$1F1A. Pascal LAND is eager: scene4, pod mode and
// special-city suppression still consume exactly one draw on a DUE tick.
export function groundThreatGate({scene,foot,special,randomState}={}) {
  if(![3,4].includes(scene)||typeof foot!=='boolean'||typeof special!=='boolean'||!integer(randomState,0,0xffffffff))fail();
  const rng=sourceRandom(randomState),roll=rng.next();
  return {triggered:scene===3&&foot&&roll%64===21&&!special,randomState:rng.state,draws:1};
}

function contentValid(content) {
  if(![22,23,24].every(n=>dense(content?.glyphs?.[n],8,v=>integer(v,0,127)))||
    !content.glyphs[24].every(n=>n===127)||
    !dense(content.patterns,2,row=>dense(row,12,v=>integer(v,0,127)))||
    !content.patterns.every(row=>row[8]===0&&row[11]===127))fail();
}
function windowAt(origin) {
  const left=clamp(origin.x-40,10,199),top=clamp(origin.y-30,10,131);
  return {left,top,right:left+80,bottom:top+60};
}
const sessionKeys=['origin','window','copyOrigin','tile','threshold','player','enemy','fast','counter',
  'mode','status','direction','kind','randomState','elapsed'];
export function validateGroundChase(value) {
  if(!keys(value,sessionKeys)||!point(value.origin)||!point(value.player)||!point(value.enemy)||
    !keys(value.window,['left','top','right','bottom'])||!keys(value.copyOrigin,['x','y'])||
    !integer(value.tile,2,15)||!integer(value.threshold,0,15)||typeof value.fast!=='boolean'||
    !integer(value.counter,-32768,32767)||!['chasing','caught','escaped'].includes(value.status)||
    !integer(value.elapsed,0,GROUND_CHASE_TICK_MS-1)||!integer(value.randomState,0,0xffffffff))fail();
  const w=windowAt(value.origin),copy={x:clamp(Math.trunc(value.origin.x/7)-10,0,20),y:clamp(value.origin.y-48,0,96)};
  if(!same(value.copyOrigin,copy)||!['left','top','right','bottom'].every(k=>value.window[k]===w[k])||
    value.mode!==(value.status==='chasing'?8:9)||
    (value.status==='caught'? !integer(value.direction,0,8)||![16,18,22].includes(value.kind):value.direction!==null||value.kind!==null)||
    value.status!=='chasing'&&value.elapsed!==0)fail();
  // A saved activation cannot jump outside its cleared window. These bounds
  // include the final escape step; collision and the exit test run separately.
  for(const p of [value.player,value.enemy])if(p.x<w.left+2||p.x>w.right-8||p.y<w.top+8||p.y>w.bottom-1)fail();
  sourceRandom(value.randomState);
  return structuredClone(value);
}

// Game21 proc40 $1BDA–$1CCC. Map tile is read before clearing the window.
// The host keeps the real city pose; these are separate screen coordinates.
export function createGroundChase({position,tile,threshold,randomState}={},content) {
  contentValid(content);
  if(!point(position)||!integer(tile,0,15)||!integer(threshold,0,15)||!integer(randomState,0,0xffffffff))fail();
  if(tile<2)throw Error('groundChaseInvalidTile'); // Native SYSTEMERROR21,40.
  const window=windowAt(position),player={x:window.left+37,y:window.top+33},enemy={...player};
  const rng=sourceRandom(randomState),side=rng.next()%4;
  if(side===0)enemy.x=window.left+3;
  else if(side===1)enemy.y=window.top+10;
  else if(side===2)enemy.x=window.left+70;
  else enemy.y=window.top+55;
  const state={origin:{...position},window,
    copyOrigin:{x:clamp(Math.trunc(position.x/7)-10,0,20),y:clamp(position.y-48,0,96)},
    tile,threshold,player,enemy,fast:rng.next()%3===0,counter:32767,mode:8,status:'chasing',
    direction:null,kind:null,randomState:rng.state,elapsed:0};
  return {state:validateGroundChase(state),draws:2};
}

// Library22 proc7 patterns11/8, with the native absolute byte-column phase.
// Pixels outside the owned overlay are not used by chase movement/collision.
function fill(rows,rect,pattern,content) {
  for(let y=rect.top;y<=rect.bottom;y++)for(let x=rect.left;x<=rect.right;x++) {
    const column=Math.floor(x/7),bit=1<<(x%7),mask=content.patterns[column%2][pattern];
    rows[y][column]=(rows[y][column]&~bit)|(mask&bit);
  }
}
export function groundChaseGeometry(previous,content) {
  contentValid(content);const state=validateGroundChase(previous),w=state.window;
  const rows=Array.from({length:192},()=>Array(40).fill(0));
  fill(rows,w,11,content);
  fill(rows,{left:w.left+2,right:w.left+78,top:w.top+1,bottom:w.top+59},8,content);
  return {width:280,height:192,collisionRows:content.glyphs[24],backgrounds:{ship:rows}};
}
function controlValid(input) {
  const {move=false,pointer=null}=input??{};
  if(typeof move!=='boolean'||pointer!==null&&(!keys(pointer,['x','y'])||
    !integer(pointer.x,0,279)||!integer(pointer.y,0,191))||move&&pointer===null)fail();
  return {move,pointer};
}
function moveActor(state,geometry,content,actor,other,dx,dy) {
  const rows=geometry.backgrounds.ship.map(row=>[...row]);
  drawRoomGlyph(rows,state[other],content.glyphs[other==='player'?22:23]);
  const previous=state[actor],next=tryStep({...geometry,backgrounds:{ship:rows}},previous,dx,dy);
  state[actor]={...next};return !same(previous,next);
}

// Game21 proc40 $1CCE–$1DF0. Player movement uses the RAW pointer, unlike
// Game17's -3/+3 offsets. The chaser's decremented counter is a raw Boolean
// low bit, not JavaScript truthiness. Catch is a blocked movement retry.
export function stepGroundChase(previous,content,input={}) {
  const state=validateGroundChase(previous),control=controlValid(input),geometry=groundChaseGeometry(state,content);
  if(state.status!=='chasing')return {state,draws:0,events:[]};
  if(control.move)moveActor(state,geometry,content,'player','enemy',
    Math.sign(control.pointer.x-state.player.x),Math.sign(control.pointer.y-state.player.y));
  state.counter=signed(state.counter-1);
  let caught=false;
  if((state.counter|Number(state.fast))&1) {
    const dx=Math.sign(state.player.x-state.enemy.x),dy=Math.sign(state.player.y-state.enemy.y);
    // Native hides its cursor then retries with the SAME delta. The browser
    // cursor is presentation only, so both attempts use identical geometry.
    if(!moveActor(state,geometry,content,'enemy','player',dx,dy))
      caught=!moveActor(state,geometry,content,'enemy','player',dx,dy);
  }
  const p=state.player,w=state.window,escaped=p.x<=w.left+3||p.x>w.left+71||p.y<=w.top+9||p.y>w.top+57;
  let draws=0;const events=[];
  if(caught||escaped) {
    state.status=caught?'caught':'escaped';state.mode=9;state.elapsed=0;
    events.push(caught?'groundCaught':'groundChaseEscaped');
    if(caught) {
      state.direction=4+3*Math.sign(Math.trunc((state.enemy.x-p.x)/3))+Math.sign(Math.trunc((state.enemy.y-p.y)/3));
      const rng=sourceRandom(state.randomState),roll=rng.next();draws++;
      if(roll%16>state.threshold&&state.tile<12)state.kind=16;
      else {state.kind=rng.next()%3===0?22:18;draws++}
      state.randomState=rng.state;
    }
  }
  return {state:validateGroundChase(state),draws,events};
}

export const GROUND_CHASE_TICK_MS=50;
export function advanceGroundChase(previous,content,milliseconds,input={}, {paused=false}={}) {
  let state=validateGroundChase(previous);contentValid(content);controlValid(input);
  if(!integer(milliseconds,0,60000)||typeof paused!=='boolean')fail();
  let draws=0;const events=[];
  if(paused||state.status!=='chasing')return {state,draws,events};
  let elapsed=state.elapsed+milliseconds;
  while(elapsed>=GROUND_CHASE_TICK_MS&&state.status==='chasing') {
    const r=stepGroundChase(state,content,input);state=r.state;draws+=r.draws;events.push(...r.events);elapsed-=GROUND_CHASE_TICK_MS;
  }
  state.elapsed=state.status==='chasing'?elapsed:0;
  return {state,draws,events};
}

// Game21 proc30 reads system word8/nibble3, the same byte/nibble already
// exported as Game16 local32. Resolve it from the ACTUAL ground world.
export function campaignGroundThreatContext(campaign,world,content) {
  const {ground,travel,pod}=campaign??{};
  if(!ground||ground.worldId!==world?.worldId||!['city','surface'].includes(travel?.scene)||
    (travel.scene==='surface')!==(ground.cityId===null)||typeof pod?.occupied!=='boolean')fail();
  const system=content?.navigation?.systems?.find(s=>s.worldIds.includes(ground.worldId));
  const threshold=content?.dialogue?.systems?.systems?.find(s=>s.id===system?.id)?.local32;
  if(!integer(threshold,0,15)||!keys(ground.camera,['x','y'])||
    !integer(ground.camera.x,0,39)||!integer(ground.camera.y,0,23)||
    !keys(travel.cityPosition,['x','y'])||!integer(travel.cityPosition.x,0,1119)||
    !integer(travel.cityPosition.y,0,travel.scene==='city'?767:575))fail();
  const scene=travel.scene==='city'?3:4,height=scene===3?32:24;
  const position={x:wrap(travel.cityPosition.x-ground.camera.x*28,1120),y:wrap(travel.cityPosition.y-ground.camera.y*height,height*24)};
  if(!point(position))fail();
  let tile=null;
  if(scene===3) {
    if(!world.cityIds.has(ground.cityId))fail();
    const map=world.city(ground.cityId,pod.attached).map;
    tile=map.tiles[wrap(ground.camera.y+Math.trunc((position.y-3)/32),24)]
      [wrap(ground.camera.x+Math.trunc((position.x+3)/28),40)]&15;
  }
  return {scene,foot:!pod.occupied,special:ground.cityId==='city-60',position,tile,threshold,
    randomState:campaign.encounters.randomState};
}

// One already-due host tick. Campaign RNG has one owner; the frozen return
// travel/ground/pod records are never replaced with chase screen coordinates.
export function produceCampaignGroundChase(previous,world,content,chaseContent) {
  const context=campaignGroundThreatContext(previous,world,content),gate=groundThreatGate(context);
  const next=structuredClone(previous);next.encounters.randomState=gate.randomState;
  let session=null,draws=gate.draws;
  if(gate.triggered) {
    const r=createGroundChase({position:context.position,tile:context.tile,threshold:context.threshold,randomState:gate.randomState},chaseContent);
    session=r.state;next.encounters.randomState=session.randomState;draws+=r.draws;
  }
  return {campaign:next,session,draws};
}

// Game17 proc10 + Library22 proc51: use the ORIGINAL ground screen pose,
// not the moved chase actor. Initialization alone does not skip Game17's
// mandatory initial Game16 conversation; the host must dispatch it next.
export function initializeCaughtGroundCombat(previous,chaseContent,combatContent,personal) {
  const state=validateGroundChase(previous);contentValid(chaseContent);
  if(state.status!=='caught')throw Error('groundChaseNotCaught');
  const column=Math.trunc((state.origin.x+3)/7),row=Math.trunc((state.origin.y-3)/8);
  const left=7*clamp(column-10,1,19),top=clamp(row*8-48,7,88);
  const bounds={left,top,right:left+139,bottom:top+95};
  const rows=Array.from({length:192},()=>Array(40).fill(0));
  fill(rows,{left:left+2,right:left+137,top:top+2,bottom:top+93},8,chaseContent);
  const arena={width:280,height:192,bounds,collisionRows:combatContent.glyphs[24],glyphs:combatContent.glyphs,backgrounds:{ship:rows}};
  const result=createGroundCombat({...personal,kind:state.kind,direction:state.direction,sceneMid:3,randomState:state.randomState},arena);
  return {...result,arena};
}
