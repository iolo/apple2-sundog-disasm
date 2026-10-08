// Controlled actual-map imports isolate live encounter integration. All
// production, dialogue, movement, shots, returns and saves use ordinary UI.
// This does not replace the fresh-character campaign acceptance gate.
async browserPage => {
  const browser=browserPage.context().browser(),checks=[],errors=[];
  const context=await browser.newContext({viewport:{width:1280,height:720},hasTouch:true}),page=await context.newPage();
  page.on('pageerror',error=>errors.push(error.stack||error.message));page.on('dialog',dialog=>dialog.accept());
  const assert=(value,name)=>{if(!value)throw Error(name);checks.push(name)};
  const ready=()=>page.waitForFunction(()=>document.documentElement.dataset.ready==='true');
  const settled=()=>page.waitForFunction(()=>document.querySelector('#checkpoint-back')?.disabled===false);
  const state=()=>page.locator('#walk-screen').evaluate(el=>({...el.dataset}));
  const saves=async()=>{await page.locator(await page.locator('#dialogue-panel').count()?'#dialogue-saves':await page.locator('.sleep-panel').count()?'#sleep-saves':'#walk-saves').click();await settled()};
  const exported=async()=>{
    await saves();const pending=page.waitForEvent('download',{timeout:5000});await page.locator('#export-checkpoint').click();
    let text='';for await(const part of await(await pending).createReadStream())text+=part;
    await settled();await page.locator('#checkpoint-back').click();return JSON.parse(text);
  };
  const imported=async value=>{
    if(!await page.locator('#checkpoint-screen').isVisible())await saves();const pending=page.waitForEvent('download');
    await page.evaluate(value=>{const link=document.createElement('a');link.href=URL.createObjectURL(new Blob([JSON.stringify(value)],{type:'application/json'}));link.download='ground-fixture.json';link.click()},value);
    await(await pending).saveAs('output/playwright/remake/ground-fixture.json');
    await page.locator('#checkpoint-file').setInputFiles('output/playwright/remake/ground-fixture.json');await settled();
    const message=await page.locator('#checkpoint-message').innerText();
    if(!/imported|가져왔습니다/i.test(message))throw Error('Import failed: '+message+'; '+errors.join('; '));
    await page.locator('#checkpoint-back').click();
  };
  const reloaded=async()=>{
    const before=await exported();await saves();await page.locator('#save-checkpoint-0').click();await settled();
    await page.reload();await ready();await page.locator('#campaign-saves').click();await settled();
    await page.locator('#load-checkpoint-0').click();await settled();await page.locator('#checkpoint-back').click();
    assert(JSON.stringify((await exported()).state)===JSON.stringify(before.state),'Fresh page reconstructs exact encounter campaign state');return before;
  };
  const run=async milliseconds=>{if((await state()).paused==='true')await page.locator('#walk-pause').click();await page.clock.runFor(milliseconds)};
  const point=async(x,y)=>{const box=await page.locator('#stage').boundingBox();await page.mouse.move(box.x+(145+(x+.25)*1.25)*box.width/640,box.y+(126+(y+.25)*1.25)*box.height/480)};
  const fixture=async(original,seed=10804,equipped=false)=>page.evaluate(async({original,seed,equipped})=>{
    const value=structuredClone(original),s=value.state;
    s.ship.position={x:54,y:118};s.travel={scene:'city',cityPosition:{x:392,y:288}};s.ground.camera={x:9,y:6};s.encounters.randomState=seed;
    s.combat={...(await import('/js/core/campaign-combat.js')).initialCampaignCombat()};
    if(equipped)s.ship.inventory=(await import('/js/core/inventory.js')).transferItem(s.ship.inventory,{container:'stores',index:11},{container:'carried',index:0},{x:54,y:83});
    return value;
  },{original,seed,equipped});
  const catchEncounter=async value=>{
    await imported(value);await run(800);assert((await state()).encounter==='chase','Actual due clock starts the live city chase');
    await run(6000);assert((await state()).encounter==='dialogue','Catch opens mandatory dialogue before combat');
  };
  const activation=async value=>page.evaluate(async value=>{
    const [{loadAssets},{createGroundWorld},{regionalGroundStart},{restoreCampaignGroundHost}]=await Promise.all([
      import('/js/render/assets.js'),import('/js/core/campaign-ground.js'),import('/js/core/regional-world.js'),import('/js/core/ground-host.js')]);
    const a=await loadAssets(),world=createGroundWorld({...a.campaignContent,...a.campaignContent.ground},regionalGroundStart(value.state));
    return restoreCampaignGroundHost(value.state,world,a.campaignContent).encounter.activation;
  },value);
  try {
    await page.addInitScript(()=>localStorage.setItem('sundog.locale','en'));
    await page.clock.install({time:new Date('2026-10-07T00:00:00Z')});await page.clock.pauseAt(new Date('2026-10-07T00:00:01Z'));
    await page.goto('http://127.0.0.1:8000/');await ready();
    await page.locator('#create-character').click();await page.locator('#character-name').fill('Ground pilot');
    await page.locator('#prepare-campaign').click();await page.locator('#campaign-seed').fill('12345');await page.locator('#start-campaign').click();
    const original=await exported();assert(original.version===29&&original.scope==='ship-salvage-1','Live asset loader retains ground encounters in version29');
    const baseline=await fixture(original);await imported(baseline);await run(500);
    const partial=await reloaded();assert(partial.state.combat.ground===null&&partial.state.combat.clock.iterations>0,'Partial due clock survives fresh-page load');
    await run(350);assert((await state()).encounter==='chase','Restored clock produces the chase without a new RNG seed');
    const chasing=await reloaded();assert(chasing.state.combat.ground.inputs.length>0,'Chase saves contain source tick inputs');
    const paused=JSON.stringify((await exported()).state);await page.clock.runFor(3000);
    assert(JSON.stringify((await exported()).state)===paused,'Paused chase freezes clock, actors and RNG');
    await run(2000);assert((await state()).dialogue==='65','Mandatory source threat entry65 renders');
    const talking=await reloaded();assert(talking.state.combat.ground.inputs.length>0,'Mandatory dialogue reconstructs from its encounter log');
    await page.locator('#dialogue-reply-0').click();await page.locator('#dialogue-cancel').click();
    assert((await state()).encounter==='combat','Agree returns to the existing live combat');
    assert(await page.locator('#walk-inventory').count()===0&&await page.locator('#walk-airlock').count()===0,'Encounter owns inventory and map return access');
    await reloaded();
    const suspended=JSON.stringify((await exported()).state);
    await page.locator('#walk-back').click();await page.locator('#explore').click();await page.locator('#begin-walk').click();
    assert((await state()).mode==='walk'&&(await state()).encounter===''&&await page.locator('#dialogue-panel').count()===0,'Standalone walkthrough keeps its own scene without a campaign encounter');
    await page.locator('#walk-back').click();await page.locator('#home').click();await page.locator('#resume-campaign').click();
    assert(JSON.stringify((await exported()).state)===suspended,'Title and standalone walkthrough preserve the suspended campaign encounter');
    await run(10000);
    const surrendered=await exported();assert(surrendered.state.combat.ground===null&&surrendered.state.dialogue.cash===0,'Surrender return commits robbery once');
    assert(JSON.stringify(surrendered.state.travel)===JSON.stringify(baseline.state.travel),'Surrender returns to the actual frozen city pose');
    await reloaded();assert((await exported()).state.dialogue.cash===0,'Reload does not repeat a terminal robbery');

    await imported(baseline);await run(800);await point(0,191);await page.mouse.down();await page.clock.runFor(4000);await page.mouse.up();
    const escaped=await exported();assert(escaped.state.combat.ground===null&&escaped.state.dialogue.cash===baseline.state.dialogue.cash,'Held pointer escapes the chase without a personal loss');
    await imported(baseline);await run(800);await page.locator('#walk-surface').focus();
    await page.keyboard.down('ArrowLeft');await page.keyboard.down('ArrowDown');await page.clock.runFor(4000);await page.keyboard.up('ArrowLeft');await page.keyboard.up('ArrowDown');
    const keyEscape=await exported();assert(keyEscape.state.combat.ground===null&&keyEscape.state.dialogue.cash===baseline.state.dialogue.cash,'Arrow-key movement escapes without changing the campaign return point');
    await catchEncounter(baseline);await page.locator('#dialogue-reply-0').click();await page.locator('#dialogue-cancel').click();
    await run(1);await page.locator('#walk-surface').focus();await page.keyboard.press('s');await page.clock.runFor(100);
    const cancelled=await exported();assert(cancelled.state.combat.ground.inputs.some(e=>e.type==='tick'&&e.control.cancelSurrender),'S records the actual cancel-surrender input');
    assert(!(await activation(cancelled)).combat.flags[48],'Cancel surrender clears the source flag on the existing activation');

    const armed=await fixture(original,10753,true);
    for(const method of ['space','right']) {
      await catchEncounter(armed);await page.locator('#dialogue-reply-2').click();await page.locator('#dialogue-cancel').click();await page.locator('#dialogue-cancel').click();
      const enemy=(await activation(await exported())).combat.actors[1];await run(1);await point(enemy[1]+3,enemy[0]-3);await page.locator('#walk-surface').focus();
      if(method==='space')await page.keyboard.down(' ');else await page.mouse.down({button:'right'});
      await page.clock.runFor(100);
      if(method==='space')await page.keyboard.up(' ');else await page.mouse.up({button:'right'});
      const fired=await exported();assert(fired.state.combat.ground.inputs.some(e=>e.type==='tick'&&e.control.fire),`${method} firing records a real source control tick`);
    }

    await catchEncounter(armed);
    await page.locator('#dialogue-reply-2').click();await page.locator('#dialogue-cancel').click();await page.locator('#dialogue-cancel').click();
    assert((await state()).encounter==='combat','Visitor refusal and threat return activate the same combat actors');
    for(const [width,height] of [[640,480],[390,844],[844,390],[1920,1080]])for(const locale of ['en','ko']) {
      await page.setViewportSize({width,height});await page.clock.runFor(50);
      if(await page.locator('html').getAttribute('lang')!==locale)await page.locator('#walk-language').click();
      const fit=await page.locator('.walk-actions').evaluate(el=>[...el.querySelectorAll('button')].every(button=>{
        const r=button.getBoundingClientRect();return r.left>=0&&r.right<=innerWidth+1&&r.top>=0&&r.bottom<=innerHeight+1;
      }));assert(fit,`${locale} combat actions fit ${width}x${height}`);
      const helpBefore=JSON.stringify((await exported()).state);
      await page.locator('#walk-help').click();assert((await page.locator('.help').innerText()).includes('Space'),`${locale} help explains firing`);
      await page.clock.runFor(3000);
      await page.locator('#walk-close-help').click();
      assert(JSON.stringify((await exported()).state)===helpBefore,'Help/save overlays freeze the combat');
    }
    await page.setViewportSize({width:390,height:844});await page.screenshot({path:'output/playwright/remake/r10h-ground-combat-ko-390.png'});
    await page.setViewportSize({width:1280,height:720});
    for(let count=0;count<80&&(await state()).encounter==='combat';count++) {
      const saved=await exported(),enemy=(await activation(saved)).combat.actors[1];
      if(!enemy)break;
      if(count===0){await page.locator('#combat-mode').click();assert(await page.locator('#combat-mode').getAttribute('aria-pressed')==='true','Touch aim mode toggles independently of campaign state')}
      await run(1);await point(enemy[1]+3,enemy[0]-3);await page.locator('#walk-surface').focus();
      // Aim-mode pointer firing follows the same held control as Space/right click.
      await page.mouse.down();await page.clock.runFor(50);await page.mouse.up();
    }
    assert((await state()).encounter==='dialogue','Owned laser shots reach post-fight conversation');
    const won=await reloaded();assert(won.state.combat.ground.inputs.some(e=>e.type==='tick'&&e.control.fire),'Real aim/fire controls persist in the replay');
    assert((await state()).dialogue==='51','Winning opens source post-fight entry51');
    await page.locator('#dialogue-cancel').click();const reward=await exported();
    assert(reward.state.combat.rewards.length===1&&reward.state.dialogue.cash>armed.state.dialogue.cash,'Post-fight return commits one source-quoted cash reward');
    assert(reward.state.ship.inventory.stores[11]===0&&reward.state.ship.inventory.carried[0]===12,'Winning preserves the actual transferred laser owner');
    await reloaded();assert((await exported()).state.dialogue.cash===reward.state.dialogue.cash,'Fresh-page reward restore grants no duplicate income');

    // Actual source knockout supplies the later injury; only gate seeds and
    // initial map placement are controlled, never actors or damage results.
    await catchEncounter(baseline);await page.locator('#dialogue-cancel').click();await page.locator('#dialogue-cancel').click();await run(10000);
    const injured=await exported();assert(injured.state.ship.condition.health===51,'Unarmed source fight returns a living injured survivor');
    const later=await fixture(injured,10753);await catchEncounter(later);
    await page.locator('#dialogue-reply-2').click();await page.locator('#dialogue-cancel').click();await page.locator('#dialogue-cancel').click();await run(10000);
    assert((await state()).dead==='true','Fatal source damage opens the live death scene');
    const dead=await reloaded();assert(dead.state.combat.defeat.reason==='groundDeath'&&dead.state.ship.condition.health===0&&dead.state.ship.condition.vigor===0,'Death saves retain source condition and durable reason');
    const deadBefore=JSON.stringify(dead.state);await page.clock.runFor(5000);assert(JSON.stringify((await exported()).state)===deadBefore,'Death scene cannot restart movement or time');
    // Exercise the actual UI loop with explicit browser display-timer shims;
    // no game reducer/state is replaced. Absolute time, not rounded frame
    // duration, must own the host's50ms iteration remainder.
    await page.addInitScript(()=>{
      const hz=Number(localStorage.getItem('ground-test-hz'));
      if([30,60,144].includes(hz)) {
        window.requestAnimationFrame=callback=>setTimeout(()=>callback(performance.now()),1000/hz);
        window.cancelAnimationFrame=id=>clearTimeout(id);
      }
    });
    const refresh=[];
    for(const hz of [30,60,144]) {
      await page.evaluate(hz=>localStorage.setItem('ground-test-hz',hz),hz);await page.reload();await ready();
      await page.locator('#campaign-saves').click();await settled();await imported(baseline);await run(3000);
      assert((await state()).encounter==='dialogue',`${hz}Hz UI reaches mandatory dialogue from the actual due clock`);
      refresh.push((await exported()).state);
    }
    assert(JSON.stringify(refresh[0])===JSON.stringify(refresh[1])&&JSON.stringify(refresh[1])===JSON.stringify(refresh[2]),'Live30/60/144Hz display loops yield identical campaign, replay inputs and RNG');
    const inputRates=[],movingFixture=await fixture(original,12345);
    for(const hz of [30,60,144]) {
      await page.evaluate(hz=>localStorage.setItem('ground-test-hz',hz),hz);await page.reload();await ready();
      await page.locator('#campaign-saves').click();await settled();await imported(movingFixture);await run(0);
      await page.locator('#walk-surface').focus();await page.keyboard.down('ArrowRight');await page.clock.runFor(137);await page.keyboard.up('ArrowRight');
      const partial=await exported();assert(partial.state.combat.clock.elapsed===37,`${hz}Hz ground input/save retains the complete137ms budget`);
      await page.clock.runFor(1000);assert(JSON.stringify((await exported()).state)===JSON.stringify(partial.state),`${hz}Hz ground pause freezes every campaign owner`);
      await reloaded();await run(0);const pose=await state();
      await point(Number(pose.x)-Number(pose.cameraX)*28+1,Number(pose.y)-Number(pose.cameraY)*32-3);
      await page.mouse.down();await page.clock.runFor(137);await page.mouse.up();
      const pointerPartial=await exported();assert(pointerPartial.state.combat.clock.elapsed===24,`${hz}Hz captured ground pointer preserves its partial budget after reload`);
      await reloaded();await run(0);await page.locator('#walk-surface').focus();await page.keyboard.down('ArrowDown');await page.clock.runFor(726);await page.keyboard.up('ArrowDown');
      const completed=await exported();assert(completed.state.combat.clock.elapsed===0,`${hz}Hz resumed ground controls consume exactly1000ms`);inputRates.push(completed.state);
    }
    assert(JSON.stringify(inputRates[0])===JSON.stringify(inputRates[1])&&JSON.stringify(inputRates[1])===JSON.stringify(inputRates[2]),'Live30/60/144Hz held ground keys, captured pointer, partial save, pause and fresh reload yield identical complete campaign state');
    assert(errors.length===0,'No uncaught browser errors');
    return {browser:browser.version(),fixture:'controlled actual-map placement and gate seeds; live controls, terminal outcomes and fresh-page saves',checks:checks.length,results:checks,errors};
  }finally{await context.close()}
}
