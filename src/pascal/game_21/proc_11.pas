{ game_21 procedure11, $030A..$03B9, attributes $03C2.
  Capture the six-word city row before packed writes; retain ordered edges. }
procedure proc21_11(xpos, ypos, xradius, yradius: integer);
var
  cityrow: g19caddr;
begin
  data29.nibbles45[1] := data29.nibbles45[2];
  data29.nibbles45[2] := 4;
  cityrow.word := data29.words[25] + 12 * (data29.bits37.mid6 - 1);
  data29.bits38.low6 := cityrow.rows^[1].coords5.low6;
  data29.bits39.low5 := cityrow.rows^[1].coords5.mid5;
  data29.words[40] := 11;
  data29.bytes[80] := 16;
  if xpos < 12 - xradius then data29.words[40] := 0
  else if xpos > 17 + xradius then data29.words[40] := 21;
  if ypos < 7 - yradius then data29.bytes[80] := 7
  else if ypos > 11 + yradius then data29.bytes[80] := 23;
  if (data29.words[40] = 11) and (data29.bytes[80] = 16) then
    data29.words[40] := 0;
  data29.words[40] := data29.words[40] + 140;
  data29.bytes[80] := data29.bytes[80] + 96;
  data29.bits37.mid6 := 0
end;
