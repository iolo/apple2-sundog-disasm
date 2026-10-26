{ game_17 procedure11, $0418..$051B, attributes $0526.
  Keep exactly two local words: count must occupy slot2. The original copy
  length subtracts this CHILD address from PARENT slot99, not parent slot4.
  Under the original frame allocator this is212 bytes, extending16 bytes
  beyond the parent's196-byte local area. Preserve the raw operation. }
procedure proc17_11;
var
  input4: integer;
  count: integer;
begin
  data29.words[2] := 2;
  if arg1 <> 0 then
  begin
    count := proc22_24(g17.words[99]) - proc22_24(count);
    g17.ptr100.word := -9408;
    moveleft(g17.ptr100.bytes^, g17, count);
    data29.bounds11 := g17.saved43;
    proc17_10(false);
    if data29.flags82[48] then proc17_5
    else if data29.flags82[49] then
    begin
      g17.words[78] := 2;
      data29.flags82[49] := false
    end;
    repeat
      input4 := proc22_2(4);
      count := proc22_2(5)
    until not odd(input4) and not odd(count)
  end
  else
  begin
    if data29.words[217] = 16 then
    begin
      data29.flags82[50] := false;
      g17.words[94] := proc22_40(2, 6)
    end
    else if data29.words[217] <> 15 then
    begin
      data29.flags82[50] := true;
      g17.words[94] := 2
    end;
    { Mode15 deliberately leaves count94 unchanged. }
    g17.words[81] := data29.words[351];
    data29.words[351] := 1;
    g17.words[78] := 0;
    proc17_10(true);
    proc17_9;
    data29.flags82[48] := false;
    data29.flags82[49] := false
  end;
  proc17_6;
  g17.words[39] := 0;
  g17.words[42] := ord(data29.words[217] = 15);
  proc22_19(data29.bounds11, 0);
  g17.items[1].active := false;
  g17.words[40] := 0;
  g17.words[75] := 0;
  if not data29.flags82[50] then proc17_7
end;
