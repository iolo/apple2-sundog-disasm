{ Views established by system4. syse denotes its runtime ancestor frame:
  LDA/LOD1 in entry1,2 in its children,3 in grandchildren. It is not DATA29.
  Only accessed spans are described; pointer values alias the original storage. }
s4text7 = string[7];
s4text23 = string[23];
s4date = packed record
  low9: 0..511;
  high7: 0..127
end;
{ Only the first13-word directory/header entry is accessed by scope7. }
s4head = record
  case integer of
    0: (words: array[0..12] of integer);
    1: (before3: array[0..2] of integer; caption: s4text7);
    2: (before12: array[0..11] of integer; flags12: s4date)
end;
s4hptr = ^s4head;
s4flags = packed array[0..15] of boolean;
s4raw = record
  case integer of
    0: (word: integer);
    1: (bytes: ^bytebuffer);
    2: (flags: ^s4flags)
end;
s4str11 = record
  case integer of
    0: (text: string[11]);
    1: (bytes: packed array[0..11] of 0..255)
end;
s4short = record
  case integer of
    0: (text: string[6]);
    1: (bytes: packed array[0..7] of 0..255);
    2: (words: array[0..3] of integer)
end;
s4temp = record
  case integer of
    0: (text: string[12]);
    1: (words: array[0..6] of integer)
end;
s4ctrl = record
  case integer of
    0: (words: array[0..5] of integer);
    1: (bytes: packed array[0..11] of 0..255);
    2: (before5: array[0..4] of integer;
        flags5: packed array[0..15] of boolean)
end;
s4keys = record
  case integer of
    0: (words: array[0..10] of integer);
    1: (bytes: packed array[0..21] of 0..255);
    2: (before10: array[0..9] of integer;
        flags10: packed array[0..15] of boolean)
end;
s4config = record
  case integer of
    0: (words: array[0..47] of integer);
    1: (before31: array[0..30] of integer;
        control: s4ctrl; keys: s4keys);
    2: (before4: array[0..3] of integer; directory: s4hptr)
end;
{ NEW in9 allocates exactly30 words; using the580-byte buffered sysfile here
  would change the heap layout. Callees receive the address of header word0. }
s4file = record
  words: array[0..29] of integer
end;
s4fptr = ^s4file;
s4unit = record
  caption: s4text7;
  flag4: integer;
  word5: integer
end;
s4env = record
  case integer of
    0: (words: array[1..534] of integer);
    1: (state: ^s4config;
        files2: array[0..2] of s4fptr;
        heap5: ^integer;
        file6: s4fptr;
        file7: s4fptr;
        file8: s4fptr;
        file9: s4fptr);
    2: (before25: array[1..24] of integer;
        name25: s4str11;
        units31: array[0..20] of s4unit;
        flags157: packed array[0..255] of boolean);
    3: (before230: array[1..229] of integer; file230: sysfile);
    4: (before20: array[1..19] of integer; powers20: array[0..4] of integer);
    5: (before521: array[1..520] of integer;
        short521: s4short; short525: s4short;
        name529: s4text7; bytes533: packed array[0..3] of 0..255);
    6: (before10: array[1..9] of integer;
        name10: s4text7; name14: s4text7);
    7: (before173: array[1..172] of integer;
        name173: s4text23; text185: text80)
end;
{ Configuration file input is144 words; only the copied fields are named. }
s4misc = record
  case integer of
    0: (words: array[0..143] of integer);
    1: (before29: array[0..28] of integer;
        word29: integer; word30: integer;
        control31: s4ctrl; keys37: s4keys)
end;
s4view = record
  case integer of
    0: (control: ^s4ctrl);
    1: (keys: ^s4keys)
end;
{ Procedure3: filename1..12, misc13..156, index157, state158, view159,
  limit160 reused as the first word of the seven-word concatenation temporary. }
s4conf = record
  case integer of
    0: (words: array[1..166] of integer);
    1: (filename: s4text23; misc: s4misc;
        index157: integer; state158: ^s4config; view159: s4view;
        temp160: s4temp)
end;
{ Root1's306 words (612 bytes); original parameter area is0 bytes. }
s4root = record
  case integer of
    0: (words: array[1..306] of integer);
    1: (command: s4text23);
    2: (before15: array[1..14] of integer; file15: sysfile);
    3: (before306: array[1..305] of integer; raw306: s4raw)
end;
{ Procedure2's376 words. Its result slot43 deliberately overlaps the file
  record. Buffer303 and address words1/2 retain their original positions. }
s4load = record
  case integer of
    0: (words: array[1..376] of integer);
    1: (flagptr: address16; target: address16; file3: sysfile);
    2: (before303: array[1..302] of integer;
        buffer: array[0..73] of integer)
end;
