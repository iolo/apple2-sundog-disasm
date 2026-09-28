import { createCampaignStart, CREATION_RECIPE } from './campaign.js';
import { checkpointCodec, openCheckpointStore } from './checkpoints.js';

export const CAMPAIGN_FORMAT = 'sundog-campaign';
export const CAMPAIGN_LIMIT = 131072;
const VERSION = 1, SCOPE = 'landed-ship-1';
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

// This first save scope supports ship walking/inventory/survival only. `start`
// is the immutable creation record; `ship` is the active state for those rules.
// Economy, navigation and machinery changes require a later scope/version.
export function campaignSaveCodec(content, geometry) {
  // Own the content used for replay validation; later caller edits cannot
  // retroactively change what this codec accepts.
  const baseline=structuredClone(content), walk=checkpointCodec(geometry);
  function snapshot(value) {
    try {
      if (!keysMatch(value,['start','ship']) || value.start?.creation?.recipe!==CREATION_RECIPE) fail();
      const start=createCampaignStart(value.start.character,baseline,value.start.creation.seed);
      if (!sameTree(value.start,start)) fail();
      const ship=walk.snapshot(value.ship);
      if (!sameTree(value.ship,ship)) fail();
      return {start,ship};
    } catch { fail(); }
  }
  function validate(value) {
    if (!keysMatch(value,['format','version','scope','slot','savedAt','state']) ||
        value.format!==CAMPAIGN_FORMAT || value.version!==VERSION || value.scope!==SCOPE ||
        !Number.isInteger(value.slot) || value.slot<0 || value.slot>3 ||
        typeof value.savedAt!=='string' || value.savedAt.length>30 || !Number.isFinite(Date.parse(value.savedAt))) fail();
    return {format:CAMPAIGN_FORMAT,version:VERSION,scope:SCOPE,slot:value.slot,savedAt:value.savedAt,state:snapshot(value.state)};
  }
  return {
    snapshot,validate,
    create(character,seed) {
      const start=createCampaignStart(character,baseline,seed);
      return {start,ship:walk.snapshot({position:start.playerLocation.position,inventory:start.inventory,
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
