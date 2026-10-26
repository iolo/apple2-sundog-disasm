{ Additional native contracts required by library27. }

{ Native23, $0EFE..$0F19: pops return address, destination address, value;
  writes the value's low/high bytes at destination offsets0/1. No result. }
procedure store_word(value: integer; var destination: integer); external;

{ Native32/33, $0FE0/$1008: pop ten bytes (return address, four reserved
  result bytes, two argument words), push one word, then restore return.
  AND/ORA respectively combine both bytes, not just their Boolean low bits. }
function word_and(left, right: integer): integer; external;
function word_or(left, right: integer): integer; external;
