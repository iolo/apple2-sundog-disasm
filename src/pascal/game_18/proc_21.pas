{ game_18 procedure 21, $0EB2..$1057, attributes $1066.
  Parent slot 2 is an address; the copied span is slots 5..150, excluding 151.
  The saved address is the original 16-bit value -9408 ($DB40). }
procedure proc18_21;
var
  flagidx, ignored, randomv: integer;
  argaddr, saved: address16;
begin
  ignored := proc22_2(4);
  ignored := proc22_2(0);
  ignored := proc22_2(5);
  ignored := proc22_2(1);
  argaddr.word := arg2;
  if argaddr.value^ > 0 then
  begin
    g18a148[152] := -9408;
    g18a148[153] := proc22_24(g18a148[151]) - proc22_24(g18items[0].words[0]);
    saved.word := g18a148[152];
    moveleft(saved.bytes^, g18items, g18a148[153])
  end;
  g18a133[143] := 0;
  g18a133[138] := 0;
  g18a133[137] := 0;
  data29.words[2] := 2;
  { $0F18: reread the pointed-to value after the restore and stores. }
  argaddr.word := arg2;
  if argaddr.value^ > 0 then
  begin
    g18w147 := data29.bytes[550];
    with g18items[g18w147] do
    begin
      if (g18w147 > 1) and (argaddr.value^ > 15) and data29.flags82[49] then
      begin
        g18a112[123] := g18w147;
        randomv := proc22_3;
        if odd(randomv) then proc18_10(g18a112[123]);
        if not flags.bit5 then proc18_11(g18a112[123])
      end;
      if g18w147 <> 1 then
      begin
        split8.low := data29.bytes[549];
        flags.bit1 := data29.bytes[552] <> 0
      end
    end;
    if odd(g18a133[136]) and data29.flags82[65] then
    begin
      g18w111 := proc22_40(1, 4);
      proc18_15(g18w111, true);
      data29.flags82[65] := false
    end;
    data29.flags82[48] := false;
    data29.flags82[49] := false;
    data29.flags82[50] := false;
    data29.flags82[51] := false
  end
  else
  begin
    g18a133[142] := ord(arg1 = 16);
    g18a112[124] := 0;
    g18a112[123] := 0;
    g18a112[117] := data29.words[351];
    g18a112[112] := data29.words[353];
    data29.words[353] := 30;
    data29.words[351] := 1;
    g18w111 := 0;
    data29.flags82[57] := false;
    flagidx := 64;
    while flagidx <= 71 do
    begin
      data29.flags82[flagidx] := false;
      flagidx := flagidx + 1
    end;
    proc18_20;
    proc18_14
  end;
  g18w147 := 0;
  g18a112[116] := 0;
  g18a133[141] := 0;
  argaddr.word := arg2;
  argaddr.value^ := 0;
  proc22_42(g18a133[134], g18a133[133], 2, data29.bounds11)
end;
