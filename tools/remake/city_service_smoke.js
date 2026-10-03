// Read-only source geometry finds a route; all live changes use normal UI.
async browserPage => {
  const browser=browserPage.context().browser(),checks=[],errors=[];
  const context=await browser.newContext({viewport:{width:1280,height:720},hasTouch:true});
  const page=await context.newPage();
  page.on('pageerror',e=>errors.push(e.message));page.on('requestfailed',r=>errors.push(r.url()));page.on('dialog',d=>d.accept());
  const assert=(ok,name)=>{if(!ok)throw Error(name);checks.push(name)};
  const ready=()=>page.waitForFunction(()=>document.documentElement.dataset.ready==='true');
  const settled=()=>page.waitForFunction(()=>document.querySelector('#checkpoint-back')?.disabled===false);
  const state=()=>page.locator('#walk-screen').evaluate(el=>({...el.dataset}));
  const saves=async()=>{await page.locator(['transstation','depot','exchange'].includes((await state()).scene) ? '#service-saves' : '#walk-saves').click();await settled()};
  const exportGame=async()=>{
    await saves();const pending=page.waitForEvent('download');await page.locator('#export-checkpoint').click();
    let text='';for await(const part of await (await pending).createReadStream())text+=part;
    await settled();await page.locator('#checkpoint-back').click();return JSON.parse(text);
  };
  const importGame=async value=>{
    await saves();const pending=page.waitForEvent('download');
    await page.evaluate(value=>{const a=document.createElement('a');a.href=URL.createObjectURL(new Blob([JSON.stringify(value)],{type:'application/json'}));a.download='room-fixture.json';a.click();setTimeout(()=>URL.revokeObjectURL(a.href),1000)},value);
    await (await pending).saveAs('output/playwright/remake/room-fixture.json');
    await page.locator('#checkpoint-file').setInputFiles('output/playwright/remake/room-fixture.json');await settled();
    const message=await page.locator('#checkpoint-message').innerText();await page.locator('#checkpoint-back').click();return message;
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
        if(cityDoorAt(map,p)?.scene===6&&cityDoorAt(map,p)?.type===type){end=k;break}
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
  try {
    await page.clock.install({time:new Date('2026-09-30T00:00:00Z')});await page.clock.pauseAt(new Date('2026-09-30T00:00:01Z'));
    await page.goto('http://127.0.0.1:8000/');await ready();
    await page.locator('#create-character').click();await page.locator('#character-name').fill('Service pilot');
    await page.locator('#prepare-campaign').click();await page.locator('#campaign-seed').fill('12345');await page.locator('#start-campaign').click();
    const initial=await exportGame();
    await page.locator('#walk-pause').click();await page.locator('#walk-surface').focus();
    await page.keyboard.down('ArrowDown');await page.clock.runFor(200);await page.keyboard.up('ArrowDown');
    await page.locator('#walk-airlock').click();
    for(const [type,scene,title] of [[1,'transstation','TransStation'],[3,'depot','Drahew Depot'],[5,'exchange','Drahew Exchange']]) {
      await walkToBuilding(type);
      assert(await page.locator('#walk-airlock').innerText()==='Enter service',`${scene} source door offers entry after ordinary walking`);
      const street=await exportGame();
      await page.locator('#walk-surface').focus();await page.keyboard.press('Enter');
      assert((await state()).scene===scene&&await page.locator('#service-title').innerText()===title,`${scene} opens the source-named service screen`);
      assert(await page.locator('#service-panel').isVisible()&&await page.locator('#walk-surface').evaluate(e=>e.inert||e.closest('[inert]')!==null),`${scene} makes the street inert`);
      await page.locator('#service-saves').focus();await page.keyboard.press('Tab');
      assert(await page.evaluate(()=>document.activeElement.id)==='service-language',`${scene} traps forward focus`);
      await page.keyboard.press('Shift+Tab');
      assert(await page.evaluate(()=>document.activeElement.id)==='service-saves',`${scene} traps reverse focus`);
      const entered=await exportGame();
      assert(entered.version===18&&entered.scope==='landed-depot-1',`${scene} exports a version18 service visit`);
      const expected=structuredClone(street.state);expected.travel.scene=scene;
      if(scene==='exchange'){expected.economy=entered.state.economy;expected.encounters=entered.state.encounters;assert(entered.state.encounters.randomState!==street.state.encounters.randomState&&entered.state.economy.exchange.visit.offers.length===8,'Exchange entry generates live offers and advances RNG')}
      const exited=structuredClone(expected);exited.travel.scene='city';if(scene==='exchange')exited.economy.exchange.visit=null;
      assert(JSON.stringify(entered.state)===JSON.stringify(expected),`${scene} entry changes only the active scene`);
      const before=await state();await page.keyboard.press('ArrowRight');await page.clock.runFor(6000);
      assert(JSON.stringify(await state())===JSON.stringify(before),`${scene} pauses movement and time`);
      await saves();await page.locator('#save-checkpoint-0').click();await settled();
      await page.reload();await ready();await page.locator('#campaign-saves').click();await settled();
      await page.locator('#load-checkpoint-0').click();await settled();await page.locator('#checkpoint-back').click();
      assert(JSON.stringify((await exportGame()).state)===JSON.stringify(entered.state),`${scene} fresh-page IndexedDB load preserves complete state`);
      for(const lang of ['en','ko']) {
        if(await page.locator('html').getAttribute('lang')!==lang)await page.locator('#service-language').click();
        for(const [width,height] of [[640,480],[1280,720],[1920,1080],[390,844],[844,390]]) {
          await page.setViewportSize({width,height});await page.clock.runFor(100);
          await page.waitForFunction(()=>Math.abs(document.querySelector('#stage').getBoundingClientRect().width-Math.min(innerWidth,innerHeight*4/3))<1);
          const fits=await page.locator('#service-panel').evaluate(el=>{
            const stage=document.querySelector('#stage').getBoundingClientRect(),box=el.getBoundingClientRect();
            return box.left>=stage.left&&box.right<=stage.right&&box.top>=stage.top&&box.bottom<=stage.bottom&&el.scrollHeight<=el.clientHeight+1&&[...el.querySelectorAll('button,h2,p')].every(e=>e.scrollWidth<=e.clientWidth+1);
          });
          assert(fits,`${scene} ${lang} fits ${width}x${height}`);
        }
        await page.screenshot({path:`output/playwright/remake/service-${scene}-${lang}.png`,animations:'disabled'});
      }
      if(await page.locator('html').getAttribute('lang')!=='en')await page.locator('#service-language').click();
      await page.setViewportSize({width:1280,height:720});await page.clock.runFor(100);
      await page.waitForFunction(()=>Math.abs(document.querySelector('#stage').getBoundingClientRect().width-Math.min(innerWidth,innerHeight*4/3))<1);
      assert(JSON.stringify((await exportGame()).state)===JSON.stringify(entered.state),`${scene} presentation changes preserve state`);
      const legacy=structuredClone(entered);legacy.version=10;delete legacy.state.resources;delete legacy.state.pod;delete legacy.state.economy;legacy.scope='landed-taverns-1';
      assert((await importGame(legacy)).includes('Invalid'),`${scene} rejects service visits disguised as version10`);
      const wrong=structuredClone(entered);wrong.state.travel.scene=scene==='exchange'?'depot':'exchange';
      assert((await importGame(wrong)).includes('Invalid'),`${scene} rejects a different service at the same street anchor`);
      assert(JSON.stringify((await exportGame()).state)===JSON.stringify(entered.state),`${scene} rejected imports preserve the visit`);
      await page.keyboard.press('Escape');
      assert(JSON.stringify((await exportGame()).state)===JSON.stringify(exited),`${scene} Escape returns to the street with committed progress`);
      await page.locator('#walk-airlock').tap();await page.locator('#service-leave').tap();
      const reentered=(await exportGame()).state;if(scene==='exchange')exited.encounters=reentered.encounters;
      assert(JSON.stringify(reentered)===JSON.stringify(exited),`${scene} touch reentry preserves committed progress`);
    }
    const end=await exportGame();
    assert(JSON.stringify(end.state.start)===JSON.stringify(initial.state.start)&&JSON.stringify(end.state.equipment)===JSON.stringify(initial.state.equipment)&&JSON.stringify(end.state.dialogue)===JSON.stringify(initial.state.dialogue),'The complete three-service route preserves creation, equipment and cash/dialogue');
    assert(errors.length===0,'No browser exceptions or failed requests');
    return {browser:browser.version(),checks,errors};
  } finally {await context.close()}
}
