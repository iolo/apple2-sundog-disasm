// Resume the legitimate two-cargo approach after defeating the first pirate.
async browserPage => {
  const browser=browserPage.context().browser(),checks=[],errors=[];
  const context=await browser.newContext({viewport:{width:1280,height:720}}),page=await context.newPage();
  page.on('pageerror',e=>errors.push(e.stack||e.message));page.on('dialog',d=>d.accept());
  const assert=(ok,name)=>{if(!ok)throw Error(name);checks.push(name)};
  const ready=()=>page.waitForFunction(()=>document.documentElement.dataset.ready==='true');
  const settled=()=>page.waitForFunction(()=>document.querySelector('#checkpoint-back')?.disabled===false);
  const state=()=>page.locator('#walk-screen').evaluate(el=>({...el.dataset}));
  const saves=async()=>{await page.locator((await page.locator('#navigation-panel').count())?'#nav-saves':
    (await page.locator('#space-panel').count())?'#space-saves':'#walk-saves').click();await settled()};
  const exported=async(path=null)=>{await saves();const pending=page.waitForEvent('download');await page.locator('#export-checkpoint').click();const download=await pending;if(path)await download.saveAs(path);let text='';for await(const part of await download.createReadStream())text+=part;await settled();await page.locator('#checkpoint-back').click();return JSON.parse(text)};
  const reload=async()=>{const before=await exported();await saves();await page.locator('#save-checkpoint-0').click();await settled();await page.reload();await ready();await page.locator('#campaign-saves').click();await settled();await page.locator('#load-checkpoint-0').click();await settled();await page.locator('#checkpoint-back').click();const after=await exported();assert(JSON.stringify(after.state)===JSON.stringify(before.state),'Fresh-page save reload preserves the shielded journey');return after};
  const navigation=async()=>{if(await page.locator('#navigation-panel').count())return;await page.locator(await page.locator('#space-panel').count()?'#space-navigation':'#walk-navigation').click()};
  const command=async type=>{await navigation();await page.locator('#nav-'+type).click();await page.locator('#nav-confirm').click()};
  const destination=async(scale,id)=>{await navigation();await page.locator('#nav-scale-'+scale).click();await page.locator('#nav-destination').selectOption(id);await page.locator('#nav-select').click();await page.locator('#nav-confirm').click()};
  try{
    await page.addInitScript(()=>localStorage.setItem('sundog.locale','en'));
    await page.clock.install({time:new Date('2026-10-15T00:00:00Z')});await page.clock.pauseAt(new Date('2026-10-15T00:00:01Z'));
    await page.goto('http://127.0.0.1:8000/');await ready();
    await page.locator('#create-character').click();await page.locator('#character-name').fill('Import shell');
    await page.locator('#prepare-campaign').click();await page.locator('#campaign-seed').fill('1');await page.locator('#start-campaign').click();
    await page.locator('#walk-saves').click();await settled();
    await page.locator('#checkpoint-file').setInputFiles('output/playwright/remake/r11-phase-three-home-pirate-cleared.json');
    await page.waitForFunction(()=>/imported/i.test(document.querySelector('#checkpoint-message')?.textContent||''));
    await page.locator('#checkpoint-back').click();
    const original=(await exported()).state;
    assert(original.start.creation.seed===12345&&original.space.words[216]===0&&
      original.flight.motion?.type==='sublight'&&original.colony.receipts.length===13&&
      original.pod.cargo.some(c=>c?.commodityId==='cargo-22')&&original.pod.cargo.some(c=>c?.commodityId==='cargo-31'),
      'Saved pirate victory retains both cargo lots on the ongoing home leg');
    await navigation();
    if((await state()).paused==='true')await page.locator('#nav-run').click();
    let contact=false;
    for(let i=0;i<2048;i++){
      if((await state()).paused==='true')await page.locator('#nav-run').click();
      await page.clock.runFor(250);const s=await state();
      if(s.contact==='true'){
        const seen=(await exported()).state;
        if(seen.space.flags[40]&&seen.space.words[216]>0){contact=true;break}
      }
      if(s.dead==='true'||!s.flight)break;
    }
    if(contact){
      const encounter=(await exported('output/playwright/remake/r11-phase-three-home-contact2.json')).state;
      throw Error(`Second live space contact: ${JSON.stringify({hull:encounter.resources.hull,shield:encounter.resources.shields,fuel:encounter.resources.fuel,minutes:encounter.ship.minutes,progress:encounter.flight.motion?.progress})}`);
    }
    const orbit=(await exported()).state;
    assert(orbit.regional.shipLocation.worldId==='world-01'&&!orbit.space.defeat&&orbit.resources.hull>0,
      'The cleared contact lets both lots reach world 01 orbit');
    await destination('planet','city-01');await page.locator('#nav-run').click();
    for(let i=0;i<1024;i++){await page.clock.runFor(250);if(!(await state()).flight)break}
    const landed=(await reload()).state;
    assert(landed.regional.shipLocation.cityId==='city-01'&&landed.pod.cargo.every(Boolean)&&
      landed.colony.receipts.length===13,'Both lots land at Drahew after the pirate victory');
    const checkpoint=await exported('output/playwright/remake/r11-phase-three-world08-home-landed.json');
    assert(JSON.stringify(checkpoint.state)===JSON.stringify(landed),'The home landing exports unchanged');
    assert(errors.length===0,'No uncaught errors on the home approach');
    return{browser:browser.version(),checks,errors,failures:[],journey:{hull:landed.resources.hull,
      fuel:landed.resources.fuel,shield:landed.resources.shields,minutes:landed.ship.minutes}};
  }catch(error){await page.screenshot({path:'output/playwright/remake/r11-phase-three-home-resume-error.png'});return{browser:browser.version(),checks,errors,failures:[error.stack||error.message]}}
  finally{await context.close()}
}
