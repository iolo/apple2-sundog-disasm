#!/usr/bin/env python3
"""Capture declared native Tractor-entry continuation on disposable IIe media."""
import argparse
import json
import os
from pathlib import Path
import pty
import re
import select
import subprocess
import sys
import time

ROOT = Path(__file__).resolve().parents[2]


class Console:
    def __init__(self, out, rompath):
        self.out = out
        self.master, slave = pty.openpty()
        self.child = subprocess.Popen([
            sys.executable, str(ROOT / 'tools/remake/encounter_bootstrap.py'),
            '--output-dir', str(out), '--rompath', str(rompath), '--debug'],
            cwd=ROOT, stdin=slave, stdout=slave, stderr=slave, start_new_session=True)
        os.close(slave)
        os.set_blocking(self.master, False)
        self.buffer = ''
        self.log = None
        self.receipts = []
        self.breakpoints = []
        print(json.dumps({'ownedChild': self.child.pid, 'output': str(out)}), flush=True)

    def pump(self):
        if select.select([self.master], [], [], .05)[0]:
            try:
                raw = os.read(self.master, 65536)
            except OSError:
                raw = b''
            if raw:
                if self.log is None and self.out.exists():
                    self.log = (self.out / 'console.log').open('ab', buffering=0)
                if self.log:
                    self.log.write(raw)
                self.buffer += raw.decode(errors='replace')

    def wait(self, predicate, label, timeout=30):
        deadline = time.monotonic() + timeout
        while not predicate():
            if self.child.poll() is not None:
                raise RuntimeError(f'owned MAME exited {self.child.returncode}: {label}')
            if time.monotonic() >= deadline:
                raise TimeoutError(label)
            self.pump()

    def command(self, lua, identifier):
        start = len(self.buffer)
        # The console can consume a leading byte while its line editor resets.
        # A harmless leading space plus the observed prompt avoids losing Lua.
        os.write(self.master, (' ' + lua + '\n').encode())
        found = []

        def receipt():
            for match in re.finditer(r'A2 (\{[^\n]*\})\r?\n', self.buffer[start:]):
                try:
                    value = json.loads(match[1])
                except ValueError:
                    continue
                if value.get('id') == identifier:
                    found.append((value, start + match.end()))
                    return True
            return False

        self.wait(receipt, f'receipt {identifier}')
        result, end = found[-1]
        if result.get('result', {}).get('scheduled') != 'exit':
            self.wait(lambda: '\x1b[8C' in self.buffer[end:], f'prompt {identifier}')
        self.receipts.append(result)
        (self.out / 'receipts.json').write_text(json.dumps(self.receipts, indent=2) + '\n')
        print(json.dumps(result), flush=True)
        if not result['ok']:
            raise RuntimeError(result.get('error', identifier))
        return result['result']

    def call(self, identifier, operation, *args):
        def literal(v):
            return json.dumps(v) if not isinstance(v, bool) else ('true' if v else 'false')
        lua = 'a2.call(' + ','.join(map(literal, (identifier, operation, *args))) + ')'
        return self.command(lua, identifier)

    def source_breakpoint(self, identifier, offset):
        value = self.call(identifier, 'tacticalOpcodeBreakpoint', offset)
        self.breakpoints.append(value['id'])
        return value['id']

    def capture(self, name, offset):
        # A go receipt is scheduled only. Poll the same owned session until it
        # actually stops, then assert its source IP inside the capture helper.
        self.call(name + '-go', 'go')
        deadline = time.monotonic() + 30
        while True:
            state = self.call(name + '-status-' + str(len(self.receipts)), 'status')
            if state['debugger'] == 'stop':
                break
            if time.monotonic() >= deadline:
                raise TimeoutError(f'debugger stop {name}')
            self.pump()
        self.call(name + '-save', 'tacticalStoppedSave', str(self.out / name), offset)

    def close(self):
        clean = False
        try:
            if self.child.poll() is None:
                for bp in self.breakpoints:
                    self.call('clear-' + str(bp), 'clear_breakpoint', bp)
                if hasattr(self, 'refs_loaded'):
                    self.call('release', 'encounterRelease')
                self.call('exit', 'exit')
                os.write(self.master, b'\n')  # Wake the console after scheduled exit.
                self.wait(lambda: self.child.poll() is not None, 'owned terminal exit', timeout=10)
            clean = self.child.returncode == 0
        finally:
            if self.child.poll() is None:
                self.child.terminate()
                try:
                    self.child.wait(timeout=5)
                except subprocess.TimeoutExpired:
                    self.child.kill()
                    self.child.wait(timeout=5)
            result = {'ownedChild': self.child.pid, 'exitCode': self.child.returncode,
                      'clean': clean}
            (self.out / 'terminal.json').write_text(json.dumps(result, indent=2) + '\n')
            print(json.dumps(result), flush=True)
            if self.log:
                self.log.close()
            os.close(self.master)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--output-dir', required=True, type=Path)
    parser.add_argument('--rompath', required=True, type=Path)
    args = parser.parse_args()
    out = args.output_dir.resolve()
    if out.exists():
        parser.error('output directory must be new')
    console = Console(out, args.rompath.resolve())
    try:
        console.wait(lambda: '[MAME]' in console.buffer, 'console startup')
        helper = Path.home() / '.codex/skills/a2skills/a2-mame/scripts/control.lua'
        console.command(f'a2=dofile({json.dumps(str(helper))});a2.call("load","status")', 'load')
        console.call('devices', 'devices')
        console.call('boot-go', 'go')
        console.wait(lambda: 'R10_BOOT_PAUSED' in console.buffer, 'recorded boot pause', timeout=60)
        loader = out / 'refs.lua'
        helpers = ['encounter_reference.lua', 'ground_reference.lua', 'tactical_reference.lua',
                   'tactical_input_reference.lua', 'salvage_reference.lua']
        loader.write_text('\n'.join('dofile(' + json.dumps(str(ROOT / 'tools/remake' / f)) + ')'
                                    for f in helpers) + '\na2.call("refs","status")\n')
        console.command('dofile(' + json.dumps(str(loader)) + ')', 'refs')
        console.refs_loaded = True
        start = len(console.buffer)
        console.call('contact', 'spaceContact', str(out / 'contact'))
        console.wait(lambda: 'R10_PROBE ' in console.buffer[start:], 'contact macro completion')
        console.source_breakpoint('main-bp', 0x1388)
        console.capture('main', 0x1388)
        console.call('setup', 'salvageCollectionSetup', str(out / 'setup.json'))
        console.source_breakpoint('entry-bp', 0x0fca)
        console.capture('entry', 0x0fca)
        loop_bp = console.source_breakpoint('loop-bp', 0x1048)
        for n in range(1, 6):
            console.capture('loop-' + str(n), 0x1048)
        console.call('loop-clear', 'clear_breakpoint', loop_bp)
        console.breakpoints.remove(loop_bp)
        console.source_breakpoint('copied-bp', 0x1072)
        console.capture('copied', 0x1072)
        console.source_breakpoint('complete-bp', 0x1096)
        console.capture('complete', 0x1096)
        console.source_breakpoint('menu-before-bp', 0x0f19)
        console.capture('menu-before', 0x0f19)
        console.source_breakpoint('menu-after-bp', 0x0f2b)
        console.capture('menu-after', 0x0f2b)
        # The earlier owned main breakpoint proves return to the same live loop.
        console.capture('returned', 0x1388)
    finally:
        console.close()


if __name__ == '__main__':
    main()
