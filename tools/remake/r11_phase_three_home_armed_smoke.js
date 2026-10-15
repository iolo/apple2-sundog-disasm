// Negotiate a six-tick firing pause while charging the ship's real laser.
async browserPage => {
  const browser=browserPage.context().browser(),checks=[],errors=[],samples=[];
  const context=await browser.newContext({viewport:{width:1280,height:720}}),page=await context.newPage();
  page.on('pageerror',e=>errors.push(e.stack||e.message));page.on('dialog',d=>d.accept());
  const assert=(ok,name)=>{if(!ok)throw Error(name);checks.push(name)};
  const ready=()=>page.waitForFunction(()=>document.documentElement.dataset.ready==='true');
  const settled=()=>page.waitForFunction(()=>document.querySelector('#checkpoint-back')?.disabled===false);
  const state=()=>page.locator('#walk-screen').evaluate(el=>({...el.dataset}));
  const saves=async()=>{await page.locator((await page.locator('#navigation-panel').count())?'#nav-saves':
    (await page.locator('#space-panel').count())?'#space-saves':'#walk-saves').click();await settled()};
  const exported=async(path=null)=>{await saves();const pending=page.waitForEvent('download');await page.locator('#export-checkpoint').click();const download=await pending;if(path)await download.saveAs(path);let text='';for await(const part of await download.createReadStream())text+=part;await settled();await page.locator('#checkpoint-back').click();return JSON.parse(text)};
  try{
    await page.addInitScript(()=>localStorage.setItem('sundog.locale','en'));
    await page.clock.install({time:new Date('2026-10-15T00:00:00Z')});await page.clock.pauseAt(new Date('2026-10-15T00:00:01Z'));
    await page.goto('http://127.0.0.1:8000/');await ready();
    await page.locator('#create-character').click();await page.locator('#character-name').fill('Import shell');
    await page.locator('#prepare-campaign').click();await page.locator('#campaign-seed').fill('1');await page.locator('#start-campaign').click();
    await page.locator('#walk-saves').click();await settled();
    await page.locator('#checkpoint-file').setInputFiles('output/playwright/remake/r11-phase-three-home-contact.json');
    await page.waitForFunction(()=>/imported/i.test(document.querySelector('#checkpoint-message')?.textContent||''));
    await page.locator('#checkpoint-back').click();
    const start=(await exported()).state;
    assert(start.space.flags[40]&&start.colony.receipts.length===13&&start.pod.cargo.every(Boolean),
      'The live pirate contact starts with both paid cargo lots aboard');
    if(await page.locator('#navigation-panel').count())await page.locator('#nav-tactical').click();
    else {await page.locator('#walk-navigation').click();await page.locator('#nav-tactical').click()}
    await page.locator('#space-comm').click();await page.locator('#dialogue-reply-0').click();
    await page.locator('#dialogue-cancel').click();
    const agreed=(await exported()).state;
    assert(agreed.space.communication.pending&&agreed.space.communication.ticks===6&&agreed.pod.cargo.every(Boolean),
      'The source six-tick negotiation pauses fire while both lots stay aboard');
    await page.locator('#space-guns').click();await page.locator('#space-laser').click();
    let current=await exported();
    for(let i=0;i<60;i++){
      if((await state()).paused==='true')await page.locator('#space-run').click();
      await page.clock.runFor(250);
      if((await state()).dead==='true')throw Error('Pirate destroyed ship before laser charged');
      current=await exported();
      samples.push({i,minutes:current.state.ship.minutes,hull:current.state.resources.hull,
        shields:current.state.resources.shields.charge,gun:current.state.resources.guns.charge,
        enemy:current.state.space.words[216],range:current.state.space.words[217],
        ticks:current.state.space.communication.ticks,contact:current.state.space.flags[40]});
      if(current.state.resources.guns.charge>=64)break;
    }
    const armed=(await exported('output/playwright/remake/r11-phase-three-home-armed.json')).state;
    assert(armed.resources.guns.charge>=64&&armed.resources.hull>0&&armed.space.flags[40],
      'Normal power phases charge a usable laser while contact remains live');
    assert(armed.pod.cargo.every(Boolean)&&armed.colony.receipts.length===13,'Both cargo lots and all receipts survive the pause');
    assert(errors.length===0,'No browser errors while arming');
    return{browser:browser.version(),checks,errors,failures:[],samples,journey:{hull:armed.resources.hull,shield:armed.resources.shields.charge,gun:armed.resources.guns.charge}};
  }catch(error){await page.screenshot({path:'output/playwright/remake/r11-phase-three-home-armed-error.png'});return{browser:browser.version(),checks,errors,failures:[error.stack||error.message],samples}}
  finally{await context.close()}
}
