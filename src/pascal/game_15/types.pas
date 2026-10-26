{ Raw address26 points at a15-character Pascal string. No allocation occurs. }
g15textp = record
  case integer of
    0: (word: integer);
    1: (text: ^text15)
end;
{ Original parent slots1..26,52 bytes, no parameters. }
g15frame = record
  case integer of
    0: (words: array[1..26] of integer);
    1: (before14: array[1..13] of integer;
        bounds14: bounds4;
        text18: text15;
        target26: g15textp)
end;
