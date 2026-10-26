{ game_12 procedure22, $1272..$1349, attributes $1356; nested in1.
  Transition packet byte stores truncate to8 bits. Flag47 with a target
  present produces no message or transition. }
procedure proc12_22;
begin
  if data29.flags82[40] and not data29.flags82[47] then
  begin
    g12.words[12] := 1;
    data29.nibbles45[2] := 9;
    data29.nibbles45[1] := 1;
    proc22_19(data29.bnd339, 0);
    proc22_11(1);
    data29.bytes[540 + 8] := 0;
    data29.bytes[540 + 9] := 0;
    data29.bytes[540 + 11] := data29.words[214] + 1;
    data29.flags82[35] := true;
    data29.flags82[44] := true;
    data29.flags82[48] := false;
    data29.flags82[49] := false;
    data29.flags82[50] := false;
    if odd(g12.words[33]) then
    begin
      proc22_12(g12.words[24], g12.words[23]);
      proc22_9(g12.words[42]);
      proc22_12(g12.words[22], g12.words[21]);
      proc22_9(g12.words[42])
    end;
    data29.bytes[540 + 16] := g12.words[45];
    data29.bytes[540 + 17] := g12.words[44]
  end
  else if not data29.flags82[40] then
  begin
    proc12_2;
    proc22_44;
    proc22_48('No ship to hail');
    proc12_2
  end
end;
