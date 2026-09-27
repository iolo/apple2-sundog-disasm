// Run through playwright-cli run-code using tools/remake/chrome.config.json.
async (browserPage) => {
  const browser = browserPage.context().browser(), checks = [], errors = [];
  const assert = (value, message) => { if (!value) throw new Error(message); checks.push(message); };
  const context = await browser.newContext({ viewport: { width: 1280, height: 720 } });
  const page = await context.newPage();
  page.on('pageerror', error => errors.push(error.message));
  page.on('response', response => { if (response.status() >= 400) errors.push(`${response.status()} ${response.url()}`); });
  const position = () => page.locator('#walk-screen').evaluate(el => ({ x: Number(el.dataset.x), y: Number(el.dataset.y) }));
  const point = async (x, y) => {
    const box = await page.locator('#stage').boundingBox();
    return { x: box.x + (32 + x * 640 / 280) * box.width / 640, y: box.y + (46 + y * 384 / 192) * box.height / 480 };
  };
  const open = async (target = page) => {
    await target.goto('http://127.0.0.1:8000/');
    await target.waitForFunction(() => document.documentElement.dataset.ready === 'true');
    await target.locator('#explore').click(); await target.locator('#begin-walk').click();
  };
  try {
    await open();
    assert(JSON.stringify(await position()) === '{"x":54,"y":110}', 'Verified fresh-character spawn');
    const destination = await point(53, 96);
    await page.mouse.move(destination.x, destination.y); await page.mouse.down();
    await page.waitForFunction(() => document.querySelector('#walk-screen').dataset.y !== '110');
    await page.waitForTimeout(500); await page.mouse.up();
    const stopped = await position(); await page.waitForTimeout(180);
    assert(JSON.stringify(await position()) === JSON.stringify(stopped), 'Pointer release stops movement');
    assert(await page.evaluate(async () => {
      const { canStand } = await import('/js/core/ship-walk.js');
      const g = await fetch('/data/ship-walk.json').then(r => r.json()), el = document.querySelector('#walk-screen');
      return canStand(g, { x: Number(el.dataset.x), y: Number(el.dataset.y) });
    }), 'Pointer movement stays in clear collision space');
    await page.locator('#walk-reset').click();
    await page.locator('#walk-surface').focus(); await page.keyboard.down('ArrowUp');
    await page.waitForTimeout(260); await page.keyboard.up('ArrowUp');
    assert((await position()).y < 110, 'Keyboard movement uses focused ship');
    await page.locator('#walk-pause').click(); const paused = await position();
    await page.locator('#walk-surface').focus(); await page.keyboard.down('ArrowDown'); await page.waitForTimeout(180); await page.keyboard.up('ArrowDown');
    assert(JSON.stringify(await position()) === JSON.stringify(paused), 'Pause blocks held keyboard movement');
    await page.locator('#walk-pause').click();
    await page.keyboard.down('ArrowDown'); await page.waitForTimeout(100);
    await page.evaluate(() => window.dispatchEvent(new Event('blur'))); await page.keyboard.up('ArrowDown');
    const blurred = await position(); await page.waitForTimeout(180);
    assert(await page.locator('#walk-screen').getAttribute('data-paused') === 'true' && JSON.stringify(await position()) === JSON.stringify(blurred), 'Blur pauses and clears held input');
    await page.locator('#walk-help').click(); await page.keyboard.press('Tab');
    assert(await page.evaluate(() => document.activeElement.id === 'walk-close-help'), 'Walk help traps focus');
    await page.keyboard.press('Escape');
    assert(await page.evaluate(() => document.activeElement.id === 'walk-help'), 'Help Escape restores focus without leaving ship');
    await page.locator('#walk-reset').click();
    for (const language of ['en', 'ko']) {
      if (await page.locator('html').getAttribute('lang') !== language) await page.locator('#walk-language').click();
      assert(JSON.stringify(await position()) === '{"x":54,"y":110}', `${language} locale preserves position`);
      for (const [width, height] of [[640, 480], [1280, 720], [390, 844]]) {
        await page.setViewportSize({ width, height });
        await page.waitForFunction(() => Math.abs(document.querySelector('#stage').getBoundingClientRect().width - Math.min(innerWidth, innerHeight * 4 / 3)) < 1);
        const fits = await page.evaluate(() => {
          const box = document.querySelector('#stage').getBoundingClientRect();
          const controls = [...document.querySelectorAll('#walk-screen button,#walk-screen h1,.walk-note,#walk-status')];
          const status = document.querySelector('#walk-status').getBoundingClientRect(), footer = document.querySelector('.walk-actions').getBoundingClientRect();
          return status.bottom <= footer.top && controls.every(el => {const r=el.getBoundingClientRect();return r.left >= box.left - 1 && r.right <= box.right + 1 && r.top >= box.top - 1 && r.bottom <= box.bottom + 1;}) && document.documentElement.scrollWidth <= innerWidth;
        });
        assert(fits, `${language} walkthrough layout ${width}x${height}`);
        await page.screenshot({ path: `output/playwright/remake/walk-${language}-${width}.png` });
      }
    }
    await page.locator('#walk-surface').focus();
    await page.keyboard.down('ArrowUp'); await page.waitForTimeout(160); await page.keyboard.up('ArrowUp');
    const beforeExit = await position();
    await page.keyboard.press('Escape');
    assert(await page.evaluate(() => document.activeElement.id === 'begin-walk'), 'Walk Escape restores entry focus');
    await page.locator('#begin-walk').click();
    assert(JSON.stringify(await position()) === JSON.stringify(beforeExit), 'Reopening walkthrough retains local position');
    await page.context().setOffline(true); await page.locator('#walk-reset').click();
    await page.locator('#walk-surface').focus(); await page.keyboard.down('ArrowUp'); await page.waitForTimeout(140); await page.keyboard.up('ArrowUp');
    assert((await position()).y < 110, 'Walking works after network disconnect');
    await page.context().setOffline(false);
    await page.goto('http://127.0.0.1:8000/tests/'); await page.waitForFunction(() => document.documentElement.dataset.result);
    const unitResults = (await page.locator('#results').innerText()).split('\n');
    assert(await page.locator('html').getAttribute('data-result') === 'pass', unitResults.join('\n'));
    const touchContext = await browser.newContext({ viewport: { width: 390, height: 844 }, deviceScaleFactor: 2, hasTouch: true });
    const touch = await touchContext.newPage();
    try {
      touch.on('pageerror', error => errors.push(error.message));
      await open(touch);
      const box = await touch.locator('#stage').boundingBox();
      const x = box.x + (32 + 53 * 640 / 280) * box.width / 640, y = box.y + (46 + 96 * 2) * box.height / 480;
      const cdp = await touchContext.newCDPSession(touch);
      await cdp.send('Input.dispatchTouchEvent', { type: 'touchStart', touchPoints: [{ x, y }] });
      await touch.waitForFunction(() => document.querySelector('#walk-screen').dataset.y !== '110');
      await cdp.send('Input.dispatchTouchEvent', { type: 'touchCancel', touchPoints: [] });
      const stoppedTouch = await touch.locator('#walk-screen').getAttribute('data-y'); await touch.waitForTimeout(180);
      assert(await touch.locator('#walk-screen').getAttribute('data-y') === stoppedTouch, 'Real touch cancellation releases movement');
      assert(await touch.locator('#walk-screen canvas').evaluate(el => Math.abs(el.width - el.getBoundingClientRect().width * 2) < 2), 'DPR2 canvas scales without changing logical coordinates');
      await touch.screenshot({ path: 'output/playwright/remake/walk-touch-dpr2.png' });
    } finally { await touchContext.close(); }
    assert(errors.length === 0, `No browser/resource errors: ${errors.join(', ')}`);
    return { browser: browser.version(), passed: checks.length, checks: checks.map(value => value.startsWith('PASS ') ? '19 browser rule/storage/movement tests' : value), unitResults };
  } catch (error) { await page.screenshot({ path: 'output/playwright/remake/walk-failure.png' }); throw new Error(`${error.message}; last check: ${checks.at(-1)}`); }
  finally { await context.close(); }
}
