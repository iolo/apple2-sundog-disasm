{ System file storage, established by system2 and its core7/8/33 callers.
  Offsets are zero-based words. The full MOV290 snapshot is580 bytes; the
  sector starts at word33, with one final word beyond its512 bytes. Use raw
  words for flags whose consumers test only bit0. No host file abstraction. }
sysblock = packed array[0..511] of 0..255;
sysentry = record
  case integer of
    0: (words: array[0..12] of integer);
    1: (before2: array[0..1] of integer;
        kind2: packed record
          kind: 0..15;
          spare: 0..4095
        end)
end;
sysfile = record
  case integer of
    0: (words: array[0..289] of integer);
    1: (bytes: packed array[0..579] of 0..255);
    2: (current: address16);
    3: (before16: array[0..15] of integer; entry16: sysentry);
    4: (before33: array[0..32] of integer; sector33: sysblock)
end;
sysfptr = ^sysfile;
syseptr = ^sysentry;
{ Raw address-word arguments of system1's entry; its body never reads them. }
syswptr = ^integer;
