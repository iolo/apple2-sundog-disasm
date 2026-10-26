{ Native library22:8, $1030..$10EF, attributes $1128.
  Pops return into $06/$07, second coordinate into $0C/$0D, first into
  $0A/$0B; restores only return (six bytes popped, four argument bytes consumed).
  Drawing uses the low byte of the second coordinate and the first word.
  Global-relative $02DA selects no-op/single/pair plotting; $02CC selects
  row tables; $02CA controls the high display bit. The helper at segment
  $1607 converts the first coordinate to byte/bit indices. It can write
  one or two pixels through fixed row tables $0D00/$0D60 or $0DC0/$0E80.
  No Pascal result or implicit coordinate clipping is supplied. }
procedure proc22_8(first, second: integer); external;

{ Native library22:55 entry $1600..$1606, attributes $176C.
  No arguments or result: read $C054 then $C050 and RTS, preserving the native
  return address on the stack. The later $1607 helper and tables in this
  procedure's extent are internal graphics dependencies, not extra entry args. }
procedure proc22_55; external;

{ Another evidenced target of library22:25's raw-call trampoline.
  Library22:54 pushes the address of DATASEG29 word20 then target3904 ($0F40).
  src/native/raw_screen_init.s $0F40..$0FA8 consumes that one pointer without
  using it, writes192 HGR low row bytes at $0DC0 and96 low/high linear row
  addresses at $0D00/$0D60, then restores return. The HGR high row bytes at
  $0E80 come from the loaded block. This is not the checksum target contract.
  Bind through22:25 to the currently loaded raw entry; no Pascal result. }
procedure callinit(var unused: integer; target: integer); external;
