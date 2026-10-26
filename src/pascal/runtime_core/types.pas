{ Core string views; include after storage.pas. Pointers alias caller storage.
  bytebuffer bounds describe access, not allocation or a string capacity.
  In particular, core23 accepts the caller's explicit capacity (including120).
  Core27 alone owns an80-character temporary, as evidenced by its88 local bytes. }
s0str80 = record
  case integer of
    0: (text: text80);
    1: (bytes: packed array[0..81] of 0..255);
    2: (words: array[0..40] of integer)
end;
s0str10 = record
  case integer of
    0: (text: string[10]);
    1: (bytes: packed array[0..11] of 0..255)
end;
s0bptr = ^bytebuffer;
s0strptr = record
  case integer of
    0: (word: ^integer);
    1: (text: ^text80);
    2: (bytes: s0bptr);
    3: (address: integer)
end;
