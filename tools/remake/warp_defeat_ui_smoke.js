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
  // Declared R10aa native pre-action hit, prepared through the live save codec.
  // Only the subsequent Warp/confirmation/recovery steps are ordinary UI actions.
  const fixture=async(original,phase=1)=>page.evaluate(async({original,phase})=>{
    const [{loadAssets},{campaignSaveCodec},{createInitialEquipment},{recalculateEquipment},{canStand,interactionAt},{reduceCampaignFlight}]=await Promise.all([
      import('/js/render/assets.js'),import('/js/core/campaign-saves.js'),import('/js/core/initialization.js'),import('/js/core/equipment.js'),import('/js/core/ship-walk.js'),import('/js/core/campaign-flight.js')]);
    const a=await loadAssets(),codec=campaignSaveCodec(a.campaignContent,a.shipWalk,a.cityGeometry);let s=structuredClone(original.state);
    s.equipment=createInitialEquipment({next:()=>1}).map(recalculateEquipment);
    for(let y=0;y<192;y++)for(let x=0;x<280;x++)if(canStand(a.shipWalk,{x,y})&&interactionAt({x,y})===1){s.ship.position={x,y};y=192;break}
    Object.assign(s.regional.shipLocation,{worldId:null,cityId:null,orbit:{angle:16,radius:43},surfacePosition:{x:0,y:0},cityPosition:{x:0,y:0},position:{x:0,y:0}});
    s.regional.podWorldId=null;s.ground.cityId=null;s.ground.podCityId=null;
    s.resources.hull=1;s.resources.fuel=228;s.resources.guns={charge:68,powered:false};s.resources.enginesPowered=false;s.resources.shields={charge:0,targetCharge:0};
    s.machinery.phase=phase;s.encounters.randomState=28;s.space.flags[40]=s.space.flags[41]=s.space.flags[45]=true;s.space.flags[44]=false;
    s.ship.minutes=1278;s.ship.condition={vigor:237,rest:235,health:255,nourishment:228};
    Object.assign(s.space.words,{205:512,206:512,207:0,208:0,209:0,214:1,215:44,216:200,217:5,354:3});
    s=reduceCampaignFlight(s,a.campaignContent,{type:'setWarp',systemId:'system-11'});s.resources.warp.charge=s.resources.warp.targetCharge;
    return codec.make(s,0);
  },{original,phase});
  const states=[];
  try {
    await page.addInitScript(()=>{if(!localStorage.getItem('sundog.locale'))localStorage.setItem('sundog.locale','en')});
    await page.clock.install({time:new Date('2026-10-08T00:00:00Z')});await page.clock.pauseAt(new Date('2026-10-08T00:00:01Z'));
    await page.goto('http://127.0.0.1:8000/');await ready();await page.locator('#create-character').click();
    await page.locator('#character-name').fill('Warp return');await page.locator('#prepare-campaign').click();await page.locator('#campaign-seed').fill('12345');await page.locator('#start-campaign').click();
    const original=await exported();
    for(const [locale,viewport,phase] of [['en',{width:1280,height:720},1],['ko',{width:390,height:844},1],['en',{width:1280,height:720},3]]) {
      const living=await fixture(original,phase),label=`${locale} phase${phase}`;
      await page.setViewportSize(viewport);await imported(living);
      if(await page.locator('html').getAttribute('lang')!==locale)await page.locator('#walk-language').click();
      await saves();await page.locator('#save-checkpoint-1').click();await settled();await page.locator('#checkpoint-back').click();
      await page.locator('#walk-navigation').click();assert(await page.locator('#nav-warp').isEnabled(),`${label}: real charged Warp control is enabled`);
      await page.locator('#nav-warp').click();const pending=await exported();
      assert(JSON.stringify(pending.state)===JSON.stringify(living.state),`${label}: review does not mutate the accepted source fixture`);
      await page.locator('#nav-confirm').click();
      assert((await ui()).dead==='true'&&await page.locator('.sleep-panel').isVisible(),`${label}: confirmed Warp fatal hit opens terminal recovery panel`);
      assert(await page.locator('#sleep-title').innerText()===(locale==='en'?'Ship destroyed':'함선 파괴'),`${label}: terminal heading is localized`);
      const dead=await reload(),d=dead.state;
      assert(await page.locator('html').getAttribute('lang')===locale,`${label}: terminal reload retains the selected language`);
      assert(d.resources.hull===0&&d.resources.guns.charge===60&&d.resources.fuel===228&&d.machinery.phase===(phase+3)%4,`${label}: fatal Warp commits source hull/gun/fuel/phase`);
      assert(d.space.words[215]===40&&d.space.words[217]===5&&d.space.words[354]===(phase===1?6:0)&&d.encounters.randomState===0xc387ee1f,`${label}: fatal Warp commits source cooldown/range/counter/RNG`);
      assert(d.ship.minutes===1278+(phase===1?0:1)&&JSON.stringify(d.ship.condition)===JSON.stringify(living.state.ship.condition),`${label}: Nav suffix retains the source clock/condition boundary`);
      assert(d.regional.shipLocation.systemId==='system-11'&&!d.space.flags[40]&&!d.space.flags[47]&&d.space.tactical===null&&d.space.elapsed===0,`${label}: jump completes before death without tactical startup`);
      assert(JSON.stringify(d.resources.warp)===JSON.stringify({charge:0,targetCharge:0,targetSystemId:null,charging:false})&&d.space.defeat.minutes===1278,`${label}: source Warp request clears and fatal minute is durable`);
      for(const key of ['start','equipment','pod','economy'])assert(JSON.stringify(d[key])===JSON.stringify(living.state[key]),`${label}: independent ${key} owner is preserved`);
      await page.screenshot({path:`output/playwright/remake/warp-defeat-${locale}-phase${phase}.png`,fullPage:true});
      await page.clock.runFor(5000);assert(JSON.stringify((await exported()).state)===JSON.stringify(d),`${label}: terminal elapsed time stays completely frozen after reload`);
      await saves();await page.locator('#load-checkpoint-1').click();await settled();await page.locator('#checkpoint-back').click();
      assert(JSON.stringify((await exported()).state)===JSON.stringify(living.state),`${label}: explicit earlier-slot recovery restores every living owner`);
      await page.locator('#walk-navigation').click();await page.locator('#nav-cancel-warp').click();
      const recovered=(await exported()).state;assert(!recovered.space.defeat&&recovered.resources.hull===1&&!recovered.resources.warp.charging,`${label}: recovered campaign accepts a new normal navigation action`);
      states.push({locale,phase,living:living.state,dead:d,recovered});
    }
    return {browser:browser.version(),scope:'Declared R10aa phase1 pre-action fatal-hit fixture in both locales, plus source-derived phase3 clock-crossing return; actual live Warp/confirm/terminal save/reload/earlier-slot recovery',checks,failures:[],errors,states};
  } catch(error) {return {browser:browser.version(),checks,failures:[error.stack||error.message],errors,states}} finally {await context.close()}
}
