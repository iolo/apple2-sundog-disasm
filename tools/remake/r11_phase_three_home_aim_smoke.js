// Use the ordinary tactical pan keys to aim the charged gun at the live contact.
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
    await page.locator('#checkpoint-file').setInputFiles('output/playwright/remake/r11-phase-three-home-armed.json');
    await page.waitForFunction(()=>/imported/i.test(document.querySelector('#checkpoint-message')?.textContent||''));
    await page.locator('#checkpoint-back').click();
    const start=(await exported()).state;
    assert(start.space.flags[40]&&start.resources.guns.charge>=64&&start.pod.cargo.every(Boolean),
      'Charged laser and both lots resume at the negotiated contact');
    let current=await exported();
    for(let i=0;i<30;i++){
      const s=current.state,w=s.space.words;
      const dx=512-w[206],dy=512-w[205];
      if(Math.abs(dx)<=16&&Math.abs(dy)<=16)break;
      if((await state()).paused==='true')await page.locator('#space-run').click();
      await page.locator('#space-surface').focus();
      const keys=[];
      if(Math.abs(dx)>16)keys.push(dx>0?'ArrowRight':'ArrowLeft');
      if(Math.abs(dy)>16)keys.push(dy>0?'ArrowDown':'ArrowUp');
      for(const key of keys)await page.keyboard.down(key);
      await page.clock.runFor(50);
      for(const key of keys)await page.keyboard.up(key);
      if((await state()).dead==='true')throw Error('Ship destroyed during manual aim');
      current=await exported();
      samples.push({i,minutes:current.state.ship.minutes,hull:current.state.resources.hull,
        shields:current.state.resources.shields.charge,gun:current.state.resources.guns.charge,
        enemy:current.state.space.words[216],range:current.state.space.words[217],
        x:current.state.space.words[206],y:current.state.space.words[205]});
    }
    const aimed=(await exported('output/playwright/remake/r11-phase-three-home-aimed.json')).state;
    assert(Math.abs(512-aimed.space.words[206])<=16&&Math.abs(512-aimed.space.words[205])<=16&&
      aimed.resources.guns.charge>=64&&aimed.resources.hull>0,'Ordinary pan controls align a charged laser within one fire-frame adjustment');
    assert(aimed.pod.cargo.every(Boolean)&&aimed.colony.receipts.length===13,'Cargo and receipts survive manual aiming');
    assert(errors.length===0,'No browser errors while aiming');
    return{browser:browser.version(),checks,errors,failures:[],samples,journey:{hull:aimed.resources.hull,shield:aimed.resources.shields.charge,gun:aimed.resources.guns.charge}};
  }catch(error){await page.screenshot({path:'output/playwright/remake/r11-phase-three-home-aim-error.png'});return{browser:browser.version(),checks,errors,failures:[error.stack||error.message],samples}}
  finally{await context.close()}
}
