// R10 ordinary space acceptance: a fresh character pays for fuel and cargo,
// produces a contact through powered flight, and uses normal saved points.
// No fixtures, state imports, RNG writes, damage writes or synthetic contacts.
// Route planning only reads geometry; all state changes use normal controls.
async browserPage => {
  const browser=browserPage.context().browser(),checks=[],errors=[],states={},samples=[];let last=null;
  const context=await browser.newContext({viewport:{width:1280,height:720}}),page=await context.newPage();
  page.on('pageerror',e=>errors.push(e.stack||e.message));page.on('dialog',d=>d.accept());
  const assert=(ok,name)=>{if(!ok)throw Error(name);checks.push(name)};
  const ready=()=>page.waitForFunction(()=>document.documentElement.dataset.ready==='true');
  const settled=()=>page.waitForFunction(()=>document.querySelector('#checkpoint-back')?.disabled===false);
  const state=()=>page.locator('#walk-screen').evaluate(el=>({...el.dataset}));
  const saves=async()=>{await page.locator(await page.locator('#dialogue-panel').count()?'#dialogue-saves':await page.locator('.sleep-panel').count()?'#sleep-saves':await page.locator('#navigation-panel').count()?'#nav-saves':await page.locator('#space-panel').count()?'#space-saves':await page.locator('#power-panel').count()?'#power-saves':await page.locator('#equipment-panel').count()?'#equipment-saves':['exchange','depot'].includes((await state()).scene)?'#service-saves':'#walk-saves').click();await settled()};
  const exported=async()=>{await saves();const pending=page.waitForEvent('download');await page.locator('#export-checkpoint').click();let text='';for await(const part of await(await pending).createReadStream())text+=part;await settled();await page.locator('#checkpoint-back').click();last=JSON.parse(text);return last};
  const reload=async(slot=0)=>{const before=await exported();await saves();await page.locator('#save-checkpoint-'+slot).click();await settled();await page.reload();await ready();await page.locator('#campaign-saves').click();await settled();await page.locator('#load-checkpoint-'+slot).click();await settled();await page.locator('#checkpoint-back').click();assert(JSON.stringify((await exported()).state)===JSON.stringify(before.state),'Fresh-page reload preserves the complete campaign state');return before};
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
      const after=await state();if(goal==='surface'&&after.scene==='surface'){assert(true,'City boundary enters the surface through normal movement');return}if(Number(after.x)!==p.x||Number(after.y)!==p.y)throw Error(`Route ${goal}: ${after.x},${after.y}, expected ${p.x},${p.y}`);
    }
    assert(true,`${goal} reached through normal movement (${points.length} steps)`);
    if(goal==='street'){await page.locator('#walk-pause').click();return}
    const button=goal==='navigation'?'#walk-navigation':goal==='engineering'?'#walk-equipment':goal==='pod'?'#walk-pod':'#walk-airlock';assert(await page.locator(button).isEnabled(),`${goal} action is available at the reached location`);await page.locator(button).click();
  }
  async function buy() {
    await page.locator('#exchange-offers').click();const s=(await exported()).state;
    // Pricing is a read-only plan; live purchases still use the normal board.
    const selected=await page.evaluate(async s=>{const {loadAssets}=await import('/js/render/assets.js'),a=await loadAssets(),{quoteExchangeCargo,exchangeLocation}=await import('/js/core/exchange.js'),market=s.start.economy.markets.find(m=>m.cityId==='city-09'),originLocation=exchangeLocation(a.campaignContent.exchange,'city-01'),location=exchangeLocation(a.campaignContent.exchange,'city-09');return s.economy.exchange.visit.offers.map((o,i)=>({o,i,quote:o?quoteExchangeCargo({commodityId:o.commodityId,quality:o.quality,originCity:'city-01',pricePaid:o.price},{market,location,originLocation,items:a.campaignContent.dialogue.items},'sell'):0})).filter(v=>v.o&&v.o.price<s.dialogue.cash+s.economy.accounts[0].balance&&v.quote>v.o.price).sort((a,b)=>(b.quote-b.o.price)-(a.quote-a.o.price))[0]},s);
    if(!selected)throw Error('No affordable profitable cargo');await page.locator(`#exchange-row-${selected.i}`).click();await page.locator('#exchange-confirm').click();
  }
  async function navigation() {if(await page.locator('#navigation-panel').count())return;await page.locator(await page.locator('#space-panel').count()?'#space-navigation':'#walk-navigation').click()}
  async function command(type) {await navigation();await page.locator('#nav-'+type).click();await page.locator('#nav-confirm').click()}
  async function destination(scale,id) {await navigation();await page.locator('#nav-scale-'+scale).click();await page.locator('#nav-destination').selectOption(id);await page.locator('#nav-select').click();await page.locator('#nav-confirm').click()}
  async function arrive() {await page.locator('#nav-run').click();for(let i=0;i<1024;i++){await page.clock.runFor(250);if(!(await state()).flight)break}assert(!(await state()).flight,'The confirmed journey reaches its destination through the live clock')}
  try {
    await page.addInitScript(()=>localStorage.setItem('sundog.locale','en'));await page.clock.install({time:new Date('2026-10-07T00:00:00Z')});await page.clock.pauseAt(new Date('2026-10-07T00:00:01Z'));await page.goto('http://127.0.0.1:8000/');await ready();
    await page.locator('#create-character').click();await page.locator('#character-name').fill('R10 pilot');await page.locator('#prepare-campaign').click();await page.locator('#campaign-seed').fill('12345');await page.locator('#start-campaign').click();const initial=await exported();
    await route('depart');await route('depot');await page.locator('#depot-refuel').click();await page.locator('#depot-all').click();await page.locator('#depot-confirm').click();await page.locator('#service-leave').click();await route('exchange');await buy();await buy();await page.locator('#exchange-cargo').click();
    const bought=await exported();const slots=bought.state.economy.exchange.warehouse.slots.map((c,i)=>c?.originCity==='city-01'?i:null).filter(i=>i!==null);assert(slots.length===2,'Two ordinary board purchases are available to load');
    for(const i of slots){await page.locator('#cargo-warehouse-'+i).click();await page.locator('#exchange-confirm').click()}
    const loaded=await reload();assert(loaded.state.pod.cargo.every(Boolean),'Both normally purchased lots are loaded');await page.locator('#service-leave').click();await route('dock');await route('navigation');
    await command('launch');await arrive();const orbit=await exported();
    await destination('system','point-0');await page.locator('#nav-run').click();
    for(let i=0;i<1024;i++) {
      await page.clock.runFor(250);const current=await state();
      if(current.contact==='true'||current.dead==='true'||!current.flight)break;
    }
    const contact=await exported();
    if((await state()).contact==='true') {await navigation();await page.locator('#nav-tactical').click()}
    const tactical=await exported();
    assert(contact.state.space.flags[40]&&tactical.state.space.view==='tactical','Powered flight naturally produces a contact and normal Navigation opens tactical controls');
    assert(tactical.state.resources.hull===15&&tactical.state.space.words[216]>0,'Encounter begins with legitimate initial hull and an actual living enemy');
    states.tactical=await reload(1);
    const run=async ms=>{if((await state()).paused==='true')await page.locator('#space-run').click();await page.clock.runFor(ms)};
    // Finish the actual sublight route before requesting shields: powering
    // full shields for the entire approach exhausts this legitimate fuel load.
    await run(50);
    for(let i=0;i<2000;i++) {
      const pose=await state();if(!pose.flight)break;
      if(pose.dead==='true')throw Error('Defeat before flight arrival');
      await page.clock.runFor(50);
    }
    states.arrived=await exported();
    assert(states.arrived.state.regional.shipLocation.worldId===null,'The ordinary sublight journey reaches open space with actual fuel');
    await page.locator('#space-shields').click();await page.locator('#space-shield-full').click();await page.locator('#space-menu-back').click();
    states.fighting=await reload(1);
    assert(states.fighting.state.space.flags[40]&&states.fighting.state.regional.shipLocation.worldId===null,'An ordinary contact remains active at the reached open-space location');
    let prev=states.fighting,shieldHit=false;
    for(let i=0;i<600;i++) {
      await run(50);const after=await exported();
      if(after.state.resources.shields.charge<prev.state.resources.shields.charge&&
        after.state.resources.shields.targetCharge===255&&prev.state.space.flags[45]&&!after.state.space.flags[45]) {
        states.beforeShield=prev;states.afterShield=after;shieldHit=true;break;
      }
      if(after.state.space.defeat)throw Error('Defeat before shield absorption');
      prev=after;
    }
    assert(shieldHit,'Actual ordinary enemy fire consumes charged ship shields');
    assert(states.beforeShield.state.resources.shields.charge>0&&states.afterShield.state.resources.shields.charge===0,'The ordinary high-strength hit consumes the shield buffer before applying overflow');
    assert(states.afterShield.state.resources.hull===states.beforeShield.state.resources.hull&&JSON.stringify(states.afterShield.state.equipment)!==JSON.stringify(states.beforeShield.state.equipment)&&states.afterShield.state.space.combatFailures.some(Boolean),'Ordinary overflow preserves hull and commits actual component damage/failure owners');
    states.damaged=await reload(2);await page.screenshot({path:'output/playwright/remake/ordinary-space-shield-overflow.png'});
    await page.locator('#space-guns').click();await page.locator('#space-laser').click();
    let current=await exported();
    for(let i=0;i<120;i++) {
      const s=current.state,w=s.space.words,t=s.space.tactical;
      if(s.space.defeat)throw Error('Defeat during manual aim');
      if(w[216]===0)break;
      const due=w[354]+1>=t.record.frameLimit,moves=due?2:1,scale=3-(w[217]>>5);
      const counter=due&&s.machinery.phase===0?0:w[354]+1;
      const releasedMoves=counter+1>=t.record.frameLimit?2:1;
      // Read-only aim plan selects a legal pointer paddle position. Hits,
      // charge expenditure, drift and damage remain owned by live controls.
      const x=Math.max(-8,Math.min(8,Math.round((512-w[206]-(moves+releasedMoves)*scale*w[209])/(2*moves))));
      const y=Math.max(-8,Math.min(8,Math.round((512-w[205]-(moves+releasedMoves)*scale*w[208])/(2*moves))));
      await run(0);const box=await page.locator('#space-surface').boundingBox();
      await page.mouse.move(box.x+box.width*(.5+x/16),box.y+box.height*(.5+y/16));await page.mouse.down();await page.clock.runFor(50);await page.mouse.up();await page.clock.runFor(50);
      current=await exported();if(i%20===0)await page.screenshot({path:'output/playwright/remake/ordinary-space-fight-progress.png'});samples.push({i,x,y,minutes:current.state.ship.minutes,resources:current.state.resources,words:current.state.space.words,randomState:current.state.encounters.randomState});
    }
    states.won=await reload(2);
    assert(states.won.state.space.words[216]===0&&!states.won.state.space.defeat,'Ordinary manual laser aim and fresh pointer fire defeat a real pirate');
    await page.screenshot({path:'output/playwright/remake/ordinary-space-victory.png'});
    const wreck=states.won.state.space.tactical.record.wreck;
    assert(wreck?.present,'Ordinary laser victory produces a real source wreck');
    if(wreck?.present) {
      await page.locator('#space-gun-off').click();await page.locator('#space-menu-back').click();await page.locator('#space-bolts').click();await page.locator('#space-jettison-2').click();
      await page.locator('#space-menu-back').click();await page.locator('#space-guns').click();await page.locator('#space-tractor').click();states.pulling=await reload(2);
      await run(2000);states.collected=await reload(2);
      assert(states.collected.state.space.tactical.record.wreck===null&&JSON.stringify(states.collected.state.pod.cargo[1])===JSON.stringify(wreck.lot),'Ordinary Tractor loads the actual produced wreck into the explicitly emptied slot');
    }
    const hash=async s=>page.evaluate(async value=>{
      const bytes=new Uint8Array(await crypto.subtle.digest('SHA-256',new TextEncoder().encode(JSON.stringify(value))));
      return Array.from(bytes,b=>b.toString(16).padStart(2,'0')).join('');
    },s);
    const project=async v=>({stateHash:await hash(v.state),ship:v.state.ship,resources:v.state.resources,space:v.state.space,equipment:v.state.equipment,
      machinery:v.state.machinery,engineering:v.state.engineering,flight:v.state.flight,regional:v.state.regional.shipLocation,
      pod:v.state.pod,accounts:v.state.economy.accounts,cash:v.state.dialogue.cash,randomState:v.state.encounters.randomState});
    Object.assign(states,{initial,loaded,orbit,contact});
    assert(Object.values(states).every(v=>JSON.stringify(v.state.start)===JSON.stringify(initial.state.start)),'Every ordinary fight and salvage checkpoint preserves immutable creation data');
    assert(states.won.state.economy.accounts[0].balance===states.fighting.state.economy.accounts[0].balance+3000&&JSON.stringify(states.won.state.economy.accounts.slice(1))===JSON.stringify(states.fighting.state.economy.accounts.slice(1)),'Ordinary victory credits the actual system bank once with its source3000Cr bounty');
    assert(states.won.state.dialogue.cash===states.fighting.state.dialogue.cash&&JSON.stringify(states.won.state.pod.cargo)===JSON.stringify(states.fighting.state.pod.cargo),'Ship victory preserves independent personal cash and purchased cargo owners');
    assert(states.collected.state.space.bounties.length===1&&states.collected.state.space.bounties[0].count===1&&states.collected.state.economy.accounts[0].balance===states.won.state.economy.accounts[0].balance,'Fresh-page recovery and Tractor continuation never repeat the victory bounty');
    assert(states.collected.state.space.losses.length===1&&JSON.stringify(states.collected.state.space.losses[0].lot)===JSON.stringify(states.won.state.pod.cargo[1])&&JSON.stringify(states.collected.state.pod.cargo[0])===JSON.stringify(states.won.state.pod.cargo[0]),'Tractor replaces only the explicitly discarded paid slot while retaining its actual loss and the other paid lot');
    await page.clock.runFor(5000);assert(JSON.stringify((await exported()).state)===JSON.stringify(states.collected.state),'Paused elapsed time cannot collect a wreck twice or duplicate its bounty');
    await page.screenshot({path:'output/playwright/remake/ordinary-space-collected.png'});
    const projected={};for(const [n,v]of Object.entries(states))projected[n]=await project(v);
    return {browser:browser.version(),scope:'Fresh seed12345 character; ordinary paid fuel/cargo, flight contacts, shield overflow, manual laser aim/fresh fire, source victory and Tractor; no imports or state mutations outside UI',checks,failures:[],errors,creationHash:await hash(initial.state.start),samples,pose:await state(),states:projected};
  }catch(error){return {browser:browser.version(),checks,failures:[error.stack||error.message],errors,samples,stages:Object.fromEntries(Object.entries(states).map(([n,v])=>[n,{minutes:v.state.ship.minutes,space:v.state.space,resources:v.state.resources,equipment:v.state.equipment,engineering:v.state.engineering,randomState:v.state.encounters.randomState}])),last:last?{space:last.state.space,resources:last.state.resources,equipment:last.state.equipment,engineering:last.state.engineering,randomState:last.state.encounters.randomState}:null,pose:await state(),buttons:await page.locator('button').evaluateAll(els=>els.filter(e=>e.offsetParent).map(e=>({id:e.id,text:e.textContent,disabled:e.disabled})))}}finally{await context.close()}
}
