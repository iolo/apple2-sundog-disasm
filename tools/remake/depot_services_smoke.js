// Plan routes from read-only source geometry; change the campaign only via UI.
async browserPage => {
  const browser=browserPage.context().browser(),checks=[],errors=[];
  const context=await browser.newContext({viewport:{width:1280,height:720}}),page=await context.newPage();
  page.on('pageerror',e=>errors.push(e.message));page.on('dialog',d=>d.accept());
  const assert=(ok,name)=>{if(!ok)throw Error(name);checks.push(name)};
  const ready=()=>page.waitForFunction(()=>document.documentElement.dataset.ready==='true');
  const settled=()=>page.waitForFunction(()=>document.querySelector('#checkpoint-back')?.disabled===false);
  const state=()=>page.locator('#walk-screen').evaluate(el=>({...el.dataset}));
  const saves=async()=>{await page.locator(['exchange','depot'].includes((await state()).scene)?'#service-saves':'#walk-saves').click();await settled()};
  const exported=async()=>{await saves();const pending=page.waitForEvent('download');await page.locator('#export-checkpoint').click();let text='';for await(const part of await(await pending).createReadStream())text+=part;await settled();await page.locator('#checkpoint-back').click();return JSON.parse(text)};
  const reload=async()=>{const before=await exported();await saves();await page.locator('#save-checkpoint-0').click();await settled();await page.reload();await ready();await page.locator('#campaign-saves').click();await settled();await page.locator('#load-checkpoint-0').click();await settled();await page.locator('#checkpoint-back').click();assert(JSON.stringify((await exported()).state)===JSON.stringify(before.state),'Fresh-page reload preserves pod location, cargo, accounts and RNG');return before};
  async function route(goal) {
    const from=await state();
    const points=await page.evaluate(async({from,goal})=>{
      const [{loadAssets},{canStand,interactionAt},{tryPodStep,canDockPod,podServiceAt}]=await Promise.all([import('/js/render/assets.js'),import('/js/core/ship-walk.js'),import('/js/core/city-pod.js')]);
      const a=await loadAssets(),pod=from.transport==='pod',g=pod?a.cityGeometry.pod:a.shipWalk;
      const start=Number(from.y)*g.width+Number(from.x),queue=[start],seen=new Map([[start,null]]);let end;
      for(let i=0;i<queue.length&&end===undefined;i++) {
        const k=queue[i],p={x:k%g.width,y:Math.floor(k/g.width)};
        for(let dy=-1;dy<=1;dy++)for(let dx=-1;dx<=1;dx++)if(dx||dy) {
          const next=pod?tryPodStep(g,p,dx,dy):{position:{x:p.x+dx,y:p.y+dy}};
          if(!next||(!pod&&!canStand(g,next.position)))continue;
          const n=next.position.y*g.width+next.position.x;if(seen.has(n))continue;
          seen.set(n,{from:k,dx,dy});queue.push(n);
          if(goal==='depart'?interactionAt(next.position)===3:goal==='dock'?canDockPod(g,next.position,next.heading):podServiceAt(g,next.position,next.heading)===goal){end=n;break}
        }
      }
      if(end===undefined)throw Error('No route '+goal);const result=[];
      for(let k=end;k!==start;){const n=seen.get(k);result.unshift({x:k%g.width,y:Math.floor(k/g.width),dx:n.dx,dy:n.dy});k=n.from}
      return result;
    },{from,goal});
    if((await state()).paused==='true')await page.locator('#walk-pause').click();
    const box=await page.locator('#stage').boundingBox();
    for(const p of points) {
      const before=await state();
      if(before.transport==='pod') {
        await page.locator('#walk-surface').focus();
        const keys=[...(p.dx?[p.dx>0?'ArrowRight':'ArrowLeft']:[]),...(p.dy?[p.dy>0?'ArrowDown':'ArrowUp']:[])];
        for(const key of keys)await page.keyboard.down(key);
        for(let t=0;t<10;t++){await page.clock.runFor(16);const n=await state();if(n.x!==before.x||n.y!==before.y)break}
        for(const key of keys)await page.keyboard.up(key);
      } else {
        await page.mouse.move(box.x+(32+(p.x+3.25)*640/280)*box.width/640,box.y+(46+(p.y-2.75)*2)*box.height/480);
        await page.mouse.down();await page.clock.runFor(100);await page.mouse.up();
      }
      const after=await state();if(Number(after.x)!==p.x||Number(after.y)!==p.y)throw Error(`Route ${goal}: ${after.x},${after.y}, expected ${p.x},${p.y}`);
    }
    assert(await page.locator('#walk-airlock').isEnabled(),`${goal} reached through normal movement (${points.length} steps)`);
    await page.locator('#walk-airlock').click();
  }
  async function fits(label) {
    for(const lang of ['en','ko']) {
      if(await page.locator('html').getAttribute('lang')!==lang)await page.locator('#service-language').click();
      for(const [width,height] of [[1280,720],[640,480],[390,844],[844,390]]) {
        await page.setViewportSize({width,height});await page.clock.runFor(100);
        await page.waitForFunction(()=>Math.abs(document.querySelector('#stage').getBoundingClientRect().width-Math.min(innerWidth,innerHeight*4/3))<1);
        const fit=await page.locator('#service-panel').evaluate(el=>{const r=el.getBoundingClientRect();return r.left>=0&&r.top>=0&&r.right<=innerWidth+1&&r.bottom<=innerHeight+1&&el.scrollWidth<=el.clientWidth&&el.scrollHeight<=el.clientHeight+1&&[...el.querySelectorAll('button')].every(b=>{const q=b.getBoundingClientRect();return q.top>=r.top&&q.bottom<=r.bottom&&q.left>=r.left&&q.right<=r.right&&b.scrollWidth<=b.clientWidth+1})});
        if(!fit){await page.screenshot({path:'output/playwright/remake/depot-fit-failure.png'});throw Error(JSON.stringify(await page.locator('#service-panel').evaluate(el=>({panel:el.getBoundingClientRect().toJSON(),scroll:[el.scrollWidth,el.clientWidth,el.scrollHeight,el.clientHeight],buttons:[...el.querySelectorAll('button')].map(b=>({id:b.id,rect:b.getBoundingClientRect().toJSON(),scroll:[b.scrollWidth,b.clientWidth]}))}))))}
        assert(fit,`${lang} ${label} fits ${width}x${height}`);
      }
    }
    await page.screenshot({path:`output/playwright/remake/depot-${label}-ko.png`});
    await page.setViewportSize({width:1280,height:720});await page.clock.runFor(100);
    await page.locator('#service-language').click();
  }
  try {
    await page.addInitScript(()=>localStorage.setItem('sundog.locale','en'));await page.clock.install({time:new Date('2026-10-03T00:00:00Z')});await page.clock.pauseAt(new Date('2026-10-03T00:00:01Z'));await page.goto('http://127.0.0.1:8000/');await ready();
    await page.locator('#create-character').click();await page.locator('#character-name').fill('Depot pilot');await page.locator('#prepare-campaign').click();await page.locator('#campaign-seed').fill('12345');await page.locator('#start-campaign').click();
    const initial=await exported();assert(initial.version===19&&initial.scope==='landed-failures-1','Fresh campaign exports version19 active resources');
    await route('depart');await route('depot');assert((await state()).scene==='depot','Normal pod driving reaches the depot');
    const arrived=await exported();await fits('services');
    await page.locator('#depot-repair').click();assert((await page.locator('#depot-price').innerText()).includes('145'),'Hull repair quotes the source local price');
    await page.keyboard.press('Escape');assert(JSON.stringify((await exported()).state)===JSON.stringify(arrived.state),'Cancelling a repair leaves money, hull, RNG and cargo unchanged');
    await page.locator('#depot-repair').click();await page.locator('#depot-confirm').click();const repaired=await reload();
    assert(repaired.state.resources.hull===16&&repaired.state.economy.accounts[0].balance===arrived.state.economy.accounts[0].balance-145&&repaired.state.dialogue.cash===arrived.state.dialogue.cash,'Confirmed hull repair charges the local bank and survives reload');
    assert(await page.locator('#depot-repair').isDisabled(),'Full hull disables another repair');
    await page.locator('#depot-refuel').click();await page.locator('#depot-more').click();await page.locator('#depot-less').click();await page.locator('#depot-all').click();
    await fits('review');const reviewing=await exported();assert(JSON.stringify(reviewing.state)===JSON.stringify(repaired.state),'Quantity and language review leave committed state unchanged');
    await reload();assert(await page.locator('#depot-refuel').isVisible()&&await page.locator('#depot-confirm').count()===0,'Reload discards an unpaid service review');
    await page.locator('#depot-refuel').click();await page.locator('#depot-all').click();
    await page.locator('#depot-confirm').click();const filled=await reload();
    assert(filled.state.resources.fuel===255&&filled.state.economy.accounts[0].balance===repaired.state.economy.accounts[0].balance-2512,'Full tank buys sixteen fuel units at 157 credits');
    assert(await page.locator('#depot-refuel').isDisabled(),'Full fuel disables another refill');
    await page.locator('#depot-auxiliary').click();await page.locator('#depot-all').click();await page.locator('#depot-confirm').click();const loaded=await reload();
    assert(loaded.state.pod.cargo.every(c=>c?.commodityId==='cargo-01'&&c.quality===7&&c.originWorld==='world-01'&&c.pricePaid===0)&&loaded.state.economy.accounts[0].balance===filled.state.economy.accounts[0].balance-4400,'Auxiliary purchase loads both pod slots with world-origin fuel and debits the bank');
    assert(await page.locator('#depot-auxiliary').isDisabled(),'Full pod prevents more auxiliary loading');
    await page.locator('#service-leave').click();await route('exchange');await page.locator('#exchange-cargo').click();
    await page.locator('#cargo-pod-0').click();await page.locator('#exchange-confirm').click();const stored=await reload();
    const slot=stored.state.economy.exchange.warehouse.slots.findIndex(c=>c?.commodityId==='cargo-01');
    assert(slot>=0&&stored.state.pod.cargo[0]===null,'Store moves auxiliary fuel into the warehouse');
    await page.locator('#exchange-warehouse').click();assert(await page.locator(`#exchange-row-${slot}`).isDisabled(),'Auxiliary fuel cannot be sold as an ordinary commodity');
    await page.locator('#exchange-cargo').click();await page.locator(`#cargo-warehouse-${slot}`).click();await page.locator('#exchange-confirm').click();
    await page.locator('#service-leave').click();await route('dock');const docked=await reload();
    assert(docked.state.pod.attached&&JSON.stringify(docked.state.pod.cargo)===JSON.stringify(loaded.state.pod.cargo)&&JSON.stringify(docked.state.resources)===JSON.stringify(loaded.state.resources),'Loaded return preserves auxiliary cargo and serviced ship resources');
    await page.locator('#walk-inventory').click();assert(await page.locator('#pod-manifest p').count()===2,'Ship manifest displays both auxiliary loads');await page.locator('#inventory-close').click();
    assert(JSON.stringify(docked.state.start)===JSON.stringify(initial.state.start),'Servicing preserves immutable creation data');
    assert(errors.length===0,'No uncaught depot journey errors');return {browser:browser.version(),checks,errors};
  } finally {await context.close()}
}
