#!/usr/bin/env python3
"""Boot an owned IIe encounter-reference console on disposable game media."""
import argparse
import json
import os
from pathlib import Path
import shutil
import sys

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / 'tools'))
from verify_inputs import main as verify_inputs


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--output-dir', required=True, type=Path, help='new directory')
    parser.add_argument('--rompath', required=True, type=Path)
    parser.add_argument('--mame', default='/usr/games/mame')
    parser.add_argument('--skill-dir', type=Path,
                        default=Path.home() / '.codex/skills/a2skills/a2-mame')
    parser.add_argument('--prepare-only', action='store_true')
    args = parser.parse_args()
    verify_inputs()
    launcher = args.skill_dir.resolve() / 'scripts/launch.py'
    if not launcher.is_file():
        parser.error('a2-mame skill launcher is missing; supply --skill-dir')
    mame = shutil.which(args.mame)
    if not mame:
        parser.error('MAME executable is missing; supply --mame')
    out = args.output_dir.resolve()
    if not str(out).isascii():
        parser.error('MAME Lua reference paths must currently be ASCII')
    out.mkdir(parents=True, exist_ok=False)
    disk2 = out / 'disk2.dsk'
    shutil.copyfile(ROOT / 'sundog-disk2-util.dsk', disk2)
    # The skill launcher has no joystick argument. Pass it only during startup;
    # MAME's verifyroms frontend does not accept the dynamic gameio option.
    wrapper = out / 'mame-joystick'
    wrapper.write_text('#!/usr/bin/env python3\nimport os,sys\n'
                       f'program={mame!r}\n'
                       'extra=[] if "-verifyroms" in sys.argv else ["-gameio","joy","-nothrottle"]\n'
                       'os.execv(program,[program,*sys.argv[1:],*extra])\n')
    wrapper.chmod(0o755)
    sequence = json.loads((ROOT / 'docs/reference/game-play.json').read_text())
    lines = [
        'local m=manager.machine', 'local ports=m.ioport.ports',
        "local buttons=ports[':gameio:joy:joystick_buttons'].fields",
        "local x=ports[':gameio:joy:joystick_1_x'].fields['P1 Joystick X']",
        "local y=ports[':gameio:joy:joystick_1_y'].fields['P1 Joystick Y']",
        'x:set_value(128);y:set_value(128)',
        "buttons['P1 Button 1']:set_value(0);buttons['P1 Button 2']:set_value(0)",
        'local frames=0', 'emu.register_frame_done(function()', ' frames=frames+1',
    ]
    for event in sequence['events']:
        if event['frame'] > 18000:
            continue
        lines.append(f" if frames=={event['frame']} then")
        for axis in ('x', 'y'):
            if axis in event:
                lines.append(f"  {axis}:set_value({int(event[axis])})")
        if 'button' in event:
            lines.append(f"  buttons['P1 Button {int(event['button'])+1}']:set_value({int(event['pressed'])})")
        if 'mount' in event:
            assert event['mount'] == 'disk2'
            lines.append("  assert(not m.images[':sl6:diskiing:0:525']:load("+json.dumps(str(disk2))+"))")
        if event['frame'] == 18000:
            lines.extend(['  emu.pause()', "  print('R10_BOOT_PAUSED',frames)"])
        lines.append(' end')
    lines.append('end)')
    script = out / 'bootstrap.lua'
    script.write_text('\n'.join(lines) + '\n')
    command = [sys.executable, str(launcher), '--mame', str(wrapper), '--driver', 'apple2e',
               '--rompath', str(args.rompath.resolve()), '--output-dir', str(out / 'session'),
               '--disk', str(ROOT / 'sundog-disk1-game.dsk'), '--script', str(script), '--headless']
    (out / 'launch.json').write_text(json.dumps(command, indent=2) + '\n')
    print('Launch: ' + json.dumps(command), flush=True)
    if not args.prepare_only:
        os.execv(sys.executable, command)


if __name__ == '__main__':
    main()
