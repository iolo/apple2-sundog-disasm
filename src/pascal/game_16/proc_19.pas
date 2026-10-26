{ game_16 procedure19, $077A..$079B, attributes $07A6.
  Initialize the display on the first flush, then write the raw length byte.
  The final flush happens even for an empty buffer. }
procedure proc16_19;
begin
  if not odd(printed) then proc22_44;
  printed := 1;
  line.bytes[0] := next - 1;
  proc22_48(line.text);
  next := 1
end;
