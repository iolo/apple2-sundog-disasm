{ A31-character Pascal string and its raw bytes, including the length byte.
  Procedure13 uses raw writes; compiler range checks are disabled as elsewhere. }
g16str = string[31];
g16text = record
  case integer of
    0: (text: g16str);
    1: (bytes: packed array[0..31] of 0..255);
    2: (short: text15)
end;
g16line = record
  case integer of
    0: (text: text80);
    1: (bytes: packed array[0..81] of 0..255)
end;
{ Game16 parent has three value words and278 local bytes, slots4..142.
  Views expose only the spans used by recovered children. The two text31
  buffers occupy16 words each; short108 shares the formatter's text15 prefix. }
g16frame = record
  case integer of
    0: (words: array[4..142] of integer);
    1: (before56: array[4..55] of integer;
        saved56: bounds4;
        dialog60: bounds4;
        saved64: bounds4;
        panel68: bounds4;
        buttons72: array[0..3] of bounds4);
    2: (pad100: array[4..99] of integer;
        fund100: wordpair;
        fund102: wordpair;
        cash104: wordpair;
        price106: wordpair;
        text108: string[31];
        caption124: string[31];
        source140: address16;
        table141: address16);
    3: (pad108: array[4..107] of integer;
        short108: text15)
end;
{20-byte system rows. These fields overlap names and amounts in other views.}
g16bits = packed record
  spare7: 0..127;
  flag7: boolean;
  spare8: 0..255
end;
g16row = record
  case integer of
    0: (words: array[0..9] of integer);
    1: (pad5: array[0..4] of integer; bits5: g16bits);
    2: (pad6: array[0..5] of integer; amount6: wordpair);
    3: (pad8: array[0..7] of integer; nibbles8: packed array[0..7] of 0..15)
end;
g16rows = array[1..15] of g16row;
g16addr = record
  case integer of
    0: (word: integer);
    1: (rows: ^g16rows)
end;
