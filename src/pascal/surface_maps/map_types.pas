{ Game21:26 reads four128-byte city maps per block. Each map has four header
  words followed by20 columns of12 four-bit cells (three words per column).
  These pointer views allocate no map storage and retain column-major order. }
g21nibs = packed array[0..11] of 0..15;
g21city = record
  header: array[0..3] of integer;
  tiles: array[0..19] of g21nibs
end;
g21cptr = record
  case integer of
    0: (word: integer);
    1: (city: ^g21city)
end;
