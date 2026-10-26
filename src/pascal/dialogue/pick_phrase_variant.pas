{ game_16 procedure14, $05BA..$05F4, attributes $0600.
  Nested in13: updates its glyph at slot4 while counting65..96 bytes.
  The VAR count starts at1; read its divisor after the unconditional random
  call. Added random local does not change its parent's lexical slots. }
procedure pick_phrase_variant(var chosen_variant: integer; scan_offset, scan_count: integer);
var
  random_value: integer;
begin
  chosen_variant := 1;
  while scan_count > 0 do
  begin
    variant_marker := g16.phrase_bytes.bytes^[scan_offset];
    if (variant_marker > 64) and (variant_marker < 97) then chosen_variant := chosen_variant + 1;
    scan_offset := scan_offset + 1;
    scan_count := scan_count - 1
  end;
  random_value := random_word;
  chosen_variant := random_value mod chosen_variant
end;
