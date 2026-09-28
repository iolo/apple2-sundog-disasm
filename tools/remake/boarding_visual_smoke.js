async browserPage => {
  const context=await browserPage.context().browser().newContext({viewport:{width:640,height:480}});
  const page=await context.newPage(),checks=[];
  try {
    await page.goto('http://127.0.0.1:8000/');
    await page.waitForFunction(()=>document.documentElement.dataset.ready==='true');
    await page.locator('#create-character').click();
    await page.locator('#character-name').fill('선독 <b>');
    await page.locator('#prepare-campaign').click();
    await page.locator('#campaign-seed').fill('12345');
    for(const lang of ['en','ko']) {
      if(await page.locator('html').getAttribute('lang')!==lang)await page.locator('#character-language').click();
      for(const [width,height] of [[640,480],[1280,720],[390,844]]) {
        await page.setViewportSize({width,height});
        await page.waitForFunction(()=>getComputedStyle(document.querySelector('.launch-form')).opacity==='1');
        checks.push(`${lang} boarding entrance reaches full opacity at ${width}x${height} with normal browser time`);
        await page.screenshot({path:`output/playwright/remake/boarding-${lang}-${width}.png`});
      }
    }
    return {passed:checks.length,checks};
  } finally {await context.close()}
}
