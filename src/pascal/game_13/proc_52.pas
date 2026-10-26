{ game_13 procedure52, $2512..$257A, attributes $2584; nested in1.
  Preserve the literal 'Refuel ETA:  ', flag writes, two-word time copy and
  conditional random delay. The displayed value is read after the text call. }
procedure proc13_52;
var
  delay: integer;
begin
  proc22_50(data29.words[342], data29.words[341],
            data29.words[340], data29.words[339]);
  proc22_44;
  data29.flags82[25] := true;
  data29.flags82[51] := false;
  data29.clock78 := data29.clock42;
  delay := 30;
  if data29.pos72.fields.planet = 0 then delay := delay + proc22_40(30, 120);
  proc22_26(data29.clock78, delay);
  proc22_48('Refuel ETA:  ');
  proc22_28(data29.clock78)
end;
