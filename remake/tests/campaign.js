import { createCampaignStart, CREATION_RECIPE } from '../js/core/campaign.js';
import { createCharacter } from '../js/core/character.js';
import { sourceRandom } from '../js/core/random.js';
import { createInitialEquipment, createInitialSystems, createInitialOrbits } from '../js/core/initialization.js';
import { createInitialEconomy } from '../js/core/economy.js';
import { checkpointCodec } from '../js/core/checkpoints.js';
import { validateDraft } from '../js/core/drafts.js';

export async function campaignTests(test,equal) {
  const [navigation,economy,inventory,location,geometry,captured,native] = await Promise.all([
    '../data/initial-navigation.json','../data/initial-economy.json','../data/ship-inventory.json',
    '../data/initial-location.json','../data/ship-walk.json','fixtures/campaign-reference.json','fixtures/random-reference.json',
  ].map(path=>fetch(path).then(r=>r.json())));
  const content={navigation,economy,inventory,location};
  const character={...createCharacter(),name:' 선독 '};
  const rejects=run=>{let failed=false;try{run()}catch{failed=true}equal(failed,true)};
  await test('Campaign creation keeps saved gameplay RNG separate from generation and follows utility order',()=>{
    for(const vector of native.filter(v=>v.seed!==0 && v.seed!==0x80000000)) {
      const start=createCampaignStart(character,content,vector.seed);
      const saved=vector.draws.slice(0,4).reduce((sum,draw,i)=>sum+(draw.value%256)*2**(8*i),0);
      equal(start.gameplayRandomState,saved);equal(start.credits,vector.draws[4].value%900);
      const random=sourceRandom(vector.draws[4].state);
      equal(start.equipment,createInitialEquipment(random));
      equal(start.systems,createInitialSystems(navigation.systems,random));
      equal(start.worlds,createInitialOrbits(random,0));
      equal(start.economy,createInitialEconomy(economy,random));
      equal(start.creation,{recipe:CREATION_RECIPE,seed:vector.seed,finalRandomState:random.state,firstOrbitComparison:0});
      // Resume gameplay from the saved startup bytes, not the creation tail.
      const resumed=sourceRandom(start.gameplayRandomState),expected=sourceRandom(saved);
      for(let i=0;i<20;i++)equal(resumed.next(),expected.next());
    }
  });
  await test('Campaign start links generated orbit to both captured starting locations and preserves character',()=>{
    const start=createCampaignStart(character,content,0x53444f47);
    equal(start.character,{...createCharacter(),name:'선독'});equal(start.minutes,0);
    equal(start.inventory,{carried:inventory.carried,locker:inventory.locker,stores:inventory.stores});
    equal(start.condition,inventory.condition);
    for(const field of ['playerLocation','shipLocation']) {
      const expected=structuredClone(captured[field]);expected.orbit.angle=start.worlds[0].orbitalAngle;
      equal(start[field],expected);
    }
    equal(start.playerLocation.cityId,'city-01');equal(economy.cities[0].name,'Drahew');
    equal(start.systems[0].id,start.playerLocation.systemId);
    equal(start.systems[0].bankBalance>=29000 && start.systems[0].bankBalance<=31999,true);
    equal(start.credits>=0 && start.credits<900,true);
    // The existing formats cannot accidentally accept this larger creation object.
    rejects(()=>validateDraft(start));rejects(()=>checkpointCodec(geometry).validate(start));
  });
  await test('Campaign creation is atomic, validates input and isolates content, characters and location copies',()=>{
    const before=JSON.stringify({character,content}),start=createCampaignStart(character,content,12345);
    for(const seed of [0,0x80000000,-1,0x100000000,1.5,NaN,'1'])rejects(()=>createCampaignStart(character,content,seed));
    rejects(()=>createCampaignStart({...character,name:''},content,1));
    rejects(()=>createCampaignStart({...character,attributes:{...character.attributes,strength:101}},content,1));
    rejects(()=>createCampaignStart(character,{...content,location:{...location,cityId:'city-60'}},1));
    rejects(()=>createCampaignStart(character,{...content,inventory:{...inventory,carried:[0]}},1));
    rejects(()=>createCampaignStart(character,{...content,navigation:{...navigation,worlds:[]}},1));
    start.character.attributes.strength=50;start.inventory.carried[0]=8;start.condition.health=1;
    start.playerLocation.orbit.angle=999;start.playerLocation.cityPosition.x=999;
    equal(start.shipLocation.orbit.angle,start.worlds[0].orbitalAngle);equal(start.shipLocation.cityPosition,location.cityPosition);
    equal(JSON.stringify({character,content}),before);
    const next=createCampaignStart(character,content,12345);equal(next.character.attributes.strength,30);equal(next.inventory.carried[0],0);
  });
  await test('100 campaign starts replay independently of prior creations and remain JSON serializable',()=>{
    for(let seed=1;seed<=100;seed++) {
      const a=createCampaignStart(character,content,seed);
      createCampaignStart(character,content,seed+10000);
      equal(a,createCampaignStart(character,content,seed));equal(JSON.parse(JSON.stringify(a)),a);
      equal(a.economy.warehouses.flatMap(w=>w.slots.filter(Boolean)).length,17);
      equal(a.worlds.length,18);equal(a.systems.length,12);equal(a.equipment.length,6);
    }
  });
}
