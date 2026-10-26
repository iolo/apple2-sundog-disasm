{ Seven words include30 three-bit entries plus padding compared/copied by
  the original. IXP5,3 leaves bit15 of every word outside the entries. }
g20levels = record
  case integer of
    0: (words: array[0..6] of integer);
    1: (bytes: packed array[0..13] of 0..255);
    2: (values: packed array[1..35] of 0..7)
end;
g20ware = array[1..4] of stock4;
g20wlist = array[0..59] of g20ware;
g20waddr = record
  case integer of
    0: (word: integer);
    1: (rows: ^g20wlist)
end;
g20names = array[0..31] of text15;
g20nbytes = packed array[0..511] of 0..255;
g20naddr = record
  case integer of
    0: (word: integer);
    1: (names: ^g20names);
    2: (bytes: ^g20nbytes)
end;
g20phase = packed array[0..8] of 0..31;
g20phases = array[0..8] of g20phase;
g20text = record
  case integer of
    0: (text: text15);
    1: (bytes: packed array[0..15] of 0..255)
end;
{ Parent slots2..165,328 bytes. Transfers beginning at22 and38 deliberately
  span adjacent fields, with original byte counts32 and28. }
g20frame = record
  case integer of
    0: (words: array[2..165] of integer);
    1: (before18: array[2..17] of integer;
        ptr18: g20waddr;
        names19: g20naddr;
        addr20: address16;
        addr21: address16;
        stock22: g20levels;
        stock29: g20levels;
        day36: integer;
        word37: integer;
        stock38: g20levels;
        stock45: g20levels;
        ware52: g20ware);
    2: (before160: array[2..159] of integer;
        zero160: wordpair;
        bonus162: wordpair;
        cash164: wordpair);
    3: (pad60: array[2..59] of integer;
        capt60: packed array[0..167] of 0..255;
        offers144: array[0..7] of stock4)
end;
