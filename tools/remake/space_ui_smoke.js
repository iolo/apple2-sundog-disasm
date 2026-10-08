// Declared aboard/contact/equipment fixtures exercise the live host. All
// tactical actions, mutations and continuation use ordinary UI controls.
// These fixtures do not replace fresh-character encounter acceptance.
async browserPage => {
  const browser=browserPage.context().browser(),checks=[],errors=[];
  const context=await browser.newContext({viewport:{width:1280,height:720},hasTouch:true}),page=await context.newPage();
  page.on('pageerror',e=>errors.push(e.stack||e.message));page.on('dialog',d=>d.accept());
  page.on('console',m=>{if(m.type()==='error')errors.push(m.text())});
  const assert=(ok,name)=>{if(!ok)throw Error(name);checks.push(name)};
  const ready=()=>page.waitForFunction(()=>document.documentElement.dataset.ready==='true');
  const settled=()=>page.waitForFunction(()=>document.querySelector('#checkpoint-back')?.disabled===false);
  const ui=()=>page.locator('#walk-screen').evaluate(el=>({...el.dataset}));
  const saves=async()=>{if(await page.locator('#inventory-panel').count())await page.locator('#inventory-close').click();const id=await page.locator('#dialogue-panel').count()?'#dialogue-saves':await page.locator('.sleep-panel').count()?'#sleep-saves':await page.locator('#space-panel').count()?'#space-saves':await page.locator('#navigation-panel').count()?'#nav-saves':'#walk-saves';await page.locator(id).click();await settled()};
  const exported=async()=>{
    await saves();if(!await page.locator('#export-checkpoint').isEnabled())throw Error('Export disabled: '+await page.locator('#checkpoint-message').innerText()+'; '+errors.join('; '));const pending=page.waitForEvent('download',{timeout:5000}).catch(()=>null);await page.locator('#export-checkpoint').click();let text='';
    const download=await pending;if(!download)throw Error('Export failed: '+await page.locator('#checkpoint-message').innerText()+'; '+errors.join('; '));
    for await(const part of await download.createReadStream())text+=part;
    await settled();await page.locator('#checkpoint-back').click();return JSON.parse(text);
  };
  const imported=async value=>{
    if(!await page.locator('#checkpoint-screen').isVisible())await saves();
    const pending=page.waitForEvent('download');
    await page.evaluate(value=>{const a=document.createElement('a');a.href=URL.createObjectURL(new Blob([JSON.stringify(value)],{type:'application/json'}));a.download='space-fixture.json';a.click()},value);
    await(await pending).saveAs('output/playwright/remake/space-fixture.json');
    await page.locator('#checkpoint-file').setInputFiles('output/playwright/remake/space-fixture.json');await settled();
    const message=await page.locator('#checkpoint-message').innerText();if(!/imported|가져왔습니다/i.test(message))throw Error('Import failed: '+message+'; '+errors.join('; '));
    await page.locator('#checkpoint-back').click();
  };
  const reload=async()=>{
    const before=await exported();await saves();await page.locator('#save-checkpoint-0').click();await settled();
    await page.reload();await ready();await page.locator('#campaign-saves').click();await settled();await page.locator('#load-checkpoint-0').click();await settled();await page.locator('#checkpoint-back').click();
    assert(JSON.stringify((await exported()).state)===JSON.stringify(before.state),'Fresh page restores every campaign and tactical owner exactly');return before;
  };
  const run=async ms=>{if((await ui()).paused==='true')await page.locator(await page.locator('#space-panel').count()?'#space-run':await page.locator('.sleep-panel').count()?'#sleep-pause':'#walk-pause').click();await page.clock.runFor(ms)};
  const fixture=async(original,{tactical=false,fatal=false,componentHit=false,contact=true,charge=null}={})=>page.evaluate(async({original,tactical,fatal,componentHit,contact,charge})=>{
    const [{loadAssets},{campaignSaveCodec},{createInitialEquipment},{recalculateEquipment},{canStand,interactionAt},{reduceCampaignSpace}]=await Promise.all([
      import('/js/render/assets.js'),import('/js/core/campaign-saves.js'),import('/js/core/initialization.js'),import('/js/core/equipment.js'),import('/js/core/ship-walk.js'),import('/js/core/campaign-space.js')]);
    const a=await loadAssets(),codec=campaignSaveCodec(a.campaignContent,a.shipWalk,a.cityGeometry);let s=structuredClone(original.state);
    s.equipment=createInitialEquipment({next:()=>1}).map(recalculateEquipment);s.resources.fuel=255;s.resources.guns={charge:100,powered:false};s.resources.shields={charge:0,targetCharge:0};
    const g=s.equipment[3];g.units.forEach(u=>u.components[g.requiredSocket]=g.spares[g.requiredSocket]);s.equipment[3]=recalculateEquipment(g);
    for(let y=0;y<192;y++)for(let x=0;x<280;x++)if(canStand(a.shipWalk,{x,y})&&interactionAt({x,y})===1){s.ship.position={x,y};y=192;break}
    s.space.flags[40]=contact;s.space.flags[44]=false;s.encounters.randomState=29;s.machinery.phase=0;
    Object.assign(s.space.words,{205:512,206:512,207:0,208:0,209:0,214:1,215:40,216:contact?200:0,217:20});
    if(tactical)s=reduceCampaignSpace(s,{type:'view',view:'tactical'},a.campaignContent);
    if(charge!==null)s.resources.guns.charge=charge;
    if(componentHit){s.encounters.randomState=4;s.machinery.phase=1;s.space.flags[45]=true;
      s.space.rangeMemory=20;Object.assign(s.space.words,{215:41,217:20,354:4});}
    if(fatal){s.resources.hull=1;s.resources.guns={charge:68,powered:false};s.resources.shields={charge:0,targetCharge:0};s.resources.fuel=228;
      s.encounters.randomState=28;s.machinery.phase=1;s.space.flags[45]=true;s.ship.minutes=1278;
      s.ship.condition={vigor:237,rest:235,health:255,nourishment:228};s.space.rangeMemory=45;
      Object.assign(s.space.words,{215:41,217:5,354:4});}
    return codec.make(s,0);
  },{original,tactical,fatal,componentHit,contact,charge});
  try {
    await page.addInitScript(()=>localStorage.setItem('sundog.locale','en'));
    await page.clock.install({time:new Date('2026-10-08T00:00:00Z')});await page.clock.pauseAt(new Date('2026-10-08T00:00:01Z'));
    await page.goto('http://127.0.0.1:8000/');await ready();await page.locator('#create-character').click();
    await page.locator('#character-name').fill('Space controls');await page.locator('#prepare-campaign').click();await page.locator('#campaign-seed').fill('12345');await page.locator('#start-campaign').click();
    const original=await exported();assert(original.version===29&&original.scope==='ship-salvage-1','Live campaign owns version29 space and tactical state');
    await imported(await fixture(original));await page.locator('#walk-navigation').click();await page.locator('#nav-tactical').click();
    assert(await page.locator('#space-panel').isVisible(),'Pilotage enters the live tactical panel through navigation');
    const entry=await reload();assert(entry.state.machinery.phase===3&&entry.state.resources.guns.charge===84,'Live tactical entry commits the source three startup calls');
    const before=JSON.stringify(entry.state);await page.clock.runFor(1000);assert(JSON.stringify((await exported()).state)===before,'Paused tactical view spends no RNG, time or resources');
    for(const locale of ['en','ko']) {
      if(await page.locator('html').getAttribute('lang')!==locale)await page.locator('#space-language').click();
      for(const viewport of [{width:640,height:480},{width:390,height:844},{width:844,height:390},{width:1920,height:1080}]) {
        await page.setViewportSize(viewport);await page.evaluate(()=>window.dispatchEvent(new Event('resize')));await page.clock.runFor(50);
        for(const menu of ['root','shields','guns','bolts']) {
          if(menu!=='root')await page.locator('#space-'+menu).click();
          const layout=await page.locator('#space-panel').evaluate(el=>{
            const box=el.getBoundingClientRect(),nodes=[...el.querySelectorAll('button,canvas,p')];
            const fits=nodes.every(child=>{const r=child.getBoundingClientRect();return r.left>=box.left-1&&r.right<=box.right+1&&r.top>=box.top-1&&r.bottom<=box.bottom+1});
            const blocked=[...el.querySelectorAll('button:not(:disabled),canvas')].filter(child=>{const r=child.getBoundingClientRect(),hit=document.elementFromPoint(r.x+r.width/2,r.y+r.height/2);return !hit||!child.contains(hit)}).map(n=>n.id);
            return {fits,blocked};
          });
          if(viewport.width===390||viewport.width===1920)await page.screenshot({path:`output/playwright/remake/r10-space-${locale}-${viewport.width}-${menu}.png`});
          assert(layout.fits&&!layout.blocked.length,`${locale} ${menu} controls fit and remain clickable at ${viewport.width}x${viewport.height}: ${layout.blocked.join(',')}`);
          if(menu!=='root')await page.locator('#space-menu-back').click();
        }
      }
      await page.locator('#space-help').click();assert((await page.locator('.help').innerText()).includes(locale==='en'?'Tractor':'견인'),'Localized help explains source ship controls');await page.locator('#walk-close-help').click();
    }
    await page.setViewportSize({width:1280,height:720});if(await page.locator('html').getAttribute('lang')!=='en')await page.locator('#space-language').click();
    await page.locator('#space-shields').click();await page.locator('#space-shield-more').click();
    assert((await exported()).state.resources.shields.targetCharge===64,'Shield control commits the real target charge');
    await page.locator('#space-shield-off').click();await page.locator('#space-menu-back').click();await page.locator('#space-guns').click();await page.locator('#space-laser').click();
    await run(1);await page.locator('#space-surface').focus();await page.keyboard.down('ArrowRight');await page.clock.runFor(100);await page.keyboard.up('ArrowRight');
    const moved=await exported();assert(moved.state.space.words[206]>entry.state.space.words[206],'Arrow input advances source tactical coordinates');
    await imported(await fixture(original,{tactical:true,charge:5}));await page.locator('#space-guns').click();await page.locator('#space-laser').click();
    await run(0);await page.locator('#space-surface').focus();await page.keyboard.down(' ');await page.clock.runFor(100);
    const firstHit=Number((await ui()).shipHealth);assert(firstHit>0&&firstHit<200,`Low-charge keyboard fire damages the live target without a fabricated kill (health${firstHit})`);
    await page.clock.runFor(600);assert(Number((await ui()).shipHealth)===firstHit&&Number((await ui()).shipGun)>0,'Held keyboard fire does not shoot again after actual recharge');
    await page.keyboard.up(' ');const held=await reload();assert(held.state.space.tactical.trigger.previous&&!held.state.space.tactical.control.fire,'Save releases physical fire while preserving the native prior-button history');
    await run(50);const target=await page.locator('#space-surface').boundingBox();await page.mouse.move(target.x+target.width/2,target.y+target.height/2);
    await page.mouse.down();await page.clock.runFor(50);await page.mouse.up();const pointerKill=await exported();
    assert(pointerKill.state.space.tactical.trigger.previous&&!pointerKill.state.space.tactical.trigger.latched&&
      (pointerKill.state.resources.guns.charge===0||pointerKill.state.resources.fuel<held.state.resources.fuel),
      'A fresh primary-pointer press after observed release spends real shot energy once');
    await imported(await fixture(original,{tactical:true,contact:false}));await page.locator('#space-guns').click();await page.locator('#space-laser').click();await run(0);
    const emptyBox=await page.locator('#space-surface').boundingBox();await page.mouse.move(emptyBox.x+emptyBox.width/2,emptyBox.y+emptyBox.height/2);
    await page.mouse.down({button:'right'});await page.clock.runFor(50);await page.mouse.up({button:'right'});const empty=await exported();
    assert(empty.state.resources.guns.charge===0&&!empty.state.space.bounties.length&&empty.state.space.words[216]===0,'Right-pointer empty-space fire spends actual stored charge without a reward');
    await imported(await fixture(original,{tactical:true,contact:false}));await page.locator('#space-guns').click();await page.locator('#space-laser').click();await run(0);
    await page.locator('#space-fire').focus();await page.keyboard.press('Enter');await page.clock.runFor(17);
    const buffered=await reload();assert(buffered.state.space.tactical.trigger.latched&&buffered.state.space.elapsed===17,'Fire-button activation retains its buffered press and partial budget through a fresh-page save');
    await run(33);assert((await exported()).state.resources.guns.charge===0,'Restored short press spends actual charge at its first source frame');
    await imported(await fixture(original,{tactical:true}));await page.locator('#space-guns').click();await page.locator('#space-laser').click();await run(0);
    const panButton=await page.locator('#space-pan-right').boundingBox();await page.mouse.move(panButton.x+panButton.width/2,panButton.y+panButton.height/2);
    await page.mouse.down();await page.clock.runFor(137);await page.mouse.up();const panned=await exported();
    assert(panned.state.space.words[206]>512&&panned.state.space.tactical.control.x===0,`Held direction button advances real coordinates and releases its captured pointer (x${panned.state.space.words[206]}, control${panned.state.space.tactical.control.x})`);
    await imported(await fixture(original,{tactical:true}));await page.locator('#space-guns').click();await page.locator('#space-laser').click();
    const armed=await exported();await run(1);await page.locator('#space-surface').focus();await page.keyboard.down(' ');await page.clock.runFor(100);await page.keyboard.up(' ');
    const killed=await exported();assert(killed.state.space.bounties.length===1&&killed.state.economy.accounts[0].balance===armed.state.economy.accounts[0].balance+2000,'Actual live laser kill credits its source bounty once');
    assert(killed.state.space.tactical.record.wreck?.present&&killed.state.space.wrecks.length===1,'Live kill retains the produced wreck and cargo owner');
    await page.locator('#space-gun-off').click();await page.locator('#space-tractor').click();await page.clock.runFor(1000);
    const collected=await reload();assert(collected.state.pod.cargo[1]?.commodityId===killed.state.space.wrecks[0].lot.commodityId&&!collected.state.space.tactical.record.wreck,'Tractor completes through actual due calls into pod slot2');
    await page.locator('#space-menu-back').click();await page.locator('#space-bolts').click();assert(await page.locator('#space-jettison-2').isEnabled(),'Bolts arm only the occupied ordinary cargo slot');
    await page.locator('#space-jettison-2').click();const discarded=await reload();assert(discarded.state.pod.cargo[1]===null&&discarded.state.space.losses.length===1,'Live jettison commits actual cargo loss and survives reload');
    await imported(await fixture(original,{tactical:true}));await page.locator('#space-comm').click();const opened=await reload();
    assert(opened.state.space.communication.conversation!==null,'Comm freezes and reloads the actual campaign conversation');
    await page.locator('#dialogue-reply-0').click();await page.locator('#dialogue-cancel').click();const agreed=await reload();
    assert(agreed.state.space.communication.pending&&agreed.state.space.communication.ticks===6,'Verified agreement arms the real six-tick cargo deadline');
    await page.locator('#space-navigation').click();const left=await exported();assert(!left.state.space.communication.pending&&left.state.space.flags[44],'Leaving tactical restores aggression and releases the pending deadline');
    await page.locator('#nav-close').click();await page.locator('#walk-inventory').click();await page.locator('#inventory-sleep').click();await page.clock.runFor(137);
    const asleep=await reload();assert(asleep.state.space.activity.sleeping&&asleep.state.space.elapsed>0,'Sleep and its partial machinery remainder survive a fresh-page reload');
    await page.locator('#sleep-wake').click();assert((await exported()).state.space.activity.sleeping===false,'Wake returns through the actual saved activity owner');
    await imported(await fixture(original,{tactical:true,componentHit:true}));await run(100);const damaged=await reload();
    assert(JSON.stringify(damaged.state.equipment[1].units[1].components)===JSON.stringify([31,156,30,24])&&damaged.state.equipment[1].performance===12&&
      damaged.state.engineering.pendingFailures[1]===6&&damaged.state.space.combatFailures[1],
      'Live enemy component hit commits the independent source bytes, performance and engineering failure owner');
    const recovery=await fixture(original,{tactical:true});await imported(recovery);await saves();await page.locator('#save-checkpoint-1').click();await settled();await page.locator('#checkpoint-back').click();
    await imported(await fixture(original,{tactical:true,fatal:true}));await run(100);
    assert((await ui()).dead==='true'&&await page.locator('#sleep-title').innerText()==='Ship destroyed','Fatal hull damage opens the live ship-destruction scene');
    const dead=await reload();assert(dead.state.space.words[215]===35&&dead.state.resources.guns.charge===60&&dead.state.machinery.phase===3,'Live fatal frame matches the observed native exit vector');
    assert(JSON.stringify(dead.state.ship.condition)===JSON.stringify({vigor:237,rest:235,health:255,nourishment:228}),'Ship death preserves personal condition');
    await page.clock.runFor(5000);assert(JSON.stringify((await exported()).state)===JSON.stringify(dead.state),'Terminal clock remains frozen after reload');
    await saves();await page.locator('#load-checkpoint-1').click();await settled();await page.locator('#checkpoint-back').click();
    assert(JSON.stringify((await exported()).state)===JSON.stringify(recovery.state),'Explicit saved-point recovery restores all earlier owners');
    await run(500);assert((await ui()).dead==='false'&&Number((await ui()).minutes)>recovery.state.ship.minutes,'Restored campaign resumes playable tactical time');
    // Replace only the browser display callback cadence, preserving the live
    // UI, input handlers, reducers, serialized budgets and persistence.
    await page.addInitScript(()=>{
      const hz=Number(localStorage.getItem('space-test-hz'));
      if([30,60,144].includes(hz)) {
        window.requestAnimationFrame=callback=>setTimeout(()=>callback(performance.now()),1000/hz);
        window.cancelAnimationFrame=id=>clearTimeout(id);
      }
    });
    const rates=[];
    for(const hz of [30,60,144]) {
      await page.evaluate(hz=>localStorage.setItem('space-test-hz',hz),hz);await page.reload();await ready();
      await page.locator('#campaign-saves').click();await settled();await imported(await fixture(original,{tactical:true,contact:false,charge:100}));
      await page.locator('#space-guns').click();await page.locator('#space-laser').click();await run(0);
      await page.locator('#space-surface').focus();await page.keyboard.down('ArrowRight');await page.clock.runFor(137);
      const partial=await reload();await page.keyboard.up('ArrowRight');assert(partial.state.space.elapsed===37,`${hz}Hz save while input is held retains the exact partial tactical budget`);
      await page.clock.runFor(1000);assert(JSON.stringify((await exported()).state)===JSON.stringify(partial.state),`${hz}Hz pause freezes every owner`);
      await run(0);await page.locator('#space-surface').focus();await page.keyboard.down('ArrowDown');
      await page.clock.runFor(17);await page.keyboard.down(' ');await page.keyboard.up(' ');await page.clock.runFor(846);await page.keyboard.up('ArrowDown');
      const awake=await reload();assert(awake.state.space.elapsed===0&&awake.state.space.tactical.trigger.latched===false,`${hz}Hz short fire pulse is consumed once across due frames`);
      await page.locator('#space-navigation').click();await page.locator('#nav-close').click();await page.locator('#walk-inventory').click();await page.locator('#inventory-sleep').click();
      await page.clock.runFor(137);const sleepPartial=await reload();assert(sleepPartial.state.space.activity.sleeping&&sleepPartial.state.space.elapsed===37,`${hz}Hz sleep/save retains its exact partial budget`);
      await run(863);const sleep=await exported();
      await imported(await fixture(original,{tactical:true,componentHit:true}));await run(100);const damage=await reload();
      assert(damage.state.encounters.randomState===1082204676&&damage.state.engineering.pendingFailures[1]===6,`${hz}Hz live enemy damage consumes the independent six-draw RNG vector`);
      await run(900);const damageContinued=await exported();
      await imported(await fixture(original,{tactical:true,fatal:true}));await run(100);
      if(await page.locator('#space-surface').isVisible()){await page.locator('#space-surface').focus();await page.keyboard.press('ArrowRight')}
      assert(await page.locator('#sleep-title').innerText()==='Ship destroyed',`${hz}Hz input settling a fatal interval immediately renders the terminal scene`);
      const fatal=await exported();
      assert(fatal.state.space.defeat&&fatal.state.encounters.randomState===3280408540&&fatal.state.machinery.phase===3,`${hz}Hz fatal combat reaches the same native RNG and exit phase`);
      rates.push({partial:partial.state,awake:awake.state,sleepPartial:sleepPartial.state,sleep:sleep.state,damage:damage.state,damageContinued:damageContinued.state,fatal:fatal.state});
    }
    assert(JSON.stringify(rates[0])===JSON.stringify(rates[1])&&JSON.stringify(rates[1])===JSON.stringify(rates[2]),'Live30/60/144Hz input, fire, pause, fresh reload, sleep, enemy damage/RNG and fatal exits yield identical complete campaign state');
    assert(errors.length===0,'No uncaught browser errors');
    return {browser:browser.version(),checks:checks.length,results:checks,errors,fixture:'declared working equipment, contact and fatal setup; live UI actions, due clocks and explicit saved-point recovery'};
  } catch(error) {return {browser:browser.version(),checks:checks.length,results:checks,errors,failures:[error.stack||error.message]}}
  finally {await context.close()}
}
