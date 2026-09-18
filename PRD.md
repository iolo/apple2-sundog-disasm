# apple2-sundog-disasm

GOAL: Reverse [Sundog](https://en.wikipedia.org/wiki/SunDog:_Frozen_Legacy) for Apple IIgame

## input

- two disk images: [sundog-disk1-game.dsk], [sundog-disk2-util.dsk]
  (filenames preserved; observed roles: disk 1 title/utilities, disk 2 play side)
- scaned manual(no text): [sundog.pdf]

## output

- disassembled source code of Sundog
- extracted assets(images, fonts, sounds, etc.)
- build scripts to generate runnable disk images from reverse-engineered source code and extracted data/assets; byte-identical output is preferred, not required
- (optional) documentation of the disassembled code
- (optional) analysis of the game mechanics and structure

## tools

- cc65 toolchain(ca65, da65, ld65, ...)
- apple2ts emulator with apple2ts-server mcp server
- mame emulator with apple2 driver

# references

- https://github.com/snafaru/Wizardry.Code/ - Reverse engineering of Wizardry for Apple II, that was written in Apple Pascal(UCSD Pascal)
- https://en.wikipedia.org/wiki/SunDog:_Frozen_Legacy
- https://sundogresurrectionproject.com/ - Unofficial Sundog Resurrection Project
- https://github.com/laanwj/sundog - SDL port of Sundog for Atari ST
- https://github.com/iolo/apple2-stella7-disasm - my another disassembly project
- https://github.com/iolo/apple2-rescue-raiders-disasm - my another disassembly project

## required completion criteria

- Classify every disk region as code or data with recorded evidence and source
  locations. No unidentified byte chunks may remain in the final deliverable.
- Represent all executable content as disassembled instructions, including
  native code and Pascal p-code, including unused executable routines. Do not
  hide code in binary data files.
- Separate data from code. A data region's precise meaning may remain unknown
  if its classification is supported by evidence; a filename or lack of observed
  execution alone is not sufficient. Identify and extract assets where supported.
- Build independently from delivered source and data/assets. Original disk images
  are validation references, not build inputs.
- Prefer exact matching and retain comparison tools. Any output differences must
  be mapped, explained, and behaviorally validated; unexplained differences are
  not accepted as "possibly identical."
- Document boot, gameplay, disk swaps, utilities, and save/load checks in apple2ts
  and MAME, along with any remaining limitations.
- Keep a log in PROGRESS.md and commit changes after every step or substep.

This revision relaxes byte identity only. It does not permit a partial disassembly
with unclassified binary remainders to be declared complete. Detailed semantic
explanations and game-mechanics analysis remain optional.
