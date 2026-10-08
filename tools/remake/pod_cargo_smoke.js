// Plan routes from read-only source geometry; change the campaign only via UI.
async browserPage => {
  const browser=browserPage.context().browser(),checks=[],errors=[];
  const context=await browser.newContext({viewport:{width:1280,height:720}}),page=await context.newPage();
  page.on('pageerror',e=>errors.push(e.message));page.on('dialog',d=>d.accept());
  const assert=(ok,name)=>{if(!ok)throw Error(name);checks.push(name)};
  const ready=()=>page.waitForFunction(()=>document.documentElement.dataset.ready==='true');
  const settled=()=>page.waitForFunction(()=>document.querySelector('#checkpoint-back')?.disabled===false);
  const state=()=>page.locator('#walk-screen').evaluate(el=>({...el.dataset}));
  const saves=async()=>{await page.locator((await state()).scene==='exchange'?'#service-saves':'#walk-saves').click();await settled()};
  const exported=async()=>{await saves();const pending=page.waitForEvent('download');await page.locator('#export-checkpoint').click();let text='';for await(const part of await(await pending).createReadStream())text+=part;await settled();await page.locator('#checkpoint-back').click();return JSON.parse(text)};
  const reload=async()=>{const before=await exported();await saves();await page.locator('#save-checkpoint-0').click();await settled();await page.reload();await ready();await page.locator('#campaign-saves').click();await settled();await page.locator('#load-checkpoint-0').click();await settled();await page.locator('#checkpoint-back').click();assert(JSON.stringify((await exported()).state)===JSON.stringify(before.state),'Fresh-page reload preserves pod location, cargo, accounts and RNG');return before};
  async function route(goal) {
    const from=await state();
    const points=await page.evaluate(async({from,goal})=>{
      const [{loadAssets},{canStand,interactionAt},{tryPodStep,canDockPod,podExchangeAt}]=await Promise.all([import('/js/render/assets.js'),import('/js/core/ship-walk.js'),import('/js/core/city-pod.js')]);
      const a=await loadAssets();const {createPodGeometry}=await import('/js/core/city-pod.js');a.cityGeometry.pod=createPodGeometry(a.cityGeometry.map,a.campaignContent.ground.cityWalk,{...a.campaignContent.location,position:a.campaignContent.location.shipPosition},{surfaceTravel:true});const routeBounds={left:130,right:955,top:123,bottom:650};const pod=from.transport==='pod',g=pod?a.cityGeometry.pod:a.shipWalk;
      const start=Number(from.y)*g.width+Number(from.x),queue=[start],seen=new Map([[start,null]]);let end;
      for(let i=0;i<queue.length&&end===undefined;i++) {
        const k=queue[i],p={x:k%g.width,y:Math.floor(k/g.width)};
        for(let dy=-1;dy<=1;dy++)for(let dx=-1;dx<=1;dx++)if(dx||dy) {
          const next=pod?tryPodStep(g,p,dx,dy):{position:{x:p.x+dx,y:p.y+dy}};
          if(!next||(!pod&&!canStand(g,next.position)))continue;
          if(routeBounds&&(next.position.x<routeBounds.left||next.position.x>routeBounds.right||next.position.y<routeBounds.top||next.position.y>routeBounds.bottom)&&pod)continue;
          const n=next.position.y*g.width+next.position.x;if(seen.has(n))continue;
          seen.set(n,{from:k,dx,dy});queue.push(n);
          if(goal==='depart'?interactionAt(next.position)===3:goal==='dock'?canDockPod(g,next.position,next.heading):podExchangeAt(g,next.position,next.heading)){end=n;break}
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
        for(const key of keys)await page.keyboard.up(key);await page.clock.runFor(50); // Let the source host observe the released movement button.
      } else {
        await page.mouse.move(box.x+(32+(p.x+3.25)*640/280)*box.width/640,box.y+(46+(p.y-2.75)*2)*box.height/480);
        await page.mouse.down();await page.clock.runFor(100);await page.mouse.up();
      }
      const after=await state();if(Number(after.x)!==p.x||Number(after.y)!==p.y)throw Error(`Route ${goal}: ${after.x},${after.y}, expected ${p.x},${p.y}`);
    }
    assert(await page.locator('#walk-airlock').isEnabled(),`${goal} reached through normal movement (${points.length} steps)`);
    await page.locator('#walk-airlock').click();
  }
  async function buy() {
    await page.locator('#exchange-offers').click();const s=(await exported()).state;
    const offer=s.economy.exchange.visit.offers.map((o,i)=>({o,i})).filter(v=>v.o&&v.o.price<s.dialogue.cash+s.economy.accounts[0].balance).sort((a,b)=>a.o.price-b.o.price)[0];
    if(!offer)throw Error('No affordable cargo');await page.locator(`#exchange-row-${offer.i}`).click();await page.locator('#exchange-confirm').click();
  }
  try {
    await page.addInitScript(()=>localStorage.setItem('sundog.locale','en'));await page.clock.install({time:new Date('2026-10-01T00:00:00Z')});await page.clock.pauseAt(new Date('2026-10-01T00:00:01Z'));await page.goto('http://127.0.0.1:8000/');await ready();
    await page.locator('#create-character').click();await page.locator('#character-name').fill('Cargo pilot');await page.locator('#prepare-campaign').click();await page.locator('#campaign-seed').fill('12345');await page.locator('#start-campaign').click();
    const initial=await exported();await route('depart');assert((await state()).transport==='pod','Fresh campaign departs in the pod');
    const departed=await reload();assert(departed.version===29&&departed.state.pod.position.x===296&&departed.state.pod.position.y===211,'Version29 stores source pod departure');
    await route('exchange');assert((await state()).scene==='exchange','Pod cargo entrance opens the exchange');await buy();await buy();await buy();
    await page.locator('#exchange-cargo').click();const before=await exported();
    await page.locator('#cargo-warehouse-0').click();assert(await page.locator('#exchange-confirm').isEnabled(),'Fetch offers confirmation before transferring');
    await page.locator('#exchange-cancel').click();assert(JSON.stringify((await exported()).state)===JSON.stringify(before.state),'Cancelling a fetch preserves all state');
    await page.locator('#cargo-warehouse-0').click();await page.locator('#exchange-confirm').click();await page.locator('#cargo-warehouse-1').click();await page.locator('#exchange-confirm').click();
    const loaded=await exported();assert(loaded.state.pod.cargo.every(Boolean)&&loaded.state.economy.exchange.warehouse.slots.slice(0,2).every(c=>c===null),'Fetch fills the two pod slots and clears the warehouse sources');
    assert(JSON.stringify(loaded.state.economy.accounts)===JSON.stringify(before.state.economy.accounts)&&loaded.state.encounters.randomState===before.state.encounters.randomState,'Cargo loading changes no cash, account or RNG');
    await page.locator('#cargo-warehouse-2').click();assert(await page.locator('#exchange-confirm').isDisabled(),'Full pod blocks a third fetch');await page.locator('#exchange-cancel').click();
    await page.locator('#cargo-swap').click();await page.locator('#cargo-pod-0').click();assert(await page.locator('#exchange-confirm').isDisabled(),'Swap requires both occupied selections');await page.locator('#cargo-warehouse-2').click();await page.locator('#exchange-confirm').click();
    const swapped=await exported();assert(JSON.stringify(swapped.state.pod.cargo[0])===JSON.stringify(loaded.state.economy.exchange.warehouse.slots[2])&&JSON.stringify(swapped.state.economy.exchange.warehouse.slots[2])===JSON.stringify(loaded.state.pod.cargo[0]),'Swap exchanges both complete lots without repricing');
    for(const lang of ['en','ko']) {
      if(lang==='ko')await page.locator('#service-language').click();
      for(const [width,height] of [[1280,720],[640,480],[390,844],[844,390]]) {
        await page.setViewportSize({width,height});await page.clock.runFor(100);
        await page.waitForFunction(()=>Math.abs(document.querySelector('#stage').getBoundingClientRect().width-Math.min(innerWidth,innerHeight*4/3))<1);
        assert(await page.locator('#service-panel').evaluate(el=>{const r=el.getBoundingClientRect();return r.left>=0&&r.top>=0&&r.right<=innerWidth+1&&r.bottom<=innerHeight+1&&el.scrollWidth<=el.clientWidth&&[...el.querySelectorAll('button')].every(b=>{const q=b.getBoundingClientRect();return q.top>=r.top&&q.bottom<=r.bottom&&q.left>=r.left&&q.right<=r.right})}),`${lang} loading controls fit ${width}x${height}`);
      }
    }
    await page.screenshot({path:'output/playwright/remake/pod-loading-ko.png'});await page.setViewportSize({width:1280,height:720});await reload();
    await page.locator('#service-leave').click();await route('dock');const docked=await reload();
    assert(docked.state.pod.attached&&JSON.stringify(docked.state.pod.cargo)===JSON.stringify(swapped.state.pod.cargo),'Docking retains loaded cargo aboard the ship');
    await page.locator('#walk-inventory').click();assert(await page.locator('#pod-manifest p').count()===2,'Ship inventory displays the same two-slot pod manifest');await page.locator('#inventory-close').click();
    await route('depart');await route('exchange');await page.locator('#exchange-cargo').click();
    for(const i of [0,1]){await page.locator(`#cargo-pod-${i}`).click();await page.locator('#exchange-confirm').click()}
    const stored=await exported();assert(stored.state.pod.cargo.every(c=>c===null),'Store unloads both cargo lots into warehouse vacancies');
    await page.locator('#exchange-warehouse').click();await page.locator('#exchange-row-0').click();await page.locator('#exchange-confirm').click();const sold=await exported();
    assert(sold.state.economy.accounts[0].balance>stored.state.economy.accounts[0].balance&&sold.state.economy.exchange.warehouse.slots[0]===null,'Transported cargo sells into the local bank account');
    assert(JSON.stringify(sold.state.start)===JSON.stringify(initial.state.start),'The complete cargo journey preserves immutable creation data');
    await reload();assert(errors.length===0,'No uncaught pod/cargo errors');return {browser:browser.version(),checks,errors};
  } finally {await context.close()}
}
