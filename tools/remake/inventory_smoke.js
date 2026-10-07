// Run via playwright-cli in the configured Chrome; no fixture injection into UI.
async browserPage => {
  const browser = browserPage.context().browser();
  const context = await browser.newContext({ viewport: { width: 1280, height: 720 } });
  const page = await context.newPage(), checks = [], errors = [];
  const assert = (ok, name) => { if (!ok) throw new Error(name); checks.push(name); };
  page.on('pageerror', error => errors.push(error.message));
  page.on('response', response => { if (response.status() >= 400) errors.push(`${response.status()} ${response.url()}`); });
  const slot = (container, index) => page.locator(`#slot-${container}-${index}`);
  const label = (container, index) => slot(container, index).getAttribute('aria-label');
  const move = async (x, y) => {
    if (await page.locator('#walk-screen').getAttribute('data-paused') === 'true') await page.locator('#walk-pause').click();
    const box = await page.locator('#stage').boundingBox();
    // Aim inside the source pixel, not on a floating-point boundary.
    await page.mouse.move(box.x + (32 + (x + 3.25) * 640 / 280) * box.width / 640, box.y + (46 + (y - 2.75) * 2) * box.height / 480);
    await page.mouse.down();
    await page.waitForFunction(({ x, y }) => { const el = document.querySelector('#walk-screen'); return Number(el.dataset.x) === x && Number(el.dataset.y) === y; }, { x, y });
    await page.mouse.up();
  };
  const open = async () => {
    await page.goto('http://127.0.0.1:8000/'); await page.waitForFunction(() => document.documentElement.dataset.ready === 'true');
    if (await page.locator('html').getAttribute('lang') !== 'en') await page.locator('[data-action="language"]').click();
    await page.locator('#explore').click(); await page.locator('#begin-walk').click();
  };
  try {
    await open();
    await page.keyboard.press('i');
    assert(await page.locator('.item-slot').count() === 4, 'Inventory away from storage exposes only four carried slots');
    await page.keyboard.press('Shift+Tab');
    assert(await page.evaluate(() => document.querySelector('#inventory-panel').contains(document.activeElement)), 'Inventory traps reverse keyboard focus');
    await page.keyboard.press('Escape');
    assert(await page.evaluate(() => document.activeElement.id === 'walk-inventory'), 'Inventory closes with focus restored');
    await move(54, 86); await page.locator('#walk-inventory').click();
    assert(await page.locator('.item-slot').count() === 24 && await slot('stores', 19).count() === 1, 'Walking reaches stores and reveals twenty storage slots');
    assert((await label('stores', 10)).includes('Shield (7)'), 'Initial shield retains seven encoded charge units');
    await slot('stores', 10).click();
    await page.keyboard.press('Escape');
    assert((await label('stores', 10)).includes('Shield (7)') && await page.locator('#inventory-panel').count() === 1, 'Escape cancels selection without consuming an item or closing inventory');
    await slot('stores', 10).click(); await slot('carried', 0).click();
    assert((await label('carried', 0)).includes('Shield (7)') && (await label('stores', 10)).includes('Empty'), 'Store pickup transfers the entire charged item');
    await slot('stores', 5).click(); await slot('carried', 0).click();
    assert((await label('carried', 0)).includes('Food') && (await label('stores', 5)).includes('Shield (7)'), 'Occupied carried slot swaps without losing either item');
    await slot('stores', 0).click(); await page.locator('#inventory-cancel').click();
    assert((await label('stores', 0)).includes('Rapidheal') && await page.locator('.item-slot[aria-pressed=true]').count() === 0, 'Cancel button leaves inventory unchanged');
    await slot('stores', 0).click(); await page.locator('#inventory-close').click(); await page.locator('#walk-inventory').click();
    assert((await label('stores', 0)).includes('Rapidheal') && await page.locator('.item-slot[aria-pressed=true]').count() === 0, 'Closing with a selection never strands an item');
    await slot('stores', 5).click(); await page.locator('#inventory-language').click();
    assert((await label('stores', 5)).includes('방어막 (7)') && await slot('stores', 5).getAttribute('aria-pressed') === 'true', 'Korean switch preserves selected slot and charge');
    await page.locator('#inventory-language').click();
    assert(await slot('stores', 5).getAttribute('aria-pressed') === 'true', 'English switch preserves selection');
    await page.locator('#inventory-cancel').click();
    for (const language of ['en', 'ko']) {
      if (await page.locator('html').getAttribute('lang') !== language) await page.locator('#inventory-language').click();
      for (const [width, height] of [[640, 480], [1280, 720], [390, 844]]) {
        await page.setViewportSize({ width, height });
        await page.waitForFunction(() => Math.abs(document.querySelector('#stage').getBoundingClientRect().width - Math.min(innerWidth, innerHeight * 4 / 3)) < 1);
        assert(await page.evaluate(() => {
          const box = document.querySelector('#stage').getBoundingClientRect();
          const fits = [...document.querySelectorAll('#inventory-panel button,#inventory-panel h2,.inventory-note,.inventory-columns,.inventory-bottom')].every(el => { const r = el.getBoundingClientRect(); return r.left >= box.left - 1 && r.right <= box.right + 1 && r.top >= box.top - 1 && r.bottom <= box.bottom + 1 && el.scrollWidth <= el.clientWidth + 1; });
          return fits && document.querySelector('.inventory-columns').getBoundingClientRect().bottom < document.querySelector('.inventory-bottom').getBoundingClientRect().top;
        }), `${language} inventory fits ${width}x${height}`);
        await page.screenshot({ path: `output/playwright/remake/inventory-${language}-${width}.png` });
      }
    }
    if (await page.locator('html').getAttribute('lang') !== 'en') await page.locator('#inventory-language').click();
    await page.locator('#inventory-close').click(); await move(54, 110); await move(83, 110);
    await page.locator('#walk-inventory').click();
    assert(await slot('locker', 19).count() === 1 && (await label('locker', 15)).includes('Shunt'), 'Locker is reachable and has the original five shunts');
    await page.context().setOffline(true);
    await slot('carried', 0).click(); await slot('locker', 0).click();
    assert((await label('locker', 0)).includes('Food') && (await label('carried', 0)).includes('Empty'), 'Carried-to-locker deposit works offline');
    await page.locator('#inventory-close').click(); await page.keyboard.press('Escape'); await page.locator('#begin-walk').click(); await page.locator('#walk-inventory').click();
    assert((await label('locker', 0)).includes('Food'), 'Leaving and reopening the walkthrough retains transferred items');
    await page.context().setOffline(false);
    await open(); await move(54, 86); await page.locator('#walk-inventory').click();
    assert((await label('stores', 10)).includes('Shield (7)') && (await label('carried', 0)).includes('Empty'), 'Reload resets the isolated walkthrough inventory');
    await page.goto('http://127.0.0.1:8000/tests/'); await page.waitForFunction(() => document.documentElement.dataset.result,null,{timeout:120000});
    const unitResults = (await page.locator('#results').innerText()).split('\n');
    assert(await page.locator('html').getAttribute('data-result') === 'pass', `${unitResults.length} browser tests pass`);
    const touchContext = await browser.newContext({ viewport: { width: 390, height: 844 }, hasTouch: true });
    const touch = await touchContext.newPage();
    try {
      touch.on('pageerror', error => errors.push(error.message));
      await touch.goto('http://127.0.0.1:8000/'); await touch.waitForFunction(() => document.documentElement.dataset.ready === 'true');
      await touch.locator('#explore').tap(); await touch.locator('#begin-walk').tap();
      const box = await touch.locator('#stage').boundingBox(), cdp = await touchContext.newCDPSession(touch);
      const x = box.x + (32 + 57.25 * 640 / 280) * box.width / 640, y = box.y + (46 + 83.25 * 2) * box.height / 480;
      await cdp.send('Input.dispatchTouchEvent', { type: 'touchStart', touchPoints: [{ x, y }] });
      await touch.waitForFunction(() => document.querySelector('#walk-screen').dataset.y === '86');
      await cdp.send('Input.dispatchTouchEvent', { type: 'touchEnd', touchPoints: [] });
      await touch.locator('#walk-inventory').tap(); await touch.locator('#slot-stores-10').tap(); await touch.locator('#slot-carried-0').tap();
      assert((await touch.locator('#slot-carried-0').getAttribute('aria-label')).includes('(7)') && await touch.locator('#slot-stores-10 img').count() === 0, 'Touch walking and slot taps transfer the shield with its charge');
    } finally { await touchContext.close(); }
    assert(errors.length === 0, `No browser/resource errors: ${errors.join(', ')}`);
    return { browser: browser.version(), passed: checks.length, checks, unitResults };
  } catch (error) { await page.screenshot({ path: 'output/playwright/remake/inventory-failure.png' }); throw new Error(`${error.message}; last check: ${checks.at(-1)}`); }
  finally { await context.close(); }
}
