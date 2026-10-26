{ game17 parent frame views, derived from IXA5, MOV5 and packed accesses.
  Entry fields occupy words0..4; active is bit8 of word4. }
g17entry = packed record
  second: integer;
  first: integer;
  code: 0..255;
  draw: 0..255;
  radius: 0..255;
  life: 0..255;
  delay: 0..255;
  active: boolean;
  spare: 0..127
end;
g17trail = record
  word0: integer;
  word1: integer;
  second: integer;
  first: integer
end;
g17frame = record
  case integer of
    0: (words: array[4..101] of integer);
    { Initialization clears entries0..6 (70 bytes). This is an access view,
      not proof that every restored count or caller-supplied index is valid. }
    1: (items: array[0..6] of g17entry);
    2: (before43: array[4..42] of integer;
        saved43: bounds4);
    3: (before47: array[4..46] of integer;
        trail: array[0..6] of g17trail);
    4: (before100: array[4..99] of integer;
        ptr100: address16)
end;
