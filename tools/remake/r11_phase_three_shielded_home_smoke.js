// Continue a real two-cargo home warp with ordinary shields and rescue calls.
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
    await page.locator('#checkpoint-file').setInputFiles('output/playwright/remake/r11-phase-three-world08-home-warp.json');
    await page.waitForFunction(()=>/imported/i.test(document.querySelector('#checkpoint-message')?.textContent||''));
    await page.locator('#checkpoint-back').click();
    const original=(await exported()).state;
    assert(original.start.creation.seed===12345&&original.regional.shipLocation.systemId==='system-01'&&
      original.regional.shipLocation.worldId===null&&original.colony.receipts.length===13&&
      original.pod.cargo.some(c=>c?.commodityId==='cargo-22')&&original.pod.cargo.some(c=>c?.commodityId==='cargo-31'),
      'The saved home warp has both legitimate phase-three cargo lots');
    await command('distress');await page.locator('#nav-run').click();
    for(let i=0;i<1024;i++){await page.clock.runFor(250);if(/Fuel 255\b/.test(await page.locator('#nav-resources').innerText()))break}
    assert((await exported()).state.resources.fuel===255,'Normal distress refuels before the exposed home approach');
    await page.locator('#nav-tactical').click();await page.locator('#space-shields').click();
    await page.locator('#space-shield-more').click();await page.locator('#space-shield-more').click();
    await page.locator('#space-menu-back').click();
    if((await state()).paused==='true')await page.locator('#space-run').click();
    for(let i=0;i<512;i++){await page.clock.runFor(250);if(/Shields 128\/128/.test(await page.locator('#space-resources').innerText()))break}
    const shielded=(await exported('output/playwright/remake/r11-phase-three-home-shielded.json')).state;
    assert(shielded.resources.shields.charge===128&&shielded.resources.shields.targetCharge===128&&
      shielded.resources.fuel>0,'Ordinary shield controls charge to 128 before powered travel');
    await command('distress');await destination('system','world-01');
    const moving=(await exported()).state;
    assert(moving.flight.motion?.type==='sublight'&&moving.flight.refuelAt!==null,
      'A second ordinary distress request is pending during the sublight leg');
    await page.locator('#nav-run').click();
    let contact=false;
    for(let i=0;i<2048;i++){
      await page.clock.runFor(250);const s=await state();
      if(s.contact==='true'){contact=true;break}
      if(s.dead==='true'||!s.flight)break;
    }
    if(contact){
      const encounter=(await exported('output/playwright/remake/r11-phase-three-home-contact.json')).state;
      assert(encounter.space.flags[40]&&encounter.resources.hull===8&&encounter.resources.shields.charge===128&&
        encounter.pod.cargo.every(Boolean),'Live pirate contact pauses at full precharged shields with both lots aboard');
      assert(errors.length===0,'No browser errors before the tactical encounter');
      return{browser:browser.version(),checks,errors,failures:[],journey:{hull:encounter.resources.hull,
        fuel:encounter.resources.fuel,shield:encounter.resources.shields,minutes:encounter.ship.minutes}};
    }
    throw Error('Expected tactical contact did not occur on the deterministic home approach');
  }catch(error){await page.screenshot({path:'output/playwright/remake/r11-phase-three-shielded-home-error.png'});return{browser:browser.version(),checks,errors,failures:[error.stack||error.message]}}
  finally{await context.close()}
}
