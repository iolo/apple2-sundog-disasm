{ Native library22:25, $0F44..$0F58, is a stack-preserving raw-call trampoline.
  It removes its return address and a target word, patches the JMP operand,
  replaces the return address, then jumps to target. Remaining arguments and
  any results belong to the target's contract; there is no single fixed arity.

  This declaration is the game21 checksum call shape: one VAR word followed
  by target. src/native/disk_checksum.s $1840..$1886 consumes that address,
  writes two independent modulo256 byte sums through it, and returns no
  Pascal result. Binding must use22:25 and the loaded raw entry, not a normal
  two-word-cleanup implementation of the trampoline alone. Other target
  signatures require their own evidenced declarations; the screen-init use
  is declared in native_display_interfaces.pas. Game13's warp and viewscreen
  targets have separate contracts in ../game_13/native_interfaces.pas. }
procedure call_disk_checksum(var value: integer; target: integer); external;
