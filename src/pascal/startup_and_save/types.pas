{ Entry parameter occupies slot1; these36 local bytes occupy slots2..19.
  memory is the pointer stored at slot2, not an allocated6140-byte buffer. }
s7frame = record
  case integer of
    0: (words: array[2..19] of integer);
    1: (memory: address16)
end;
