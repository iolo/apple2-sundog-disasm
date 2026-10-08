#!/usr/bin/env python3
"""Capture a declared fatal Comm-dispatch return on copied IIe media."""
import argparse
import sys,json,time
from pathlib import Path
root=Path(__file__).resolve().parents[2]
sys.path.insert(0,str(root/'tools/remake'))
from capture_salvage_reference import Console
parser=argparse.ArgumentParser(description=__doc__)
parser.add_argument('--output-dir',required=True,type=Path)
parser.add_argument('--rompath',required=True,type=Path)
args=parser.parse_args()
out=args.output_dir.resolve()
if out.exists():parser.error('output directory must be new')
c=Console(out,args.rompath.resolve())
try:
 c.wait(lambda:'[MAME]' in c.buffer,'console startup')
 helper=Path.home()/'.codex/skills/a2skills/a2-mame/scripts/control.lua'
 c.command(f'a2=dofile({json.dumps(str(helper))});a2.call("load","status")','load')
 c.call('devices','devices');c.call('boot-go','go')
 c.wait(lambda:'R10_BOOT_PAUSED' in c.buffer,'recorded boot pause',timeout=60)
 loader=out/'refs.lua'
 loader.write_text('\n'.join('dofile('+json.dumps(str(root/'tools/remake'/f))+')' for f in ['encounter_reference.lua','ground_reference.lua','tactical_reference.lua','tactical_input_reference.lua','recovery_reference.lua'])+'\na2.call("refs","status")\n')
 c.command('dofile('+json.dumps(str(loader))+')','refs');c.refs_loaded=True
 start=len(c.buffer);c.call('contact','spaceContact',str(out/'contact'))
 c.wait(lambda:'R10_PROBE ' in c.buffer[start:],'contact macro completion')
 bp=c.source_breakpoint('main-bp',0x1388);c.capture('main',0x1388)
 c.call('main-clear','clear_breakpoint',bp);c.breakpoints.remove(bp)
 c.call('comm-entry','recoveryCommSetup',str(out/'comm-entry.json'))
 bp=c.source_breakpoint('comm-store-bp',0x1320);c.capture('comm-store',0x1320)
 c.call('comm-store-clear','clear_breakpoint',bp);c.breakpoints.remove(bp)
 def rb(name,seg,offset):
  bp=c.call(name+'-bp','recoverySourceBreakpoint',seg,offset)['id'];c.breakpoints.append(bp);return bp
 def capture(name,seg,offset):
  c.call(name+'-go','go');deadline=time.monotonic()+30
  while True:
   status=c.call(name+'-status-'+str(len(c.receipts)),'status')
   if status['debugger']=='stop':break
   if time.monotonic()>deadline:raise TimeoutError(name)
   c.pump()
  c.call(name+'-save','recoverySourceSave',str(out/name),seg,offset)
 # No dialogue buttons are injected. The original Game16 timed return runs
 # before Game13 is stopped, and its returned flag51 is retained in the capture.
 bp=rb('dispatch',13,0x2588);capture('dispatch',13,0x2588)
 c.call('dispatch-clear','clear_breakpoint',bp);c.breakpoints.remove(bp)
 bp=rb('fire-before',24,0x084c);capture('fire-before',24,0x084c)
 c.call('fatal-setup','recoveryFatalSetup',str(out/'fatal-setup.json'))
 c.call('fire-before-clear','clear_breakpoint',bp);c.breakpoints.remove(bp)
 bp=rb('fatal',24,0x096a);capture('fatal',24,0x096a)
 c.call('fatal-clear','clear_breakpoint',bp);c.breakpoints.remove(bp)
 bp=rb('dispatch-after',13,0x258b);capture('dispatch-after',13,0x258b)
 c.call('dispatch-after-clear','clear_breakpoint',bp);c.breakpoints.remove(bp)
 bp=rb('counter',13,0x20e8);capture('counter',13,0x20e8)
 c.call('counter-clear','clear_breakpoint',bp);c.breakpoints.remove(bp)
 rb('death',7,0x04b2);capture('death',7,0x04b2)
finally:c.close()
