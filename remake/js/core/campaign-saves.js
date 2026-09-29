import { createCampaignStart, CREATION_RECIPE } from './campaign.js';
import { checkpointCodec, openCheckpointStore } from './checkpoints.js';
import { fitsComponent, recalculateEquipment } from './equipment.js';
import { cityReachability, SHIP_REENTRY } from './city-walk.js';

export const CAMPAIGN_FORMAT = 'sundog-campaign';
export const CAMPAIGN_LIMIT = 131072;
const VERSION = 3, SCOPE = 'landed-city-1';
const cityValidators=new WeakMap();
const fail = () => { throw new Error('invalidCampaign'); };
const keysMatch = (value, keys) => value && typeof value==='object' && !Array.isArray(value) &&
  Object.keys(value).length===keys.length && keys.every(key=>Object.hasOwn(value,key));

// Compare against the bounded generated tree; key order is irrelevant. Extra
// fields and unsupported progress fail instead of being silently discarded.
function sameTree(value, expected) {
  if (expected===null || typeof expected!=='object') return value===expected;
  if (Array.isArray(expected)) return Array.isArray(value) && value.length===expected.length &&
    Object.keys(value).length===expected.length && expected.every((item,i)=>sameTree(value[i],item));
  const keys=Object.keys(expected);
  return keysMatch(value,keys) && keys.every(key=>sameTree(value[key],expected[key]));
}

// `start` remains immutable; equipment is active, independently owned state.
// Machinery stays off; navigation, power, fuel and economy changes remain gated.
export function campaignSaveCodec(content, geometry, cityGeometry=null) {
  // Own the content used for replay validation; later caller edits cannot
  // retroactively change what this codec accepts.
  const baseline=structuredClone(content), walk=checkpointCodec(geometry);
  function snapshot(value, version = VERSION) {
    try {
      if (!keysMatch(value,version===1 ? ['start','ship'] : version===2 ? ['start','ship','equipment'] : ['start','ship','equipment','travel']) || value.start?.creation?.recipe!==CREATION_RECIPE) fail();
      const start=createCampaignStart(value.start.character,baseline,value.start.creation.seed);
      if (!sameTree(value.start,start)) fail();
      const ship=walk.snapshot(value.ship);
      if (!sameTree(value.ship,ship)) fail();
      let equipment;
      if (version===1) equipment=start.equipment.map(recalculateEquipment);
      else {
        if (!Array.isArray(value.equipment) || value.equipment.length!==6 || Object.keys(value.equipment).length!==6) fail();
        equipment=value.equipment.map((group,i)=>{
          const initial=start.equipment[i];
          if (!Array.isArray(group?.units) || group.units.length!==4) fail();
          for (const unit of group.units) {
            if (!Array.isArray(unit?.components) || unit.components.length!==4 ||
                Array.from(unit.components).some((byte,socket)=>!Number.isInteger(byte) || (byte!==0 && byte!==7 && !fitsComponent(initial,byte,socket)))) fail();
          }
          const expected=recalculateEquipment({...initial,units:group.units});
          if (!sameTree(group,expected)) fail();
          return expected;
        });
      }
      let travel={scene:'ship',cityPosition:null};
      if(version===VERSION) {
        if(!keysMatch(value.travel,['scene','cityPosition']))fail();
        if(value.travel.scene==='city') {
          if(!cityGeometry||!keysMatch(value.travel.cityPosition,['x','y'])||!sameTree(ship.position,SHIP_REENTRY))fail();
          if(!cityValidators.has(cityGeometry))cityValidators.set(cityGeometry,cityReachability(cityGeometry));
          if(!cityValidators.get(cityGeometry)(value.travel.cityPosition))fail();
          travel={scene:'city',cityPosition:{...value.travel.cityPosition}};
        } else if(!sameTree(value.travel,travel))fail();
      }
      return {start,ship,equipment,travel};
    } catch { fail(); }
  }
  function validate(value) {
    const legacy=(value?.version===1 && value.scope==='landed-ship-1') ||
      (value?.version===2 && value.scope==='landed-engineering-1');
    if (!keysMatch(value,['format','version','scope','slot','savedAt','state']) ||
        value.format!==CAMPAIGN_FORMAT || (!legacy && (value.version!==VERSION || value.scope!==SCOPE)) ||
        !Number.isInteger(value.slot) || value.slot<0 || value.slot>3 ||
        typeof value.savedAt!=='string' || value.savedAt.length>30 || !Number.isFinite(Date.parse(value.savedAt))) fail();
    return {format:CAMPAIGN_FORMAT,version:VERSION,scope:SCOPE,slot:value.slot,savedAt:value.savedAt,state:snapshot(value.state,value.version)};
  }
  return {
    snapshot:value=>snapshot(value),validate,
    create(character,seed) {
      const start=createCampaignStart(character,baseline,seed);
      return {start,travel:{scene:'ship',cityPosition:null},equipment:start.equipment.map(recalculateEquipment),ship:walk.snapshot({position:start.playerLocation.position,inventory:start.inventory,
        condition:start.condition,minutes:start.minutes})};
    },
    make: (state,slot) => validate({format:CAMPAIGN_FORMAT,version:VERSION,scope:SCOPE,slot,savedAt:new Date().toISOString(),state}),
    parse(text) {
      if (typeof text!=='string' || text.length>CAMPAIGN_LIMIT) fail();
      let value;try {value=JSON.parse(text)} catch {fail()}
      return validate(value);
    },
  };
}

// Reuse the tested transactional compare-before-write mechanism while keeping
// the database and error vocabulary separate from drafts and walkthroughs.
export async function openCampaignStore(codec, name='sundog-campaigns') {
  const translate = error => new Error(({checkpointChanged:'campaignChanged',
    checkpointStorageUnavailable:'campaignStorageUnavailable',invalidCheckpoint:'invalidCampaign'})[error.message] || error.message);
  let store;
  try { store=await openCheckpointStore(codec,name); } catch(error) {throw translate(error)}
  const run = async action => {try {return await action()} catch(error) {throw translate(error)}};
  return {
    list:()=>run(()=>store.list()),
    save:(value,expected=null)=>run(()=>store.save(value,expected)),
    delete:(slot,expected)=>run(()=>store.delete(slot,expected)),
    close:()=>store.close(),
  };
}
