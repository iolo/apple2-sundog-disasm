// Declared carried-item fixture isolates engineering; every subsequent change uses UI.
// The source trader producer is covered by equipment-failures.js tests.
async browserPage => {
  const browser=browserPage.context().browser(),checks=[],errors=[];
  const context=await browser.newContext({viewport:{width:1280,height:720}});
  const page=await context.newPage();
  page.on('pageerror',e=>errors.push(e.message));page.on('dialog',d=>d.accept());
  const assert=(ok,name)=>{if(!ok)throw Error(name);checks.push(name)};
  const ready=()=>page.waitForFunction(()=>document.documentElement.dataset.ready==='true');
  const settled=()=>page.waitForFunction(()=>document.querySelector('#checkpoint-back')?.disabled===false);
  const state=()=>page.locator('#walk-screen').evaluate(el=>({...el.dataset}));
  const exportGame=async()=>{
    await page.locator(await page.locator('#equipment-panel').count()?'#equipment-saves':'#walk-saves').click();await settled();
    const pending=page.waitForEvent('download');await page.locator('#export-checkpoint').click();
    const download=await pending;let text='';
    for await(const part of await download.createReadStream())text+=part;
    await settled();await page.locator('#checkpoint-back').click();return JSON.parse(text);
  };
  const move=async(from,to)=>{
    await page.locator(from).click();await page.locator('#equipment-move').click();await page.locator(to).click();
  };
  const rating=()=>page.locator('.equipment-rating').innerText();
  let fixture=0;
  const importValue=async value=>{
    // Make a fixture file without accessing application state. The CLI sandbox
    // has no Node Buffer; download a Blob, then use the ordinary import control.
    const pending=page.waitForEvent('download');
    await page.evaluate(value=>{
      const url=URL.createObjectURL(new Blob([JSON.stringify(value)],{type:'application/json'}));
      const link=document.createElement('a');link.href=url;link.download='fixture.json';link.click();
      setTimeout(()=>URL.revokeObjectURL(url),1000);
    },value);
    const path=`output/playwright/remake/equipment-import-${++fixture}.json`;
    await (await pending).saveAs(path);
    await page.locator('#checkpoint-file').setInputFiles(path);await settled();
  };
  try {
    await page.addInitScript(()=>localStorage.setItem('sundog.locale','en'));await page.clock.install({time:new Date('2026-10-03T00:00:00Z')});await page.clock.pauseAt(new Date('2026-10-03T00:00:01Z'));
    await page.goto('http://127.0.0.1:8000/');await ready();
    const fixture=await page.evaluate(async()=>{
      const [{loadAssets},{campaignSaveCodec},{createCharacter}]=await Promise.all([import('/js/render/assets.js'),import('/js/core/campaign-saves.js'),import('/js/core/character.js')]);
      const a=await loadAssets(),codec=campaignSaveCodec(a.campaignContent,a.shipWalk,a.cityGeometry),s=codec.create({...createCharacter(),name:'Fault repair'},12345);
      s.ship.position={x:109,y:60};s.ship.inventory.carried=[156,28,23,0];return codec.make(s,0);
    });
    await page.locator('#campaign-saves').click();await settled();await importValue(fixture);await page.locator('#checkpoint-back').click();
    const initial=await exportGame();assert(initial.version===23&&initial.scope==='regional-flight-1','Version23 owns engineering failure progress');
    await page.locator('#walk-equipment').click();assert((await rating()).includes('14 / 16'),'Fixture starts with source-generated partial output');
    await move('#equipment-carried-0','#equipment-slot-0-0');assert((await page.locator('#equipment-message').innerText()).includes('Does not fit'),'Fault encoding cannot bypass socket fit');
    await move('#equipment-carried-0','#equipment-slot-0-1');
    assert((await rating()).includes('15 / 16')&&await page.locator('#equipment-move').isDisabled(),'Faulty installation briefly restores output and waits for its update');
    const pending=await exportGame();assert(pending.state.engineering.pendingFailures[0]===1&&pending.state.equipment[0].units[0].components[1]===156,'Pending save retains full faulty byte and source offset');
    assert(JSON.stringify(pending.state.ship.inventory.carried)==='[23,28,23,0]','The displaced shunt returns to the supplying pocket');
    await page.locator('#equipment-saves').click();await settled();await page.locator('#save-checkpoint-0').click();await settled();await page.clock.runFor(1000);await page.locator('#checkpoint-back').click();
    assert(JSON.stringify((await exportGame()).state)===JSON.stringify(pending.state),'Opening saves suspends the engineering update');
    await page.clock.runFor(300);assert((await rating()).includes('11 / 16')&&(await page.locator('#equipment-message').innerText()).includes('Component failed'),'Next engineering update burns out the faulty part and drops output');
    const failed=await exportGame();assert(failed.state.engineering.pendingFailures.every(n=>n===31)&&failed.state.equipment[0].units[0].components[1]===7,'Failure clears the pending target and stores destroyed-item7');
    assert(failed.state.ship.minutes===pending.state.ship.minutes&&JSON.stringify(failed.state.economy)===JSON.stringify(pending.state.economy)&&JSON.stringify(failed.state.encounters)===JSON.stringify(pending.state.encounters),'Failure does not invent a repair fee, game-time charge or random draw');
    for(const lang of ['en','ko']) {
      if(await page.locator('html').getAttribute('lang')!==lang)await page.locator('#equipment-language').click();
      for(const [width,height] of [[1280,720],[640,480],[390,844],[844,390]]) {
        await page.setViewportSize({width,height});await page.clock.runFor(100);await page.waitForFunction(()=>Math.abs(document.querySelector('#stage').getBoundingClientRect().width-Math.min(innerWidth,innerHeight*4/3))<1);
        assert(await page.locator('#equipment-panel').evaluate(root=>{const box=document.querySelector('#stage').getBoundingClientRect();return [...root.querySelectorAll('button,p,h2,h3,table,footer')].every(el=>{const b=el.getBoundingClientRect();return b.left>=box.left-1&&b.right<=box.right+1&&b.top>=box.top-1&&b.bottom<=box.bottom+1&&el.scrollWidth<=el.clientWidth+1})&&root.querySelector('.equipment-bottom').getBoundingClientRect().bottom<=root.querySelector('footer').getBoundingClientRect().top}),`${lang} failure, readiness and saves controls fit ${width}x${height}`);
      }
    }
    await page.screenshot({path:'output/playwright/remake/engineering-failure-ko.png'});await page.setViewportSize({width:1280,height:720});await page.clock.runFor(100);await page.locator('#equipment-language').click();
    await move('#equipment-slot-0-1','#equipment-carried-3');await move('#equipment-carried-1','#equipment-slot-0-1');
    const repaired=await exportGame();assert((await rating()).includes('15 / 16')&&repaired.state.ship.inventory.carried[3]===7&&repaired.state.equipment[0].units[0].components[1]===28,'Removing the destroyed part and installing a working replacement restores output');
    assert(JSON.stringify(repaired.state.start)===JSON.stringify(initial.state.start)&&JSON.stringify(repaired.state.resources)===JSON.stringify(initial.state.resources),'Repair preserves immutable creation and current hull/fuel');
    await page.locator('#equipment-saves').click();await settled();await page.locator('#save-checkpoint-1').click();await settled();await page.reload();await ready();await page.locator('#campaign-saves').click();await settled();await page.locator('#load-checkpoint-1').click();await settled();await page.locator('#checkpoint-back').click();
    assert(JSON.stringify((await exportGame()).state)===JSON.stringify(repaired.state),'Fresh-page reload retains the repaired system and displaced parts');
    await page.locator('#walk-saves').click();await settled();await page.locator('#load-checkpoint-0').click();await settled();await page.locator('#checkpoint-back').click();
    assert(JSON.stringify((await exportGame()).state)===JSON.stringify(pending.state),'Loading a pending save preserves its temporary output before frame entry');
    await page.locator('#walk-equipment').click();assert(JSON.stringify((await exportGame()).state)===JSON.stringify(failed.state),'Opening the pending frame resolves the fault with canonical output');
    await page.locator('#equipment-saves').click();await settled();const malformed=structuredClone(pending);malformed.state.engineering.pendingFailures[0]=31;await importValue(malformed);
    assert((await page.locator('#checkpoint-message').innerText()).includes('Invalid'),'Unmatched encoded component import is rejected');await page.locator('#checkpoint-back').click();assert(JSON.stringify((await exportGame()).state)===JSON.stringify(failed.state),'Rejected imports leave the live state untouched');
    await page.locator('#equipment-saves').click();await settled();const old=structuredClone(repaired);old.version=18;delete old.state.regional;delete old.state.flight;delete old.state.ground;delete old.state.pod?.occupied;delete old.state.machinery;old.scope='landed-depot-1';delete old.state.engineering;await importValue(old);
    assert((await page.locator('#checkpoint-message').innerText()).includes('imported'),'Version18 repaired equipment imports through normal controls');await page.locator('#checkpoint-back').click();assert(JSON.stringify((await exportGame()).state)===JSON.stringify(repaired.state),'Migration preserves resources, repaired equipment and inventory');
    assert(errors.length===0,'No uncaught engineering failure errors');return {browser:browser.version(),checks,errors};
  } catch(error) {await page.screenshot({path:'output/playwright/remake/engineering-failure-error.png'});throw Error(`${error.message}; last check: ${checks.at(-1)}`)}
  finally {await context.close()}
}
