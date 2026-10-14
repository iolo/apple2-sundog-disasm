import { initialColony, colonyDemand, reduceCampaignColony, validateColony } from '../js/core/colony.js';
import { campaignSaveCodec } from '../js/core/campaign-saves.js';
import { createCharacter } from '../js/core/character.js';
import { createCityMaps } from '../js/core/city-map.js';
import { createPodGeometry, podServiceAt } from '../js/core/city-pod.js';
import { cityServiceAt } from '../js/core/city-doors.js';
import { validateRegionalCargo } from '../js/core/regional-world.js';
import { colonyPanel } from '../js/ui/colony.js';
import { translator } from '../js/ui/i18n.js';

export async function colonyTests(test,equal) {
  const names=['initial-navigation','initial-economy','initial-location','ship-inventory','ship-walk','maps',
    'city-walk','surface-walk','dialogue','dialogue-text','items','dialogue-systems','ground-chase','ground-combat','exchange-defaults','flight-defaults'];
  const [navigation,economy,location,inventory,walk,maps,cityWalk,surfaceWalk,scripts,text,items,systems,chase,ground,exchange,flight]=
    await Promise.all(names.map(n=>fetch(`../data/${n}.json`).then(r=>r.json())));
  const content={navigation,economy,location,inventory,ground:{maps,cityWalk,surfaceWalk},dialogue:{scripts,text,items,systems},
    exchange,flight,regional:true,combat:{chase,ground},space:true,tactical:true,colony:true};
  const codec=campaignSaveCodec(content,walk),fresh=()=>codec.create({...createCharacter(),name:'Colony pilot'},12345);
  const reject=(f,code)=>{let error;try{f()}catch(e){error=e.message}equal(error,code)};
  const map=createCityMaps(maps,navigation,economy)['city-60'],geometry=createPodGeometry(map,cityWalk,null,{surfaceTravel:true});
  const foot=(()=>{for(let y=0;y<768;y++)for(let x=0;x<1120;x++)if(cityServiceAt(map,{x,y})==='colony')return{x,y}})();
  const pod=(()=>{for(let y=0;y<768;y++)for(let x=0;x<1120;x++)if(podServiceAt(geometry,{x,y},16)==='colony')return{x,y}})();
  const lot=id=>({commodityId:`cargo-${String(id).padStart(2,'0')}`,quality:7,originCity:'city-01',pricePaid:100});
  const service=(s,position=pod,occupied=true)=>{
    s.ground={...s.ground,worldId:'world-01',cityId:'city-60',podCityId:'city-60'};
    s.travel={scene:'city',cityPosition:position};s.pod={...s.pod,attached:false,occupied,position:pod,heading:16};return s;
  };
  await test('Banville Center starts once, consumes one actual pod lot per requirement and advances on the final delivery',()=>{
    let s=service(fresh(),foot,false);equal(cityServiceAt(map,foot),'colony');equal(podServiceAt(geometry,pod,16),'colony');
    s=reduceCampaignColony(s,content,geometry,{type:'enter'});equal([s.colony.completedPhase,s.colony.activePhase],[0,1]);
    equal(colonyDemand(s.colony,content).reduce((a,b)=>a+b,0),4);
    reject(()=>reduceCampaignColony(s,content,geometry,{type:'enter'}),'colonyUnavailable');
    s=reduceCampaignColony(s,content,geometry,{type:'leave'});
    s=service(s);s=reduceCampaignColony(s,content,geometry,{type:'enter'});
    for(const id of [8,9,11]) {
      s.pod.cargo[0]=lot(id);
      s=reduceCampaignColony(s,content,geometry,{type:'deliver',container:'pod',slot:0});
      equal(s.pod.cargo[0],null);
    }
    equal(colonyDemand(s.colony,content)[12],1);
    s.pod.cargo[0]=lot(13);s=reduceCampaignColony(s,content,geometry,{type:'deliver',container:'pod',slot:0});
    equal([s.colony.completedPhase,s.colony.activePhase],[1,2]);
    s.pod.cargo[0]=lot(8);reject(()=>reduceCampaignColony(s,content,geometry,{type:'deliver',container:'pod',slot:0}),'colonyNotNeeded');
    s.pod.cargo[0]=null;s=reduceCampaignColony(s,content,geometry,{type:'leave'});
    s=reduceCampaignColony(s,content,geometry,{type:'enter'});equal([s.colony.completedPhase,s.colony.activePhase],[1,2]);
    equal(colonyDemand(s.colony,content)[30],2);
    equal(validateColony(s.colony,content),s.colony);
  });
  await test('Center warehouse transfers preserve identity and duplicate cryogen receipts fail conservation',()=>{
    let s=service(fresh()),source=s.regional.cities.find(c=>c.warehouse.slots[0]?.commodityId==='cargo-31');
    const cryo=source.warehouse.slots[0];source.warehouse.slots[0]=null;s.pod.cargo[0]=cryo;
    s=reduceCampaignColony(s,content,geometry,{type:'enter'});
    s=reduceCampaignColony(s,content,geometry,{type:'store',slot:0});equal(s.colony.warehouse[0],cryo);equal(s.pod.cargo[0],null);
    s=reduceCampaignColony(s,content,geometry,{type:'fetch',slot:0});equal(s.pod.cargo[0],cryo);equal(s.colony.warehouse[0],null);
    validateRegionalCargo(s.start,s.economy.exchange,s.pod,s.regional,[],{colony:s.colony});
    const bad=structuredClone(s);bad.colony.warehouse[0]=cryo;
    reject(()=>validateRegionalCargo(bad.start,bad.economy.exchange,bad.pod,bad.regional,[],{colony:bad.colony}),'invalidRegional');
  });
  await test('Version 30 preserves phase receipts, rejects overdelivery and migrates version 29 without invented progress',()=>{
    const s=fresh(),old=structuredClone(s);delete old.colony;
    const legacy={format:'sundog-campaign',version:29,scope:'ship-salvage-1',slot:0,savedAt:new Date().toISOString(),state:old};
    const upgraded=codec.parse(JSON.stringify(legacy));equal(upgraded.version,30);equal(upgraded.scope,'colony-contract-1');equal(upgraded.state.colony,initialColony());
    s.colony.activePhase=1;s.colony.receipts=[8,9].map(id=>({phase:1,lot:lot(id)}));s.economy.accounts[0].balance-=200;
    const saved=codec.make(s,0);equal(codec.parse(JSON.stringify(saved)),saved);
    const bad=structuredClone(saved);bad.state.colony.receipts.push({phase:1,lot:lot(8)});
    reject(()=>codec.parse(JSON.stringify(bad)),'invalidCampaign');
    bad.state.colony.receipts.pop();bad.state.colony.completedPhase=1;
    reject(()=>codec.parse(JSON.stringify(bad)),'invalidCampaign');
    bad.state.colony.completedPhase=0;bad.state.economy.accounts[0].balance+=200;
    reject(()=>codec.parse(JSON.stringify(bad)),'invalidCampaign');
  });
  await test('Center panel renders phase demand, pod delivery choices and fulfilled ending in both locales',async()=>{
    const [en,ko]=await Promise.all(['en','ko'].map(id=>fetch(`../locales/${id}.json`).then(r=>r.json())));
    const s=service(fresh());s.colony.activePhase=1;s.pod.cargo[0]=lot(8);
    for(const locale of ['en','ko']) {
      const t=translator({en,ko},locale),html=colonyPanel({state:s,content,t});
      equal(html.includes('id="colony-phase"'),true);equal(html.includes('data-colony-action="deliver"'),true);
      equal(html.includes('id="service-saves"'),true);
      const done=structuredClone(s);done.colony.activePhase=10;done.colony.completedPhase=9;
      equal(colonyPanel({state:done,content,t}).includes('id="colony-ending"'),true);
    }
  });
}
