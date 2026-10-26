{ game_12 procedure17, $0F52..$0FBC, attributes $0FC8; nested in1.
  Preserve the extra input1 poll/store before clearing manual mode. }
procedure proc12_17;
begin
  data29.flags82[2] := true;
  g12.words[29] := 1;
  g12.words[47] := -1;
  proc22_19(data29.bnd343, 0);
  proc22_11(1);
  repeat
    if odd(proc22_2(0)) then proc12_7;
    data29.words[354] := data29.words[354] + 1;
    proc12_12
  until odd(proc22_2(1)) or odd(data29.words[347]);
  g12.words[29] := proc22_2(1);
  data29.flags82[2] := false;
  g12.words[29] := 0;
  g12.words[47] := 0;
  if not odd(g12.words[31]) then callsky(g12.words[43], 2518)
end;
