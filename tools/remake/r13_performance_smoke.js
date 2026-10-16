// Measure real requestAnimationFrame cadence while the release build draws busy scenes.
async browserPage => {
  const browser=browserPage.context().browser(),context=await browser.newContext({viewport:{width:1280,height:720},deviceScaleFactor:1,locale:'en-US'}),page=await context.newPage();
  const errors=[],frames=[];
  page.on('pageerror',error=>errors.push(error.message));page.on('dialog',dialog=>dialog.accept());
  const measure=async scene=>{
    const result=await page.evaluate(()=>new Promise(resolve=>{
      const intervals=[];let last=null;
      const tick=now=>{if(last!==null)intervals.push(now-last);last=now;
        if(intervals.length===180){const sorted=[...intervals].sort((a,b)=>a-b);resolve({median:sorted[89],p95:sorted[170],max:sorted[179],frames:intervals.length})}
        else requestAnimationFrame(tick)};
      requestAnimationFrame(tick);
    }));
    frames.push({scene,...result});
    if(result.median>20||result.p95>34)throw Error(`${scene} missed 60Hz target: ${JSON.stringify(result)}`);
  };
  await page.goto('http://127.0.0.1:8000/');await page.waitForFunction(()=>document.documentElement.dataset.ready==='true');
  await page.locator('#create-character').click();await page.locator('#character-name').fill('Perf');
  await page.locator('#prepare-campaign').click();await page.locator('#campaign-seed').fill('1');
  await page.locator('#start-campaign').click();
  await measure('landed ship');
  await page.locator('#walk-saves').click();await page.waitForFunction(()=>document.querySelector('#checkpoint-back')?.disabled===false);
  await page.locator('#checkpoint-file').setInputFiles('output/playwright/remake/r11-phase-one-checkpoint.json');
  await page.waitForFunction(()=>/imported/i.test(document.querySelector('#checkpoint-message')?.textContent||''));
  await page.locator('#checkpoint-back').click();
  await measure('active Center');
  await page.locator('#service-leave').click();
  await measure('composed city with pod');
  await context.close();
  if(errors.length)throw Error(errors.join('; '));
  return {browser:browser.version(),status:'pass',frames,errors,machine:{userAgent:await browserPage.evaluate(()=>navigator.userAgent)}};
}
