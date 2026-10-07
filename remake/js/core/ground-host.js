import { conditionHour } from './survival.js';
import { CONDITION_FIELDS } from './condition.js';
import { sourceRandom } from './random.js';
import { reduceCampaignGround } from './campaign-ground.js';
import { groundPointerDelta } from './ground-camera.js';
import { produceGroundEncounter,advanceGroundEncounter,restoreGroundEncounter,idleGroundControl } from './ground-encounter.js';

const keys=(value,names)=>value&&typeof value==='object'&&!Array.isArray(value)&&
  Object.keys(value).length===names.length&&names.every(name=>Object.hasOwn(value,name));
const integer=(value,min,max)=>Number.isInteger(value)&&value>=min&&value<=max;
const fail=()=>{throw Error('invalidGroundHost')};
export const GROUND_HOST_TICK_MS=50;
export const initialGroundClock=()=>({scene:null,moving:false,limit:15,minutesPerTick:1,iterations:0,elapsed:0,podDirection:null});
export function validateGroundClock(value) {
  if(!keys(value,['scene','moving','limit','minutesPerTick','iterations','elapsed','podDirection'])||
    ![null,'city','surface'].includes(value.scene)||typeof value.moving!=='boolean'||
    ![15,10,2].includes(value.limit)||!integer(value.iterations,0,value.limit-1)||!integer(value.elapsed,0,49)||
    !(value.limit===15&&value.minutesPerTick===1||value.moving&&
      (value.scene==='city'&&value.limit===10&&[1,10].includes(value.minutesPerTick)||
       value.scene==='surface'&&value.limit===2&&[20,120].includes(value.minutesPerTick)))||
    value.podDirection!==null&&(!keys(value.podDirection,['x','y'])||
      !integer(value.podDirection.x,-1,1)||!integer(value.podDirection.y,-1,1))||
    value.scene===null&&(value.moving||value.iterations||value.podDirection!==null))fail();
  return structuredClone(value);
}

// Game21 procs27/29/30 and1, Library22 proc29. The50ms logical iteration
// is a declared browser adaptation; source loop limits and minute rates remain.
export function groundClockRate(scene,foot,moving) {
  if(!['city','surface'].includes(scene)||typeof foot!=='boolean'||typeof moving!=='boolean')fail();
  if(!moving)return {limit:15,minutes:1};
  return scene==='city'?{limit:10,minutes:foot?10:1}:{limit:2,minutes:foot?120:20};
}
export function stepGroundClock(previous,{scene,foot,moving,minutes,condition}) {
  const clock=validateGroundClock(previous);groundClockRate(scene,foot,moving);
  if(!integer(minutes,0,Number.MAX_SAFE_INTEGER-1440)||!keys(condition,CONDITION_FIELDS)||
    !CONDITION_FIELDS.every(key=>integer(condition[key],0,255)))fail();
  if(clock.scene!==scene){clock.scene=scene;clock.limit=15;clock.minutesPerTick=1;clock.podDirection=null}
  if(clock.moving!==moving) {
    clock.moving=moving;const rate=groundClockRate(scene,foot,moving);
    clock.limit=rate.limit;clock.minutesPerTick=rate.minutes;
  }
  clock.iterations++;
  if(clock.iterations<clock.limit)return {clock,minutes,condition:{...condition},due:false,dead:false,exhausted:false};
  clock.iterations=0;
  const nextMinutes=minutes+clock.minutesPerTick;
  if(!integer(nextMinutes,0,Number.MAX_SAFE_INTEGER-1440))fail();
  // Source proc29 observes the changed hour once, even when foot travel
  // advances120 minutes. Do not synthesize a second condition update.
  const hourChanged=Math.floor(minutes/60)%24!==Math.floor(nextMinutes/60)%24;
  const update=hourChanged?conditionHour(condition):{condition:{...condition},dead:false,exhausted:false};
  return {clock,minutes:nextMinutes,...update,due:true};
}

export function createGroundHost(campaign) {
  return {campaign:structuredClone(campaign),clock:initialGroundClock(),encounter:null,
    defeated:false,exhausted:false,events:[]};
}

export function restoreCampaignGroundHost(campaign,world,content) {
  if(!campaign.combat)fail();
  const next=createGroundHost(campaign);next.clock=validateGroundClock(campaign.combat.clock);
  if(campaign.combat.ground)next.encounter=restoreGroundEncounter(campaign,world,content,campaign.combat.ground);
  next.defeated=campaign.combat.defeat!==null;
  next.exhausted=next.encounter===null&&campaign.ship.condition.rest===0;
  return next;
}

// One owner moves first, advances the source due clock, then eagerly draws the
// threat gate. Encounter windows own their actors; campaign return poses freeze.
export function advanceGroundHost(previous,world,content,milliseconds,control=idleGroundControl(),{paused=false}={}) {
  const clock=validateGroundClock(previous.clock);
  if(!integer(milliseconds,0,60000)||typeof paused!=='boolean'||
    !keys(control,['move','fire','cancelSurrender','pointer'])||
    ![control.move,control.fire,control.cancelSurrender].every(v=>typeof v==='boolean')||
    control.pointer!==null&&(!keys(control.pointer,['x','y'])||
      !integer(control.pointer.x,0,279)||!integer(control.pointer.y,0,191))||
    (control.move||control.fire)&&control.pointer===null)fail();
  const next=structuredClone(previous);next.clock=clock;next.events=[];
  if(paused||previous.defeated||previous.exhausted)return next;
  if(previous.encounter&&['dialogue','escaped','returned','defeated'].includes(previous.encounter.activation.phase))return next;
  if(!['city','surface'].includes(next.campaign.travel.scene))throw Error('groundHostUnavailable');
  let elapsed=clock.elapsed+milliseconds;
  while(elapsed>=GROUND_HOST_TICK_MS) {
    elapsed-=GROUND_HOST_TICK_MS;
    if(next.encounter) {
      next.encounter=advanceGroundEncounter(next.encounter,content,{type:'tick',control,ticks:1});
      next.campaign=next.encounter.campaign;next.events.push(...next.encounter.events);
      if(!['chase','combat'].includes(next.encounter.activation.phase)){elapsed=0;break}
    } else {
      let sceneChanged=false;
      let movedDirection=null;
      if(control.fire||control.cancelSurrender)throw Error('groundCombatUnavailable');
      if(control.move) {
        // One pointer space for the whole host, including a chase that starts
        // partway through a frame. Only normal travel projects it onto the map.
        const surface=next.campaign.travel.scene==='surface',height=surface?576:768;
        const pointer={x:(control.pointer.x+next.campaign.ground.camera.x*28)%1120,
          y:(control.pointer.y+next.campaign.ground.camera.y*(surface?24:32))%height};
        const delta=groundPointerDelta(next.campaign.travel.cityPosition,pointer,surface);
        const driving=next.campaign.pod.occupied;
        const dx=Math.sign(driving?delta.x>>3:delta.x),dy=Math.sign(driving?delta.y>>3:delta.y);
        movedDirection={x:dx,y:dy};
        const repeated=driving&&clock.podDirection?.x===dx&&clock.podDirection?.y===dy;
        const oldScene=next.campaign.travel.scene;
        if(dx||dy)next.campaign=reduceCampaignGround(next.campaign,world,{type:'move',dx:dx*(repeated?2:1),dy:dy*(repeated?2:1)});
        sceneChanged=next.campaign.travel.scene!==oldScene;
        if(sceneChanged)next.events.push('groundSceneChanged');
      } else clock.podDirection=null;
      const time=stepGroundClock(clock,{scene:next.campaign.travel.scene,foot:!next.campaign.pod.occupied,
        moving:control.move,minutes:next.campaign.ship.minutes,condition:next.campaign.ship.condition});
      Object.assign(clock,time.clock);next.campaign.ship.minutes=time.minutes;next.campaign.ship.condition=time.condition;
      clock.podDirection=movedDirection;
      next.defeated=time.dead;next.exhausted=time.exhausted;
      if(time.due) {
        if(time.dead) {
          // Proc29 changes source scene-middle to12 before the eager gate.
          const random=sourceRandom(next.campaign.encounters.randomState);random.next();
          next.campaign.encounters.randomState=random.state;
        } else {
          const produced=produceGroundEncounter(next.campaign,world,content);
          next.campaign=produced.campaign;
          if(produced.activation){next.encounter=produced;next.events.push('groundChaseStarted')}
        }
      }
      if(next.defeated||next.exhausted||sceneChanged){elapsed=0;break}
    }
  }
  clock.elapsed=elapsed;
  return next;
}
