// Run with playwright-cli run-code in the configured Chrome session.
async (browserPage) => {
  const context = await browserPage.context().browser().newContext({ viewport: { width: 1280, height: 720 } });
  const page = await context.newPage(), checks = [], errors = [];
  const assert = (condition, label) => { if (!condition) throw new Error(label); checks.push(label); };
  const root = 'http://127.0.0.1:8000/';
  const ready = () => page.waitForFunction(() => document.documentElement.dataset.ready === 'true');
  page.on('pageerror', e => errors.push(e.message));
  let acceptDialogs = true;
  page.on('dialog', dialog => acceptDialogs ? dialog.accept() : dialog.dismiss());
  try {
    await page.goto(`${root}tests/`);
    await page.waitForFunction(() => document.documentElement.dataset.result);
    const results = await page.locator('#results').innerText();
    if (await page.locator('html').getAttribute('data-result') !== 'pass') throw new Error(results);
    checks.push('13 browser rule/localization/storage tests');
    await page.goto(root); await ready();
    await page.locator('#create-character').click();
    assert(await page.locator('#points-left').innerText() === '440 points left', 'Initial budget 440');
    assert(await page.locator('#minus-strength').isDisabled() && await page.locator('#minus-luck').isDisabled(), 'Minimum controls disabled');
    await page.locator('#character-name').fill('선독');
    for (let i = 0; i < 70; i++) await page.locator('#plus-strength').click();
    assert(await page.locator('#value-strength').innerText() === '100' && await page.locator('#plus-strength').isDisabled(), 'Full budget reaches strength 100');
    await page.locator('#minus-strength').click();
    assert(await page.locator('#points-left').innerText() === '16 points left', 'Refund at upper tier');
    await page.locator('#character-language').click();
    assert(await page.locator('#character-name').inputValue() === '선독' && await page.locator('#value-strength').innerText() === '99', 'Locale change preserves character');
    for (const locale of ['en', 'ko']) {
      if (await page.locator('html').getAttribute('lang') !== locale) await page.locator('#character-language').click();
      for (const [width, height] of [[640, 480], [1280, 720], [390, 844]]) {
        await page.setViewportSize({ width, height });
        await page.waitForFunction(() => Math.abs(document.querySelector('#stage').getBoundingClientRect().width - Math.min(innerWidth, innerHeight * 4 / 3)) < 1);
        const fit = await page.evaluate(() => {
          const stage = document.querySelector('#stage').getBoundingClientRect();
          const panel = document.querySelector('#character-screen');
          const points = panel.querySelector('#points-left').getBoundingClientRect();
          const footer = panel.querySelector('.draft-actions').getBoundingClientRect();
          if (points.bottom > footer.top) return false;
          const elements = [...panel.querySelectorAll('button,input:not([hidden]),.draft-note,#points-left')];
          return elements.every(el => { const r = el.getBoundingClientRect(); return r.left >= stage.left - 1 && r.right <= stage.right + 1 && r.top >= stage.top - 1 && r.bottom <= stage.bottom + 1; }) && document.documentElement.scrollWidth <= innerWidth && document.documentElement.scrollHeight <= innerHeight;
        });
        assert(fit, `${locale} character layout ${width}x${height}`);
        await page.screenshot({ path: `output/playwright/remake/character-${locale}-${width}.png` });
      }
    }
    await page.locator('#show-drafts').click();
    await page.waitForFunction(() => document.querySelector('#save-draft-0')?.disabled === false);
    assert(await page.locator('.draft-row').count() === 4, 'Exactly four draft slots');
    await page.locator('#save-draft-0').click();
    await page.waitForFunction(() => document.querySelector('#character-message').textContent.includes('저장했습니다'));
    await page.screenshot({ path: 'output/playwright/remake/drafts-ko-mobile.png' });
    const downloadPromise = page.waitForEvent('download');
    await page.locator('#export-draft').click();
    const download = await downloadPromise;
    await download.saveAs('output/playwright/remake/character-export.json');
    assert(download.suggestedFilename() === 'sundog-character.json', 'JSON export download');
    await page.reload(); await ready(); await page.locator('#create-character').click();
    await page.locator('#show-drafts').click();
    await page.waitForFunction(() => document.querySelector('#load-draft-0')?.disabled === false);
    await page.locator('#load-draft-0').click();
    assert(await page.locator('#character-name').inputValue() === '선독' && await page.locator('#value-strength').innerText() === '99', 'Draft survives reload and restores exact allocation');
    await page.locator('#minus-strength').click();
    await page.locator('#show-drafts').click();
    acceptDialogs = false; await page.locator('#save-draft-0').click(); acceptDialogs = true;
    await page.locator('#load-draft-0').click();
    assert(await page.locator('#value-strength').innerText() === '99', 'Cancelled overwrite preserves saved draft');
    await page.locator('#show-drafts').click(); await page.locator('#save-draft-1').click();
    await page.waitForFunction(() => document.querySelector('#character-message').textContent.includes('같은 이름'));
    assert(await page.locator('#load-draft-1').isDisabled(), 'Duplicate save leaves empty slot intact');
    await page.locator('#edit-character').click(); await page.locator('#reset-character').click();
    assert(await page.locator('#value-strength').innerText() === '30', 'Reset restores attributes');
    await page.locator('#show-drafts').click();
    await page.locator('#draft-file').setInputFiles('output/playwright/remake/character-export.json');
    await page.waitForSelector('#character-name');
    assert(await page.locator('#character-name').inputValue() === '선독' && await page.locator('#value-strength').innerText() === '99', 'Export/import roundtrip');
    await page.locator('#show-drafts').click();
    await page.locator('#draft-file').setInputFiles('remake/tests/fixtures/future-draft.json');
    await page.waitForFunction(() => document.querySelector('#character-message').textContent.includes('지원하지'));
    await page.locator('#edit-character').click();
    assert(await page.locator('#value-strength').innerText() === '99', 'Invalid import preserves editor');
    await page.locator('#character-name').fill('<b>선독</b>');
    await page.locator('#show-drafts').click(); await page.locator('#save-draft-1').click();
    await page.waitForFunction(() => document.querySelectorAll('.slot-name')[1].textContent === '<b>선독</b>');
    assert(await page.locator('.slot-name b').count() === 0, 'Imported/user names render as text');
    await page.evaluate(() => document.dispatchEvent(new KeyboardEvent('keydown', { key: 'Escape', isComposing: true, bubbles: true })));
    assert(await page.locator('#character-screen').isVisible(), 'IME composition Escape does not close editor');
    await page.keyboard.press('Escape');
    assert(await page.evaluate(() => document.activeElement.id === 'create-character'), 'Escape closes editor and restores focus');
    await page.evaluate(() => Object.defineProperty(window, 'indexedDB', { value: { open() { throw new Error('blocked'); } }, configurable: true }));
    // A fresh document is required so the editor does not retain its open connection.
    await page.addInitScript(() => Object.defineProperty(window, 'indexedDB', { value: { open() { throw new Error('blocked'); } } }));
    await page.reload(); await ready(); await page.locator('#create-character').click();
    await page.waitForFunction(() => document.querySelector('#character-message').textContent.includes('저장소'));
    await page.locator('#character-name').fill('Storage test'); await page.locator('#show-drafts').click();
    assert(await page.locator('#save-draft-0').isDisabled() && await page.locator('#export-draft').isEnabled(), 'Storage failure retains export and disables saving');
    assert(errors.length === 0, `No page errors: ${errors.join(', ')}`);
    return { browser: context.browser().version(), checks, passed: checks.length, unitResults: results.split('\n') };
  } catch (error) { await page.screenshot({ path: 'output/playwright/remake/character-failure.png' }); throw new Error(`${error.message}; last check: ${checks.at(-1)}`); } finally { await context.close(); }
}
