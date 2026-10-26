{ Game19 parent has one parameter and56 local bytes, slots2..29.
  These overlays preserve aliases between the raw frame and two-word amounts. }
g19frame = record
  case integer of
    0: (words: array[2..29] of integer);
    1: (before8: array[2..7] of integer;
        amount8: wordpair;
        amount10: wordpair);
    2: (amount2: wordpair)
end;
g19bits5 = packed record
  low2: 0..3;
  mid5: 0..31;
  spare9: 0..511
end;
{ DATASEG29 word23 holds a pointer to20-byte system rows. The amount at
  words6/7 overlaps other existing name/table views. }
g19row = record
  case integer of
    0: (words: array[0..9] of integer);
    1: (before6: array[0..5] of integer;
        amount6: wordpair);
    2: (before8: array[0..7] of integer;
        nibbles8: packed array[0..7] of 0..15);
    3: (before5: array[0..4] of integer;
        bits5: g19bits5);
    4: (caption: text15)
end;
g19bytes = packed record
  low: 0..255;
  high: 0..255
end;
g19planet = record
  prefix: array[0..5] of integer;
  coords6: g19bytes;
  place7: bits37view
end;
g19coord = packed record
  low6: 0..63;
  mid5: 0..31;
  spare5: 0..31
end;
g19city = record
  prefix: array[0..4] of integer;
  coords5: g19coord
end;
g19plist = array[1..31] of g19planet;
g19clist = array[1..63] of g19city;
g19paddr = record
  case integer of
    0: (word: integer);
    1: (rows: ^g19plist)
end;
g19caddr = record
  case integer of
    0: (word: integer);
    1: (rows: ^g19clist)
end;
g19rows = array[1..15] of g19row;
g19addr = record
  case integer of
    0: (word: integer);
    1: (rows: ^g19rows)
end;
