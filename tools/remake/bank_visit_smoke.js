// Read-only source geometry finds a route; all live changes use normal UI.
async browserPage => {
  const browser=browserPage.context().browser(),checks=[],errors=[];
  const context=await browser.newContext({viewport:{width:1280,height:720},hasTouch:true});
  const page=await context.newPage();
  page.on('pageerror',e=>errors.push(e.message));page.on('dialog',d=>d.accept());
  const assert=(ok,name)=>{if(!ok)throw Error(name);checks.push(name)};
  const ready=()=>page.waitForFunction(()=>document.documentElement.dataset.ready==='true');
  const settled=()=>page.waitForFunction(()=>document.querySelector('#checkpoint-back')?.disabled===false);
  const state=()=>page.locator('#walk-screen').evaluate(el=>({...el.dataset}));
  const saves=async()=>{await page.locator((await state()).scene==='bank' ? '#bank-saves' : '#walk-saves').click();await settled()};
  const exportGame=async()=>{
    await saves();const pending=page.waitForEvent('download');await page.locator('#export-checkpoint').click();
    let text='';for await(const part of await (await pending).createReadStream())text+=part;
    await settled();await page.locator('#checkpoint-back').click();return JSON.parse(text);
  };
  try {
    await page.clock.install();await page.goto('http://127.0.0.1:8000/');await ready();
    await page.locator('#create-character').click();await page.locator('#character-name').fill('Bank pilot');
    await page.locator('#prepare-campaign').click();await page.locator('#campaign-seed').fill('12345');await page.locator('#start-campaign').click();
    const initial=await exportGame();
    await page.locator('#walk-pause').click();await page.locator('#walk-surface').focus();
    await page.keyboard.down('ArrowDown');await page.clock.runFor(200);await page.keyboard.up('ArrowDown');
    await page.locator('#walk-airlock').click();
    const from=await state();
    assert(from.scene==='city'&&await page.locator('#bank-panel').count()===0,'Bank cannot be entered remotely from the ship airlock');
    const route=await page.evaluate(async from=>{
      const [{canStand},{createCityMaps},{createCityGeometry},{atCityBank}]=await Promise.all([
        import('/js/core/ship-walk.js'),import('/js/core/city-map.js'),import('/js/core/city-walk.js'),import('/js/core/city-doors.js')]);
      const [maps,navigation,economy,location,content]=await Promise.all(['maps','initial-navigation','initial-economy','initial-location','city-walk'].map(n=>fetch(`/data/${n}.json`).then(r=>r.json())));
      const map=createCityMaps(maps,navigation,economy)['city-01'];
      const g=createCityGeometry(map,content,{...location,position:location.shipPosition});
      const start=Number(from.y)*g.width+Number(from.x),previous=new Int32Array(g.width*g.height).fill(-1),queue=[start];
      previous[start]=start;let end;
      for(let i=0;i<queue.length;i++) {
        const k=queue[i],p={x:k%g.width,y:Math.floor(k/g.width)};
        if(atCityBank(map,p)){end=k;break}
        for(let dy=-2;dy<=2;dy++)for(let dx=-2;dx<=2;dx++) {
          if(!dx&&!dy)continue;
          const q={x:p.x+dx,y:p.y+dy},next=q.y*g.width+q.x;
          if(previous[next]===-1&&canStand(g,q)){previous[next]=k;queue.push(next)}
        }
      }
      if(end===undefined)throw Error('No reachable bank');
      const points=[];for(let k=end;k!==start;k=previous[k])points.unshift({x:k%g.width,y:Math.floor(k/g.width)});
      return points;
    },from);
    await page.locator('#walk-pause').click();
    const box=await page.locator('#stage').boundingBox();
    for(const point of route) {
      const before=await state(),cx=Math.max(0,Math.min(30,Math.floor(Number(before.x)/28)-5)),cy=Math.max(0,Math.min(18,Math.floor(Number(before.y)/32)-3));
      await page.mouse.move(box.x+(145+(point.x+3.25-cx*28)*1.25)*box.width/640,box.y+(126+(point.y-2.75-cy*32)*1.25)*box.height/480);
      await page.mouse.down();await page.clock.runFor(100);await page.mouse.up();
      const after=await state();if(Number(after.x)!==point.x||Number(after.y)!==point.y)throw Error(`Route stopped at ${after.x},${after.y}, expected ${JSON.stringify(point)}`);
    }
    assert(await page.locator('#walk-airlock').innerText()==='Enter bank','Walking to the original bank door changes the contextual action');
    const outside=await exportGame();
    await page.locator('#walk-airlock').tap();
    assert((await state()).scene==='bank'&&await page.locator('#bank-panel').isVisible(),'Touch opens the bank at a reachable source door');
    assert(await page.locator('#bank-title').innerText()==='Jondd Bank','Bank is named for the current system');
    assert(await page.locator('#bank-cash').innerText()===String(initial.state.start.credits)&&await page.locator('#bank-balance').innerText()===String(initial.state.start.systems[0].bankBalance),'Uniteller shows generated cash and the current system account');
    await page.locator('#bank-saves').focus();await page.keyboard.press('Tab');
    assert(await page.evaluate(()=>document.activeElement.id)==='bank-language','Tab remains inside the bank dialog');
    await page.keyboard.press('Shift+Tab');assert(await page.evaluate(()=>document.activeElement.id)==='bank-saves','Reverse Tab wraps within the bank dialog');
    const before=await state();await page.keyboard.press('ArrowRight');await page.clock.runFor(5000);
    assert(JSON.stringify(await state())===JSON.stringify(before),'Bank inquiry freezes movement and survival time');
    const bank=await exportGame();
    assert(bank.version===12&&bank.scope==='landed-banking-1'&&bank.state.travel.scene==='bank','Version12 export records the bank visit');
    assert(JSON.stringify(bank.state.ship)===JSON.stringify(outside.state.ship)&&JSON.stringify(bank.state.start)===JSON.stringify(initial.state.start)&&JSON.stringify(bank.state.equipment)===JSON.stringify(initial.state.equipment),'Visit preserves street position, inventory, condition, time, balances, equipment and creation');
    await saves();await page.locator('#save-checkpoint-0').click();await settled();
    await page.reload();await ready();await page.locator('#campaign-saves').click();await settled();await page.locator('#load-checkpoint-0').click();await settled();await page.locator('#checkpoint-back').click();
    assert((await state()).scene==='bank'&&await page.locator('#bank-panel').isVisible(),'Fresh-page slot reload returns to the bank');
    assert(JSON.stringify((await exportGame()).state)===JSON.stringify(bank.state),'Reload roundtrips all bank campaign state');
    for(const lang of ['en','ko']) {
      if(await page.locator('html').getAttribute('lang')!==lang)await page.locator('#bank-language').click();
      for(const [width,height] of [[640,480],[1280,720],[390,844],[844,390]]) {
        await page.setViewportSize({width,height});await page.clock.runFor(100);
        const fits=await page.locator('#bank-panel').evaluate(el=>{
          const stage=document.querySelector('#stage').getBoundingClientRect(),box=el.getBoundingClientRect();
          return box.left>=stage.left&&box.right<=stage.right&&box.top>=stage.top&&box.bottom<=stage.bottom&&el.scrollHeight<=el.clientHeight+1&&[...el.querySelectorAll('button,h2,p,dt,dd')].every(e=>e.scrollWidth<=e.clientWidth+1);
        });
        assert(fits,`${lang} bank view fits ${width}×${height}`);
      }
      await page.screenshot({path:`output/playwright/remake/bank-visit-${lang}.png`,animations:'disabled'});
    }
    await page.keyboard.press('Escape');
    let returned=await state();
    assert(returned.scene==='city'&&returned.x===before.x&&returned.y===before.y&&returned.paused==='true','Escape returns to the exact street position, paused');
    await page.locator('#walk-surface').focus();await page.keyboard.press('Enter');
    assert((await state()).scene==='bank','Keyboard Enter reopens the bank');
    await saves();
    const bad=JSON.parse(JSON.stringify(bank));bad.state.travel.cityPosition={x:287,y:217};
    const pending=page.waitForEvent('download');
    await page.evaluate(value=>{const a=document.createElement('a');a.href=URL.createObjectURL(new Blob([JSON.stringify(value)],{type:'application/json'}));a.download='invalid-bank.json';a.click();setTimeout(()=>URL.revokeObjectURL(a.href),1000)},bad);
    await (await pending).saveAs('output/playwright/remake/invalid-bank.json');
    await page.locator('#checkpoint-file').setInputFiles('output/playwright/remake/invalid-bank.json');await settled();
    await page.waitForFunction(()=>/Invalid|잘못/.test(document.querySelector('#checkpoint-message').textContent));
    await page.locator('#checkpoint-back').click();
    assert(JSON.stringify((await exportGame()).state)===JSON.stringify(bank.state),'Import with a reachable non-bank position fails without replacing the visit');
    await page.locator('#bank-leave').tap();returned=await state();
    assert(returned.scene==='city'&&returned.x===before.x&&returned.y===before.y,'Touch Leave bank returns to the same door');
    await page.locator('#walk-back').click();await page.locator('#explore').click();await page.locator('#begin-walk').click();
    assert((await state()).scene==='ship'&&(await state()).mode==='walk','Preview remains isolated from bank campaign progress');
    await page.locator('#walk-back').click();await page.locator('#home').click();await page.locator('#resume-campaign').click();
    assert((await state()).scene==='city'&&(await state()).x===before.x,'Campaign resumes at the bank door after using the preview');
    await page.goto('http://127.0.0.1:8000/tests/');await page.waitForFunction(()=>document.documentElement.dataset.result);
    const unitResults=(await page.locator('#results').innerText()).split('\n');
    assert(await page.locator('html').getAttribute('data-result')==='pass',unitResults.filter(s=>s.startsWith('FAIL')).join('\n')||'All browser rule groups pass');
    assert(errors.length===0,`No browser exceptions: ${errors.join(', ')}`);
    return {browser:browser.version(),routeSteps:route.length,door:{x:Number(before.x),y:Number(before.y)},checks,unitResults,errors};
  } catch(error) {await page.screenshot({path:'output/playwright/remake/bank-visit-failure.png',animations:'disabled'});throw Error(`${error.message}; last check: ${checks.at(-1)}`)}
  finally {await context.close()}
}
