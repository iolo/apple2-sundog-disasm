// Plan routes from read-only source geometry; change the campaign only via UI.
async browserPage => {
  const browser=browserPage.context().browser(),checks=[],errors=[];
  const context=await browser.newContext({viewport:{width:1280,height:720}}),page=await context.newPage();
  page.on('pageerror',e=>errors.push(e.stack||e.message));page.on('dialog',d=>d.accept());
  const assert=(ok,name)=>{if(!ok)throw Error(name);checks.push(name)};
  const ready=()=>page.waitForFunction(()=>document.documentElement.dataset.ready==='true');
  const settled=()=>page.waitForFunction(()=>document.querySelector('#checkpoint-back')?.disabled===false);
  const state=()=>page.locator('#walk-screen').evaluate(el=>({...el.dataset}));
  const saves=async()=>{await page.locator((await state()).scene==='exchange'?'#service-saves':'#walk-saves').click();await settled()};
  const exported=async()=>{await saves();const pending=page.waitForEvent('download');await page.locator('#export-checkpoint').click();let text='';for await(const part of await(await pending).createReadStream())text+=part;await settled();await page.locator('#checkpoint-back').click();return JSON.parse(text)};
  const reload=async()=>{const before=await exported();await saves();await page.locator('#save-checkpoint-0').click();await settled();await page.reload();await ready();await page.locator('#campaign-saves').click();await settled();await page.locator('#load-checkpoint-0').click();await settled();await page.locator('#checkpoint-back').click();assert(JSON.stringify((await exported()).state)===JSON.stringify(before.state),'Fresh-page reload preserves pod location, cargo, accounts and RNG');return before};
  async function route(goal) {
    const from=await state(),saved=(await exported()).state;
    const points=await page.evaluate(async({from,goal,saved})=>{
      const [{loadAssets},{canStand,interactionAt},{tryPodStep,canDockPod,podExchangeAt}]=await Promise.all([import('/js/render/assets.js'),import('/js/core/ship-walk.js'),import('/js/core/city-pod.js')]);
      const [{campaignFootGeometry},{canBoardParkedPod},{canBoardShip},{cityServiceAt},{detachedShipGeometry}]=await Promise.all([import('/js/core/campaign-pod.js'),import('/js/core/parked-pod.js'),import('/js/core/city-walk.js'),import('/js/core/city-doors.js'),import('/js/core/ship-walk.js')]);
      const a=await loadAssets(),{createGroundWorld}=await import('/js/core/campaign-ground.js'),world=createGroundWorld({...a.campaignContent,...a.campaignContent.ground},saved.start),pod=from.transport==='pod',city=from.scene==='city',g=city?(pod?world.city(saved.ground.cityId,false).pod:world.foot(saved)):(saved.pod.attached?a.shipWalk:detachedShipGeometry(a.shipWalk));
      const routeBounds=city?{left:130,right:955,top:123,bottom:650}:null; // Stay inside source camera exit thresholds while routing to a city destination.
      const reached=(p,h)=>goal==='street'?p.x===360&&p.y===215:goal==='pod'?canBoardParkedPod(g,p,saved.pod.position):goal==='footExchange'?cityServiceAt(a.cityGeometry.map,p)==='exchange':goal==='ship'?canBoardShip(g,p):goal==='airlock'?interactionAt(p)===4:goal==='depart'?interactionAt(p)===3:goal==='dock'?canDockPod(g,p,h):podExchangeAt(g,p,h);
      const start=Number(from.y)*g.width+Number(from.x),queue=[start],seen=new Map([[start,null]]);let end=reached({x:Number(from.x),y:Number(from.y)},Number(from.heading))?start:undefined;
      for(let i=0;i<queue.length&&end===undefined;i++) {
        const k=queue[i],p={x:k%g.width,y:Math.floor(k/g.width)};
        for(let dy=-1;dy<=1;dy++)for(let dx=-1;dx<=1;dx++)if(dx||dy) {
          const next=pod?tryPodStep(g,p,dx,dy):{position:{x:p.x+dx,y:p.y+dy}};
          if(!next||(!pod&&!canStand(g,next.position)))continue;
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
      if(before.transport==='pod') {
        await page.locator('#walk-surface').focus();
        const keys=[...(p.dx?[p.dx>0?'ArrowRight':'ArrowLeft']:[]),...(p.dy?[p.dy>0?'ArrowDown':'ArrowUp']:[])];
        for(const key of keys)await page.keyboard.down(key);
        for(let t=0;t<10;t++){await page.clock.runFor(16);const n=await state();if(n.x!==before.x||n.y!==before.y)break}
        for(const key of keys)await page.keyboard.up(key);
      } else {
        if(before.scene==='city') {
          const cx=Number(before.cameraX),cy=Number(before.cameraY);
          await page.mouse.move(box.x+(145+(p.x+3.25-cx*28)*1.25)*box.width/640,box.y+(126+(p.y-2.75-cy*32)*1.25)*box.height/480);
        }else await page.mouse.move(box.x+(32+(p.x+3.25)*640/280)*box.width/640,box.y+(46+(p.y-2.75)*2)*box.height/480);
        await page.mouse.down();await page.clock.runFor(100);await page.mouse.up();
      }
      const after=await state();if(Number(after.x)!==p.x||Number(after.y)!==p.y)throw Error(`Route ${goal}: ${after.x},${after.y}, expected ${p.x},${p.y}`);
    }
    assert(true,`${goal} reached through normal movement (${points.length} steps)`);
    if(goal==='street'){await page.locator('#walk-pause').click();return}
    const button=goal==='pod'?'#walk-pod':'#walk-airlock';assert(await page.locator(button).isEnabled(),`${goal} action is available at the reached location`);await page.locator(button).click();
  }
  async function buy() {
    await page.locator('#exchange-offers').click();const s=(await exported()).state;
    const offer=s.economy.exchange.visit.offers.map((o,i)=>({o,i})).filter(v=>v.o&&v.o.price<s.dialogue.cash+s.economy.accounts[0].balance).sort((a,b)=>a.o.price-b.o.price)[0];
    if(!offer)throw Error('No affordable cargo');await page.locator(`#exchange-row-${offer.i}`).click();await page.locator('#exchange-confirm').click();
  }
  try {
    await page.addInitScript(()=>localStorage.setItem('sundog.locale','en'));await page.clock.install({time:new Date('2026-10-03T00:00:00Z')});await page.clock.pauseAt(new Date('2026-10-03T00:00:01Z'));await page.goto('http://127.0.0.1:8000/');await ready();
    await page.locator('#create-character').click();await page.locator('#character-name').fill('Parking pilot');await page.locator('#prepare-campaign').click();await page.locator('#campaign-seed').fill('12345');await page.locator('#start-campaign').click();
    await route('depart');const departure=await exported();await page.locator('#walk-pod').click();
    assert((await state()).transport==='foot'&&(await state()).x==='293'&&(await state()).y==='210','Parking beside the ship uses the exact source-clear exit');
    await page.locator('#walk-pod').click();assert(JSON.stringify((await exported()).state)===JSON.stringify(departure.state),'Immediate boarding recovers the constrained departure position without changing resources');
    await route('exchange');await buy();await buy();await page.locator('#exchange-cargo').click();
    for(const i of [0,1]){await page.locator(`#cargo-warehouse-${i}`).click();await page.locator('#exchange-confirm').click()}
    const loaded=await exported();assert(loaded.state.pod.cargo.every(Boolean),'Fresh-character purchases fill both pod cargo slots');
    await page.locator('#service-leave').click();await route('street');const street=await exported();await page.locator('#walk-pod').click();const parked=await reload();
    assert(parked.version===22&&!parked.state.pod.occupied&&!parked.state.pod.attached&&JSON.stringify(parked.state.pod.position)===JSON.stringify(street.state.pod.position),'Version22 preserves the independent parked pod and player positions');
    assert(JSON.stringify(parked.state.pod.cargo)===JSON.stringify(loaded.state.pod.cargo),'Parking and reload preserve both purchased cargo lots');
    for(const lang of ['en','ko']) {
      if((await page.locator('html').getAttribute('lang'))!==lang)await page.locator('#walk-language').click();
      for(const [width,height] of [[1280,720],[640,480],[390,844],[844,390]]) {
        await page.setViewportSize({width,height});await page.clock.runFor(100);
        await page.waitForFunction(()=>Math.abs(document.querySelector('#stage').getBoundingClientRect().width-Math.min(innerWidth,innerHeight*4/3))<1);
        assert(await page.locator('.walk-actions').evaluate(el=>{const r=el.getBoundingClientRect(),buttons=[...el.querySelectorAll('button')].map(b=>b.getBoundingClientRect());return r.left>=0&&r.right<=innerWidth+1&&r.bottom<=innerHeight+1&&buttons.every((b,i)=>b.left>=r.left&&b.right<=r.right&&b.bottom<=r.bottom&&(!i||b.left>=buttons[i-1].right-1))}),`${lang} parked controls fit ${width}x${height}`);
      }
    }
    await page.screenshot({path:'output/playwright/remake/parked-pod-ko.png'});await page.setViewportSize({width:1280,height:720});
    await route('footExchange');assert(await page.locator('#exchange-cargo').count()===0,'A foot exchange visit cannot load the parked pod');const foot=await reload();
    assert(JSON.stringify(foot.state.pod)===JSON.stringify(parked.state.pod),'Foot travel and exchange reload leave the unattended pod and cargo unchanged');
    await page.locator('#service-leave').click();assert(await page.locator('#walk-pod').isDisabled(),'Board pod stays disabled away from its parked position');
    await route('ship');const aboard=await reload();assert(JSON.stringify(aboard.state.pod)===JSON.stringify(parked.state.pod)&&JSON.stringify(aboard.state.resources)===JSON.stringify(parked.state.resources),'Foot boarding leaves the pod detached and does not perform docking/refueling');
    await page.locator('#walk-inventory').click();assert(await page.locator('#pod-manifest').count()===0,'Detached cargo is not presented as aboard the ship');await page.locator('#inventory-close').click();
    await page.screenshot({path:'output/playwright/remake/parked-ship-en.png'});
    await route('airlock');await route('pod');const boarded=await reload();assert(boarded.state.pod.occupied&&JSON.stringify(boarded.state.pod.cargo)===JSON.stringify(loaded.state.pod.cargo),'Walking back and boarding restores driving with all cargo intact');
    await route('dock');const docked=await reload();assert(docked.state.pod.attached&&!docked.state.pod.occupied&&JSON.stringify(docked.state.pod.cargo)===JSON.stringify(loaded.state.pod.cargo),'Loaded docking restores attachment after the unattended journey');
    assert(JSON.stringify(docked.state.economy.accounts)===JSON.stringify(loaded.state.economy.accounts)&&docked.state.dialogue.cash===loaded.state.dialogue.cash,'Parking, walking, boarding and docking add no payments');
    assert(errors.length===0,'No uncaught parking journey errors');return {browser:browser.version(),checks,errors};
  }catch(error){await page.screenshot({path:'output/playwright/remake/parking-error.png'});return {browser:browser.version(),checks,errors,failures:[error.message]}}
  finally {await context.close()}
}
