#!/usr/bin/env python3
"""Run a frame-indexed input sequence against fresh, disposable media in MAME."""
import argparse
import hashlib
import json
import os
from pathlib import Path
import shutil
import subprocess
import tempfile

from verify_inputs import main as verify_inputs

ROOT = Path(__file__).resolve().parents[1]


def lua_string(value):
    # Lua quoted strings accept the JSON escapes used by these ASCII paths.
    value = str(value)
    if not value.isascii():
        raise ValueError("MAME reference paths must currently be ASCII")
    return json.dumps(value)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("sequence", type=Path)
    parser.add_argument("--rompath", required=True, type=Path)
    parser.add_argument("--mame", default="mame")
    args = parser.parse_args()
    verify_inputs()
    sequence = json.loads(args.sequence.read_text())
    base = ROOT / "build" / "reference"
    base.mkdir(parents=True, exist_ok=True)
    output = Path(tempfile.mkdtemp(prefix=sequence["name"] + "-", dir=base))
    media = {}
    for key, filename in [("disk1", "sundog-disk1-game.dsk"), ("disk2", "sundog-disk2-util.dsk")]:
        media[key] = output / filename
        shutil.copyfile(ROOT / filename, media[key])
    lines = [
        "local machine = manager.machine",
        "local ports = machine.ioport.ports",
        "local buttons = ports[':gameio:joy:joystick_buttons'].fields",
        "local x = ports[':gameio:joy:joystick_1_x'].fields['P1 Joystick X']",
        "local y = ports[':gameio:joy:joystick_1_y'].fields['P1 Joystick Y']",
        "x:set_value(128); y:set_value(128)",
        "buttons['P1 Button 1']:set_value(0); buttons['P1 Button 2']:set_value(0)",
        "local frames = 0",
        "emu.register_frame_done(function()",
        "  frames = frames + 1",
    ]
    for event in sequence["events"]:
        frame = int(event["frame"])
        assert frame > 0
        lines.append(f"  if frames == {frame} then")
        if "x" in event or "y" in event:
            for axis in ["x", "y"]:
                if axis in event:
                    value = int(event[axis])
                    assert 0 <= value <= 255
                    lines.append(f"    {axis}:set_value({value})")
        if "button" in event:
            button = int(event["button"])
            assert button in [0, 1]
            value = int(bool(event["pressed"]))
            lines.append(f"    buttons['P1 Button {button + 1}']:set_value({value})")
        if "mount" in event:
            path = lua_string(media[event["mount"]])
            lines.append(f"    assert(not machine.images[':sl6:diskiing:0:525']:load({path}))")
        if "snapshot" in event:
            name = event["snapshot"]
            assert Path(name).name == name and name.endswith(".png")
            path = lua_string(output / name)
            lines.append(f"    assert(not machine.screens[':screen']:snapshot({path}))")
            lines.append(f"    print('SNAPSHOT', {frame}, {lua_string(name)}, machine.devices[':maincpu'].state['PC'].value)")
        lines.append("  end")
    end_frame = int(sequence["end_frame"])
    assert end_frame >= max(event["frame"] for event in sequence["events"])
    lines.extend([f"  if frames == {end_frame} then machine:exit() end", "end)"])
    script = output / "sequence.lua"
    script.write_text("\n".join(lines) + "\n")
    command = [
        args.mame, "apple2e", "-rompath", str(args.rompath.resolve()),
        "-gameio", "joy", "-flop1", str(media[sequence["boot_disk"]]),
        "-video", "none", "-sound", "none", "-nothrottle", "-skip_gameinfo",
        "-autoboot_delay", "0", "-autoboot_script", str(script),
        "-cfg_directory", str(output / "cfg"),
        "-nvram_directory", str(output / "nvram"),
        "-snapshot_directory", str(output),
        "-seconds_to_run", str(end_frame // 60 + 20),
    ]
    (output / "command.json").write_text(json.dumps(command, indent=2) + "\n")
    (output / "sequence.json").write_text(json.dumps(sequence, indent=2) + "\n")
    print(f"Reference output: {output}", flush=True)
    try:
        result = subprocess.run(command, env={**os.environ, "SDL_VIDEODRIVER": "dummy"},
                                capture_output=True, text=True, timeout=180)
        (output / "mame.log").write_text(result.stdout + result.stderr)
        print(result.stdout + result.stderr)
        result.check_returncode()
        for event in sequence["events"]:
            if "snapshot" in event and not (output / event["snapshot"]).is_file():
                raise RuntimeError(f"Missing snapshot: {event['snapshot']}")
        hashes = {key: hashlib.sha256(path.read_bytes()).hexdigest() for key, path in media.items()}
        (output / "final-media-hashes.json").write_text(json.dumps(hashes, indent=2) + "\n")
    finally:
        verify_inputs()


if __name__ == "__main__":
    main()
