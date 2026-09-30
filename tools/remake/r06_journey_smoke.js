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
  const saves=async()=>{await page.locator((await state()).scene==='bank' ? '#bank-saves' : ['transstation','depot','exchange'].includes((await state()).scene) ? '#service-saves' : '#walk-saves').click();await settled()};
  const exportGame=async()=>{
    await saves();const pending=page.waitForEvent('download');await page.locator('#export-checkpoint').click();
    let text='';for await(const part of await (await pending).createReadStream())text+=part;
    await settled();await page.locator('#checkpoint-back').click();return JSON.parse(text);
  };
  const walkToBuilding=async (scene,type)=>{
    const from=await state();
    const route=await page.evaluate(async ({from,scene,type})=>{
      const [{canStand},{createCityMaps},{createCityGeometry,canBoardShip},{cityDoorAt}]=await Promise.all([
        import('/js/core/ship-walk.js'),import('/js/core/city-map.js'),import('/js/core/city-walk.js'),import('/js/core/city-doors.js')]);
      const [maps,navigation,economy,location,content]=await Promise.all(['maps','initial-navigation','initial-economy','initial-location','city-walk'].map(n=>fetch(`/data/${n}.json`).then(r=>r.json())));
      const map=createCityMaps(maps,navigation,economy)['city-01'];
      const g=createCityGeometry(map,content,{...location,position:location.shipPosition});
      const start=Number(from.y)*g.width+Number(from.x),previous=new Int32Array(g.width*g.height).fill(-1),queue=[start];
      previous[start]=start;let end;
      for(let i=0;i<queue.length;i++) {
        const k=queue[i],p={x:k%g.width,y:Math.floor(k/g.width)};
        if(scene===3 ? canBoardShip(g,p) : cityDoorAt(map,p)?.scene===scene&&cityDoorAt(map,p)?.type===type){end=k;break}
        for(let dy=-2;dy<=2;dy++)for(let dx=-2;dx<=2;dx++) {
          if(!dx&&!dy)continue;
          const q={x:p.x+dx,y:p.y+dy},next=q.y*g.width+q.x;
          if(previous[next]===-1&&canStand(g,q)){previous[next]=k;queue.push(next)}
        }
      }
      if(end===undefined)throw Error('No reachable building');
      const points=[];for(let k=end;k!==start;k=previous[k])points.unshift({x:k%g.width,y:Math.floor(k/g.width)});
      return points;
    },{from,scene,type});
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
    await page.locator('#create-character').click();await page.locator('#character-name').fill('R06 pilot');
    await page.locator('#prepare-campaign').click();await page.locator('#campaign-seed').fill('12345');await page.locator('#start-campaign').click();
    const initial=await exportGame();
    await page.locator('#walk-pause').click();await page.locator('#walk-surface').focus();
    await page.keyboard.down('ArrowDown');await page.clock.runFor(200);await page.keyboard.up('ArrowDown');
    await page.locator('#walk-airlock').click();
    assert((await state()).scene==='city','A fresh campaign exits through the airlock');
    const routes=[];
    for(const [scene,type,visit] of [[5,8,'tavern'],[6,2,'bank'],[5,9,'equipment shop'],[6,3,'depot'],[5,10,'item shop'],[6,5,'exchange'],[5,11,'lodging'],[6,1,'transstation']]) {
      routes.push({visit,steps:await walkToBuilding(scene,type)});
      const street=await exportGame();await page.locator('#walk-airlock').click();
      let s=await state();
      assert(s.scene===(scene===5?'room':visit),`${visit} enters from its actual street door`);
      const entered=await exportGame();
      assert(JSON.stringify(entered.state.ship)===JSON.stringify(street.state.ship)&&JSON.stringify(entered.state.travel.cityPosition)===JSON.stringify(street.state.travel.cityPosition),`${visit} entry retains ship state and the exact return anchor`);
      if(scene===5) {
        assert(Number(s.occupants)>=1&&entered.state.encounters.roomSeed===street.state.encounters.randomState,`${visit} populates using the continuing campaign RNG`);
        await page.locator('#walk-pause').click();await page.locator('#walk-surface').focus();
        await page.keyboard.down('ArrowRight');await page.clock.runFor(100);await page.keyboard.up('ArrowRight');
        assert(Number((await state()).x)>Number(s.x),`${visit} supports walking after entry`);
        const box=await page.locator('#stage').boundingBox();
        await page.mouse.move(box.x+(145+(Number(s.x)+3.25)*2.5)*box.width/640,box.y+(126+(Number(s.y)-2.75)*2.5)*box.height/480);
        await page.mouse.down();await page.clock.runFor(500);await page.mouse.up();
        assert((await state()).x===s.x&&(await state()).y===s.y,`${visit} doorway remains reachable`);
      }
      const snapshot=await exportGame();
      await saves();await page.locator('#save-checkpoint-0').click();await settled();
      await page.reload();await ready();await page.locator('#campaign-saves').click();await settled();
      await page.locator('#load-checkpoint-0').click();await settled();await page.locator('#checkpoint-back').click();
      assert(JSON.stringify((await exportGame()).state)===JSON.stringify(snapshot.state),`${visit} resumes exactly after fresh-page IndexedDB reload`);
      const language=scene===5?'#walk-language':visit==='bank'?'#bank-language':'#service-language';
      await page.locator(language).click();
      assert(await page.locator('html').getAttribute('lang')==='ko',`${visit} switches to Korean in place`);
      assert(JSON.stringify((await exportGame()).state)===JSON.stringify(snapshot.state),`${visit} language switch preserves all state`);
      await page.locator(language).click();
      if(scene===5)await page.locator('#walk-airlock').click();else await page.keyboard.press('Escape');
      const returned=await exportGame();
      assert(returned.state.travel.scene==='city'&&JSON.stringify(returned.state.travel.cityPosition)===JSON.stringify(street.state.travel.cityPosition),`${visit} returns to its street anchor`);
      assert(JSON.stringify(returned.state.ship)===JSON.stringify(snapshot.state.ship)&&JSON.stringify(returned.state.equipment)===JSON.stringify(initial.state.equipment)&&JSON.stringify(returned.state.start)===JSON.stringify(initial.state.start),`${visit} return preserves active resources, equipment and creation`);
      assert(returned.state.encounters.roomState===null&&returned.state.encounters.counter===null&&returned.state.encounters.randomState===snapshot.state.encounters.randomState,`${visit} exit clears room-only state while preserving RNG`);
      await page.locator('#walk-airlock').click();
      assert((await state()).scene===(scene===5?'room':visit),`${visit} supports immediate reentry`);
      if(scene===5)await page.locator('#walk-airlock').click();else await page.keyboard.press('Escape');
    }
    routes.push({visit:'ship',steps:await walkToBuilding(3,1)});
    const outside=await exportGame();await page.locator('#walk-airlock').click();
    const aboard=await exportGame();
    assert(aboard.state.travel.scene==='ship'&&aboard.state.travel.cityPosition===null,'The complete route returns aboard the ship');
    assert(JSON.stringify(aboard.state.ship)===JSON.stringify(outside.state.ship)&&JSON.stringify(aboard.state.encounters)===JSON.stringify(outside.state.encounters)&&JSON.stringify(aboard.state.dialogue)===JSON.stringify(outside.state.dialogue),'Boarding preserves inventory, condition, time, RNG and dialogue');
    assert(JSON.stringify(aboard.state.start)===JSON.stringify(initial.state.start)&&JSON.stringify(aboard.state.equipment)===JSON.stringify(initial.state.equipment),'All eight building classes preserve creation and equipment across the full route');
    await saves();await page.locator('#save-checkpoint-0').click();await settled();
    await page.reload();await ready();await page.locator('#campaign-saves').click();await settled();await page.locator('#load-checkpoint-0').click();await settled();await page.locator('#checkpoint-back').click();
    assert(JSON.stringify((await exportGame()).state)===JSON.stringify(aboard.state),'The final ship checkpoint resumes exactly');
    await page.screenshot({path:'output/playwright/remake/r06-return-aboard.png',animations:'disabled'});
    assert(errors.length===0,'No browser exceptions or failed requests');
    return {browser:browser.version(),checks,routes,errors};
  } finally {await context.close()}
}
