// Browser clock controls elapsed time; no game-state, position or inventory injection.
async browserPage => {
  const browser = browserPage.context().browser(), checks = [], errors = [];
  const context = await browser.newContext({ viewport: { width:1280,height:720 } });
  const page = await context.newPage();
  const assert = (ok,name) => { if (!ok) throw new Error(name); checks.push(name); };
  page.on('pageerror',e=>errors.push(e.message));
  page.on('response',r=>{if(r.status()>=400)errors.push(`${r.status()} ${r.url()}`)});
  const minutes = async () => Number(await page.locator('#walk-screen').getAttribute('data-minutes'));
  const condition = () => page.locator('[role=meter]').evaluateAll(els=>els.map(el=>Number(el.getAttribute('aria-valuenow'))));
  const changeLanguage = async () => {
    await page.locator('#inventory-close').click();
    await page.locator('#walk-language').click();
    await page.locator('#walk-inventory').click();
  };
  try {
    await page.clock.install();
    await page.goto('http://127.0.0.1:8000/');await page.waitForFunction(()=>document.documentElement.dataset.ready==='true');
    if(await page.locator('html').getAttribute('lang')!=='en')await page.locator('[data-action=language]').click();
    await page.locator('#explore').click();await page.locator('#begin-walk').click();
    const box=await page.locator('#stage').boundingBox();
    await page.mouse.move(box.x+(32+57.25*640/280)*box.width/640,box.y+(46+83.25*2)*box.height/480);
    await page.mouse.down();await page.clock.runFor(2000);await page.mouse.up();
    assert(await page.locator('#walk-screen').getAttribute('data-y')==='86','Ordinary walking reaches stores');
    await page.clock.runFor(62000);
    assert(await minutes()>=60,'Visible idle ship advances game time across an hour');
    await page.locator('#walk-inventory').click();
    assert(JSON.stringify(await condition())==='[253,251,255,252]','First awake hour matches the source condition transition');
    const paused=await minutes();await page.clock.runFor(5000);
    assert(await minutes()===paused,'Open inventory pauses the clock');
    await page.locator('#slot-stores-5').click();await page.locator('#slot-carried-0').click();await page.locator('#slot-carried-0').click();await page.locator('#inventory-use').click();
    assert(JSON.stringify(await condition())==='[253,251,255,255]' && await page.locator('#slot-carried-0 img').count()===0,'Food restores naturally depleted nourishment and consumes one item');
    await page.locator('#inventory-sleep').click();await page.clock.runFor(1000);
    assert(await page.locator('#sleep-rest').innerText()==='Rest 255 / 255','Sleep restores naturally depleted rest and caps at 255');
    assert(await minutes()>paused,'Sleep advances game time');
    await page.keyboard.press('Shift+Tab');
    assert(await page.evaluate(()=>document.querySelector('.sleep-panel').contains(document.activeElement)),'Sleep dialog traps keyboard focus');
    await page.locator('#sleep-pause').click();const sleepingPaused=await minutes();await page.clock.runFor(5000);
    assert(await minutes()===sleepingPaused,'Pause freezes sleep and its accelerated clock');
    await page.locator('#sleep-pause').click();await page.clock.runFor(1000);
    await page.evaluate(()=>window.dispatchEvent(new Event('blur')));const blurred=await minutes();await page.clock.runFor(5000);
    assert(await minutes()===blurred && (await page.locator('#sleep-pause').innerText()).includes('Resume'),'Lost focus pauses sleep until explicitly resumed');
    await page.locator('#sleep-wake').click();
    assert(await page.locator('#inventory-panel').count()===1 && await page.evaluate(()=>document.activeElement.id==='inventory-sleep'),'Wake returns to paused inventory with focus restored');
    for(const language of ['en','ko']) {
      if(await page.locator('html').getAttribute('lang')!==language)await changeLanguage();
      await page.locator('#inventory-sleep').click();await page.locator('#sleep-pause').click();
      for(const [width,height] of [[640,480],[1280,720],[390,844]]) {
        await page.setViewportSize({width,height});await page.clock.runFor(100);
        assert(await page.evaluate(()=>{
          const stage=document.querySelector('#stage').getBoundingClientRect();
          return [...document.querySelectorAll('.sleep-panel,.sleep-panel button,.sleep-panel p')].every(el=>{const b=el.getBoundingClientRect();return b.left>=stage.left-1&&b.right<=stage.right+1&&b.top>=stage.top-1&&b.bottom<=stage.bottom+1&&el.scrollWidth<=el.clientWidth+1});
        }),`${language} sleep controls fit ${width}x${height}`);
        await page.screenshot({path:`output/playwright/remake/sleep-${language}-${width}.png`});
      }
      await page.keyboard.press('Escape');
    }
    assert(await page.locator('#inventory-panel').count()===1,'Escape wakes without leaving the walkthrough');
    await context.setOffline(true);await page.locator('#inventory-sleep').click();await page.clock.runFor(1500);await page.locator('#sleep-wake').click();
    assert(await minutes()>blurred,'Sleep and wake work offline');
    await context.setOffline(false);
    const retained=await minutes();await page.locator('#inventory-close').click();await page.keyboard.press('Escape');await page.locator('#begin-walk').click();
    assert(await minutes()===retained,'Reopening retains elapsed game time');
    await page.locator('#walk-reset').click();await page.locator('#walk-inventory').click();
    assert(await minutes()===retained,'Return to start preserves condition and time');
    await page.reload();await page.waitForFunction(()=>document.documentElement.dataset.ready==='true');await page.locator('#explore').click();await page.locator('#begin-walk').click();await page.locator('#walk-inventory').click();
    assert(await minutes()===0 && JSON.stringify(await condition())==='[255,255,255,255]','Reload restores the isolated clock and condition');
    assert(errors.length===0,`No browser/resource errors: ${errors.join(', ')}`);
    return {browser:browser.version(),passed:checks.length,checks};
  } catch(error) {await page.screenshot({path:'output/playwright/remake/survival-failure.png'});throw new Error(`${error.message}; last check: ${checks.at(-1)}`)}
  finally {await context.close()}
}
