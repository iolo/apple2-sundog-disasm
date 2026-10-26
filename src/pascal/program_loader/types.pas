{ Code-file header views established by system5: one512-byte sector.
  The sixteen rows at0 have a two-word stride; kind words start96 and packed
  mapping words128. Bounds describe nominal tables, not new runtime checks. }
s5mask16 = packed array[0..15] of boolean;
s5mask32 = packed array[0..31] of boolean;
s5tag = packed record
  number: 0..255;
  spare: 0..31;
  kind: 0..7
end;
s5header = record
  case integer of
    0: (words: array[0..255] of integer);
    1: (rows: array[0..15] of wordpair);
    2: (before96: array[0..95] of integer;
        kinds96: array[0..15] of integer);
    3: (before128: array[0..127] of integer;
        tags128: array[0..15] of s5tag;
        needs144: s5mask32;
        legacy146: wordpair)
end;
s5hptr = ^s5header;
{ Raw string views retain byte-length writes and the existing core string
  interfaces. A VAR word may point to a smaller caller buffer; its actual
  capacity is supplied separately to2, as in entry1's23-character name. }
s5str80 = record
  case integer of
    0: (text: text80);
    1: (words: array[0..40] of integer);
    2: (bytes: packed array[0..81] of 0..255)
end;
s5nameptr = record
  case integer of
    0: (word: ^integer);
    1: (name: ^s5str80)
end;
s5str40 = record
  case integer of
    0: (text: string[40]);
    1: (words: array[0..20] of integer)
end;
s5str5 = record
  case integer of
    0: (text: string[5]);
    1: (bytes: packed array[0..5] of 0..255)
end;
s5temp = record
  case integer of
    0: (text: string[120]);
    1: (words: array[0..60] of integer)
end;
s5segment = record
  unit0: integer;
  block1: integer;
  size2: integer
end;
s5config = record
  before48: array[0..47] of integer;
  segments: array[0..31] of s5segment
end;
{ Both pointers view the same runtime configuration address. The system4
  view ends before the segment descriptors used here; no copy is performed. }
s5state = record
  case integer of
    0: (base: ^s4config);
    1: (config: ^s5config)
end;
s5env = record
  case integer of
    0: (common: s4env);
    1: (before533: array[1..532] of integer; mask533: s5mask32)
end;
