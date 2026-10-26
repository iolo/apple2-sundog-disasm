{ game_16 procedure14, $05BA..$05F4, attributes $0600.
  Nested in13: updates its glyph at slot4 while counting65..96 bytes.
  The VAR count starts at1; read its divisor after the unconditional random
  call. Added random local does not change its parent's lexical slots. }
procedure proc16_14(var selection: integer; atbyte, count: integer);
var
  randomv: integer;
begin
  selection := 1;
  while count > 0 do
  begin
    glyph := g16.table141.bytes^[atbyte];
    if (glyph > 64) and (glyph < 97) then selection := selection + 1;
    atbyte := atbyte + 1;
    count := count - 1
  end;
  randomv := proc22_3;
  selection := randomv mod selection
end;
