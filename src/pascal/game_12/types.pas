{ game12 entry1 has94 local bytes, slots1..47. Keep the shared frame's
  evidenced aliases; these names do not imply a complete original type model. }
g12frame = record
  case integer of
    0: (words: array[1..47] of integer);
    1: (before34: array[1..33] of integer;
        cargo34: stock4);
    2: (before37: array[1..36] of integer;
        hull37: bounds4)
end;
g12scratch = record
  case integer of
    0: (word: integer);
    1: (row: ^g19row);
    2: (caption: ^text80)
end;
