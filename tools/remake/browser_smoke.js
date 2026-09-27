// Pass this function to playwright-cli run-code in the configured Chrome session.
async (page) => {
  const root = 'http://127.0.0.1:8000/';
  const failures = [], checks = [], requests = [], errors = [];
  const assert = (condition, name) => { if (!condition) failures.push(name); else checks.push(name); };
  const resize = async (width, height) => {
    await page.setViewportSize({ width, height });
    // Playwright's viewport acknowledgment can precede the page's resize event.
    await page.waitForFunction(() => {
      const rect = document.querySelector('#stage').getBoundingClientRect();
      return Math.abs(rect.width - Math.min(innerWidth, innerHeight * 4 / 3)) < 1;
    });
  };
  page.on('pageerror', error => errors.push(error.message));
  page.on('request', request => requests.push(request.url()));
  page.on('response', response => { if (response.status() >= 400) errors.push(`${response.status()} ${response.url()}`); });
  await page.goto(root);
  await page.waitForFunction(() => document.documentElement.dataset.ready === 'true');
  await page.evaluate(() => localStorage.setItem('sundog.locale', 'en'));
  await page.reload();
  await page.waitForFunction(() => document.documentElement.dataset.ready === 'true');
  assert(await page.evaluate(() => document.fonts.check('16px Mulmaru', '선독')), 'Local font ready');
  await resize(1280, 720);
  await page.screenshot({ path: 'output/playwright/remake/title-en.png' });
  await page.locator('#explore').click();
  for (const locale of ['en', 'ko']) {
    if (await page.locator('html').getAttribute('lang') !== locale) await page.locator('#language').click();
    for (const view of ['ship', 'cities', 'worlds']) {
      await page.locator(`#nav-${view}`).click();
      for (const [width, height] of [[640, 480], [1280, 720], [1920, 1080], [390, 844]]) {
        await resize(width, height);
        const fit = await page.evaluate(() => {
          const rect = document.querySelector('#stage').getBoundingClientRect();
          const heading = document.querySelector('.scene-heading h1').getBoundingClientRect();
          const pager = document.querySelector('.pager').getBoundingClientRect();
          return { ratio: rect.width / rect.height, fits: rect.left >= -1 && rect.top >= -1 && rect.right <= innerWidth + 1 && rect.bottom <= innerHeight + 1,
            scroll: document.documentElement.scrollWidth <= innerWidth && document.documentElement.scrollHeight <= innerHeight,
            headingFits: heading.right <= pager.left + 1 };
        });
        assert(Math.abs(fit.ratio - 4 / 3) < .001 && fit.fits && fit.scroll && fit.headingFits, `${locale}/${view}/${width}×${height} layout`);
        const bounds = await page.locator('#stage').boundingBox();
        await page.mouse.click(bounds.x + 320 * bounds.width / 640, bounds.y + 240 * bounds.height / 480);
        assert(!(await page.locator('.selection').innerText()).includes(locale === 'en' ? 'Select' : '선택하세요'), `${locale}/${view}/${width} pointer`);
      }
      await resize(1280, 720);
      await page.screenshot({ path: `output/playwright/remake/${view}-${locale}.png` });
    }
  }
  await page.locator('#nav-cities').click();
  await page.locator('#previous').click();
  assert((await page.locator('.pager').innerText()).includes('60 / 60'), 'Reverse city wrap');
  await page.locator('#next').click();
  assert((await page.locator('.pager').innerText()).includes('01 / 60'), 'Forward city wrap');
  for (const bank of ['0', '1', '2', '3']) await page.locator('#bank').selectOption(bank);
  await page.locator('#inspect').focus();
  await page.keyboard.press('Enter');
  const before = await page.locator('.selection').innerText();
  await page.keyboard.press('ArrowRight');
  assert(await page.locator('.selection').innerText() !== before, 'Keyboard tile selection');
  await page.locator('#nav-ship').click();
  await page.locator('#help').click();
  await page.keyboard.press('Tab');
  assert(await page.evaluate(() => document.activeElement.id === 'close-help'), 'Modal focus stays inside dialog');
  await page.keyboard.press('Escape');
  assert(await page.evaluate(() => document.activeElement.id === 'help'), 'Modal restores focus');
  await page.keyboard.press('Escape');
  assert(await page.locator('#explore').count() === 1, 'Escape returns to title');
  await page.reload();
  await page.waitForFunction(() => document.documentElement.dataset.ready === 'true');
  assert(await page.locator('html').getAttribute('lang') === 'ko', 'Language survives reload');
  await resize(390, 844);
  await page.screenshot({ path: 'output/playwright/remake/title-ko-mobile.png' });
  await page.locator('#explore').click();
  await page.screenshot({ path: 'output/playwright/remake/ship-ko-mobile.png' });
  await page.context().setOffline(true);
  await page.locator('#nav-worlds').click();
  for (let i = 0; i < 18; i++) await page.locator('#next').click();
  await page.locator('#nav-cities').click();
  for (let i = 0; i < 60; i++) await page.locator('#next').click();
  assert((await page.locator('.pager').innerText()).includes('01 / 60'), 'All world/city layouts browse after disconnecting network');
  await page.context().setOffline(false);
  await page.goto(`${root}tests/`);
  await page.waitForFunction(() => document.documentElement.dataset.result);
  assert(await page.locator('html').getAttribute('data-result') === 'pass', 'Six browser rule/localization tests');
  await page.goto('http://127.0.0.1:8001/archive/');
  await page.waitForFunction(() => document.documentElement.dataset.ready === 'true');
  await page.locator('#explore').click();
  await page.locator('#nav-cities').click();
  assert(await page.locator('.pager').count() === 1, 'Standalone copied folder at nested base');
  assert(requests.every(url => ['http://127.0.0.1:8000/', 'http://127.0.0.1:8001/'].some(origin => url.startsWith(origin))), 'No external runtime requests');
  assert(errors.length === 0, `No browser/resource errors: ${errors.join(', ')}`);
  if (failures.length) throw new Error(failures.join('\n'));
  return { browser: page.context().browser().version(), passed: checks.length, failures, checks };
}
