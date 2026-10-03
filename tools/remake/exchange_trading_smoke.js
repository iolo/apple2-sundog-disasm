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
    await page.clock.install({time:new Date('2026-10-01T00:00:00Z')});await page.clock.pauseAt(new Date('2026-10-01T00:00:01Z'));
    await page.goto('http://127.0.0.1:8000/');await ready();
    await page.locator('#create-character').click();await page.locator('#character-name').fill('Warehouse pilot');
    await page.locator('#prepare-campaign').click();await page.locator('#campaign-seed').fill('12345');await page.locator('#start-campaign').click();
    const initial=await exportGame();
    await page.locator('#walk-pause').click();await page.locator('#walk-surface').focus();
    await page.keyboard.down('ArrowDown');await page.clock.runFor(200);await page.keyboard.up('ArrowDown');await page.locator('#walk-airlock').click();
    await walkToBuilding(5);const street=await exportGame();await page.locator('#walk-airlock').click();
    const entered=await exportGame(),ex=s=>s.state.economy.exchange;
    assert(entered.version===19&&entered.scope==='landed-failures-1','Exchange exports version19');
    assert(ex(entered).visit.offers.length===8&&ex(entered).market.lastUpdateDay===0,'Ordinary entry creates and persists eight offer rows');
    assert(entered.state.encounters.randomState!==street.state.encounters.randomState,'Entry advances continuing gameplay RNG');
    const cheapest=s=>ex(s).visit.offers.map((o,i)=>({o,i})).filter(r=>r.o).sort((a,b)=>a.o.price-b.o.price)[0].i;
    const slot=cheapest(entered),offer=ex(entered).visit.offers[slot];
    await page.locator(`#exchange-row-${slot}`).click();assert(await page.locator('#exchange-confirm').isEnabled(),'Affordable lot opens purchase review');
    assert(JSON.stringify((await exportGame()).state)===JSON.stringify(entered.state),'Review and opening saves do not spend money or RNG');
    await page.keyboard.press('Escape');assert(await page.locator('#exchange-offers').isVisible(),'Escape cancels the pending purchase');
    await page.locator(`#exchange-row-${slot}`).click();await page.locator('#exchange-confirm').click();const bought=await exportGame();
    assert(bought.state.dialogue.cash===entered.state.dialogue.cash&&bought.state.economy.accounts[0].balance===entered.state.economy.accounts[0].balance-offer.price,'Purchase spends local bank before cash');
    assert(ex(bought).warehouse.slots[0].commodityId===offer.commodityId&&ex(bought).warehouse.slots[0].pricePaid===offer.price,'Purchased cargo occupies a warehouse slot with its paid price');
    await page.locator('#exchange-warehouse').click();assert((await page.locator('#exchange-row-0').innerText()).includes(String.fromCharCode(72-offer.quality)),'Warehouse shows owned cargo and quality');
    await page.locator('#exchange-row-0').click();await page.locator('#exchange-cancel').click();assert(JSON.stringify((await exportGame()).state)===JSON.stringify(bought.state),'Cancelling a sale preserves cargo, funds and RNG');
    await saves();await page.locator('#save-checkpoint-0').click();await settled();await page.locator('#checkpoint-back').click();
    await page.locator('#exchange-row-0').click();
    await page.reload();await ready();await page.locator('#campaign-saves').click();await settled();await page.locator('#load-checkpoint-0').click();await settled();await page.locator('#checkpoint-back').click();
    assert(JSON.stringify((await exportGame()).state)===JSON.stringify(bought.state),'Fresh-page load preserves offers, market, cargo, money and RNG exactly');
    assert(await page.locator('#exchange-confirm').count()===0,'Fresh load discards pending confirmations');
    for(const lang of ['en','ko']) {
      if(await page.locator('html').getAttribute('lang')!==lang)await page.locator('#service-language').click();
      for(const mode of ['offers','warehouse','review']) {
        await page.locator(mode==='offers'?'#exchange-offers':'#exchange-warehouse').click();
        if(mode==='review')await page.locator('#exchange-row-0').click();
        for(const [width,height] of [[640,480],[1280,720],[1920,1080],[390,844],[844,390]]) {
          await page.setViewportSize({width,height});await page.clock.runFor(100);await page.evaluate(()=>document.fonts.ready);await page.clock.runFor(100);
          const fit=await page.locator('#service-panel').evaluate(el=>{const b=el.getBoundingClientRect(),s=document.querySelector('#stage').getBoundingClientRect();return b.left>=s.left-1&&b.right<=s.right+1&&b.top>=s.top-1&&b.bottom<=s.bottom+1&&el.scrollHeight<=el.clientHeight+1&&[...el.querySelectorAll('button,p,h2')].every(x=>x.scrollWidth<=x.clientWidth+1)});
          assert(fit,`${lang} ${mode} fits ${width}x${height}`);
        }
        await page.screenshot({path:`output/playwright/remake/exchange-${mode}-${lang}.png`,animations:'disabled'});
        if(mode==='review')await page.locator('#exchange-cancel').click();
      }
    }
    if(await page.locator('html').getAttribute('lang')!=='en')await page.locator('#service-language').click();
    await page.setViewportSize({width:1280,height:720});await page.clock.runFor(100);
    await page.locator('#exchange-offers').click();
    let current=await exportGame();
    while(ex(current).warehouse.slots.includes(null)) {
      const i=cheapest(current);await page.locator(`#exchange-row-${i}`).click();assert(await page.locator('#exchange-confirm').isEnabled(),'Next inexpensive lot is affordable');await page.locator('#exchange-confirm').click();current=await exportGame();
    }
    await page.locator(`#exchange-row-${cheapest(current)}`).click();assert(await page.locator('#exchange-confirm').isDisabled(),'Full warehouse prevents a fifth purchase');assert((await page.locator('#exchange-message').innerText()).includes('full'),'Capacity failure explains why confirmation is unavailable');await page.locator('#exchange-cancel').click();
    assert(JSON.stringify((await exportGame()).state)===JSON.stringify(current.state),'Full-capacity attempt changes nothing');
    await page.locator('#exchange-warehouse').click();await page.locator('#exchange-row-0').click();
    const sale=Number((await page.locator('#exchange-price').innerText()).match(/\d+/)[0]);await page.locator('#exchange-confirm').click();const sold=await exportGame();
    assert(ex(sold).warehouse.slots[0]===null&&sold.state.economy.accounts[0].balance===current.state.economy.accounts[0].balance+sale,'Confirmed sale removes cargo and deposits exact proceeds');
    assert(sold.state.dialogue.cash===current.state.dialogue.cash&&sale<=ex(current).warehouse.slots[0].pricePaid,'Sale preserves cash and respects the local purchase-price ceiling');
    await page.locator('#service-saves').focus();await page.keyboard.press('Tab');assert(await page.evaluate(()=>document.activeElement.id)==='service-language','Focus wraps around the exchange controls');
    await page.keyboard.press('Shift+Tab');assert(await page.evaluate(()=>document.activeElement.id)==='service-saves','Reverse focus wraps and skips disabled empty slots');
    await page.keyboard.press('Escape');const left=await exportGame();assert(ex(left).visit===null&&JSON.stringify(left.state.travel.cityPosition)===JSON.stringify(street.state.travel.cityPosition),'Leaving clears only the visit board and returns to the street anchor');
    await page.locator('#walk-airlock').click();const again=await exportGame();assert(JSON.stringify(ex(again).warehouse)===JSON.stringify(ex(left).warehouse)&&JSON.stringify(ex(again).market)===JSON.stringify(ex(left).market),'Same-day reentry retains stock changes and owned cargo');
    assert(again.state.encounters.randomState!==left.state.encounters.randomState,'Reentry creates a new board from continuing RNG');
    assert(JSON.stringify(again.state.start)===JSON.stringify(initial.state.start),'Trading leaves immutable creation data untouched');
    const forged=structuredClone(again),forgedRow=ex(forged).visit.offers.find(Boolean);forgedRow.price++;
    assert((await importGame(forged)).includes('Invalid'),'Import rejects a forged asking price');
    assert(JSON.stringify((await exportGame()).state)===JSON.stringify(again.state),'Rejected import preserves all live progress');
    const previous=structuredClone(again);previous.version=13;delete previous.state.engineering;delete previous.state.resources;delete previous.state.pod;delete previous.state.economy.personalTrade;previous.scope='landed-exchange-1';
    assert((await importGame(previous)).includes('imported'),'Version13 traded exchange progress imports');
    assert(JSON.stringify((await exportGame()).state)===JSON.stringify(again.state),'Version13 migration preserves cargo, money, market, offers and RNG');
    const legacy=structuredClone(entered);legacy.version=12;delete legacy.state.engineering;delete legacy.state.resources;delete legacy.state.pod;delete legacy.state.economy.personalTrade;legacy.scope='landed-banking-1';delete legacy.state.economy.exchange;
    assert((await importGame(legacy)).includes('imported'),'Version12 exchange preview imports through normal UI');
    const migrated=await exportGame();
    assert(ex(migrated).visit.offers.length===8&&migrated.state.encounters.randomState!==legacy.state.encounters.randomState,'Legacy exchange gets its first board exactly at resume');
    assert(JSON.stringify(migrated.state.economy.accounts)===JSON.stringify(legacy.state.economy.accounts)&&migrated.state.dialogue.cash===legacy.state.dialogue.cash,'Legacy entry does not change existing funds');
    assert(errors.length===0,'No browser exceptions or failed requests');return {browser:browser.version(),checks,errors};
  } finally {await context.close()}
}
