{ library_22 procedure60, $03A0..$0443, attributes $044E; nested in29.
  Four-character value copy precedes global accesses. }
procedure proc22_60(which: integer; rates: quadchars);
var
  spare5: array[5..7] of integer;
  current: integer;
begin
  current := data29.bytes[118 + which];
  if (which <> 1) or not data29.flags82[59] then
    current := current - (ord(rates[current div 64]) - 48);
  if (which = 2) and (current > 128) then current := current + index * 4;
  if current <= 0 then
  begin
    current := 0;
    if which = 1 then
    begin
      if data29.nibbles45[2] < 7 then
      begin
        data29.nibbles45[0] := data29.nibbles45[1];
        data29.nibbles45[1] := data29.nibbles45[2]
      end;
      data29.nibbles45[2] := 10;
      data29.words[347] := 1
    end
  end
  else if current > 255 then current := 255;
  data29.bytes[118 + which] := current;
  if current < 64 then adjust := adjust + (current div 16 - 4);
  total := total + current
end;
