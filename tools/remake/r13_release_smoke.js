// Runs against browser_check.py --clean-copy: only the shipped remake/ tree is served.
async browserPage => {
  const browser=browserPage.context().browser(),checks=[],errors=[],requests=[],frames=[];
  const assert=(condition,label)=>{if(!condition)throw Error(label);checks.push(label)};
  const ready=page=>page.waitForFunction(()=>document.documentElement.dataset.ready==='true');
  const measure=page=>page.evaluate(()=>new Promise(resolve=>{
    const times=[];let previous=null;
    const tick=now=>{if(previous!==null)times.push(now-previous);previous=now;
      if(times.length===120){const sorted=[...times].sort((a,b)=>a-b);resolve({median:sorted[59],p95:sorted[113],max:sorted[119],frames:times.length})}
      else requestAnimationFrame(tick)};
    requestAnimationFrame(tick);
  }));
  for(const dpr of [1,2]) {
    const context=await browser.newContext({viewport:{width:1280,height:720},deviceScaleFactor:dpr,locale:'en-US'}),page=await context.newPage();
    page.on('pageerror',error=>errors.push(error.message));
    page.on('console',message=>{if(message.type()==='error')errors.push(message.text())});
    page.on('dialog',dialog=>dialog.accept());
    page.on('request',request=>requests.push(request.url()));
    page.on('response',response=>{if(response.status()>=400)errors.push(`${response.status()} ${response.url()}`)});
    await page.goto('http://127.0.0.1:8000/');await ready(page);await page.evaluate(()=>document.fonts.ready);
    assert(await page.evaluate(()=>document.fonts.check('16px Mulmaru','선독')),`DPR${dpr}: bundled Korean font loads`);
    if(dpr===1)frames.push({scene:'title',dpr,...await measure(page)});
    await page.locator('#explore').click();await page.locator('#nav-ship').click();
    let reference=null;
    for(const [width,height] of [[640,480],[1280,720],[1920,1080],[390,844]]) {
      await page.setViewportSize({width,height});
      await page.waitForFunction(([w,h])=>{const r=document.querySelector('#stage').getBoundingClientRect();return Math.abs(r.width-Math.min(w,h*4/3))<1},[width,height]);
      const geometry=await page.evaluate(()=>{
        const stage=document.querySelector('#stage').getBoundingClientRect(),canvas=document.querySelector('#scene');
        const enabled=[...document.querySelectorAll('button:not(:disabled)')].filter(button=>button.getClientRects().length&&!button.closest('[inert]'));
        return {stage:{x:stage.x,y:stage.y,width:stage.width,height:stage.height,right:stage.right,bottom:stage.bottom},
          backing:{width:canvas.width,height:canvas.height},scroll:document.documentElement.scrollWidth>innerWidth||document.documentElement.scrollHeight>innerHeight,
          clipped:enabled.filter(button=>{const r=button.getBoundingClientRect();return r.left<stage.left-1||r.right>stage.right+1||r.top<stage.top-1||r.bottom>stage.bottom+1}).map(button=>button.id)};
      });
      const s=geometry.stage,expectedWidth=Math.round(s.width*dpr),expectedHeight=Math.round(s.height*dpr);
      assert(Math.abs(s.width/s.height-4/3)<.001&&s.x>=-1&&s.y>=-1&&s.right<=width+1&&s.bottom<=height+1&&!geometry.scroll,
        `DPR${dpr} ${width}x${height}: 4:3 stage without page scrolling`);
      assert(Math.abs(geometry.backing.width-expectedWidth)<=1&&Math.abs(geometry.backing.height-expectedHeight)<=1,
        `DPR${dpr} ${width}x${height}: canvas backing matches physical pixels`);
      assert(!geometry.clipped.length,`DPR${dpr} ${width}x${height}: essential inspector controls fit (${geometry.clipped.join(',')})`);
      await page.mouse.click(s.x+s.width/2,s.y+s.height/2);
      const selected=await page.locator('.selection').innerText();
      assert(selected&&!/select a point|선택하세요/i.test(selected),`DPR${dpr} ${width}x${height}: pointer selects ship art`);
      if(reference!==null)assert(selected===reference,`DPR${dpr} ${width}x${height}: pointer maps to the same ship coordinate`);
      reference=selected;
      if((width===1920||width===390)&&dpr===2)await page.screenshot({path:`output/playwright/remake/r13-ship-${width}-dpr${dpr}.png`});
    }
    await page.setViewportSize({width:1280,height:720});
    if(dpr===1)frames.push({scene:'inspector',dpr,...await measure(page)});
    await page.locator('#language').click();
    assert(await page.locator('html').getAttribute('lang')==='ko',`DPR${dpr}: Korean inspector locale`);
    await page.locator('#home').click();await page.locator('#create-character').click();
    await page.locator('#character-name').fill('출시 점검');await page.locator('#prepare-campaign').click();
    await page.locator('#campaign-seed').fill('12345');await page.locator('#start-campaign').click();
    assert(await page.locator('#walk-screen').isVisible(),`DPR${dpr}: clean-copy campaign starts`);
    if(dpr===1)frames.push({scene:'ship',dpr,...await measure(page)});
    if(dpr===2)await page.screenshot({path:'output/playwright/remake/r13-ship-ko-dpr2.png'});
    await context.close();
  }
  assert(requests.length>150&&requests.every(url=>url.startsWith('http://127.0.0.1:8000/')),
    `All ${requests.length} runtime requests stay inside the clean static copy`);
  assert(!errors.length,`No uncaught or missing-resource errors: ${errors.join('; ')}`);
  return {browser:browser.version(),status:'pass',checks,requests:requests.length,errors,frames,
    machine:{userAgent:await browserPage.evaluate(()=>navigator.userAgent)}};
}
