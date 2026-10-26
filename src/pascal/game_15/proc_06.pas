{ game_15 procedure6, $023A..$026D, attributes $0278.
  FJP uses bit0 of word347. Original four unused local bytes are omitted. }
procedure proc15_6;
begin
  data29.flags82[116] := false;
  data29.flags82[117] := false;
  if not odd(data29.words[347]) then data29.nibbles45[2] := 3;
  g15.words[1] := 0;
  data29.words[292] := 6;
  g15.words[5] := g15.words[5] + 20;
  proc15_5
end;
