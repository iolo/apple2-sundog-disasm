import { currentShipLocation } from './regional-world.js';
import { validateCargoLot } from './cargo.js';
import { fitsComponent,recalculateEquipment } from './equipment.js';
import { produceShipEncounter,stepShipCombat,fireShipGun,jettisonShipCargo } from './ship-combat.js';

const CONTACT_FLAGS=Object.freeze([29,36,40,41,42,43,44,45,46,47]);
const CONTACT_WORDS=Object.freeze([205,206,207,208,209,214,215,216,217,347,354]);
const integer=(n,lo,hi)=>Number.isInteger(n)&&n>=lo&&n<=hi;
const keys=(v,n)=>v&&typeof v==='object'&&!Array.isArray(v)&&Object.keys(v).length===n.length&&n.every(k=>Object.hasOwn(v,k));
const dense=(v,n)=>Array.isArray(v)&&v.length===n&&Object.keys(v).length===n&&
  Array.from({length:n},(_,i)=>Object.hasOwn(v,i)).every(Boolean);
const fail=()=>{throw Error('invalidCampaignSpace')};
const signature=lot=>JSON.stringify(lot);

// Utility12 $0289–$0291 clears system word8/nibble7 for all12 systems.
// Resource, equipment, cargo and RNG fields have existing campaign owners.
export const initialCampaignSpace=()=>({flags:Array(128).fill(false),
  words:{205:512,206:512,207:0,208:0,209:0,214:0,215:0,216:0,217:127,347:0,354:0},
  rangeMemory:127,cooldowns:Array(12).fill(0),elapsed:0,view:'ship',
  combatFailures:Array(6).fill(false),losses:[],defeat:null});

export function validateSpaceLosses(value) {
  if(!Array.isArray(value)||!dense(value,value.length)||value.length>512)fail();
  const seen=new Set();
  return value.map(entry=>{
    if(!keys(entry,['lot','count'])||!integer(entry.count,1,65535))fail();
    const lot=validateCargoLot(entry.lot,{auxiliaryFuel:true}),key=signature(lot);
    if(seen.has(key)||lot.commodityId==='cargo-31'&&entry.count>17)fail();
    seen.add(key);return {lot,count:entry.count};
  });
}

// Combat recomputes from raw damaged bytes; installation computes with one
// marked byte masked. Keep those caches distinct, including multiple shunts.
export function canonicalCombatEngineeringGroup(group,initial,pending) {
  if(!dense(group?.units,4)||pending===31||!integer(pending,0,18)||pending%5===4)fail();
  const units=group.units.map(u=>{
    if(!dense(u?.components,4))fail();
    return {components:Array.from(u.components,(b,s)=>{
      if(!integer(b,0,255)||(b!==0&&b!==7&&!fitsComponent(initial,b>127?b&31:b,s)))fail();
      return b;
    })};
  });
  if(units[Math.floor(pending/5)].components[pending%5]<=127)fail();
  return recalculateEquipment({...initial,units});
}

export function validateCampaignSpace(campaign,value) {
  if(!keys(value,['flags','words','rangeMemory','cooldowns','elapsed','view','combatFailures','losses','defeat'])||
    !dense(value.flags,128)||!value.flags.every((b,i)=>typeof b==='boolean'&&(CONTACT_FLAGS.includes(i)||!b))||
    !keys(value.words,CONTACT_WORDS.map(String))||!dense(value.cooldowns,12)||!value.cooldowns.every(n=>integer(n,0,15))||
    !dense(value.combatFailures,6)||!value.combatFailures.every(b=>typeof b==='boolean')||
    !integer(value.rangeMemory,0,255)||!integer(value.elapsed,0,249)||!['ship','tactical'].includes(value.view))fail();
  const w=value.words;
  if(![205,206].every(n=>integer(w[n],0,1023))||![207,208,209].every(n=>integer(w[n],-4,4))||
    !integer(w[214],0,3)||!integer(w[215],-32768,32767)||!integer(w[216],0,255)||
    !integer(w[217],0,32767)||!integer(w[347],0,1)||!integer(w[354],-32768,32767))fail();
  if((value.flags[40]||value.view==='tactical'||value.defeat!==null)&&
    (campaign.travel.scene!=='ship'||campaign.pod.occupied||campaign.combat.ground!==null))fail();
  if(value.defeat===null?w[347]!==0||campaign.resources.hull===0:
    !keys(value.defeat,['reason','minutes'])||value.defeat.reason!=='shipDestroyed'||
    value.defeat.minutes!==campaign.ship.minutes||w[347]!==1||value.elapsed!==0)fail();
  return {...structuredClone(value),losses:validateSpaceLosses(value.losses)};
}

export function campaignShipSource(state) {
  const r=state.resources,flags=[...state.space.flags];
  flags[0]=r.warp.charging;flags[1]=r.enginesPowered;flags[2]=r.guns.powered;
  flags[4]=r.shields.targetCharge>0;flags[7]=state.pod.attached;flags[12]=state.machinery.cloaked;
  state.equipment.forEach((g,i)=>flags[16+i]=g.specialAvailable);
  return {flags,words:{...state.space.words,222:r.warp.targetCharge,223:r.warp.charge,
    224:r.shields.targetCharge,225:r.shields.charge,226:r.guns.charge,227:r.fuel,349:0,350:0},
    rangeMemory:state.space.rangeMemory,hull:r.hull,sceneHigh:state.space.defeat?12:state.space.view==='tactical'?1:2,
    shipWorld:currentShipLocation(state).worldId!==null,
    equipment:state.equipment.map((group,i)=>({group:structuredClone(group),pendingFailure:state.engineering.pendingFailures[i]})),
    cargo:structuredClone(state.pod.cargo),randomState:state.encounters.randomState};
}

// Internal commit into an already private campaign clone. Every source helper
// feeds this same owner; a power tick cannot discard combat-owned flags.
export function commitCampaignShipSource(state,source,{combatDamage=false}={}) {
  const r=state.resources,w=source.words,f=source.flags,s=state.space;
  r.hull=source.hull;r.fuel=w[227];r.guns={charge:w[226],powered:f[2]};
  r.shields={charge:w[225],targetCharge:w[224]};r.enginesPowered=f[1];
  r.warp={charge:w[223],targetCharge:w[222],targetSystemId:f[0]?r.warp.targetSystemId:null,charging:f[0]};
  state.machinery.cloaked=f[12];state.pod.cargo=structuredClone(source.cargo);state.encounters.randomState=source.randomState;
  CONTACT_FLAGS.forEach(n=>s.flags[n]=f[n]);CONTACT_WORDS.forEach(n=>s.words[n]=w[n]);s.rangeMemory=source.rangeMemory;
  source.equipment.forEach(({group,pendingFailure},i)=>{
    if(combatDamage&&JSON.stringify(group.units)!==JSON.stringify(state.equipment[i].units)&&pendingFailure!==31)s.combatFailures[i]=true;
    state.equipment[i]=structuredClone(group);state.engineering.pendingFailures[i]=pendingFailure;
  });
  if(w[347]===1&&!s.defeat){s.defeat={reason:'shipDestroyed',minutes:state.ship.minutes};s.elapsed=0}
  return state;
}

// Called after movement, before power. The native non-arrival jump also runs
// the producer; planetary browser overlays keep their declared separate ETA.
export function stepCampaignSpaceProducer(previous,content,{enabled,arrived}) {
  if(!previous.space||!enabled||previous.space.defeat)return previous;
  const next=structuredClone(previous),source=campaignShipSource(next),ship=currentShipLocation(next);
  if(arrived&&source.flags[40])source.words[215]=0; // $049B–$04A6.
  const index=next.start.systems.findIndex(s=>s.id===ship.systemId),system=content.dialogue.systems.systems.find(s=>s.id===ship.systemId);
  if(index<0||!integer(system?.local32,0,15))fail();
  const produced=produceShipEncounter(source,{cityPresent:ship.cityId!==null,
    system:{piracy:system.local32,cooldown:next.space.cooldowns[index]}});
  commitCampaignShipSource(next,produced.state);next.space.cooldowns[index]=produced.system.cooldown;
  return next;
}

export function stepCampaignSpaceCombat(previous) {
  if(!previous.space||!previous.space.flags[40]||previous.space.defeat)return previous;
  const next=structuredClone(previous),result=stepShipCombat(campaignShipSource(next));
  return commitCampaignShipSource(next,result.state,{combatDamage:true});
}

export function finishCampaignSpaceWarp(state) {
  if(state.space){state.space.flags[40]=state.space.flags[47]=false;state.space.view='tactical'}
  return state;
}

// These reducers operate on the actual aboard state. UI sensor/reticle mapping
// and the source bolt-arming confirmation are separate controls, still pending.
export function reduceCampaignSpace(previous,action) {
  if(!previous.space||previous.travel.scene!=='ship'||previous.space.defeat||previous.combat.defeat)throw Error('spaceUnavailable');
  const next=structuredClone(previous);
  if(action.type==='view'&&['ship','tactical'].includes(action.view)) {next.space.view=action.view;return next}
  if(next.space.view!=='tactical')throw Error('spaceUnavailable');
  const index=next.start.systems.findIndex(s=>s.id===currentShipLocation(next).systemId);
  if(action.type==='fire') {
    const result=fireShipGun(campaignShipSource(next),{focused:action.focused,dexterity:next.dialogue.attributes[2]});
    commitCampaignShipSource(next,result.state);next.space.cooldowns[index]=(next.space.cooldowns[index]+result.cooldownIncrement)&15;
  } else if(action.type==='jettison') {
    if(!next.pod.attached)throw Error('spaceCargoUnavailable');
    const result=jettisonShipCargo(campaignShipSource(next),action.selection);
    for(const {lot} of result.jettisoned) {
      const entry=next.space.losses.find(e=>signature(e.lot)===signature(lot));
      if(entry)entry.count++;else next.space.losses.push({lot:structuredClone(lot),count:1});
    }
    next.space.losses=validateSpaceLosses(next.space.losses);
    commitCampaignShipSource(next,result.state);if(result.resetSystemCooldown)next.space.cooldowns[index]=0;
  } else throw Error('spaceUnavailable');
  return next;
}
