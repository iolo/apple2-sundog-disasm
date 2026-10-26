{ DATASEG30 allocation is342 bytes (library header slot9, kind7).
  Eight16-byte captions occupy words1..64; counts are65/66;21 ten-byte
  items begin at67. Sprite and button views overlap the same record. }
tag25 = packed record
  code: 0..255;
  button: boolean;
  caption: 0..15;
  spare: 0..7
end;
item25 = record
  case integer of
    0: (words: array[0..4] of integer);
    1: (tag: tag25;
        bounds: bounds4)
end;
data30_view = record
  captions: array[1..8] of text15;
  nlabels: integer;
  nitems: integer;
  items: array[1..21] of item25
end;
