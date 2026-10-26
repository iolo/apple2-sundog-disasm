{ Three parameter words precede204 local bytes, slots4..105.
  Eight text15 captions occupy10..73; seven four-word bounds occupy74..101. }
g14frame = record
  case integer of
    0: (words: array[4..105] of integer);
    1: (before10: array[4..9] of integer;
        captions: array[0..7] of text15;
        meter74: bounds4;
        panel78: bounds4;
        title82: bounds4;
        lamps86: array[0..3] of bounds4)
end;
