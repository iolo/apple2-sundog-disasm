import { sourceRandom } from './random.js';
import { canStand, tryStep } from './ship-walk.js';
import { drawRoomGlyph } from './room-actors.js';

const integer=(n,lo,hi)=>Number.isInteger(n)&&n>=lo&&n<=hi;
const dense=(v,n,test)=>Array.isArray(v)&&v.length===n&&Object.keys(v).length===n&&v.every(test);
const byte=n=>integer(n,0,255);
const signed=n=>((n&65535)^32768)-32768;
const fail=()=>{throw Error('invalidGroundCombat')};
const position=a=>({x:a[1],y:a[0]});
const health=a=>a[3]>>>8;
const skill=a=>a[3]&255;
const cooldown=a=>a[4]&255;
const setCooldown=(a,n)=>{a[4]=(a[4]&256)|(n&255)};
const setHealth=(a,n)=>{a[3]=(n<<8)|skill(a)};
const glyph=a=>a[2]>>>8;
const setGlyph=(a,n)=>{a[2]=(n<<8)|24};
const ready=a=>!!(a[4]&256);

function validateArena(arena) {
  const b=arena?.bounds;
  if(!integer(arena?.width,94,280)||!integer(arena?.height,66,192)||
    ![22,23,25].every(n=>dense(arena.glyphs?.[n],8,v=>integer(v,0,127)))||
    !dense(arena.collisionRows,8,v=>v===127)||
    !dense(arena.backgrounds?.ship,arena.height,row=>dense(row,Math.ceil(arena.width/7),v=>integer(v,0,127)))||
    !integer(b?.left,0,arena.width-94)||!integer(b?.right,b.left+93,arena.width-1)||
    !integer(b?.top,0,arena.height-66)||!integer(b?.bottom,b.top+65,arena.height-1))fail();
  return arena;
}

function personal(value) {
  if(!dense(value?.attributes,5,(n)=>integer(n,0,100))||value.attributes.slice(0,4).some(n=>n<30)||
    !dense(value.condition,4,byte)||!dense(value.carried,4,byte)||
    !dense(value.flags,128,n=>typeof n==='boolean')||!integer(value.cash,0,32767999)||
    !integer(value.randomState,0,0xffffffff))fail();
  sourceRandom(value.randomState);
}

// Game17's native activation record becomes an owned JSON session. Geometry is
// supplied by the host; source indices1..6 are array indices0..5 here.
export function validateGroundCombat(value,arena) {
  validateArena(arena);personal(value);
  if(![15,16,18,22].includes(value.kind)||!integer(value.mode,0,2)||
    !Array.isArray(value.actors)||!integer(value.actors.length,1,6)||
    Object.keys(value.actors).length!==value.actors.length||
    !value.actors.every((a,i)=>dense(a,5,n=>integer(n,0,65535))&&
      integer(a[0],7,arena.height-1)&&integer(a[1],0,arena.width-7)&&
      (a[2]&255)===24&&[i===0?22:23,25].includes(glyph(a))&&skill(a)<=10&&a[4]<=511)||
    !dense(value.history,7,h=>h&&integer(h.x,0,arena.width-7)&&integer(h.y,7,arena.height-1)&&
      integer(h.dx,-1,1)&&integer(h.dy,-1,1))||!integer(value.historyIndex,0,6)||
    !integer(value.shieldSlot,0,4)||!integer(value.shieldCharges,-32768,32767)||
    typeof value.shieldActive!=='boolean'||typeof value.scatter!=='boolean'||
    !integer(value.scatterCharges,-32768,32767)||typeof value.done!=='boolean'||
    typeof value.lastEnemyKilled!=='boolean'||!integer(value.sceneMid,0,15)||
    !integer(value.elapsed,0,GROUND_TICK_MS-1)||
    !value.workspace||![8,9,10,11,12].every(n=>byte(value.workspace[n])))fail();
  if(value.shieldActive&&(value.shieldSlot===4||(value.carried[value.shieldSlot]&31)!==11)||
    value.scatter&&(value.carried[0]&31)!==13)fail();
  return structuredClone(value);
}

function stream(state) {
  const rng=sourceRandom(state.randomState);let draws=0;
  return {next(){draws++;const n=rng.next();state.randomState=rng.state;return n},
    range(lo,hi){return lo+this.next()%(hi-lo+1)},get draws(){return draws}};
}

function geometry(arena,state,excluded,{hidePlayer=false}={}) {
  const rows=arena.backgrounds.ship.map(row=>[...row]);
  for(const [i,a] of state.actors.entries())if(i!==excluded&&!(i===0&&hidePlayer))
    drawRoomGlyph(rows,position(a),arena.glyphs[glyph(a)]);
  return {...arena,backgrounds:{ship:rows}};
}

// Procedures6/7: masked shield/weapon IDs; the first weapon swaps into slot0.
// The native zero-charge underflow is retained rather than silently refilled.
function shield(state) {
  const index=state.carried.findIndex(n=>(n&31)===11);
  state.shieldSlot=index<0?4:index;state.shieldActive=index>=0;
  state.shieldCharges=index<0?0:state.carried[index]>>>5;
}
function weapon(state) {
  state.actors[0][4]&=255;state.scatter=false;state.scatterCharges=0;
  const slot=state.carried.findIndex(n=>[12,13].includes(n&31));
  if(slot<0)return;
  if(slot!==0) {
    [state.carried[0],state.carried[slot]]=[state.carried[slot],state.carried[0]];
    if(state.shieldSlot===0)state.shieldSlot=slot;
  }
  state.actors[0][4]|=256;state.scatter=(state.carried[0]&31)===13;
  if(state.scatter)state.scatterCharges=state.carried[0]>>>5;
}
function knocked(state) {
  state.mode=1;setCooldown(state.actors[0],state.flags[48]?2:10);
  if(health(state.actors[0])===0)state.sceneMid=12;
}
function remove(state,index) {
  state.actors.splice(index,1);
  if(state.actors.length===1)state.done=true;
}

// Procedures9/11. The caller supplies the prepared combat window and approach
// direction produced by Game21; fresh kind16 chooses2..6 total actors.
export function createGroundCombat(input,arena) {
  validateArena(arena);personal(input);
  if(![16,18,22].includes(input.kind)||!integer(input.direction,0,8))fail();
  const state={kind:input.kind,mode:0,attributes:[...input.attributes],condition:[...input.condition],
    carried:[...input.carried],cash:input.cash,flags:[...input.flags],randomState:input.randomState,
    actors:[],history:[],historyIndex:0,shieldSlot:4,shieldCharges:0,shieldActive:false,
    scatter:false,scatterCharges:0,done:false,lastEnemyKilled:false,sceneMid:input.sceneMid??3,
    elapsed:0,workspace:{8:0,9:4,10:2,11:0,12:0}};
  const rng=stream(state),b=arena.bounds,count=input.kind===16?rng.range(2,6):2;
  state.flags[50]=input.kind!==16;state.flags[48]=state.flags[49]=state.flags[65]=state.flags[66]=false;
  const p=[b.top+51,b.left+67,22*256+24,
    Math.max(33,Math.trunc(input.condition[2]*input.attributes[0]/90)&255)*256+Math.trunc(input.attributes[2]/10),0];
  if(!canStand(arena,position(p)))throw Error('groundCombatPlacementUnavailable');
  state.actors.push(p);state.history=Array.from({length:7},()=>({...position(p),dx:0,dy:0}));
  state.workspace[11]=count-1;
  for(let index=1;index<count;index++) {
    const hp=rng.range(70,250),rating=rng.next()%5+rng.next()%5,timer=rng.range(10,15)-rating;
    const a=[p[0],p[1],23*256+24,hp*256+rating,timer|256];
    if(index===1) {
      a[1]+=7*(Math.trunc(input.direction/3)-1);a[0]+=8*(input.direction%3-1);
      // The native adjacent actor is drawn directly; reject an unsupported
      // prepared window rather than consume extra draws to reposition it.
      if(!canStand(geometry(arena,state,-1),position(a)))throw Error('groundCombatPlacementUnavailable');
    } else {
      // Native retries forever. Detect repeated RNG states to reject an
      // impossible window atomically, with an additional browser work bound.
      const seen=new Set();let placed=false;
      for(let attempts=0;attempts<65536;attempts++) {
        if(seen.has(state.randomState))break;seen.add(state.randomState);
        a[1]=rng.range(b.left+20,b.right-20);a[0]=rng.range(b.top+10,b.bottom-10);
        if(canStand(geometry(arena,state,-1),position(a))){placed=true;break}
      }
      if(!placed)throw Error('groundCombatPlacementUnavailable');
    }
    state.actors.push(a);
  }
  shield(state);if(!state.flags[50])weapon(state);
  return {state:validateGroundCombat(state,arena),draws:rng.draws};
}

// Procedures13/14: strict rectangular tolerance, Manhattan distance, eager
// gate draw, then shield charge OR a separate damage draw. The native scan can
// read one record beyond the active array; the browser scans active actors.
function shot(state,shooter,aim,rng,events,shots) {
  const a=state.actors[shooter],radius=shooter===0?skill(a):3;
  const distance=Math.abs(a[1]-aim.x)+Math.abs(a[0]-aim.y)-(shooter===0?state.attributes[1]:0);
  const allowed=distance<3*radius+rng.next()%128;
  const target=allowed?state.actors.findIndex(b=>health(b)!==0&&Math.abs(b[1]-aim.x)<radius&&Math.abs(b[0]-aim.y)<radius):-1;
  if(target===shooter)throw Error('groundCombatSelfShot'); // Native SYSTEMERROR17,14.
  const receipt={shooter:shooter+1,aim:{...aim},target:target<0?null:target+1,damage:0,shield:false};
  shots.push(receipt);if(target<0)return;
  if(target===0&&state.shieldActive) {
    state.shieldCharges=signed(state.shieldCharges-1);receipt.shield=true;events.push('personalShieldHit');
    if(state.shieldCharges===0){state.carried[state.shieldSlot]=7;shield(state);events.push('personalShieldExhausted')}
    return;
  }
  const victim=state.actors[target],damage=4*(rng.next()%16),hp=health(victim);
  setHealth(victim,Math.max(0,hp-damage));receipt.damage=hp-health(victim);
  events.push('groundHit');
  if(health(victim)<=32) {
    setGlyph(victim,25);
    if(target===0){knocked(state);events.push(health(victim)===0?'playerKilled':'playerKnockedOut')}
    else if(health(victim)===0) {
      remove(state,target);events.push('groundEnemyKilled');state.lastEnemyKilled=state.actors.length===1;
      if(state.lastEnemyKilled)state.kind=15;
    } else events.push('groundEnemyKnockedOut');
  }
}

// Source primitive, also useful for independent damage fixtures. Player ammo
// expenditure is owned by stepGroundCombat, which resolves the full volley.
export function fireGroundShot(previous,arena,{shooter,aim}={}) {
  const state=validateGroundCombat(previous,arena);
  if(!integer(shooter,1,state.actors.length)||!integer(aim?.x,-32768,32767)||!integer(aim?.y,-32768,32767))fail();
  if(state.done||state.sceneMid===12)throw Error('groundCombatInactive');
  const rng=stream(state),events=[],shots=[];shot(state,shooter-1,aim,rng,events,shots);
  return {state,draws:rng.draws,events,shots};
}

function moveActor(state,arena,index,dx,dy,hidePlayer=false) {
  const a=state.actors[index],next=tryStep(geometry(arena,state,index,{hidePlayer}),position(a),dx,dy);
  const moved=next.x!==a[1]||next.y!==a[0];a[1]=next.x;a[0]=next.y;return moved;
}
function outside(a,b,player) {
  return a[1]<=b.left+(player?7:5)||a[1]>b.right-12||a[0]<=b.top+(player?12:10)||a[0]>b.bottom-(player?8:5);
}
function controls(input,arena) {
  const {move=false,fire=false,cancelSurrender=false,pointer=null}=input??{};
  if(![move,fire,cancelSurrender].every(v=>typeof v==='boolean')||
    pointer!==null&&(!integer(pointer.x,0,arena.width-1)||!integer(pointer.y,0,arena.height-1))||
    (move||fire)&&pointer===null)fail();
  return {move,fire,cancelSurrender,pointer};
}

// One logical iteration: player proc16, THEN every NPC proc17. Rendering and
// the pointer graphic never alter collision or consume gameplay random draws.
export function stepGroundCombat(previous,arena,input={}) {
  const state=validateGroundCombat(previous,arena),control=controls(input,arena),rng=stream(state),events=[],shots=[];
  if(state.done||state.sceneMid===12)return {state,draws:0,events,shots};
  const p=state.actors[0];let dx=0,dy=0;
  if(health(p)<=32||state.flags[48]) {
    if(state.flags[48]&&state.mode===1&&control.cancelSurrender){state.mode=0;setCooldown(p,0);state.flags[48]=false;events.push('surrenderCancelled')}
    else if(cooldown(p)>0)setCooldown(p,cooldown(p)-1);
    if(cooldown(p)===0&&state.mode===1) {
      if(!state.flags[48])state.carried.fill(0);
      state.cash=0;state.scatter=state.shieldActive=false;state.mode=2;state.flags[48]=false;
      events.push('groundRobbed');
    } else if(cooldown(p)===0&&state.actors.length===1){state.done=true;state.flags[48]=false}
  } else {
    if(control.move) {
      dx=Math.sign(control.pointer.x-3-p[1]);dy=Math.sign(control.pointer.y+3-p[0]);
      moveActor(state,arena,0,dx,dy);
    }
    if(outside(p,arena.bounds,true)){state.done=true;events.push('playerEscaped')}
    if(control.fire&&ready(p)&&state.mode<=2) {
      const aim={x:control.pointer.x-3,y:control.pointer.y+3};
      shot(state,0,aim,rng,events,shots);
      if(state.scatter) {
        for(const [x,y] of [[0,-6],[0,3],[6,-6],[-3,-6]])shot(state,0,{x:aim.x+x,y:aim.y+y},rng,events,shots);
        state.scatterCharges=signed(state.scatterCharges-1);
        if(state.scatterCharges===0){state.carried[0]=7;weapon(state);events.push('scattergunExhausted')}
      }
      state.mode=0;
    }
  }
  // Jump pointers $0B3C/$0B3E both target $0AFF, including knocked-out ticks.
  state.historyIndex=(state.historyIndex+1)%7;state.history[state.historyIndex]={...position(p),dx,dy};
  for(let index=1;index<state.actors.length;index++) {
    const h=state.history[rng.next()%7],a=state.actors[index];
    if(cooldown(a)>0)setCooldown(a,cooldown(a)-1);
    if(health(a)<=32) {
      if(cooldown(a)===0) {
        if(health(a)>0){setGlyph(a,23);setHealth(a,33);events.push('groundEnemyRecovered')}
        else {remove(state,index--);events.push('groundEnemyRemoved')}
      }
      continue;
    }
    const distance=Math.abs(h.x-a[1])+Math.abs(h.y-a[0]);
    let mx=0,my=0;
    if(state.mode===2||state.flags[50]){mx=Math.sign(a[1]-h.x);my=Math.sign(a[0]-h.y)}
    else if(distance>35||state.mode===1){mx=Math.sign(h.x-a[1]);my=Math.sign(h.y-a[0])}
    else if(rng.next()&1)mx=h.dx;else my=h.dy;
    // Native repeats after hiding its pointer. Only the subsequent mode2
    // retry changes collision: it temporarily removes the player's glyph.
    if(!moveActor(state,arena,index,mx,my)&&state.mode===2)moveActor(state,arena,index,mx,my,true);
    if(outside(a,arena.bounds,false)){remove(state,index--);events.push('groundEnemyDeparted');continue}
    if(state.mode===0&&cooldown(a)===0&&!state.flags[50]) {
      shot(state,index,{x:h.x,y:h.y},rng,events,shots);
      // Procedure4 compacts native records in place. Its retained slot pointer
      // can now refer to another actor after friendly fire on an earlier slot.
      if(state.actors[index])setCooldown(state.actors[index],10-skill(state.actors[index]));
    }
  }
  return {state,draws:rng.draws,events,shots};
}

// Procedure12 writes personal health/vigor and packed charges before leaving
// or suspending for dialogue/save. Actors/history remain intact for a resume.
export function checkpointGroundCombat(previous,arena) {
  const state=validateGroundCombat(previous,arena);
  if(state.shieldActive)state.carried[state.shieldSlot]=(11+(state.shieldCharges<<5))&255;
  if(state.scatter)state.carried[0]=(13+(state.scatterCharges<<5))&255;
  state.condition[2]=Math.trunc(90*health(state.actors[0])/state.attributes[0])&255;
  state.condition[0]=Math.min(state.condition[0],2*state.condition[2]);
  return state;
}

// Procedure11 resume: interpreted dialogue flags/money/inventory return to the
// existing activation record; no NPC is regenerated and no RNG is drawn.
export function resumeGroundCombat(previous,arena,personalState) {
  const state=validateGroundCombat(previous,arena);personal(personalState);
  if(state.done||state.sceneMid===12)throw Error('groundCombatInactive');
  for(const field of ['attributes','condition','carried','flags'])state[field]=[...personalState[field]];
  state.cash=personalState.cash;state.randomState=personalState.randomState;
  if(state.flags[48])knocked(state);
  else if(state.flags[49]){state.mode=2;state.flags[49]=false}
  shield(state);state.scatter=false;state.scatterCharges=0;state.actors[0][4]&=255;
  if(!state.flags[50])weapon(state);
  return {state,draws:0};
}

// Explicit browser cadence; elapsed is serializable. Equal elapsed time with
// the same held input resolves the same logical ticks at any display refresh.
export const GROUND_TICK_MS=50;
export function advanceGroundCombat(previous,arena,milliseconds,input={}, {paused=false}={}) {
  let state=validateGroundCombat(previous,arena);controls(input,arena);
  if(!integer(milliseconds,0,60000)||typeof paused!=='boolean')fail();
  let draws=0;const events=[],shots=[];
  if(paused||state.done||state.sceneMid===12)return {state,draws,events,shots};
  let elapsed=state.elapsed+milliseconds;
  while(elapsed>=GROUND_TICK_MS&&!state.done&&state.sceneMid!==12) {
    const r=stepGroundCombat(state,arena,input);state=r.state;draws+=r.draws;events.push(...r.events);shots.push(...r.shots);elapsed-=GROUND_TICK_MS;
  }
  state.elapsed=state.done||state.sceneMid===12?0:elapsed;
  return {state,draws,events,shots};
}
