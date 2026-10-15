// Resolve the real charged-warp pirate with precharged shields and laser.
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
  const reload=async()=>{const before=await exported();await saves();await page.locator('#save-checkpoint-0').click();await settled();await page.reload();await ready();await page.locator('#campaign-saves').click();await settled();await page.locator('#load-checkpoint-0').click();await settled();await page.locator('#checkpoint-back').click();const after=await exported();assert(JSON.stringify(after.state)===JSON.stringify(before.state),'Fresh-page save reload preserves the pirate result');return after};
  try{
    await page.addInitScript(()=>localStorage.setItem('sundog.locale','en'));
    await page.clock.install({time:new Date('2026-10-15T00:00:00Z')});await page.clock.pauseAt(new Date('2026-10-15T00:00:01Z'));
    await page.goto('http://127.0.0.1:8000/');await ready();
    await page.locator('#create-character').click();await page.locator('#character-name').fill('Import shell');
    await page.locator('#prepare-campaign').click();await page.locator('#campaign-seed').fill('1');await page.locator('#start-campaign').click();
    await page.locator('#walk-saves').click();await settled();
    await page.locator('#checkpoint-file').setInputFiles('output/playwright/remake/r11-phase-four-max-city20-home-point-contact2.json');
    await page.waitForFunction(()=>/imported/i.test(document.querySelector('#checkpoint-message')?.textContent||''));
    await page.locator('#checkpoint-back').click();
    const original=(await exported()).state;
    assert(original.space.flags[40]&&original.resources.shields.charge===128&&
      original.pod.cargo.some(c=>c?.commodityId==='cargo-17'&&c.originCity==='city-47'),
      'The live world-eight approach starts with charged shields and paid silichips');
    if(await page.locator('#navigation-panel').count())await page.locator('#nav-tactical').click();
    else {await page.locator('#walk-navigation').click();await page.locator('#nav-tactical').click()}
    await page.locator('#space-guns').click();await page.locator('#space-laser').click();
    for(let i=0;i<16;i++){if((await state()).paused==='true')await page.locator('#space-run').click();await page.clock.runFor(50);
      if((await exported()).state.resources.guns.charge>=200)break}
    assert((await exported()).state.resources.guns.charge>=200,'The laser charges behind the safe Comm window');
    let current=(await exported()).state,shots=0;
    for(let i=0;i<600&&current.space.flags[40];i++){
      if((await state()).paused==='true')await page.locator('#space-run').click();
      await page.locator('#space-surface').focus();
      const dx=512-current.space.words[206],dy=512-current.space.words[205];
      const miss=Math.abs(dx)+Math.abs(dy),range=current.space.words[217];
      const tolerance=Math.max(0,4-(range>>5));
      if(miss<=tolerance&&current.resources.guns.charge>=200){
        await page.keyboard.down(' ');await page.clock.runFor(50);await page.keyboard.up(' ');
        shots++;
      }else{
        const keys=[];
        if(Math.abs(dx)>8)keys.push(dx>0?'ArrowRight':'ArrowLeft');
        if(Math.abs(dy)>8)keys.push(dy>0?'ArrowDown':'ArrowUp');
        for(const key of keys)await page.keyboard.down(key);
        await page.clock.runFor(50);
        for(const key of keys)await page.keyboard.up(key);
      }
      if((await state()).dead==='true')throw Error('Ship destroyed during ordinary tactical aiming');
      current=(await exported()).state;
      samples.push({i,x:current.space.words[206],y:current.space.words[205],range:current.space.words[217],
        miss,hull:current.resources.hull,shield:current.resources.shields.charge,
        gun:current.resources.guns.charge,enemy:current.space.words[216],shots});
    }
    assert(!current.space.flags[40],'The pirate retreats from the warp-point course');
    const won=(await reload()).state;
    assert(!won.space.flags[40]&&!won.space.defeat&&won.pod.cargo.some(c=>c?.commodityId==='cargo-17'),
      'Ordinary laser hits drive off the pirate without losing the paid lot');
    const checkpoint=await exported('output/playwright/remake/r11-phase-four-max-city20-home-point-final-cleared.json');
    assert(JSON.stringify(checkpoint.state)===JSON.stringify(won),'The cleared-contact checkpoint exports unchanged');
    assert(errors.length===0,'No uncaught errors during the pirate fight');
    return{browser:browser.version(),checks,errors,failures:[],samples,journey:{minutes:won.ship.minutes,
      hull:won.resources.hull,shield:won.resources.shields.charge,gun:won.resources.guns.charge,
      enemy:won.space.words[216],lot:won.pod.cargo.find(c=>c?.commodityId==='cargo-17')}};
  }catch(error){await page.screenshot({path:'output/playwright/remake/r11-phase-four-max-city20-home-point-final-pirate-error.png'});return{browser:browser.version(),checks,errors,failures:[error.stack||error.message],samples}}
  finally{await context.close()}
}
