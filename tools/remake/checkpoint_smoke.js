// Ordinary UI persistence flows; browser clock controls time, never game state.
async browserPage => {
  const browser = browserPage.context().browser(), checks = [], errors = [];
  const context = await browser.newContext({ viewport:{width:1280,height:720} });
  let page = await context.newPage(), accept = true;
  const watch = p => { p.on('pageerror',e=>errors.push(e.message)); p.on('dialog',d=>accept ? d.accept() : d.dismiss()); };
  watch(page);
  const assert = (ok,name) => { if(!ok)throw Error(name); checks.push(name); };
  const start = async p => { await p.goto('http://127.0.0.1:8000/');await p.waitForFunction(()=>document.documentElement.dataset.ready==='true');await p.locator('#explore').click();await p.locator('#begin-walk').click(); };
  const settled = p => p.waitForFunction(()=>document.querySelector('#checkpoint-back')?.disabled===false);
  const saves = async p => { await p.locator('#walk-saves').click();await settled(p); };
  const click = async id => { await page.locator(id).click();await settled(page); };
  const state = () => page.locator('#walk-screen').evaluate(el=>({...el.dataset}));
  try {
    await page.clock.install();await start(page);
    const box=await page.locator('#stage').boundingBox();
    await page.mouse.move(box.x+(32+57.25*640/280)*box.width/640,box.y+(46+83.25*2)*box.height/480);
    await page.mouse.down();await page.clock.runFor(2000);await page.mouse.up();await page.clock.runFor(62000);
    await page.locator('#walk-inventory').click();await page.locator('#slot-stores-10').click();await page.locator('#slot-carried-0').click();
    const item=await page.locator('#slot-carried-0').getAttribute('aria-label');
    const condition=await page.locator('[role=meter]').evaluateAll(els=>els.map(el=>el.getAttribute('aria-valuenow')));
    await page.locator('#inventory-close').click();await saves(page);
    const saved=await state();
    assert(await page.locator('.checkpoint-row').count()===4,'Four separate ship checkpoint slots');
    for(let i=0;i<4;i++)await click(`#save-checkpoint-${i}`);
    assert(await page.locator('[data-checkpoint=load]:enabled').count()===4,'All four slots save independently');
    const downloadPromise=page.waitForEvent('download');await click('#export-checkpoint');const download=await downloadPromise;
    await download.saveAs('output/playwright/remake/checkpoint-export.json');
    assert(download.suggestedFilename()==='sundog-ship-checkpoint.json','Validated checkpoint exports as JSON');
    await page.clock.runFor(5000);assert((await state()).minutes===saved.minutes,'Checkpoint dialog pauses elapsed time');
    await page.keyboard.press('Shift+Tab');assert(await page.evaluate(()=>document.querySelector('#checkpoint-screen').contains(document.activeElement)),'Checkpoint dialog traps keyboard focus');
    for(const lang of ['en','ko']) {
      if(await page.locator('html').getAttribute('lang')!==lang)await click('#checkpoint-language');
      for(const [width,height] of [[640,480],[1280,720],[390,844]]) {
        await page.setViewportSize({width,height});await page.clock.runFor(100);
        assert(await page.evaluate(()=>{
          const stage=document.querySelector('#stage').getBoundingClientRect();
          return [...document.querySelectorAll('#checkpoint-screen button,.checkpoint-note,#checkpoint-message,.checkpoint-row')].filter(el=>!el.hidden).every(el=>{const b=el.getBoundingClientRect();return b.left>=stage.left-1&&b.right<=stage.right+1&&b.top>=stage.top-1&&b.bottom<=stage.bottom+1&&el.scrollWidth<=el.clientWidth+1});
        }),`${lang} checkpoint layout fits ${width}x${height}`);
        await page.screenshot({path:`output/playwright/remake/checkpoints-${lang}-${width}.png`});
      }
    }
    await click('#checkpoint-language');
    accept=false;await click('#delete-checkpoint-0');accept=true;
    assert(await page.locator('#load-checkpoint-0').isEnabled(),'Cancelled delete preserves slot');
    await click('#delete-checkpoint-3');assert(await page.locator('#load-checkpoint-3').isDisabled()&&await page.locator('#load-checkpoint-0').isEnabled(),'Delete affects only selected slot');
    await page.keyboard.press('Escape');assert(await page.evaluate(()=>document.activeElement.id==='walk-saves'),'Closing restores Saves focus');
    await page.locator('#walk-reset').click();await saves(page);
    accept=false;await click('#save-checkpoint-0');accept=true;await click('#load-checkpoint-0');await page.clock.runFor(100);
    assert((await state()).y===saved.y,'Cancelled overwrite preserves original position');
    await page.close();page=await context.newPage();watch(page);await page.clock.install();await start(page);await saves(page);
    await click('#load-checkpoint-0');await page.clock.runFor(100);
    const loaded=await state();assert(loaded.x===saved.x&&loaded.y===saved.y&&loaded.minutes===saved.minutes&&loaded.paused==='true','Fresh page restores position/time and stays paused');
    await click('#checkpoint-back');await page.locator('#walk-inventory').click();
    assert(await page.locator('#slot-carried-0').getAttribute('aria-label')===item,'Charged carried item survives saved checkpoint');
    assert(JSON.stringify(await page.locator('[role=meter]').evaluateAll(els=>els.map(el=>el.getAttribute('aria-valuenow'))))===JSON.stringify(condition),'Depleted condition survives saved checkpoint');
    await page.locator('#inventory-close').click();await page.locator('#walk-reset').click();await saves(page);
    await page.locator('#checkpoint-file').setInputFiles('output/playwright/remake/checkpoint-export.json');await settled(page);await page.clock.runFor(100);
    assert((await state()).y===saved.y&&await page.locator('#load-checkpoint-3').isDisabled(),'Import restores live state without writing a slot');
    await page.locator('#checkpoint-file').setInputFiles('remake/tests/fixtures/future-draft.json');await settled(page);await page.clock.runFor(100);
    assert((await state()).y===saved.y&&(await page.locator('#checkpoint-message').innerText()).includes('Invalid'),'Foreign import reports validation failure and preserves state');
    const second=await context.newPage();watch(second);await start(second);await saves(second);await second.locator('#save-checkpoint-0').click();await settled(second);
    await click('#save-checkpoint-0');assert((await page.locator('#checkpoint-message').innerText()).includes('another tab'),'Stale tab cannot overwrite newer checkpoint');
    await click('#load-checkpoint-0');await page.clock.runFor(100);assert((await state()).y==='110','Conflict refresh exposes the newer saved state');await second.close();
    await context.setOffline(true);await click('#save-checkpoint-3');assert(await page.locator('#load-checkpoint-3').isEnabled(),'Checkpoint storage works offline');await context.setOffline(false);
    await page.addInitScript(()=>Object.defineProperty(window,'indexedDB',{value:{open(){throw Error('blocked')}}}));
    await start(page);await saves(page);
    assert(await page.locator('#save-checkpoint-0').isDisabled()&&await page.locator('#export-checkpoint').isEnabled()&&await page.locator('#import-checkpoint').isEnabled(),'Blocked storage keeps import/export available');
    await click('#retry-checkpoints');assert((await page.locator('#checkpoint-message').innerText()).includes('unavailable'),'Storage retry reports failure without losing live state');
    await page.locator('#checkpoint-file').setInputFiles('output/playwright/remake/checkpoint-export.json');await settled(page);await page.clock.runFor(100);
    assert((await state()).y===saved.y,'Import restores state with browser storage unavailable');
    assert(errors.length===0,`No browser errors: ${errors.join(', ')}`);
    return {browser:browser.version(),passed:checks.length,checks};
  } catch(error) { await page.screenshot({path:'output/playwright/remake/checkpoint-failure.png'});throw Error(`${error.message}; last check: ${checks.at(-1)}`); }
  finally {await context.close()}
}
