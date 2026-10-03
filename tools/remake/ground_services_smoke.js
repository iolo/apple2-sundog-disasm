// Declared parked-pod fixtures isolate service geometry at newly accessible
// city positions. Import, repair, refuel and save/reload use ordinary UI.
async browserPage => {
  const browser=browserPage.context().browser(),checks=[],errors=[];
  const context=await browser.newContext({viewport:{width:1280,height:720}}),page=await context.newPage();
  page.on('pageerror',e=>errors.push(e.message));page.on('dialog',d=>d.accept());
  const assert=(v,name)=>{if(!v)throw Error(name);checks.push(name)};
  const settled=()=>page.waitForFunction(()=>document.querySelector('#checkpoint-back')?.disabled===false);
  const ready=()=>page.waitForFunction(()=>document.documentElement.dataset.ready==='true');
  const exported=async()=>{
    await page.locator('#service-saves').click();await settled();const pending=page.waitForEvent('download');await page.locator('#export-checkpoint').click();
    let text='';for await(const p of await(await pending).createReadStream())text+=p;
    await settled();await page.locator('#checkpoint-back').click();return JSON.parse(text);
  };
  try {
    await page.addInitScript(()=>localStorage.setItem('sundog.locale','en'));
    await page.goto('http://127.0.0.1:8000/');await ready();
    const fixture=await page.evaluate(async()=>{
      const {loadAssets}=await import('/js/render/assets.js'),a=await loadAssets();
      const {campaignSaveCodec}=await import('/js/core/campaign-saves.js'),{createCharacter}=await import('/js/core/character.js');
      const {createGroundWorld}=await import('/js/core/campaign-ground.js'),{groundCameraAt}=await import('/js/core/ground-camera.js');
      const {podReachability}=await import('/js/core/city-pod.js'),{cityReachability,SHIP_REENTRY}=await import('/js/core/city-walk.js');
      const {cityServiceAt}=await import('/js/core/city-doors.js');
      const codec=campaignSaveCodec(a.campaignContent,a.shipWalk,a.cityGeometry),s=codec.create({...createCharacter(),name:'Outer parking'},12345);
      const world=createGroundWorld({...a.campaignContent,...a.campaignContent.ground},s.start),city=world.city('city-01',false),reachable=podReachability(city.pod);
      let pod;
      for(let y=220;y<500&&!pod;y++)for(let x=270;x<280;x++)if(reachable({x,y},16)){pod={x,y};break}
      if(!pod)throw Error('Missing reachable outer street fixture');
      s.pod={...s.pod,attached:false,occupied:false,position:pod,heading:16};
      const foot=world.foot(s),walkable=cityReachability(foot);let position;
      for(let y=199;y<575&&!position;y++)for(let x=280;x<834;x++)if(cityServiceAt(city.map,{x,y})==='depot'&&walkable({x,y})){position={x,y};break}
      if(!position)throw Error('Missing foot depot fixture');
      s.ship.position={...SHIP_REENTRY};s.travel={scene:'depot',cityPosition:position};s.ground.camera=groundCameraAt(position);
      return codec.make(s,0);
    });
    await page.locator('#campaign-saves').click();await settled();
    const download=page.waitForEvent('download');await page.evaluate(v=>{
      const a=document.createElement('a'),url=URL.createObjectURL(new Blob([JSON.stringify(v)],{type:'application/json'}));a.href=url;a.download='ground-services.json';a.click();setTimeout(()=>URL.revokeObjectURL(url),1000);
    },fixture);
    const path='output/playwright/remake/ground-services.json';await(await download).saveAs(path);
    await page.locator('#checkpoint-file').setInputFiles(path);await settled();
    assert((await page.locator('#checkpoint-message').innerText()).includes('imported'),'Ground save accepts a reachable pod parked outside the historical city guard');
    await page.locator('#checkpoint-back').click();
    assert(await page.locator('#depot-repair').isEnabled()&&await page.locator('#depot-refuel').isEnabled(),'Foot depot renders repair and fuel offers with the outer-street pod');
    assert(await page.locator('#depot-auxiliary').isDisabled(),'Foot service cannot load the parked pod');
    await page.locator('#depot-repair').click();await page.locator('#depot-confirm').click();
    await page.locator('#depot-refuel').click();await page.locator('#depot-confirm').click();const paid=await exported();
    assert(paid.state.resources.hull===16&&paid.state.resources.fuel===16,'Confirmed repair and one fuel unit update the local ship');
    assert(paid.state.economy.accounts[0].balance===fixture.state.economy.accounts[0].balance-302,'Foot service charges source repair and fuel prices');
    assert(JSON.stringify(paid.state.pod)===JSON.stringify(fixture.state.pod),'Servicing preserves parked position, heading, occupancy and cargo');
    await page.locator('#service-saves').click();await settled();await page.locator('#save-checkpoint-0').click();await settled();
    await page.reload();await ready();await page.locator('#campaign-saves').click();await settled();await page.locator('#load-checkpoint-0').click();await settled();await page.locator('#checkpoint-back').click();
    assert(JSON.stringify((await exported()).state)===JSON.stringify(paid.state),'Fresh-page reload retains paid services and the outer-street pod');
    assert(errors.length===0,'No uncaught outer-street service errors');return {browser:browser.version(),checks,errors};
  } catch(e){return {browser:browser.version(),checks,errors,failures:[e.message]}}
  finally {await context.close()}
}
