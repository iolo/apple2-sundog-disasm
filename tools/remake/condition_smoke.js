// Ordinary UI input only: restoration is covered by source-derived pure rules,
// not by injecting depleted condition into the browser walkthrough.
async browserPage => {
  const browser = browserPage.context().browser(), checks = [], errors = [];
  const context = await browser.newContext({ viewport: { width: 1280, height: 720 } });
  const page = await context.newPage();
  const assert = (ok, name) => { if (!ok) throw new Error(name); checks.push(name); };
  const slot = (container, index) => page.locator(`#slot-${container}-${index}`);
  const meters = () => page.locator('[role="meter"]').evaluateAll(els => els.map(el => Number(el.getAttribute('aria-valuenow'))));
  const open = async () => {
    await page.goto('http://127.0.0.1:8000/');
    await page.waitForFunction(() => document.documentElement.dataset.ready === 'true');
    if (await page.locator('html').getAttribute('lang') !== 'en') await page.locator('[data-action="language"]').click();
    await page.locator('#explore').click(); await page.locator('#begin-walk').click();
    const box = await page.locator('#walk-surface').boundingBox();
    await page.mouse.move(box.x + 57.25 * box.width / 280, box.y + 83.25 * box.height / 192);
    await page.mouse.down();
    await page.waitForFunction(() => document.querySelector('#walk-screen').dataset.y === '86');
    await page.mouse.up(); await page.locator('#walk-inventory').click();
  };
  page.on('pageerror', error => errors.push(error.message));
  page.on('response', response => { if (response.status() >= 400) errors.push(`${response.status()} ${response.url()}`); });
  const changeLanguage = async () => {
    await page.locator('#inventory-close').click();
    await page.locator('#walk-language').click();
    await page.locator('#walk-inventory').click();
  };
  try {
    await open();
    assert(JSON.stringify(await meters()) === '[255,255,255,255]', 'All four meters start at the observed clean-character maximum');
    await slot('stores', 5).click();
    assert(await page.locator('#inventory-use').count() === 0, 'Stored food must be carried before use');
    await slot('carried', 0).click(); await slot('carried', 0).click();
    assert((await page.locator('#inventory-message').innerText()).includes('Already full'), 'Full nourishment warns that food will still be consumed');
    for (const language of ['en', 'ko']) {
      if (await page.locator('html').getAttribute('lang') !== language) { await changeLanguage(); await slot('carried', 0).click(); }
      for (const [width, height] of [[640,480],[1280,720],[390,844]]) {
        await page.setViewportSize({ width, height });
        await page.waitForFunction(() => Math.abs(document.querySelector('#stage').getBoundingClientRect().width - Math.min(innerWidth,innerHeight*4/3)) < 1);
        assert(await page.evaluate(() => {
          const box = document.querySelector('#stage').getBoundingClientRect();
          const fits = [...document.querySelectorAll('#inventory-panel button,.condition-row,.inventory-bottom,.inventory-note')].filter(el=>el.getClientRects().length).every(el => {
            const r = el.getBoundingClientRect();
            return r.left >= box.left-1 && r.right <= box.right+1 && r.top >= box.top-1 && r.bottom <= box.bottom+1 && el.scrollWidth <= el.clientWidth+1;
          });
          const cols = document.querySelector('.inventory-columns').getBoundingClientRect(), footer = document.querySelector('.inventory-bottom').getBoundingClientRect();
          return fits && cols.bottom < footer.top;
        }), `${language} selected food, warning, meters and controls fit ${width}x${height}`);
        await page.screenshot({ path: `output/playwright/remake/condition-${language}-${width}.png` });
      }
    }
    assert(await slot('carried', 0).getAttribute('aria-pressed') === 'true', 'Selected food remains selected across resizes');
    await page.locator('#inventory-cancel').click();
    assert(await slot('carried', 0).locator('img').count() === 1 && await page.locator('#inventory-use').count() === 0, 'Cancel preserves food and dismisses use');
    if (await page.locator('html').getAttribute('lang') !== 'en') await changeLanguage();
    await slot('carried', 0).click(); await page.locator('#inventory-use').focus(); await page.keyboard.press('Enter');
    assert(await slot('carried', 0).locator('img').count() === 0 && (await page.locator('#inventory-message').innerText()).includes('already full'), 'Keyboard activation consumes food at the cap and reports the result');
    assert(await page.evaluate(() => document.activeElement.id === 'slot-carried-0') && await page.locator('#inventory-use').count() === 0, 'Use restores focus to the empty slot and cannot repeat');
    assert(JSON.stringify(await meters()) === '[255,255,255,255]', 'At-cap consumption leaves every condition byte unchanged');
    await slot('stores', 0).click(); await slot('carried', 1).click(); await slot('carried', 1).click();
    assert((await page.locator('#inventory-use').innerText()).includes('Apply rapidheal'), 'Rapidheal offers its own use action');
    await context.setOffline(true); await page.locator('#inventory-use').click();
    assert(await slot('carried', 1).locator('img').count() === 0 && JSON.stringify(await meters()) === '[255,255,255,255]', 'Rapidheal use works offline and respects the health cap');
    assert(await slot('stores', 1).locator('img').count() === 1 && await slot('stores', 6).locator('img').count() === 1 && (await slot('stores', 10).getAttribute('aria-label')).includes('(7)'), 'Use preserves remaining food, rapidheal and the charged shield');
    await slot('stores', 10).click(); await slot('carried', 2).click(); await slot('carried', 2).click();
    assert(await page.locator('#inventory-use').count() === 0, 'Shield cannot be consumed as food or medicine');
    await page.locator('#inventory-close').click(); await page.keyboard.press('Escape'); await page.locator('#begin-walk').click(); await page.locator('#walk-inventory').click();
    assert(await slot('stores', 0).locator('img').count() === 0 && await slot('stores', 5).locator('img').count() === 0, 'Consumed items stay consumed when reopening the walkthrough');
    await context.setOffline(false); await open();
    assert(await slot('stores', 0).locator('img').count() === 1 && await slot('stores', 5).locator('img').count() === 1 && JSON.stringify(await meters()) === '[255,255,255,255]', 'Reload restores isolated inventory and condition defaults');
    const touchContext = await browser.newContext({ viewport: { width:390, height:844 }, hasTouch:true });
    try {
      const touch = await touchContext.newPage();
      touch.on('pageerror', error => errors.push(error.message));
      await touch.goto('http://127.0.0.1:8000/'); await touch.waitForFunction(() => document.documentElement.dataset.ready === 'true');
      await touch.locator('#explore').tap(); await touch.locator('#begin-walk').tap();
      const box = await touch.locator('#walk-surface').boundingBox(), cdp = await touchContext.newCDPSession(touch);
      await cdp.send('Input.dispatchTouchEvent',{ type:'touchStart',touchPoints:[{ x:box.x+57.25*box.width/280,y:box.y+83.25*box.height/192 }] });
      await touch.waitForFunction(() => document.querySelector('#walk-screen').dataset.y === '86');
      await cdp.send('Input.dispatchTouchEvent',{type:'touchEnd',touchPoints:[]});
      await touch.locator('#walk-inventory').tap(); await touch.locator('#slot-stores-5').tap(); await touch.locator('#slot-carried-0').tap(); await touch.locator('#slot-carried-0').tap(); await touch.locator('#inventory-use').tap();
      assert(await touch.locator('#slot-carried-0 img').count() === 0 && await touch.locator('#inventory-use').count() === 0, 'Touch walking, pickup and food consumption complete through visible controls');
    } finally { await touchContext.close(); }
    assert(errors.length === 0, `No browser/resource errors: ${errors.join(', ')}`);
    return { browser:browser.version(),passed:checks.length,checks };
  } catch (error) { await page.screenshot({path:'output/playwright/remake/condition-failure.png'});throw new Error(`${error.message}; last check: ${checks.at(-1)}`); }
  finally { await context.close(); }
}
