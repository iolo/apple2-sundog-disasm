// Reach world 07 under the ordinary six-tick Comm respite.
async browserPage => {
  const browser=browserPage.context().browser(),checks=[],errors=[];
  const context=await browser.newContext({viewport:{width:1280,height:720}}),page=await context.newPage();
  page.on('pageerror',e=>errors.push(e.stack||e.message));page.on('dialog',d=>d.accept());
  const assert=(ok,name)=>{if(!ok)throw Error(name);checks.push(name)};
  const ready=()=>page.waitForFunction(()=>document.documentElement.dataset.ready==='true');
  const settled=()=>page.waitForFunction(()=>document.querySelector('#checkpoint-back')?.disabled===false);
  const state=()=>page.locator('#walk-screen').evaluate(el=>({...el.dataset}));
  const saves=async()=>{await page.locator((await page.locator('#navigation-panel').count())?'#nav-saves':(await page.locator('#space-panel').count())?'#space-saves':'#walk-saves').click();await settled()};
  const exported=async(path=null)=>{await saves();const pending=page.waitForEvent('download');await page.locator('#export-checkpoint').click();const download=await pending;if(path)await download.saveAs(path);let content='';for await(const chunk of await download.createReadStream())content+=chunk;await settled();await page.locator('#checkpoint-back').click();return JSON.parse(content)};
  try{
    await page.addInitScript(()=>localStorage.setItem('sundog.locale','en'));
    await page.clock.install({time:new Date('2026-10-15T00:00:00Z')});await page.clock.pauseAt(new Date('2026-10-15T00:00:01Z'));
    await page.goto('http://127.0.0.1:8000/');await ready();
    await page.locator('#create-character').click();await page.locator('#character-name').fill('Import shell');
    await page.locator('#prepare-campaign').click();await page.locator('#campaign-seed').fill('1');await page.locator('#start-campaign').click();
    await page.locator('#walk-saves').click();await settled();
    await page.locator('#checkpoint-file').setInputFiles('output/playwright/remake/r11-phase-four-max-world07-orbit.json');
    await page.waitForFunction(()=>/imported/i.test(document.querySelector('#checkpoint-message')?.textContent||''));
    await page.locator('#checkpoint-back').click();
    const original=(await exported()).state;
    assert(original.regional.shipLocation.worldId==='world-07'&&original.pod.cargo.some(c=>c?.commodityId==='cargo-17'),
      'The world-seven orbit retains the funded phase-four cargo');
    await page.locator('#walk-navigation').click();
    await page.locator('#nav-scale-planet').click();
    await page.locator('#nav-destination').selectOption('city-20');
    await page.locator('#nav-select').click();await page.locator('#nav-confirm').click();
    if((await state()).paused==='true')await page.locator('#nav-run').click();
    for(let i=0;i<128;i++){
      await page.clock.runFor(250);const live=await state();
      if(live.dead==='true')throw Error('Ship destroyed on city-20 landing');
      if(!live.flight)break;
    }
    const landed=(await exported()).state;
    assert(landed.regional.shipLocation.cityId==='city-20'&&landed.resources.hull>0&&
      landed.pod.cargo.some(c=>c?.commodityId==='cargo-17'),
      'The ordinary planet flight lands at city 20 with paid silichips');
    const checkpoint=await exported('output/playwright/remake/r11-phase-four-max-city20-landed.json');
    assert(JSON.stringify(checkpoint.state)===JSON.stringify(landed),'The city-20 landing exports unchanged');
    assert(errors.length===0,'No uncaught errors on city-20 landing');
    return{browser:browser.version(),checks,errors,failures:[],journey:{fuel:landed.resources.fuel,hull:landed.resources.hull,contact:landed.space.flags[40],bank:landed.economy.accounts[3].balance}};
  }catch(error){await page.screenshot({path:'output/playwright/remake/r11-phase-four-max-city20-land-error.png'});return{browser:browser.version(),checks,errors,failures:[error.stack||error.message]}}
  finally{await context.close()}
}
