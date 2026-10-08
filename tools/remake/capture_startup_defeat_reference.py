#!/usr/bin/env python3
"""Capture a declared fatal startup-call continuation on copied IIe media."""
import argparse
import sys,json,time
from pathlib import Path
root=Path(__file__).resolve().parents[2]
sys.path.insert(0,str(root/'tools/remake'))
from capture_salvage_reference import Console
parser=argparse.ArgumentParser(description=__doc__)
parser.add_argument('--output-dir',required=True,type=Path)
parser.add_argument('--rompath',required=True,type=Path)
parser.add_argument('--fatal-call',type=int,choices=(1,2,3),default=1)
args=parser.parse_args()
call_name=('first','second','third')[args.fatal_call-1]
call_offset=(0x0655,0x06c4,0x074f)[args.fatal_call-1]
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
 c.call('startup-setup','recoveryStartupSetup',str(out/'startup-setup.json'))
 bp=c.source_breakpoint('startup-'+call_name+'-bp',call_offset);c.capture('startup-'+call_name,call_offset)
 c.call('startup-'+call_name+'-clear','clear_breakpoint',bp);c.breakpoints.remove(bp)
 def rb(name,seg,offset):
  bp=c.call(name+'-bp','recoverySourceBreakpoint',seg,offset)['id'];c.breakpoints.append(bp);return bp
 def capture(name,seg,offset):
  c.call(name+'-go','go');deadline=time.monotonic()+30
  while True:
   s=c.call(name+'-status-'+str(len(c.receipts)),'status')
   if s['debugger']=='stop':break
   if time.monotonic()>deadline:raise TimeoutError(name)
   c.pump()
  c.call(name+'-save','recoverySourceSave',str(out/name),seg,offset)
 bp=rb('fire-before',24,0x084c);capture('fire-before',24,0x084c)
 c.call('fatal-setup','recoveryFatalSetup',str(out/'fatal-setup.json'))
 c.call('fire-before-clear','clear_breakpoint',bp);c.breakpoints.remove(bp)
 bp=rb('fatal',24,0x096a);capture('fatal',24,0x096a)
 c.call('fatal-clear','clear_breakpoint',bp);c.breakpoints.remove(bp)
 returns=[('startup-first-after',0x0658),('startup-second-after',0x06c7),('startup-third-after',0x0752)]
 for name,offset in returns[args.fatal_call-1:]:
  bp=c.source_breakpoint(name+'-bp',offset);c.capture(name,offset)
  c.call(name+'-clear','clear_breakpoint',bp);c.breakpoints.remove(bp)
 for name,offset in [('menu-before',0x0f19),('menu-after',0x0f2b),('first-main',0x1388),('main-exit-check',0x14cc)]:
  bp=c.source_breakpoint(name+'-bp',offset);c.capture(name,offset)
  c.call(name+'-clear','clear_breakpoint',bp);c.breakpoints.remove(bp)
 rb('death',7,0x04b2);capture('death',7,0x04b2)
finally:c.close()
