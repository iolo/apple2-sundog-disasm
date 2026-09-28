import { validateCharacter } from './character.js';
import { sourceRandom } from './random.js';
import { createInitialEquipment, createInitialShipResources, createInitialSystems, createInitialOrbits } from './initialization.js';
import { createInitialEconomy } from './economy.js';
import { createInventory, CAPACITY } from './inventory.js';
import { createCondition, CONDITION_FIELDS } from './condition.js';

// Versioned creation recipe, not a campaign save codec. UI/draft/checkpoint
// schemas do not accept this object. Remaining scene/encounter flags come later.
// Recipe2 corrects recipe1's omitted utility20 hull draw before world generation.
export const CREATION_RECIPE = 'shipped-defaults-2';
const integer = (n,min,max) => Number.isInteger(n) && n>=min && n<=max;
const point = (p,xmax,ymax) => integer(p?.x,0,xmax) && integer(p?.y,0,ymax);

export function createCampaignStart(character, content, seed) {
  const player = validateCharacter(character);
  // Original zero states cannot generate valid spaced orbits. Reject explicitly;
  // never retry with a different hidden seed or partially return a campaign.
  if (!integer(seed,1,0xffffffff) || seed===0x80000000) throw new Error('Invalid campaign seed');
  const {navigation,economy,inventory,location} = content ?? {};
  if (navigation?.version!==1 || !Array.isArray(navigation.worlds) || navigation.worlds.length!==18 ||
      navigation.worlds.some((w,i)=>w?.id!==`world-${String(i+1).padStart(2,'0')}` || !integer(w.orbitalRadius,0,255)) ||
      location?.version!==1 || location.systemId!=='system-01' || location.worldId!=='world-01' ||
      !economy?.cities?.some(c=>c.id===location.cityId && c.worldId===location.worldId) ||
      location.orbitalRadius!==navigation.worlds[0].orbitalRadius ||
      !point(location.surfacePosition,39,23) || !point(location.cityPosition,19,11) ||
      !point(location.playerPosition,273,191) || !point(location.shipPosition,273,191) ||
      Object.entries(CAPACITY).some(([key,size])=>!Array.isArray(inventory?.[key]) || inventory[key].length!==size ||
        Array.from(inventory[key]).some(n=>!integer(n,0,255))) ||
      CONDITION_FIELDS.some(key=>!integer(inventory?.condition?.[key],0,255))) throw new Error('Invalid campaign content');
  const random = sourceRandom(seed);
  // Utility21 $0912–$0921, then $09D2–$09DE. Startup7 later restores these
  // four saved bytes to the live RNG; it does NOT use the generation tail.
  let gameplayRandomState=0;
  for(let byte=0;byte<4;byte++) gameplayRandomState += (random.next()%256)*2**(8*byte);
  const credits = random.next()%900;
  const equipment = createInitialEquipment(random);
  const shipResources = createInitialShipResources(random);
  const systems = createInitialSystems(navigation.systems,random);
  // Browser recipe explicitly fixes the original uninitialized first comparison
  // to0 and always uses immutable shipped defaults, independent of prior games.
  const worlds = createInitialOrbits(random,0);
  const cities = createInitialEconomy(economy,random);
  const common = {
    systemId:location.systemId,worldId:location.worldId,cityId:location.cityId,
    orbit:{angle:worlds[0].orbitalAngle,radius:location.orbitalRadius},
    surfacePosition:{...location.surfacePosition},cityPosition:{...location.cityPosition},
  };
  return {
    kind:'sundog-campaign-start',version:1,
    creation:{recipe:CREATION_RECIPE,seed,finalRandomState:random.state,firstOrbitComparison:0},
    gameplayRandomState,character:player,credits,minutes:0,
    inventory:createInventory(inventory),condition:createCondition(inventory.condition),
    equipment,shipResources,systems,worlds,economy:cities,
    playerLocation:{...structuredClone(common),position:{...location.playerPosition}},
    shipLocation:{...structuredClone(common),position:{...location.shipPosition}},
    // Utility18 copies all three independently. Destination is inactive while
    // engines are off; it is not an additional ship or the player's position.
    destinationLocation:{...structuredClone(common),position:{...location.shipPosition}},
    podLocation:{...structuredClone(common),position:{...location.shipPosition}},
    podAttached:true,
  };
}
