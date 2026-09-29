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
  const walkToBuilding=async type=>{
    const from=await state();
    const route=await page.evaluate(async ({from,type})=>{
      const [{canStand},{createCityMaps},{createCityGeometry},{cityDoorAt}]=await Promise.all([
        import('/js/core/ship-walk.js'),import('/js/core/city-map.js'),import('/js/core/city-walk.js'),import('/js/core/city-doors.js')]);
      const [maps,navigation,economy,location,content]=await Promise.all(['maps','initial-navigation','initial-economy','initial-location','city-walk'].map(n=>fetch(`/data/${n}.json`).then(r=>r.json())));
      const map=createCityMaps(maps,navigation,economy)['city-01'];
      const g=createCityGeometry(map,content,{...location,position:location.shipPosition});
      const start=Number(from.y)*g.width+Number(from.x),previous=new Int32Array(g.width*g.height).fill(-1),queue=[start];
      previous[start]=start;let end;
      for(let i=0;i<queue.length;i++) {
        const k=queue[i],p={x:k%g.width,y:Math.floor(k/g.width)};
        if(cityDoorAt(map,p)?.type===type){end=k;break}
        for(let dy=-2;dy<=2;dy++)for(let dx=-2;dx<=2;dx++) {
          if(!dx&&!dy)continue;
          const q={x:p.x+dx,y:p.y+dy},next=q.y*g.width+q.x;
          if(previous[next]===-1&&canStand(g,q)){previous[next]=k;queue.push(next)}
        }
      }
      if(end===undefined)throw Error('No reachable building');
      const points=[];for(let k=end;k!==start;k=previous[k])points.unshift({x:k%g.width,y:Math.floor(k/g.width)});
      return points;
    },{from,type});
    if((await state()).paused==='true')await page.locator('#walk-pause').click();
    const box=await page.locator('#stage').boundingBox();
    for(const point of route) {
      const before=await state(),cx=Math.max(0,Math.min(30,Math.floor(Number(before.x)/28)-5)),cy=Math.max(0,Math.min(18,Math.floor(Number(before.y)/32)-3));
      await page.mouse.move(box.x+(145+(point.x+3.25-cx*28)*1.25)*box.width/640,box.y+(126+(point.y-2.75-cy*32)*1.25)*box.height/480);
      await page.mouse.down();await page.clock.runFor(100);await page.mouse.up();
      const after=await state();if(Number(after.x)!==point.x||Number(after.y)!==point.y)throw Error(`Route stopped at ${after.x},${after.y}, expected ${JSON.stringify(point)}`);
    }
    return route.length;
  };
  const roomPointer=async(x,y,ms=1800)=>{
    if((await state()).paused==='true')await page.locator('#walk-pause').click();
    const box=await page.locator('#stage').boundingBox();
    await page.mouse.move(box.x+(145+(x+3.25)*2.5)*box.width/640,box.y+(126+(y-2.75)*2.5)*box.height/480);
    await page.mouse.down();await page.clock.runFor(ms);await page.mouse.up();
  };
  try {
    await page.clock.install();await page.goto('http://127.0.0.1:8000/');await ready();
    await page.locator('#create-character').click();await page.locator('#character-name').fill('Room pilot');
    await page.locator('#prepare-campaign').click();await page.locator('#campaign-seed').fill('12345');await page.locator('#start-campaign').click();
    const initial=await exportGame();
    await page.locator('#walk-pause').click();await page.locator('#walk-surface').focus();
    await page.keyboard.down('ArrowDown');await page.clock.runFor(200);await page.keyboard.up('ArrowDown');
    await page.locator('#walk-airlock').click();
    const routes=[];
    for(const type of [10,9]) {
      routes.push(await walkToBuilding(type));
      assert(await page.locator('#walk-airlock').innerText()==='Enter building',`Type${type} door enables entry through ordinary city walking`);
      const street=await exportGame();
      if(type===10)await page.locator('#walk-airlock').tap();
      else {await page.locator('#walk-surface').focus();await page.keyboard.press('Enter')}
      let s=await state();
      assert(s.scene==='room'&&s.x==='12'&&s.y==='56'&&s.paused==='true',`Type${type} enters at the original room anchor, paused`);
      assert(await page.locator('#walk-equipment').count()===0,`Type${type} has no remote engineering access`);
      const entered=await exportGame();
      assert(entered.version===5&&entered.scope==='landed-rooms-1'&&entered.state.travel.scene==='room',`Type${type} exports the version5 room scene`);
      assert(JSON.stringify(entered.state.travel.cityPosition)===JSON.stringify(street.state.travel.cityPosition)&&JSON.stringify(entered.state.ship)===JSON.stringify(street.state.ship),`Type${type} retains the street return anchor and all ship progress`);
      await page.locator('#walk-pause').click();await page.locator('#walk-surface').focus();
      await page.keyboard.down('ArrowRight');await page.clock.runFor(200);await page.keyboard.up('ArrowRight');
      assert(Number((await state()).x)>12&&await page.locator('#walk-airlock').isDisabled(),`Type${type} keyboard walking moves indoors and disables remote exit`);
      await roomPointer(40,50);s=await state();
      assert(s.x==='40'&&s.y==='50',`Type${type} pointer coordinates use the interior scale`);
      const time=Number(s.minutes);await page.clock.runFor(1500);
      assert(Number((await state()).minutes)>time,`Type${type} exploration advances survival time`);
      await roomPointer(type===10 ? 40 : 120,type===10 ? 85 : 50,3000);
      s=await state();
      assert(type===10 ? Number(s.y)<72 : Number(s.x)<104,`Type${type} counter blocks the complete indoor collision mask`);
      await roomPointer(40,50);
      await page.locator('#walk-inventory').click();
      assert(await page.locator('#slot-carried-0').isVisible()&&await page.locator('#slot-locker-0').count()===0&&await page.locator('#slot-stores-0').count()===0,`Type${type} inventory exposes only carried items`);
      await page.locator('#inventory-close').click();
      const saved=await exportGame();
      assert(JSON.stringify(saved.state.start)===JSON.stringify(initial.state.start)&&JSON.stringify(saved.state.equipment)===JSON.stringify(initial.state.equipment),`Type${type} exploration preserves creation, RNG and active equipment`);
      await saves();await page.locator('#save-checkpoint-0').click();await settled();
      await page.reload();await ready();await page.locator('#campaign-saves').click();await settled();await page.locator('#load-checkpoint-0').click();await settled();await page.locator('#checkpoint-back').click();
      assert((await state()).scene==='room'&&(await state()).x==='40'&&(await state()).y==='50'&&(await state()).paused==='true',`Type${type} fresh-page load restores the interior position, paused`);
      assert(JSON.stringify((await exportGame()).state)===JSON.stringify(saved.state),`Type${type} save roundtrips all room state`);
      for(const lang of ['en','ko']) {
        if(await page.locator('html').getAttribute('lang')!==lang)await page.locator('#walk-language').click();
        for(const [width,height] of [[640,480],[1280,720],[390,844],[844,390]]) {
          await page.setViewportSize({width,height});await page.clock.runFor(100);
          const fits=await page.locator('#walk-screen').evaluate(root=>{
            const stage=document.querySelector('#stage').getBoundingClientRect();
            return [...root.querySelectorAll('button,h1,#walk-status,#walk-surface')].every(el=>{
              const b=el.getBoundingClientRect();return b.left>=stage.left-1&&b.right<=stage.right+1&&b.top>=stage.top-1&&b.bottom<=stage.bottom+1&&el.scrollWidth<=el.clientWidth+1;
            });
          });
          assert(fits,`Type${type} ${lang} interior fits ${width}×${height}`);
        }
        await page.screenshot({path:`output/playwright/remake/room-${type}-${lang}.png`,animations:'disabled'});
      }
      if(await page.locator('html').getAttribute('lang')!=='en')await page.locator('#walk-language').click();
      await page.setViewportSize({width:1280,height:720});await page.clock.runFor(100);
      await page.locator('#walk-back').click();await page.locator('#explore').click();await page.locator('#begin-walk').click();
      assert((await state()).scene==='ship'&&(await state()).mode==='walk',`Type${type} preview uses its independent ship state`);
      await page.locator('#walk-back').click();await page.locator('#home').click();await page.locator('#resume-campaign').click();
      assert((await state()).scene==='room'&&(await state()).x==='40',`Type${type} resumes the room after preview`);
      await saves();
      const bad=JSON.parse(JSON.stringify(saved));bad.state.travel.roomPosition={x:40,y:10};
      const pending=page.waitForEvent('download');
      await page.evaluate(value=>{const a=document.createElement('a');a.href=URL.createObjectURL(new Blob([JSON.stringify(value)],{type:'application/json'}));a.download='invalid-room.json';a.click();setTimeout(()=>URL.revokeObjectURL(a.href),1000)},bad);
      await (await pending).saveAs('output/playwright/remake/invalid-room.json');
      await page.locator('#checkpoint-file').setInputFiles('output/playwright/remake/invalid-room.json');await settled();
      await page.waitForFunction(()=>/Invalid|잘못/.test(document.querySelector('#checkpoint-message').textContent));
      await page.locator('#checkpoint-back').click();
      assert(JSON.stringify((await exportGame()).state)===JSON.stringify(saved.state),`Type${type} wall import fails without replacing progress`);
      await roomPointer(12,56);
      assert(await page.locator('#walk-airlock').isEnabled(),`Type${type} returning to the source doorway enables exit`);
      if(type===10){await page.locator('#walk-surface').focus();await page.keyboard.press('Enter')}
      else await page.locator('#walk-airlock').tap();
      s=await state();
      assert(s.scene==='city'&&Number(s.x)===street.state.travel.cityPosition.x&&Number(s.y)===street.state.travel.cityPosition.y&&s.paused==='true',`Type${type} exit returns to the exact street anchor, paused`);
      const returned=await exportGame();
      assert(!Object.hasOwn(returned.state.travel,'roomPosition'),`Type${type} exit clears interior-only state`);
    }
    await page.goto('http://127.0.0.1:8000/tests/');await page.waitForFunction(()=>document.documentElement.dataset.result);
    const unitResults=(await page.locator('#results').innerText()).split('\n');
    assert(await page.locator('html').getAttribute('data-result')==='pass',unitResults.filter(s=>s.startsWith('FAIL')).join('\n')||'All browser rule groups pass');
    assert(errors.length===0,`No browser exceptions: ${errors.join(', ')}`);
    return {browser:browser.version(),routes,checks,unitResults,errors};
  } catch(error) {await page.screenshot({path:'output/playwright/remake/room-walk-failure.png',animations:'disabled'});throw Error(`${error.message}; last check: ${checks.at(-1)}`)}
  finally {await context.close()}
}
