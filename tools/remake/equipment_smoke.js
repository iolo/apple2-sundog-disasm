// Read-only imports derive walking routes; game changes use ordinary UI actions.
async browserPage => {
  const browser=browserPage.context().browser(),checks=[],errors=[];
  const context=await browser.newContext({viewport:{width:1280,height:720}});
  const page=await context.newPage();
  page.on('pageerror',e=>errors.push(e.message));page.on('dialog',d=>d.accept());
  const assert=(ok,name)=>{if(!ok)throw Error(name);checks.push(name)};
  const ready=()=>page.waitForFunction(()=>document.documentElement.dataset.ready==='true');
  const settled=()=>page.waitForFunction(()=>document.querySelector('#checkpoint-back')?.disabled===false);
  const state=()=>page.locator('#walk-screen').evaluate(el=>({...el.dataset}));
  const exportGame=async()=>{
    await page.locator('#walk-saves').click();await settled();
    const pending=page.waitForEvent('download');await page.locator('#export-checkpoint').click();
    const download=await pending;let text='';
    for await(const part of await download.createReadStream())text+=part;
    await settled();await page.locator('#checkpoint-back').click();return JSON.parse(text).state;
  };
  const walkTo=async bay=>{
    const from=await state();
    const route=await page.evaluate(async({from,bay})=>{
      const {canStand}=await import('/js/core/ship-walk.js');
      const {equipmentBayAt}=await import('/js/core/equipment.js');
      const geometry=await fetch('/data/ship-walk.json').then(r=>r.json());
      const start={x:Number(from.x),y:Number(from.y)},key=p=>`${p.x},${p.y}`;
      const queue=[start],previous=new Map([[key(start),null]]);let target;
      for(let i=0;i<queue.length;i++) {
        const p=queue[i];if(equipmentBayAt(p)===bay){target=p;break}
        for(const [dx,dy] of [[1,0],[-1,0],[0,1],[0,-1]]) {
          const q={x:p.x+dx,y:p.y+dy};
          if(canStand(geometry,q)&&!previous.has(key(q))){previous.set(key(q),p);queue.push(q)}
        }
      }
      if(!target)throw Error('Unreachable bay');
      const path=[];for(let p=target;p;p=previous.get(key(p)))path.unshift(p);
      return path.filter((p,i)=>i>0&&(i===path.length-1 || p.x-path[i-1].x!==path[i+1].x-p.x || p.y-path[i-1].y!==path[i+1].y-p.y));
    },{from,bay});
    if((await state()).paused==='true')await page.locator('#walk-pause').click();
    const box=await page.locator('#stage').boundingBox();
    for(const point of route) {
      const before=await state(),distance=Math.max(Math.abs(point.x-Number(before.x)),Math.abs(point.y-Number(before.y)));
      await page.mouse.move(box.x+(32+(point.x+3.25)*640/280)*box.width/640,box.y+(46+(point.y-2.75)*2)*box.height/480);
      await page.mouse.down();await page.clock.runFor(distance*60+150);await page.mouse.up();
      const after=await state();if(Number(after.x)!==point.x||Number(after.y)!==point.y)throw Error(`Route stopped at ${after.x},${after.y}, expected ${JSON.stringify(point)}`);
    }
  };
  try {
    await page.goto('http://127.0.0.1:8000/tests/');
    await page.waitForFunction(()=>document.documentElement.dataset.result,null,{timeout:120000});
    const unitResults=(await page.locator('#results').innerText()).split('\n');
    assert(await page.locator('html').getAttribute('data-result')==='pass',`All ${unitResults.length} browser groups pass`);
    await page.clock.install();await page.goto('http://127.0.0.1:8000/');await ready();
    await page.locator('#create-character').click();await page.locator('#character-name').fill('Engineer');
    await page.locator('#prepare-campaign').click();await page.locator('#campaign-seed').fill('12345');await page.locator('#start-campaign').click();
    assert(await page.locator('#walk-equipment').isDisabled(),'Engineering is unavailable away from a bay');
    const initial=await exportGame();
    const checkGroup=async index=>{
      const group=initial.equipment[index];
      assert(await page.locator('#equipment-panel').getAttribute('data-group')===group.id,`${group.id} opens at its source interaction point`);
      const rows=await page.locator('.equipment-table tbody tr').allTextContents();
      assert(group.units.every((unit,i)=>rows[i].includes(`${unit.performance} / 4`)),`${group.id} shows all four generated output values`);
      assert((await page.locator('.equipment-rating').innerText()).includes(`${group.performance} / 16`),`${group.id} shows total performance`);
      const bytes=[...group.units.map(u=>u.components),initial.ship.inventory.carried];
      const labels=await page.evaluate(()=>fetch('/locales/en.json').then(r=>r.json()));
      const actual=await page.locator('.equipment-slot').evaluateAll(els=>els.map(e=>e.getAttribute('aria-label')));
      assert(bytes.flat().every((byte,i)=>actual[i].endsWith(labels[`item${byte}`])),`${group.id} identifies every installed component and carried item`);
    };
    for(let bay=0;bay<6;bay++) {
      await walkTo(bay);assert(await page.locator('#walk-equipment').isEnabled(),`Bay ${bay+1} is reached using ship movement`);
      if(bay===0)await page.keyboard.press('Enter');else await page.locator('#walk-equipment').click();
      await checkGroup(bay);
      await page.screenshot({path:`output/playwright/remake/equipment-bay-${bay}.png`,animations:'disabled'});
      const before=await state();await page.clock.runFor(3000);
      assert((await state()).minutes===before.minutes&&(await state()).x===before.x,'Inspection pauses movement and survival time');
      await page.locator('#equipment-slot-0-0').click();
      assert((await page.locator('#equipment-detail').innerText()).includes('Socket 1'),'Selected component has visible text identification');
      await page.locator('#equipment-previous').click();
      const previous=Math.floor(bay/3)*3+(bay%3+2)%3;
      assert(await page.locator('#equipment-panel').getAttribute('data-group')===initial.start.equipment[previous].id,'Previous frame wraps within its three-system bank');
      await page.locator('#equipment-next').click();
      assert(await page.locator('#equipment-panel').getAttribute('data-group')===initial.start.equipment[bay].id,'Next frame restores the entry system');
      if(bay===0) {
        await page.locator('#equipment-close').focus();await page.keyboard.press('Shift+Tab');
        assert(await page.evaluate(()=>document.activeElement.id)==='equipment-carried-3','Reverse Tab wraps inside engineering');
        await page.keyboard.press('Tab');assert(await page.evaluate(()=>document.activeElement.id)==='equipment-close','Tab wraps to engineering Back');
      }
      if(bay===5) {
        await page.locator('#equipment-slot-3-2').click();
        for(const lang of ['en','ko']) {
          if(await page.locator('html').getAttribute('lang')!==lang)await page.locator('#equipment-language').click();
          for(const [width,height] of [[640,480],[1280,720],[1920,1080],[390,844]]) {
            await page.setViewportSize({width,height});await page.clock.runFor(100);
            const fits=await page.locator('#equipment-panel').evaluate(root=>{
              const stage=document.querySelector('#stage').getBoundingClientRect();
              return [...root.querySelectorAll('button,h2,h3,p,table')].every(el=>{const r=el.getBoundingClientRect();return r.left>=stage.left-1&&r.right<=stage.right+1&&r.top>=stage.top-1&&r.bottom<=stage.bottom+1&&el.scrollWidth<=el.clientWidth+1});
            });
            assert(fits,`${lang} engineering fits ${width}x${height}`);
            assert(await page.locator('#equipment-slot-3-2').getAttribute('aria-pressed')==='true','Selection survives locale and viewport changes');
            await page.screenshot({path:`output/playwright/remake/equipment-${lang}-${width}.png`,animations:'disabled'});
          }
        }
        await page.locator('#equipment-language').click();await page.setViewportSize({width:1280,height:720});
      }
      await page.keyboard.press('Escape');
      assert(await page.locator('#equipment-panel').count()===0&&await page.evaluate(()=>document.activeElement.id)==='walk-equipment'&&(await state()).paused==='true','Escape returns focus to Engineering and keeps the ship paused');
    }
    const after=await exportGame();
    assert(JSON.stringify(after.start)===JSON.stringify(initial.start),'Inspecting all bays leaves the entire creation record unchanged');
    assert(JSON.stringify(after.ship.inventory)===JSON.stringify(initial.ship.inventory),'Inspection never transfers or consumes components');
    await page.locator('#walk-saves').click();await settled();await page.locator('#save-checkpoint-0').click();await settled();
    await page.reload();await ready();await page.locator('#campaign-saves').click();await settled();
    await page.locator('#load-checkpoint-0').click();await settled();await page.locator('#checkpoint-back').click();
    await page.locator('#walk-equipment').click();await checkGroup(5);await page.locator('#equipment-close').click();
    assert((await state()).seed==='12345','Fresh-page load retains engineering and campaign identity');
    await page.locator('#walk-back').click();await page.locator('#explore').click();await page.locator('#begin-walk').click();
    assert(await page.locator('#walk-equipment').count()===0,'Preview does not invent campaign equipment');
    assert(errors.length===0,`No browser errors: ${errors.join(', ')}`);
    return {browser:browser.version(),passed:checks.length,checks,unitResults};
  } catch(error) {await page.screenshot({path:'output/playwright/remake/equipment-failure.png'});throw Error(`${error.message}; last check: ${checks.at(-1)}`)}
  finally {await context.close()}
}
