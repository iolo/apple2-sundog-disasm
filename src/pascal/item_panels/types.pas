{ DATASEG31 has 152 bytes. Entry accesses start at word17, stride two words;
  library27:5 limits the count to 28. Preserve the unused high byte of word2. }
item27 = packed record
  secondoff: 0..255;
  firstoff: 0..255;
  code: 0..255;
  spare: 0..255
end;
captions27 = array[0..31] of text15;
captionaddr = record
  case integer of
    0: (word: integer);
    1: (table: ^captions27)
end;
data31_view = record
  case integer of
    0: (words: array[1..76] of integer);
    1: (captions: captionaddr);
    2: (before2: integer; bounds2: bounds4);
    3: (before6: array[1..5] of integer; bounds6: bounds4);
    4: (before17: array[1..16] of integer;
        items: array[1..28] of item27)
end;
