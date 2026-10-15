// Read-only remaining phase-eight market scouting from the latest paid delivery.
async browserPage => {
  const browser=browserPage.context().browser(),checks=[],errors=[];
  const context=await browser.newContext({viewport:{width:1280,height:720}}),page=await context.newPage();
  page.on('pageerror',e=>errors.push(e.stack||e.message));page.on('dialog',d=>d.accept());
  const assert=(ok,name)=>{if(!ok)throw Error(name);checks.push(name)};
  const ready=()=>page.waitForFunction(()=>document.documentElement.dataset.ready==='true');
  const settled=()=>page.waitForFunction(()=>document.querySelector('#checkpoint-back')?.disabled===false);
  try {
    await page.addInitScript(()=>localStorage.setItem('sundog.locale','en'));
    await page.goto('http://127.0.0.1:8000/');await ready();
    await page.locator('#create-character').click();await page.locator('#character-name').fill('Import shell');
    await page.locator('#prepare-campaign').click();await page.locator('#campaign-seed').fill('1');await page.locator('#start-campaign').click();
    await page.locator('#walk-saves').click();await settled();
    await page.locator('#checkpoint-file').setInputFiles('output/playwright/remake/r11-phase-eight-city50-good02-market.json');
    await page.waitForFunction(()=>/imported/i.test(document.querySelector('#checkpoint-message')?.textContent||''));
    const pending=page.waitForEvent('download');await page.locator('#export-checkpoint').click();
    const download=await pending;let raw='';for await(const chunk of await download.createReadStream())raw+=chunk;
    const saved=JSON.parse(raw).state;
    assert(saved.colony.activePhase===8&&saved.colony.receipts.length===50,'The read-only market plan starts at the refreshed city-50 exchange');
    const plan=await page.evaluate(async s=>{
      const {loadAssets}=await import('/js/render/assets.js'),assets=await loadAssets();
      const {quoteExchangeCargo,exchangeLocation}=await import('/js/core/exchange.js');
      const result={};
      for(const n of [2,4,5]){
        const rows=[];
        for(const city of s.regional.cities){
          const market=city.market,supply=market.supply[n-1];if(supply===0)continue;
          const location=exchangeLocation(assets.campaignContent.exchange,market.cityId);
          const price=quoteExchangeCargo({commodityId:`cargo-${String(n).padStart(2,'0')}`,quality:1},
            {market,location,items:assets.campaignContent.dialogue.items});
          rows.push({cityId:market.cityId,worldId:location.worldId,systemId:location.systemId,supply,price});
        }
        result[n]=rows.sort((a,b)=>a.price-b.price||a.cityId.localeCompare(b.cityId)).slice(0,12);
      }
      return result;
    },saved);
    assert(Object.values(plan).every(rows=>rows.length>0),'Each phase-eight good has at least one initialized supplier');
    assert(errors.length===0,'No page errors during read-only market scouting');
    return{browser:browser.version(),checks,errors,failures:[],journey:{plan,accounts:saved.economy.accounts}};
  }catch(error){return{browser:browser.version(),checks,errors,failures:[error.stack||error.message]}}
  finally{await context.close()}
}
