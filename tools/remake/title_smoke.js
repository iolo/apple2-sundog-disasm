async(page) => {
  await page.goto('http://127.0.0.1:8000/');
  await page.waitForFunction(() => document.documentElement.dataset.ready === 'true');
  await page.emulateMedia({ reducedMotion: 'reduce' });
  const checks=[];
  for(const language of ['en','ko']) {
    if(await page.locator('html').getAttribute('lang') !== language) await page.locator('#language').click();
    for(const [width,height] of [[1280,720],[390,844]]) {
      await page.setViewportSize({width,height});
      await page.waitForFunction(() => Math.abs(document.querySelector('#stage').getBoundingClientRect().width - Math.min(innerWidth, innerHeight * 4/3)) < 1);
      const boxes=await page.evaluate(() => ['.hero','.hero-actions','.bottomline'].map(s=>{const r=document.querySelector(s).getBoundingClientRect();return {top:r.top,bottom:r.bottom};}));
      if(boxes[0].bottom > boxes[1].top || boxes[1].bottom > boxes[2].top) throw new Error(JSON.stringify({language,width,boxes}));
      await page.screenshot({path:`output/playwright/remake/title-final-${language}-${width}.png`});
      checks.push(`${language}/${width} title content and actions separated`);
    }
  }
  await page.locator('#about').click();
  await page.waitForSelector('#close-help');
  await page.keyboard.press('Escape');
  if(await page.evaluate(()=>document.activeElement.id)!=='about') throw new Error('about focus');
  return {checks,aboutFocus:true};
}
