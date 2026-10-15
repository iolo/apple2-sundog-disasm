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
    await page.locator('#checkpoint-file').setInputFiles('output/playwright/remake/r11-phase-four-max-world07-fifth-contact.json');
    await page.waitForFunction(()=>/imported/i.test(document.querySelector('#checkpoint-message')?.textContent||''));
    await page.locator('#checkpoint-back').click();
    const original=(await exported()).state;
    assert(original.space.flags[40]&&original.flight.motion?.progress>=20&&original.resources.hull===11,
      'The final contact is two ordinary flight ticks from world 07');
    await page.locator('#walk-navigation').click();await page.locator('#nav-tactical').click();
    await page.locator('#space-comm').click();await page.locator('#dialogue-reply-0').click();await page.locator('#dialogue-cancel').click();
    const agreed=(await exported()).state;
    assert(agreed.space.communication.pending&&agreed.space.communication.ticks===6,
      'Comm grants a short ordinary safe passage');
    await page.locator('#space-navigation').click();
    if((await state()).paused==='true')await page.locator('#nav-run').click();
    for(let i=0;i<40;i++){
      await page.clock.runFor(250);
      const live=await state();
      if(live.dead==='true')throw Error('Ship destroyed during final approach');
      if(!live.flight)break;
    }
    const arrived=(await exported()).state;
    assert(arrived.regional.shipLocation.worldId==='world-07'&&arrived.resources.hull>0&&
      arrived.pod.cargo.some(c=>c?.commodityId==='cargo-17'),
      'The final flight reaches world 07 with the paid silichips');
    const checkpoint=await exported('output/playwright/remake/r11-phase-four-max-world07-orbit.json');
    assert(JSON.stringify(checkpoint.state)===JSON.stringify(arrived),'The world-seven orbit exports unchanged');
    assert(errors.length===0,'No uncaught errors on the final flight');
    return{browser:browser.version(),checks,errors,failures:[],journey:{fuel:arrived.resources.fuel,hull:arrived.resources.hull,shield:arrived.resources.shields.charge,contact:arrived.space.flags[40]}};
  }catch(error){await page.screenshot({path:'output/playwright/remake/r11-phase-four-max-world07-fifth-arrive-error.png'});return{browser:browser.version(),checks,errors,failures:[error.stack||error.message]}}
  finally{await context.close()}
}
