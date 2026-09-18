# apple2-sundog-disasm

GOAL: Reverse [Sundog](https://en.wikipedia.org/wiki/SunDog:_Frozen_Legacy) for Apple IIgame

## input

- two disk images: [sundog-disk1-game.dsk], [sundog-disk2-util.dsk]
  (filenames preserved; observed roles: disk 1 title/utilities, disk 2 play side)
- scaned manual(no text): [sundog.pdf]

## output

- disassembled source code of Sundog
- extracted assets(images, fonts, sounds, etc.)
- build scripts to generate identical disk images from reverse-engineered source code and assets
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
