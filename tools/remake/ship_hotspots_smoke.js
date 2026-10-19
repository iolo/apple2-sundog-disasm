// Cold-start Saves and walking-input Resume. Fixtures live only in an
// isolated browser context; loading, inventory and movement use ordinary UI.
async browserPage => {
  const context = await browserPage.context().browser().newContext({ viewport: { width: 1280, height: 720 } });
  const page = await context.newPage(), errors = [], checks = [];
  const assert = (ok, name) => { if (!ok) throw Error(name); checks.push(name); };
  page.on('pageerror', error => errors.push(error.message));
  page.on('dialog', dialog => dialog.accept());
  const ready = () => page.waitForFunction(() => document.documentElement.dataset.ready === 'true');
  const settled = () => page.waitForFunction(() => document.querySelector('#checkpoint-back')?.disabled === false);
  const state = () => page.locator('#walk-screen').evaluate(el => ({ ...el.dataset }));
  try {
    await page.addInitScript(() => localStorage.setItem('sundog.locale', 'en'));
    await page.clock.install({ time: new Date('2026-10-19T00:00:00Z') });
    await page.clock.pauseAt(new Date('2026-10-19T00:00:01Z'));
    await page.goto('http://127.0.0.1:8000/'); await ready();
    await page.locator('#campaign-saves').click();
    assert(await page.locator('#checkpoint-screen').isVisible(), 'Main-menu Saved games opens without an active campaign');
    await settled();
    assert(await page.locator('#checkpoint-title').innerText() === 'Saved games', 'Saved games shows its own title');
    assert(await page.locator('#save-checkpoint-0').isDisabled(), 'An unloaded campaign cannot be saved');
    assert(await page.locator('#walk-screen').evaluate(el => el.inert), 'The unloaded ship background cannot receive input');
    await page.locator('#checkpoint-back').click();
    assert(await page.locator('#walk-screen').isHidden() && await page.locator('#campaign-saves').isEnabled(), 'Back from empty Saved games returns to the main menu');

    await page.evaluate(async () => {
      const [{ loadAssets }, { campaignSaveCodec, openCampaignStore }, { createCharacter }] = await Promise.all([
        import('/js/render/assets.js'), import('/js/core/campaign-saves.js'), import('/js/core/character.js'),
      ]);
      const assets = await loadAssets(), codec = campaignSaveCodec(assets.campaignContent, assets.shipWalk, assets.cityGeometry);
      const store = await openCampaignStore(codec);
      try {
        for (const [slot, position] of [[0, { x: 54, y: 88 }], [1, { x: 82, y: 111 }]]) {
          const campaign = codec.create({ ...createCharacter(), name: 'Hotspot check' }, 12345);
          campaign.ship.position = position;
          await store.save(codec.make(campaign, slot));
        }
        const { groundCameraAt } = await import('/js/core/ground-camera.js');
        for(const [slot,scene,position] of [[2,'city',{x:311,y:267}],[3,'surface',{x:347,y:193}]]) {
          const campaign=codec.create({...createCharacter(),name:'Resume check'},12345);
          campaign.ship.position={x:54,y:118};
          campaign.travel={scene,cityPosition:position};
          if(scene==='surface') {
            campaign.ground.cityId=null;
            campaign.ground.colonyPosition={x:16,y:13};
            campaign.regional.colonyPosition={x:16,y:13};
          }
          campaign.ground.camera=groundCameraAt(position,scene==='surface');
          await store.save(codec.make(campaign,slot));
        }
      } finally { store.close(); }
    });

    for (const [slot, station, direction] of [[0, 'Ship’s stores', 'ArrowDown'], [1, 'Ship’s locker', 'ArrowLeft']]) {
      await page.reload(); await ready();
      await page.locator('#campaign-saves').click(); await settled();
      assert(await page.locator(`#load-checkpoint-${slot}`).isEnabled(), `${station} checkpoint is loadable from a fresh main menu`);
      await page.locator(`#load-checkpoint-${slot}`).click(); await settled();
      await page.locator('#checkpoint-back').click();
      assert((await state()).paused === 'true' && await page.locator('#walk-inventory').innerText() === station, `${station} checkpoint restores paused at its hotspot`);
      await page.locator('#walk-inventory').click();
      assert(await page.locator('#inventory-panel').isVisible(), `${station} inventory still opens`);
      const inventoryBox=await page.locator('#inventory-panel').boundingBox(),stageBox=await page.locator('#stage').boundingBox();
      assert(inventoryBox.width<stageBox.width*.7&&inventoryBox.height<stageBox.height*.8,`${station} opens a compact window over the ship`);
      await page.locator('#inventory-info').click();
      assert(await page.locator('#inventory-info-panel').isVisible()&&await page.locator('[role="meter"]').first().isVisible(),`${station} info exposes instructions and condition`);
      await page.keyboard.press('Escape');
      assert(await page.locator('#inventory-panel').isVisible()&&await page.locator('#inventory-info').evaluate(el=>el===document.activeElement),`${station} info closes without dismissing inventory`);
      await page.keyboard.press(direction); await page.clock.runFor(1200);
      assert((await state()).paused === 'true', `${station} inventory input does not resume the game`);
      await page.locator('#inventory-close').click();
      const before = await state();
      if(slot===0)await page.locator('#walk-pause').click();
      else await page.locator('#walk-surface').focus();
      await page.keyboard.down(direction); await page.clock.runFor(320); await page.keyboard.up(direction);
      await page.clock.runFor(1200);
      const after = await state();
      assert(after.paused === 'false' && (before.x !== after.x || before.y !== after.y), `${slot===0?'Resume button':'Arrow input'} at ${station} restarts movement`);
      assert(Number(after.minutes) > Number(before.minutes), `Resume at ${station} restarts the game clock`);
      await page.locator('#walk-pause').click();
      const paused = await state(); await page.clock.runFor(1200);
      assert((await state()).minutes === paused.minutes, `Pause after leaving ${station} stops the clock`);
    }
    for(const slot of [2,3]) {
      await page.reload(); await ready();
      await page.locator('#campaign-saves').click(); await settled();
      await page.locator(`#load-checkpoint-${slot}`).click(); await settled();
      await page.locator('#checkpoint-back').click();
      if(slot===2) {
        const streetPixels=await page.locator('#walk-screen canvas').evaluate(canvas=>{
          const scale=canvas.width/640;
          return [...canvas.getContext('2d').getImageData(42*scale,46*scale,160*scale,80*scale).data];
        });
        await page.locator('#walk-airlock').click();
        assert((await state()).scene==='room'&&(await state()).paused==='true','Building entry remains paused');
        assert(await page.locator('#walk-screen canvas').evaluate((canvas,before)=>{
          const scale=canvas.width/640,pixels=canvas.getContext('2d').getImageData(42*scale,46*scale,160*scale,80*scale).data;
          return pixels.every((value,index)=>value===before[index]);
        },streetPixels),'Entering a building preserves the city artwork behind its window');
        const roomBox=await page.locator('#walk-surface').boundingBox(),stageBox=await page.locator('#stage').boundingBox();
        assert(Math.abs(roomBox.width/stageBox.width-280/640)<.001&&Math.abs(roomBox.height/stageBox.height-192/480)<.001,'Interior retains half the source world width and height');
      }
      const before=await state();
      // Walk away from the room entrance / surface city boundary without Resume.
      await page.locator('#walk-surface').focus();
      const direction=slot===2?'ArrowRight':'ArrowDown';
      await page.keyboard.down(direction); await page.clock.runFor(200); await page.keyboard.up(direction);
      const after=await state();
      assert(after.paused==='false'&&(before.x!==after.x||before.y!==after.y),`${before.scene} walking input resumes and moves (${before.x},${before.y} → ${after.x},${after.y})`);
      if(slot===2) {
        const box=await page.locator('#walk-surface').boundingBox();
        await page.locator('#walk-pause').click();
        await page.mouse.move(box.x+(12+3)*box.width/140,box.y+(56-3)*box.height/96);
        await page.mouse.down(); await page.clock.runFor(800); await page.mouse.up();
        assert((await state()).paused==='false'&&await page.locator('#walk-airlock').isEnabled(),'Room pointer input resumes and reaches the exit');
        await page.locator('#walk-airlock').click();
        assert((await state()).scene==='city'&&(await state()).paused==='true','Building exit remains paused');
        await page.locator('#walk-surface').focus(); await page.keyboard.down('ArrowDown'); await page.clock.runFor(160); await page.keyboard.up('ArrowDown');
        assert((await state()).paused==='false','Walking input resumes after building exit');
      }
    }
    assert(errors.length === 0, `No browser errors: ${errors.join(', ')}`);
    return { passed: checks.length, checks };
  } finally { await context.close(); }
}
