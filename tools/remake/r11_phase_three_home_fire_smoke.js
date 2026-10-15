// Fire the charged laser after a pointer adjustment, then confirm cargo survives.
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
    await page.locator('#checkpoint-file').setInputFiles('output/playwright/remake/r11-phase-three-home-aimed.json');
    await page.waitForFunction(()=>/imported/i.test(document.querySelector('#checkpoint-message')?.textContent||''));
    await page.locator('#checkpoint-back').click();
    const start=(await exported()).state;
    assert(start.space.flags[40]&&start.resources.guns.charge===255&&start.pod.cargo.every(Boolean),
      'A full laser charge and both lots resume at the centered contact');
    const box=await page.locator('#space-surface').boundingBox();
    const shot=async(x,y)=>{
      if((await state()).paused==='true')await page.locator('#space-run').click();
      await page.mouse.move(box.x+box.width*(.5+x/16),box.y+box.height*(.5+y/16));
      await page.mouse.down();await page.clock.runFor(50);await page.mouse.up();await page.clock.runFor(50);
      if((await state()).dead==='true')throw Error('Ship destroyed during laser shot');
      return (await exported()).state;
    };
    const adjusted=await shot(4,4);
    samples.push({stage:'adjusted',gun:adjusted.resources.guns.charge,enemy:adjusted.space.words[216],
      x:adjusted.space.words[206],y:adjusted.space.words[205],range:adjusted.space.words[217]});
    assert(Math.abs(512-adjusted.space.words[206])+Math.abs(512-adjusted.space.words[205])<=2,
      'First ordinary pointer press adjusts the reticle into laser tolerance');
    if((await state()).paused==='true')await page.locator('#space-run').click();
    await page.clock.runFor(250);
    const charged=(await exported()).state;
    samples.push({stage:'recharged',gun:charged.resources.guns.charge,enemy:charged.space.words[216],
      x:charged.space.words[206],y:charged.space.words[205],range:charged.space.words[217]});
    assert(charged.resources.guns.charge>=64&&charged.space.flags[40],
      'Live power recharges after the pointer adjustment');
    const won=await shot(0,0);
    samples.push({stage:'fired',gun:won.resources.guns.charge,enemy:won.space.words[216],
      x:won.space.words[206],y:won.space.words[205],range:won.space.words[217]});
    assert(won.space.words[216]===0&&!won.space.defeat,'An ordinary focused laser shot destroys the pirate');
    assert(won.pod.cargo.every(Boolean)&&won.colony.receipts.length===13,'Both lots and all receipts survive combat');
    await exported('output/playwright/remake/r11-phase-three-home-pirate-cleared.json');
    assert(errors.length===0,'No browser errors during the laser fight');
    return{browser:browser.version(),checks,errors,failures:[],samples,journey:{hull:won.resources.hull,shield:won.resources.shields.charge,enemy:won.space.words[216]}};
  }catch(error){await page.screenshot({path:'output/playwright/remake/r11-phase-three-home-fire-error.png'});return{browser:browser.version(),checks,errors,failures:[error.stack||error.message],samples}}
  finally{await context.close()}
}
