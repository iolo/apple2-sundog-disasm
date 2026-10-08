// Combined R08 acceptance: fresh character, real engineering/service payments,
// loaded ground round trip, independent parking and reload. No campaign fixture.
// Route planning only reads geometry; all state changes use normal controls.
async browserPage => {
  const browser=browserPage.context().browser(),checks=[],errors=[];
  const context=await browser.newContext({viewport:{width:1280,height:720}}),page=await context.newPage();
  page.on('pageerror',e=>errors.push(e.stack||e.message));page.on('dialog',d=>d.accept());
  const assert=(ok,name)=>{if(!ok)throw Error(name);checks.push(name)};
  const ready=()=>page.waitForFunction(()=>document.documentElement.dataset.ready==='true');
  const settled=()=>page.waitForFunction(()=>document.querySelector('#checkpoint-back')?.disabled===false);
  const state=()=>page.locator('#walk-screen').evaluate(el=>({...el.dataset}));
  const saves=async()=>{await page.locator(await page.locator('#navigation-panel').count()?'#nav-saves':await page.locator('#power-panel').count()?'#power-saves':await page.locator('#equipment-panel').count()?'#equipment-saves':['exchange','depot'].includes((await state()).scene)?'#service-saves':'#walk-saves').click();await settled()};
  const exported=async()=>{await saves();const pending=page.waitForEvent('download');await page.locator('#export-checkpoint').click();let text='';for await(const part of await(await pending).createReadStream())text+=part;await settled();await page.locator('#checkpoint-back').click();return JSON.parse(text)};
  const reload=async()=>{const before=await exported();await saves();await page.locator('#save-checkpoint-0').click();await settled();await page.reload();await ready();await page.locator('#campaign-saves').click();await settled();await page.locator('#load-checkpoint-0').click();await settled();await page.locator('#checkpoint-back').click();assert(JSON.stringify((await exported()).state)===JSON.stringify(before.state),'Fresh-page reload preserves pod location, cargo, accounts and RNG');return before};
  async function route(goal) {
    const from=await state(),saved=(await exported()).state;
    const points=await page.evaluate(async({from,goal,saved})=>{
      const [{loadAssets},{canStand,interactionAt},{tryPodStep,canDockPod,podExchangeAt,podServiceAt}]=await Promise.all([import('/js/render/assets.js'),import('/js/core/ship-walk.js'),import('/js/core/city-pod.js')]);
      const [{campaignFootGeometry},{canBoardParkedPod},{canBoardShip},{cityServiceAt},{detachedShipGeometry}]=await Promise.all([import('/js/core/campaign-pod.js'),import('/js/core/parked-pod.js'),import('/js/core/city-walk.js'),import('/js/core/city-doors.js'),import('/js/core/ship-walk.js')]);
      const {trySurfaceStep,surfaceCityAt}=await import('/js/core/surface-walk.js');const {nearbySurfacePod}=await import('/js/core/campaign-ground.js');const a=await loadAssets(),{createGroundWorld}=await import('/js/core/campaign-ground.js'),world=createGroundWorld({...a.campaignContent,...a.campaignContent.ground},(await import('/js/core/regional-world.js')).regionalGroundStart(saved)),pod=from.transport==='pod',city=from.scene==='city',surface=from.scene==='surface',g=surface?world.surface(saved.ground.colonyPosition):city?(pod?world.city(saved.ground.cityId,false).pod:world.foot(saved)):(saved.pod.attached?a.shipWalk:detachedShipGeometry(a.shipWalk));
      let routeBounds=null;if(city&&goal!=='surface'){const size=world.size(saved.ground.cityId),half=Math.floor((size+1)/2);routeBounds={left:(12-size)*28+46,right:(17+size)*28+227,top:(7-half)*32+59,bottom:(11+half)*32+138}} // Stay inside source camera exit thresholds while routing to a city destination.
      const reached=(p,h)=>goal==='surface'?p.x<125:goal.startsWith('city-')?surfaceCityAt(g.map,p)?.cityId===goal:goal==='street'?p.x===360&&p.y===215:goal==='pod'?(surface?nearbySurfacePod(p,saved.pod.position):canBoardParkedPod(g,p,saved.pod.position)):goal==='footExchange'?cityServiceAt(world.city(saved.ground.cityId,saved.pod.attached).map,p)==='exchange':goal==='ship'?canBoardShip(g,p):goal==='airlock'?interactionAt(p)===4:goal==='navigation'?interactionAt(p)===1:goal==='engineering'?interactionAt(p)===8:goal==='depot'?podServiceAt(g,p,h)==='depot':goal==='depart'?interactionAt(p)===3:goal==='dock'?canDockPod(g,p,h):podExchangeAt(g,p,h);
      const start=Number(from.y)*g.width+Number(from.x),queue=[start],seen=new Map([[start,null]]);let end=reached({x:Number(from.x),y:Number(from.y)},Number(from.heading))?start:undefined;
      for(let i=0;i<queue.length&&end===undefined;i++) {
        const k=queue[i],p={x:k%g.width,y:Math.floor(k/g.width)};
        for(let dy=-1;dy<=1;dy++)for(let dx=-1;dx<=1;dx++)if(dx||dy) {
          const next=surface?{position:trySurfaceStep(g,p,dx,dy),heading:26}:pod?tryPodStep(g,p,dx,dy):{position:{x:p.x+dx,y:p.y+dy}};
          if(!next||(!pod&&!surface&&!canStand(g,next.position)))continue;
          if(routeBounds&&(next.position.x<routeBounds.left||next.position.x>routeBounds.right||next.position.y<routeBounds.top||next.position.y>routeBounds.bottom))continue;
          const n=next.position.y*g.width+next.position.x;if(seen.has(n))continue;
          seen.set(n,{from:k,dx,dy});queue.push(n);
          if(reached(next.position,next.heading)){end=n;break}
        }
      }
      if(end===undefined)throw Error('No route '+goal);const result=[];
      for(let k=end;k!==start;){const n=seen.get(k);result.unshift({x:k%g.width,y:Math.floor(k/g.width),dx:n.dx,dy:n.dy});k=n.from}
      return result;
    },{from,goal,saved});
    if((await state()).paused==='true')await page.locator('#walk-pause').click();
    const box=await page.locator('#stage').boundingBox();
    for(const p of points) {
      const before=await state();
      if(before.transport==='pod'||before.scene==='surface') {
        await page.locator('#walk-surface').focus();
        const keys=[...(p.dx?[p.dx>0?'ArrowRight':'ArrowLeft']:[]),...(p.dy?[p.dy>0?'ArrowDown':'ArrowUp']:[])];
        for(const key of keys)await page.keyboard.down(key);
        for(let t=0;t<10;t++){await page.clock.runFor(16);const n=await state();if(n.x!==before.x||n.y!==before.y)break}
        for(const key of keys)await page.keyboard.up(key);await page.clock.runFor(50); // Let the source host observe the released movement button.
      } else {
        if(before.scene==='city') {
          const cx=Number(before.cameraX),cy=Number(before.cameraY);
          await page.mouse.move(box.x+(145+(p.x+3.5-cx*28)*1.25)*box.width/640,box.y+(126+(p.y-2.5-cy*32)*1.25)*box.height/480);
        }else await page.mouse.move(box.x+(32+(p.x+3.25)*640/280)*box.width/640,box.y+(46+(p.y-2.75)*2)*box.height/480);
        await page.mouse.down();
        if(before.scene==='city') {
          // Release after one source step: scrolling changes the map under a
          // stationary held pointer and can otherwise cause another step.
          for(let t=0;t<10;t++){await page.clock.runFor(16);const n=await state();if(n.x!==before.x||n.y!==before.y)break}
        } else await page.clock.runFor(100);
        await page.mouse.up();
      }
      const after=await state();if(goal==='surface'&&after.scene==='surface'){assert(true,'City boundary enters the surface through normal movement');return}if(Number(after.x)!==p.x||Number(after.y)!==p.y)throw Error(`Route ${goal}: ${after.x},${after.y}, expected ${JSON.stringify(p)}; before ${JSON.stringify(before)}`);
    }
    assert(true,`${goal} reached through normal movement (${points.length} steps)`);
    if(goal==='street'){await page.locator('#walk-pause').click();return}
    const button=goal==='navigation'?'#walk-navigation':goal==='engineering'?'#walk-equipment':goal==='pod'?'#walk-pod':'#walk-airlock';assert(await page.locator(button).isEnabled(),`${goal} action is available at the reached location`);await page.locator(button).click();
  }
  async function buy() {
    await page.locator('#exchange-offers').click();const s=(await exported()).state;
    const offer=s.economy.exchange.visit.offers.map((o,i)=>({o,i})).filter(v=>v.o&&v.o.price<s.dialogue.cash+s.economy.accounts[0].balance).sort((a,b)=>a.o.price-b.o.price)[0];
    if(!offer)throw Error('No affordable cargo');await page.locator(`#exchange-row-${offer.i}`).click();await page.locator('#exchange-confirm').click();
  }
  try {
    await page.addInitScript(()=>localStorage.setItem('sundog.locale','en'));await page.clock.install({time:new Date('2026-10-07T00:00:00Z')});await page.clock.pauseAt(new Date('2026-10-07T00:00:01Z'));await page.goto('http://127.0.0.1:8000/');await ready();
    await page.locator('#create-character').click();await page.locator('#character-name').fill('R09 pilot');await page.locator('#prepare-campaign').click();await page.locator('#campaign-seed').fill('12345');await page.locator('#start-campaign').click();
    const initial=await exported();assert(initial.version===29&&initial.scope==='ship-salvage-1','Live campaign retains regional flight in format29');
    await route('depart');await route('depot');await page.locator('#depot-refuel').click();await page.locator('#depot-all').click();await page.locator('#depot-confirm').click();await page.locator('#service-leave').click();await route('dock');await route('navigation');
    const cancelled=await exported();await page.locator('#nav-launch').click();await page.locator('#nav-cancel').click();assert(JSON.stringify((await exported()).state)===JSON.stringify(cancelled.state),'Destination cancellation changes no campaign state, fuel or RNG');
    for(const lang of ['en','ko']) {
      if(await page.locator('html').getAttribute('lang')!==lang)await page.locator('#nav-language').click();
      for(const viewport of [{width:640,height:480},{width:390,height:844},{width:844,height:390},{width:1920,height:1080}]) {
        await page.setViewportSize(viewport);await page.clock.runFor(50);
        for(const scale of ['star','system','planet']) {
          await page.locator('#nav-scale-'+scale).click();
          const layout=await page.locator('#navigation-panel').evaluate(el=>{const r=el.getBoundingClientRect(),nodes=[...el.querySelectorAll('button,select')];return {fits:nodes.every(n=>{const b=n.getBoundingClientRect();return b.left>=r.left-1&&b.right<=r.right+1&&b.top>=r.top-1&&b.bottom<=r.bottom+1}),scroll:document.documentElement.scrollHeight>innerHeight,ratio:document.querySelector('#stage').getBoundingClientRect().width/document.querySelector('#stage').getBoundingClientRect().height}});
          await page.screenshot({path:`output/playwright/remake/r09-navigation-${lang}-${viewport.width}-${scale}.png`});
          assert(layout.fits&&!layout.scroll&&Math.abs(layout.ratio-4/3)<0.01,`${lang} ${viewport.width}×${viewport.height} ${scale} controls fit the4:3 stage`);
        }
      }
    }
    await page.setViewportSize({width:1280,height:720});if(await page.locator('html').getAttribute('lang')!=='en')await page.locator('#nav-language').click();
    await page.locator('#nav-launch').click();await page.locator('#nav-confirm').click();await page.locator('#nav-run').click();await page.clock.runFor(2100);
    const mid=await reload();assert(mid.state.flight.motion?.type==='launch','Mid-launch save retains live transition');await page.locator('#walk-navigation').click();await page.locator('#nav-run').click();await page.clock.runFor(4100);
    const orbit=await exported();assert(orbit.state.regional.shipLocation.cityId===null&&!orbit.state.flight.motion,'Launch reaches the starting world orbit');
    await page.locator('#nav-close').click();assert(!(await page.locator('#walk-airlock').isEnabled()),'Airlock is unavailable in orbit');await page.locator('#walk-navigation').click();await page.locator('#nav-scale-planet').click();await page.locator('#nav-destination').selectOption('city-01');await page.locator('#nav-select').click();await page.locator('#nav-confirm').click();await page.locator('#nav-run').click();await page.clock.runFor(5100);
    const landed=await reload();assert(landed.state.regional.shipLocation.cityId==='city-01'&&landed.state.regional.shipLocation.position.x===150,'Normal landing restores source ship anchor and survives reload');assert(JSON.stringify(landed.state.start)===JSON.stringify(initial.state.start),'Creation remains immutable through flight');
    await page.locator('#walk-navigation').click();await page.locator('#nav-scale-star').click();await page.locator('#nav-destination').selectOption('system-02');await page.locator('#nav-select').click();await page.locator('#nav-confirm').click();await page.locator('#nav-run').click();await page.clock.runFor(1100);let chargeState=(await exported()).state;
    // Source charging rolls can fail; wait for real stored energy, not a fixed lucky second.
    for(let attempt=0;attempt<16&&chargeState.resources.warp.charging&&chargeState.resources.warp.charge===0;attempt++){if((await state()).paused==='true')await page.locator('#nav-run').click();await page.clock.runFor(1000);chargeState=(await exported()).state}
    const charging=await reload();assert(charging.state.resources.warp.charging&&charging.state.resources.warp.charge>0,'Live warp charging survives a fresh-page reload');
    await page.locator('#walk-navigation').click();await page.locator('#nav-cancel-warp').click();const stopped=await exported();assert(!stopped.state.resources.warp.charging&&stopped.state.resources.warp.charge===charging.state.resources.warp.charge,'Cancel charge preserves stored energy and consumed fuel');
    return {browser:browser.version(),checks,failures:[],errors};
  } catch(error){return {browser:browser.version(),checks,failures:[error.stack||error.message],errors}} finally{await context.close()}
}
