#!/usr/bin/env python3
"""Capture the declared rare dialogue branch through the original zero-divisor trap."""
import argparse,json,sys,time
from pathlib import Path
root=Path(__file__).resolve().parents[2];sys.path.insert(0,str(root/'tools/remake'))
from capture_salvage_reference import Console
p=argparse.ArgumentParser();p.add_argument('--output-dir',type=Path,required=True);p.add_argument('--rompath',type=Path,required=True);args=p.parse_args();out=args.output_dir.resolve()
if out.exists():p.error('output directory must be new')
c=Console(out,args.rompath.resolve())
try:
 c.wait(lambda:'[MAME]' in c.buffer,'console startup')
 helper=Path.home()/'.codex/skills/a2skills/a2-mame/scripts/control.lua'
 c.command(f'a2=dofile({json.dumps(str(helper))});a2.call("load","status")','load');c.call('devices','devices');c.call('boot-go','go')
 c.wait(lambda:'R10_BOOT_PAUSED' in c.buffer,'recorded boot pause',timeout=60)
 loader=out/'refs.lua';loader.write_text('\n'.join('dofile('+json.dumps(str(root/'tools/remake'/f))+')' for f in ['encounter_reference.lua','ground_reference.lua','tactical_reference.lua','tactical_input_reference.lua','recovery_reference.lua'])+'\na2.call("refs","status")\n')
 c.command('dofile('+json.dumps(str(loader))+')','refs');c.refs_loaded=True
 start=len(c.buffer);c.call('contact','spaceContact',str(out/'contact'));c.wait(lambda:'R10_PROBE ' in c.buffer[start:],'contact macro')
 bp=c.source_breakpoint('main-bp',0x1388);c.capture('main',0x1388);c.call('main-clear','clear_breakpoint',bp);c.breakpoints.remove(bp)
 c.call('comm-entry','recoveryCommSetup',str(out/'comm-entry.json'))
 bp=c.source_breakpoint('comm-store-bp',0x1320);c.capture('comm-store',0x1320);c.call('comm-store-clear','clear_breakpoint',bp);c.breakpoints.remove(bp)
 helper=root/'tools/remake/reward_reference.lua'
 c.command('dofile('+json.dumps(str(helper))+');a2.call("reward-refs","status")','reward-refs')
 def capture(name,offset):
  bp=c.call(name+'-bp','rewardBreakpoint',offset)['id'];c.breakpoints.append(bp);c.call(name+'-go','go');deadline=time.monotonic()+30
  while True:
   status=c.call(name+'-status-'+str(len(c.receipts)),'status')
   if status['debugger']=='stop':break
   if time.monotonic()>deadline:
    c.call(name+'-pause','pause')
    diagnostic=out/'diagnostic.lua';diagnostic.write_text('emu.pause();local j=require(\'json\');local ok,ctx=pcall(a2.groundSourceContext);local f=assert(io.open('+json.dumps(str(out/'diagnostic.json'))+',\'w\'));f:write(j.stringify({source=ok and ctx or nil,error=not ok and tostring(ctx) or nil,registers=a2.registers(),vm=a2.read(0x50,32),dictionary=a2.read(0x4a00,128)}));f:close();a2.call(\'diagnostic\',\'status\')')
    c.command('dofile('+json.dumps(str(diagnostic))+')','diagnostic');raise TimeoutError(name)
   c.pump()
  c.call(name+'-save','rewardSave',str(out/name),offset);c.call(name+'-clear','clear_breakpoint',bp);c.breakpoints.remove(bp)
 capture('reward-entry',0x1252);c.call('reward-setup','rewardSetup',str(out/'reward-setup.json'))
 for name,offset in [('rare',0x1368),('requested',0x137b),('bank-read',0x115c),('bank-loaded',0x115f),('header-test',0x0ee0),('header-return',0x0f69),('record',0x1163),('record-mode',0x0d7c),('zero-selector',0x0a34),('zero-modulus',0x0a36)]:capture(name,offset)
 bp=c.call('zero-error-bp','breakpoint',0xd7ed)['id'];c.breakpoints.append(bp)
 c.call('zero-error-go','go');deadline=time.monotonic()+30
 while True:
  status=c.call('zero-error-status-'+str(len(c.receipts)),'status')
  if status['debugger']=='stop':break
  if time.monotonic()>deadline:raise TimeoutError('zero-error')
  c.pump()
 c.call('zero-error-save','rewardSave',str(out/'zero-error'),0x0a36)
 c.call('zero-error-clear','clear_breakpoint',bp);c.breakpoints.remove(bp)
 c.call('error-go','go');deadline=time.monotonic()+1
 while time.monotonic()<deadline:c.pump()
 c.call('error-pause','pause')
 diagnostic=out/'diagnostic.lua';diagnostic.write_text('emu.pause();local j=require(\'json\');local f=assert(io.open('+json.dumps(str(out/'error.json'))+',\'w\'));f:write(j.stringify({source=a2.groundSourceContext(),registers=a2.registers(),vm=a2.read(0x50,32)}));f:close();assert(not manager.machine.screens[\':screen\']:snapshot('+json.dumps(str(out/'error.png'))+'));a2.call(\'error-save\',\'status\')')
 c.command('dofile('+json.dumps(str(diagnostic))+')','error-save')
finally:c.close()
