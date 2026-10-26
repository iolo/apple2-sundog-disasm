{ System6 views; shared storage/system types and system4 types precede these.
  sy6e: s4env aliases the runtime ancestor accessed at depth2 by these bodies.
  Its state^.words[0] is the IO error word, also addressed by system2's sysio.
  Directory entries have a13-word stride. The header is entry0; its count is
  word8, while ordinary entries have a15-character name at word3 and packed
  date bits at word12. Nominal table bounds do not add checks or allocate a
  directory: preserve the allocator/read extents in the routines using it. }
s6date = packed record
  low4: 0..15;
  middle5: 0..31;
  high7: 0..127
end;
s6entry = record
  case integer of
    0: (words: array[0..12] of integer);
    1: (before3: array[0..2] of integer; caption: text15);
    2: (before12: array[0..11] of integer; date12: s4date);
    3: (before2: array[0..1] of integer;
        kind2: packed record kind: 0..15; spare: 0..4095 end);
    4: (beforebits: array[0..11] of integer; bits12: s6date)
end;
s6eptr = ^s6entry;
s6dir = array[0..77] of s6entry;
s6dptr = ^s6dir;
{ Procedure9 allocates256 words, not the entire nominal78-entry view.
  Keep that512-byte allocation even though the original count check allows77
  entries and later traversals/writes can exceed it. The views alias; they do
  not enlarge the allocation. No additional bounds check is introduced. }
s6cache = record
  case integer of
    0: (block: ^sysblock);
    1: (directory: s6dptr);
    2: (header: s4hptr)
end;
s6config = record
  case integer of
    0: (words: array[0..47] of integer);
    1: (before4: array[0..3] of integer; cache: s6cache);
    2: (before29: array[0..28] of integer;
        flags29: packed record
          low7: 0..127; format: 0..3; high7: 0..127
        end)
end;
{ Procedure6 reuses one pointer slot for configuration and device entries. }
s6view = record
  case integer of
    0: (base: ^s4config);
    1: (config: ^s6config);
    2: (device: ^s4unit)
end;
s6wptr = ^integer;
s6file = record
  case integer of
    0: (raw: sysfile);
    1: (before8: array[0..7] of integer; volume8: s4text7);
    2: (before16: array[0..15] of integer; entry16: s6entry);
    3: (before33: array[0..32] of integer;
        tail33: packed array[0..513] of 0..255)
end;
s6heap = record
  case integer of
    0: (word: integer);
    1: (pointer: s6wptr)
end;
{ These pointer alternatives alias the same address, including30-word file
  headers. The larger sysfile view does not allocate or copy a file record. }
s6fview = record
  case integer of
    0: (word: s6wptr);
    1: (fileptr: sysfptr);
    2: (rich: ^s6file);
    3: (head: s4fptr);
    4: (device: ^s4unit)
end;
s6bview = record
  case integer of
    0: (word: s6wptr);
    1: (bytes: ^bytebuffer)
end;
s6str80 = record
  case integer of
    0: (text: text80);
    1: (words: array[0..40] of integer);
    2: (bytes: packed array[0..81] of 0..255)
end;
s6strptr = record
  case integer of
    0: (text: ^text80);
    1: (raw: ^s6str80);
    2: (narrow: ^text15)
end;
