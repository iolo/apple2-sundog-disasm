async browserPage => {
  const browser=browserPage.context().browser(),checks=[],errors=[];
  const context=await browser.newContext({viewport:{width:640,height:480}}),page=await context.newPage();
  page.on('pageerror',error=>errors.push(error.message));
  const assert=(value,name)=>{if(!value)throw Error(name);checks.push(name)};
  try {
    await page.goto('http://127.0.0.1:8000/');
    await page.waitForFunction(()=>document.documentElement.dataset.ready==='true');
    // Declared isolated dialogue fixture: source setup, runner and real panel.
    // This does not import an encounter into the live campaign.
    await page.evaluate(async()=>{
      const [{startEncounterDialogue,restoreEncounterDialogue,advanceEncounterDialogue},{dialoguePanel},{translator}]=await Promise.all([
        import('/js/core/encounter-dialogue.js'),import('/js/ui/dialogue.js'),import('/js/ui/i18n.js')]);
      const [scripts,text,items,systems,catalog,en,ko]=await Promise.all([
        'data/dialogue.json','data/dialogue-text.json','data/items.json','data/dialogue-systems.json',
        'data/catalog.json','locales/en.json','locales/ko.json'].map(path=>fetch(path).then(response=>response.json())));
      const content={scripts,text,items},assets={campaignContent:{dialogue:content},catalog};
      const old=document.querySelector('#interface'),ui=old.cloneNode(false);old.replaceWith(ui);
      let locale='en',setup,result,saved;
      const render=()=>{
        document.documentElement.lang=locale;
        ui.innerHTML=result.outcome ? '<p id="encounter-return">Returned</p>' : dialoguePanel({frame:result.conversation,assets,t:translator({en,ko},locale),locale,encounter:true});
      };
      ui.addEventListener('click',event=>{
        const button=event.target.closest('button');if(!button)return;
        let input;
        if(button.id==='dialogue-language'){locale=locale==='en'?'ko':'en';render();return}
        if(button.id==='dialogue-saves') {
          saved=JSON.stringify(result.record);
          result.conversation=restoreEncounterDialogue(content,setup,JSON.parse(saved),{randomState:result.conversation.randomState});
          render();return;
        }
        if(button.dataset.dialogueReply!==undefined)input={type:'reply',slot:Number(button.dataset.dialogueReply)};
        else if(button.dataset.dialoguePurchase!==undefined)input={type:'purchase',slot:Number(button.dataset.dialoguePurchase)};
        else if(button.dataset.dialogue)input={type:button.dataset.dialogue};
        if(input){result=advanceEncounterDialogue(content,setup,result.record,input);render()}
      });
      window.encounterFixture={
        open(kind,language='en',seed=12345,sceneMiddle=3) {
          locale=language;saved=null;
          setup={kind,system:systems.systems[0],attributes:[90,80,50,50,40],carried:[12,75,0,0],
            flags:Array(128).fill(false),workspace:{lastCity:0,mood:sceneMiddle===1?0:3,quantity:1,gate:0,item:0,actor:0},
            city:sceneMiddle===1?0:1,hour:4,surface:{x:10,y:6},cash:500,bankBalance:20000,colonyProgress:0,
            sceneMiddle,randomState:seed};
          result=startEncounterDialogue(content,setup);render();
        },
        get state(){return structuredClone(result)},get saved(){return saved},
      };
    });
    const open=(kind,locale='en',seed=12345,sceneMiddle=3)=>page.evaluate(args=>window.encounterFixture.open(...args),[kind,locale,seed,sceneMiddle]);
    const state=()=>page.evaluate(()=>window.encounterFixture.state);
    for(const [width,height] of [[640,480],[390,844],[844,390],[1920,1080]]) {
      await page.setViewportSize({width,height});
      await page.waitForFunction(()=>Math.abs(document.querySelector('#stage').getBoundingClientRect().width-Math.min(innerWidth,innerHeight*4/3))<1);
      for(const locale of ['en','ko'])for(const [kind,scene] of [[15,3],[16,3],[18,3],[19,3],[19,1],[22,3]]) {
        await open(kind,locale,12345,scene);
        const fit=await page.locator('#dialogue-panel').evaluate(panel=>{
          const r=panel.getBoundingClientRect();
          return r.left>=0&&r.top>=0&&r.right<=innerWidth+1&&r.bottom<=innerHeight+1&&panel.scrollWidth<=panel.clientWidth+1&&document.documentElement.scrollWidth<=innerWidth;
        });assert(fit,`Source kind${kind}/scene${scene} ${locale} panel fits ${width}x${height}`);
        const message=await page.locator('#dialogue-text').innerText();
        assert(locale==='en' ? /[a-z]/i.test(message) : /[가-힣]/.test(message),`Source kind${kind}/scene${scene} ${locale} message renders at ${width}x${height}`);
      }
    }
    await page.setViewportSize({width:390,height:844});await open(16,'ko');
    await page.screenshot({path:'output/playwright/remake/r10f-mugger-ko-390.png'});
    await page.locator('#dialogue-reply-0').click();
    const pending=JSON.stringify(await state());await page.locator('#dialogue-language').click();await page.locator('#dialogue-saves').click();
    assert(JSON.stringify(await state())===pending,'Locale switch and JSON replay preserve pending surrender, text and RNG');
    await page.locator('#dialogue-cancel').click();assert((await state()).outcome.flags[48],'Agree returns source surrender flag48');
    await open(16);await page.locator('#dialogue-reply-1').click();await page.locator('#dialogue-cancel').click();
    assert(!(await state()).outcome.flags.slice(48,51).some(Boolean),'Refuse returns hostile ground flags');
    await open(19,'ko',12345,1);await page.locator('#dialogue-reply-0').click();await page.locator('#dialogue-continue').click();
    const agree=(await state()).outcome;assert(agree.flags[51]&&agree.cash===500&&agree.bankBalance===20000,'Space Agree requests a cargo deadline without money transfer');
    await open(19);await page.locator('#dialogue-reply-2').click();await page.locator('#dialogue-continue').click();
    const fuel=(await state()).outcome;assert(fuel.cash===500&&fuel.bankBalance===16168&&fuel.flags[51],'Fuel response returns one bank debit with source flag51');
    await open(18);await page.locator('#dialogue-reply-1').click();await page.locator('#dialogue-continue').click();
    assert((await state()).outcome.cash===463,'Visitor payment debits only personal cash');
    await page.setViewportSize({width:640,height:480});await open(15,'ko',1);
    const cash=(await state()).conversation.state.locals[104];await page.locator('#dialogue-reply-2').click();
    assert(await page.locator('[data-dialogue-purchase="0"]').isDisabled(),'Gift cannot replace occupied carried slot');
    const giftBefore=JSON.stringify(await state());await page.locator('#dialogue-saves').click();
    assert(JSON.stringify(await state())===giftBefore,'Selected gift survives JSON replay without reroll');
    await page.screenshot({path:'output/playwright/remake/r10f-gift-ko-640.png'});
    await page.locator('[data-dialogue-purchase="2"]').click();const gift=(await state()).outcome;
    assert(gift.carried[2]===237&&gift.cash===cash,'Empty-slot transfer accepts the charged gift for zero credits');
    return {browser:browser.version(),fixture:'isolated source encounter dialogue; no live campaign import',checks:checks.length,results:checks,errors};
  } finally {await context.close()}
}
