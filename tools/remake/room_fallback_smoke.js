// Controlled street RNG enters through ordinary UI; no live state is patched.
async browserPage => {
  const browser=browserPage.context().browser(),checks=[],errors=[];
  const context=await browser.newContext({viewport:{width:1280,height:720}}),page=await context.newPage();
  page.on('pageerror',e=>errors.push(e.message));page.on('dialog',d=>d.accept());
  const assert=(ok,name)=>{if(!ok)throw Error(name);checks.push(name)};
  const ready=()=>page.waitForFunction(()=>document.documentElement.dataset.ready==='true');
  const settled=()=>page.waitForFunction(()=>document.querySelector('#checkpoint-back')?.disabled===false);
  const state=()=>page.locator('#walk-screen').evaluate(el=>({...el.dataset}));
  const saves=async()=>{await page.locator(await page.locator('#dialogue-panel').count() ? '#dialogue-saves' : '#walk-saves').click();await settled()};
  const exported=async()=>{
    await saves();const pending=page.waitForEvent('download');await page.locator('#export-checkpoint').click();
    let text='';for await(const part of await (await pending).createReadStream())text+=part;
    await settled();await page.locator('#checkpoint-back').click();return JSON.parse(text);
  };
  const walk=async(x,y)=>{
    if((await state()).paused==='true')await page.locator('#walk-pause').click();
    const box=await page.locator('#stage').boundingBox();
    await page.mouse.move(box.x+(145+(x+3.25)*2.5)*box.width/640,box.y+(126+(y-2.75)*2.5)*box.height/480);
    await page.mouse.down();await page.clock.runFor(3500);await page.mouse.up();
    const s=await state();assert(Number(s.x)===x&&Number(s.y)===y,`Walk reaches ${x},${y} in room${s.room}`);
  };
  try {
    await page.addInitScript(()=>localStorage.setItem('sundog.locale','en'));
    await page.clock.install();await page.goto('http://127.0.0.1:8000/');await ready();
    for(const [type,street,target] of [[10,{x:311,y:267},{x:14,y:71}],[9,{x:395,y:300},{x:97,y:56}]]) {
      const pending=page.waitForEvent('download');
      await page.evaluate(async street=>{
        const [{loadAssets},{campaignSaveCodec},{createCharacter}]=await Promise.all([
          import('/js/render/assets.js'),import('/js/core/campaign-saves.js'),import('/js/core/character.js')]);
        const assets=await loadAssets(),codec=campaignSaveCodec(assets.campaignContent,assets.shipWalk,assets.cityGeometry);
        const state=codec.create({...createCharacter(),name:'Fallback visit'},12345);
        state.ship.position={x:54,y:118};state.travel={scene:'city',cityPosition:street};state.encounters.randomState=0;
        const a=document.createElement('a');a.href=URL.createObjectURL(new Blob([JSON.stringify(codec.make(state,0))],{type:'application/json'}));
        a.download='fallback-street.json';a.click();
      },street);
      await (await pending).saveAs('output/playwright/remake/fallback-street.json');
      if(type===10){await page.locator('#campaign-saves').click();await settled()}else await saves();
      await page.locator('#checkpoint-file').setInputFiles('output/playwright/remake/fallback-street.json');await settled();await page.locator('#checkpoint-back').click();
      await page.locator('#walk-airlock').click();
      const entered=await exported();
      assert((await state()).scene==='room',`Type${type} accepts entry after all visitor placements fail`);
      assert(entered.state.encounters.roomState.actors.length===1&&entered.state.encounters.roomState.actors[0].slot===0,`Type${type} retains the staff member without inventing a visitor`);
      assert(entered.state.encounters.randomState===0,`Type${type} preserves the zero RNG fixed point`);
      await walk(target.x,target.y);await page.locator('#walk-talk').click();await page.clock.runFor(2000);await page.locator('#dialogue-panel').waitFor();
      assert((await page.locator('#dialogue-text').innerText()).includes('What can'),`Type${type} fallback staff serve the player`);
      const saved=await exported();await saves();await page.locator('#save-checkpoint-0').click();await settled();
      await page.reload();await ready();await page.locator('#campaign-saves').click();await settled();await page.locator('#load-checkpoint-0').click();await settled();await page.locator('#checkpoint-back').click();
      assert(JSON.stringify((await exported()).state)===JSON.stringify(saved.state),`Type${type} staff-only conversation survives IndexedDB save and page reload`);
      await page.locator('#dialogue-cancel').click();await walk(12,56);await page.locator('#walk-airlock').click();
      const left=await exported();assert(left.state.travel.scene==='city'&&JSON.stringify(left.state.travel.cityPosition)===JSON.stringify(street),`Type${type} returns to the same street doorway`);
      await page.locator('#walk-airlock').click();assert((await state()).scene==='room',`Type${type} can be entered again with the same fixed-point RNG`);
      await page.locator('#walk-airlock').click();
    }
    assert(errors.length===0,'No uncaught browser errors');
    return {browser:browser.version(),checks,errors};
  } finally {await context.close()}
}
