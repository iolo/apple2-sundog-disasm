# Manual notes for reference sessions

Page numbers below are **1-based PDF page indices**, not inferred printed page
numbers. The supplied PDF has 22 scanned pages. Relevant pages were rendered
with `pdftoppm` and visually read; OCR was not needed for these notes.

- Page 8, Playing SunDog: Apple II/II+/IIe, at least 64 KB RAM, one disk drive,
  and a two-button joystick. Boot the game side and select Play SunDog with
  joystick button 0. A fresh game starts at the ship's airlock; a saved game
  resumes where it was saved. The personal-status disk icon exposes Save Game,
  which writes the current state to the game side.
- Page 9, SunDog Utilities: the other side holds utilities for new characters,
  up to eight stored games, and ending games. Either select Use Utilities from
  the game boot menu and flip the disk, or boot the utility side. Selecting a
  slot offers actions dependent on that slot's state; button 1 backs out.
- Page 10, Joystick Control: button 0 selects and moves; button 1 backs out or
  opens personal status when there is no preceding menu. The joystick controls
  the on-screen pointer. The prose says the keyboard is never used for play.
- Page 7, Introduction: a new game begins inside the SunDog near the airlock.
  This does not establish the initial state of the supplied, possibly saved,
  game image.

These are manual descriptions, not yet proof of every behavior in the supplied
Version 2.0 images. In particular, a cold utility boot currently displays a
Flip Disk prompt in apple2ts; investigate the actual disk workflow before
assuming the manual and this image have identical startup behavior.
