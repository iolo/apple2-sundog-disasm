{ Procedure3's42-byte frame, slots1..21. Raw flags and bounds deliberately
  share the original word offsets used by its eight children. }
g13status = record
  case integer of
    0: (words: array[1..21] of integer);
    1: (before10: array[1..9] of integer;
        engine10: bounds4;
        charge14: bounds4;
        saved18: bounds4)
end;

{ Procedure27 has only six local bytes: saved flag3 and packet words4/5.
  Warp child35 also writes byte4 past this four-byte packet, into parent slot6.
  Preserve the frame and that raw access; do not enlarge the local allocation. }
g13packet = packed array[0..3] of 0..255;
g13text22 = string[22];

{ One-word address views for the existing20/16/12-byte world rows.
  Reuse the layouts established by game19; these views allocate no table. }
g13rowptr = record
  case integer of
    0: (word: integer);
    1: (sysrow: ^g19row);
    2: (planetrow: ^g19planet);
    3: (cityrow: ^g19city);
    4: (caption: ^text15);
    5: (bytes: ^bytebuffer)
end;
