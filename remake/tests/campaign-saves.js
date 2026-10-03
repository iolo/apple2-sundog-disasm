import { campaignSaveCodec, openCampaignStore, CAMPAIGN_LIMIT } from '../js/core/campaign-saves.js';
import { createCharacter } from '../js/core/character.js';
import { makeDraft } from '../js/core/drafts.js';
import { checkpointCodec } from '../js/core/checkpoints.js';
import { recalculateEquipment, exchangeEquipment } from '../js/core/equipment.js';

export async function campaignSaveTests(test,equal) {
  const [navigation,economy,inventory,location,geometry]=await Promise.all([
    '../data/initial-navigation.json','../data/initial-economy.json','../data/ship-inventory.json',
    '../data/initial-location.json','../data/ship-walk.json',
  ].map(path=>fetch(path).then(r=>r.json())));
  const content={navigation,economy,inventory,location},codec=campaignSaveCodec(content,geometry);
  const character={...createCharacter(),name:'선독'},fresh=()=>codec.create(character,0x53444f47);
  const rejects=run=>{let error;try{run()}catch(e){error=e.message}equal(error,'invalidCampaign')};
  const reverseKeys=value=>Array.isArray(value) ? value.map(reverseKeys) : value && typeof value==='object' ?
    Object.fromEntries(Object.entries(value).reverse().map(([key,item])=>[key,reverseKeys(item)])) : value;
  await test('Campaign saves preserve the full creation record and active ship progress independently',()=>{
    const state=fresh();state.ship.inventory.carried[0]=235;state.ship.inventory.stores[10]=0;
    state.ship.condition.nourishment=200;state.ship.minutes=1501;
    const save=codec.make(state,2),restored=codec.parse(JSON.stringify(reverseKeys(save)));
    equal(restored,save);equal(restored.state.start.inventory.carried[0],0);
    equal(restored.state.ship.inventory.carried[0],235);equal(restored.state.start.shipResources.hull,state.start.shipResources.hull);
    equal(restored.state.start.economy,state.start.economy);equal(restored.state.start.gameplayRandomState,state.start.gameplayRandomState);
    restored.state.ship.inventory.carried[0]=0;equal(state.ship.inventory.carried[0],235);
    restored.state.start.podLocation.position.x=999;equal(save.state.start.podLocation.position.x,147);
    equal(JSON.stringify(save).length<CAMPAIGN_LIMIT,true);
  });
  await test('Campaign imports reject stale recipes, altered generation and unsupported progress',()=>{
    const valid=codec.make(fresh(),0),before=JSON.stringify(valid);
    const changes=[
      s=>s.version++,s=>s.scope='travel',s=>s.slot=4,s=>s.savedAt='invalid',
      s=>s.state.start.creation.recipe='shipped-defaults-1',
      s=>s.state.start.creation.finalRandomState++,s=>s.state.start.gameplayRandomState++,
      s=>s.state.start.shipResources.hull=0,s=>s.state.start.shipResources.fuel=1,
      s=>s.state.start.equipment[0].performance++,s=>s.state.start.systems[0].bankBalance++,
      s=>s.state.start.economy.markets[0].demand[0]=99,
      s=>s.state.start.economy.warehouses[0].slots[0]={commodityId:'cargo-31'},
      s=>s.state.start.podAttached=false,s=>s.state.start.destinationLocation.cityId='city-60',
      s=>s.state.ship.condition.vigor=0,s=>s.state.ship.minutes=-1,
      s=>s.state.ship.position={x:0,y:0},s=>s.state.ship.inventory.carried=[0],
      s=>s.state.ship.sleeping=true,s=>s.state.extra='unsupported',s=>s.unrecognized=true,
    ];
    for(const change of changes) {const bad=structuredClone(valid);change(bad);rejects(()=>codec.parse(JSON.stringify(bad)))}
    equal(JSON.stringify(valid),before);
    rejects(()=>codec.parse('{'));rejects(()=>codec.parse(' '.repeat(CAMPAIGN_LIMIT+1)));
    rejects(()=>codec.validate(makeDraft(character,0)));
    rejects(()=>codec.validate(checkpointCodec(geometry).make(valid.state.ship,0)));
  });
  await test('Campaign codec owns its baseline and failed validation cannot replace the active session',()=>{
    const baseline=structuredClone(content),own=campaignSaveCodec(baseline,geometry),state=own.create(character,123);
    baseline.navigation.systems[0].position.x=0;baseline.inventory.carried[0]=8;
    equal(own.create(character,123),state);
    const save=own.make(state,0),before=JSON.stringify(state);let active=state;
    const bad=structuredClone(save);bad.state.start.shipResources.warp.charge=1;
    rejects(()=>{active=own.parse(JSON.stringify(bad)).state});equal(active,state);equal(JSON.stringify(state),before);
  });
  const legacy=()=>{
    const value=codec.make(fresh(),0);delete value.state.equipment;delete value.state.travel;delete value.state.encounters;delete value.state.dialogue;value.version=1;delete value.state.resources;delete value.state.pod;delete value.state.economy;value.scope='landed-ship-1';return value;
  };
  await test('Legacy campaign migration validates first, owns active equipment and preserves recipe2 identity',()=>{
    const old=legacy(),before=JSON.stringify(old),next=codec.parse(before);
    equal(next.version,18);equal(next.scope,'landed-depot-1');equal(next.state.start,old.state.start);
    equal(next.state.ship,old.state.ship);equal(next.state.equipment,old.state.start.equipment.map(recalculateEquipment));
    next.state.equipment[0].units[0].components[0]=0;
    equal(JSON.stringify(old),before);equal(next.state.start,old.state.start);
    for(const mutate of [s=>s.state.equipment=[],s=>s.state.start.equipment[0].spares[0]=23,s=>s.state.ship.extra=true,s=>s.scope='landed-engineering-1']) {
      const bad=structuredClone(old);mutate(bad);rejects(()=>codec.validate(bad));
    }
  });
  await test('Active equipment roundtrips without changing creation, and false ratings or requirements are rejected',()=>{
    const state=fresh();state.ship.position={x:109,y:60};
    const moved=exchangeEquipment(state.equipment,state.ship.inventory,state.ship.position,0,{container:'installed',unit:0,socket:0},{container:'carried',index:0});
    state.equipment=moved.equipment;state.ship.inventory=moved.inventory;
    const value=codec.make(state,0),next=codec.parse(JSON.stringify(value));equal(next,value);
    equal(next.state.equipment[0].units[0].performance,0);equal(next.state.start,fresh().start);
    for(const mutate of [s=>s.state.equipment[0].performance++,s=>s.state.equipment[0].specialAvailable=true,
      s=>s.state.equipment[0].spares[1]=23,s=>s.state.equipment[0].units[0].components[0]=159,
      s=>s.state.equipment[0].units[0].components[0]=28,s=>s.state.equipment[0].extra=true,
      s=>s.state.equipment[0].units[0].extra=true,s=>delete s.state.equipment]) {
      const bad=structuredClone(value);mutate(bad);rejects(()=>codec.validate(bad));
    }
  });
  await test('Upgrading a stored legacy slot uses the raw comparison record and rejects stale writers',async()=>{
    const name=`sundog-legacy-test-${crypto.randomUUID()}`,store=await openCampaignStore(codec,name),old=legacy();
    let db;
    try {
      db=await new Promise((resolve,reject)=>{const r=indexedDB.open(name,1);r.onsuccess=()=>resolve(r.result);r.onerror=()=>reject(r.error)});
      await new Promise((resolve,reject)=>{const tx=db.transaction('checkpoints','readwrite');tx.objectStore('checkpoints').put(old);tx.oncomplete=resolve;tx.onabort=()=>reject(tx.error)});
      equal(await store.list(),[old]);
      const updated=await store.save(codec.validate(old),old);equal(updated.version,18);
      let error;try{await store.save(updated,old)}catch(e){error=e.message}equal(error,'campaignChanged');
      equal(await store.list(),[updated]);
    } finally {db?.close();store.close();indexedDB.deleteDatabase(name)}
  });
  await test('Four campaign slots reopen and reject stale writes without affecting other slots',async()=>{
    const name=`sundog-campaign-test-${crypto.randomUUID()}`;
    let store=await openCampaignStore(codec,name),other;
    const saved=[];
    try {
      for(let slot=0;slot<4;slot++) {
        const state=codec.create({...character,name:`Pilot ${slot}`},slot+1);state.ship.minutes=slot*1440;
        saved.push(await store.save(codec.make(state,slot)));
      }
      store.close();store=await openCampaignStore(codec,name);other=await openCampaignStore(codec,name);
      equal(await store.list(),saved);
      const changed=structuredClone(saved[0]);changed.state.ship.minutes=99;
      await store.save(changed,saved[0]);
      let error;try{await other.save(saved[0],saved[0])}catch(e){error=e.message}equal(error,'campaignChanged');
      error=undefined;
      try{await other.delete(0,saved[0])}catch(e){error=e.message}equal(error,'campaignChanged');
      const corrupt=structuredClone(saved[1]);corrupt.state.start.shipResources.hull=-1;
      error=undefined;
      try{await store.save(corrupt,saved[1])}catch(e){error=e.message}equal(error,'invalidCampaign');
      equal(await store.list(),[changed,...saved.slice(1)]);
      await store.delete(0,changed);equal(await store.list(),saved.slice(1));
    } finally {store.close();other?.close();indexedDB.deleteDatabase(name)}
  });
}
