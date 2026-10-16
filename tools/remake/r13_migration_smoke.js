// Directly imports every historical campaign schema into the current live codec.
async browserPage => {
  const browser=browserPage.context().browser(),page=await browser.newPage(),errors=[];
  page.on('pageerror',error=>errors.push(error.message));
  await page.goto('http://127.0.0.1:8000/');
  await page.waitForFunction(()=>document.documentElement.dataset.ready==='true');
  const result=await page.evaluate(async()=>{
    const [{loadAssets},{campaignSaveCodec},{createCharacter}]=await Promise.all([
      import('/js/render/assets.js'),import('/js/core/campaign-saves.js'),import('/js/core/character.js')]);
    const assets=await loadAssets(),codec=campaignSaveCodec(assets.campaignContent,assets.shipWalk,assets.cityGeometry);
    const original=codec.make(codec.create({...createCharacter(),name:'Migrate'},12345),0);
    const scopes=['landed-ship-1','landed-engineering-1','landed-city-1','landed-bank-1','landed-rooms-1',
      'landed-occupants-1','landed-traffic-1','landed-dialogue-1','landed-lodging-1','landed-taverns-1',
      'landed-services-1','landed-banking-1','landed-exchange-1','landed-purchases-1','landed-personal-trade-1',
      'landed-local-cargo-1','landed-trader-matching-1','landed-depot-1','landed-failures-1','landed-power-1',
      'landed-parking-1','landed-ground-1','regional-flight-1','ground-encounters-1','ship-encounters-1',
      'ship-communication-1','ship-tactical-1','ship-input-1','ship-salvage-1'];
    const versions=[];
    for(let version=1;version<=29;version++) {
      const legacy=structuredClone(original),s=legacy.state;
      legacy.version=version;legacy.scope=scopes[version-1];delete s.colony;
      if(version<29){delete s.space.bounties;delete s.space.wrecks}
      if(version<27)delete s.space.tactical;
      if(version<26){delete s.space.communication;delete s.space.activity}
      if(version<25)delete s.space;
      if(version<24)delete s.combat;
      if(version<23){delete s.regional;delete s.flight}
      if(version<22)delete s.ground;
      if(version<20)delete s.machinery;
      if(version<19)delete s.engineering;
      if(version<18)delete s.resources;
      if(version<16)delete s.pod;else if(version<21)delete s.pod.occupied;
      if(version<12)delete s.economy;
      else {if(version<13)delete s.economy.exchange;if(version<15)delete s.economy.personalTrade}
      if(version<8)delete s.dialogue;else if(version===8)delete s.dialogue.cash;
      if(version<6)delete s.encounters;
      else {if(version<7)delete s.encounters.roomState;if(version<8)delete s.encounters.counter}
      if(version<3)delete s.travel;
      if(version<2)delete s.equipment;
      const before=JSON.stringify(legacy);
      const migrated=codec.validate(legacy);
      if(JSON.stringify(legacy)!==before)throw Error(`Version ${version} import mutated its source`);
      if(migrated.version!==30||migrated.scope!=='colony-contract-1'||JSON.stringify(migrated.state)!==JSON.stringify(original.state))
        throw Error(`Version ${version} failed exact current-state migration`);
      const wrong=structuredClone(legacy);wrong.scope='colony-contract-1';
      let rejected=false;try{codec.validate(wrong)}catch{rejected=true}
      if(!rejected)throw Error(`Version ${version} accepted the wrong scope`);
      versions.push({version,scope:legacy.scope,exact:true,wrongScopeRejected:true});
    }
    return {currentVersion:original.version,currentScope:original.scope,versions};
  });
  await page.close();
  if(errors.length)throw Error(errors.join('; '));
  return {browser:browser.version(),status:'pass',errors,...result};
}
