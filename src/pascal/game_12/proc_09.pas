{ game_12 procedure9, $04DA..$085D, attributes $0874; nested in1.
  Setup retains all conditional initialization and raw pointer construction.
  At $06FC..$06FD the original pushes integer45 as a STRING ADDRESS to22:48,
  not a glyph or literal. Preserve that raw read via the otherwise temporary
  loop-bound slot3; do not silently replace it with a character call. }
procedure proc12_9;
var
  column: integer; {1}
  work: integer;   {2}
  limit: g12scratch; {3}
begin
  data29.nibbles45[2] := 1;
  proc22_21(1024, true);
  proc12_2;
  g12.words[6] := data29.bytes[178 + 108];
  g12.words[15] := (5 + data29.bytes[94 + 2]) div 10 + 1;
  g12.words[42] := 125;
  g12.words[41] := 93;
  g12.words[4] := 0;
  if data29.flags82[122] then work := 256 else work := 0;
  g12.words[26] := 0 + work;
  g12.words[25] := 1 + work;
  g12.words[31] := ord(data29.flags82[40]);
  if odd(g12.words[31]) then proc22_19(data29.bnd303, 9);
  g12.words[30] := 1;
  g12.words[29] := 0;
  g12.words[32] := 0;
  g12.words[18] := data29.words[346] + 70 - 4;
  g12.words[17] := data29.words[344] + 48 + 3;
  data29.flags82[5] := false;
  g12.words[36] := data29.words[203];
  data29.words[203] := 0;
  g12.words[16] := proc22_30(data29.words[214], 5);
  g12.words[46] := 96;
  g12.words[47] := 0;
  data29.flags82[36] := false;
  g12.words[27] := 0;
  if not data29.flags82[35] then
  begin
    if data29.flags82[19] then
    begin
      data29.words[206] := 448 + proc22_32(proc22_3, 127);
      data29.words[205] := 448 + proc22_32(proc22_3, 127);
      g12.words[44] := proc22_31(data29.words[206], 2);
      g12.words[45] := proc22_31(data29.words[205], 2)
    end
    else
    begin
      g12.words[44] := data29.pos72.fields.w0low;
      g12.words[45] := 128
    end;
    proc22_23(proc22_24(g12.words[44]), g12.words[43]);
    if (data29.pos72.fields.xcoord = 0) and (g12.words[6] > 1) then
      callsky(g12.words[43], 2518)
    else proc22_19(data29.bnd343, 8);
    if not odd(g12.words[31]) then
    begin
      work := 41;
      limit.word := 47;
      while work <= limit.word do
      begin
        data29.flags82[work] := false;
        work := work + 1
      end
    end;
    proc24_9;
    proc22_19(data29.bnd339, 8);
    proc22_13(1);
    proc24_2(28, 42, 152);
    proc24_2(28, 105, 152);
    proc22_13(0);
    proc22_12(42 - 18, 152 - 21);
    proc22_13(10);
    proc22_12(42, 152);
    proc22_12(42 + 18 + 1, 152 - 21);
    proc22_13(0);
    proc22_12(105 - 23, 152 - 16);
    proc22_13(9);
    proc22_12(105, 152);
    proc22_12(105 - 23, 152 + 16);
    proc22_13(0);
    proc24_9;
    proc22_50(105 + 28 + 4, data29.words[341], data29.words[340], data29.words[339]);
    proc22_44;
    proc22_11(3);
    proc22_47(43);
    column := 1;
    limit.word := 20;
    while column <= limit.word do
    begin
      proc22_47(44);
      column := column + 1
    end;
    limit.word := 45;
    proc22_48(limit.caption^);
    work := 1;
    limit.word := 6;
    while work <= limit.word do
    begin
      proc22_46(0, 1 + 2 * work);
      proc22_47(75);
      proc22_46(21, 1 + 2 * work);
      proc22_47(77);
      work := work + 1
    end;
    proc22_46(0, 15);
    proc22_47(107);
    column := 1;
    limit.word := 20;
    while column <= limit.word do
    begin
      proc22_47(108);
      column := column + 1
    end;
    proc22_9(109);
    proc24_9
  end
  else
  begin
    data29.flags82[35] := false;
    data29.flags82[44] := false;
    if data29.flags82[49] then
    begin
      data29.flags82[49] := false;
      data29.words[215] := 128;
      data29.words[207] := 2
    end
    else if data29.flags82[51] then
    begin
      g12.words[28] := 1;
      g12.words[14] := 6;
      data29.flags82[51] := false
    end
    else data29.flags82[44] := true;
    data29.flags82[41] := false;
    data29.flags82[47] := true;
    g12.words[45] := data29.bytes[540 + 16];
    g12.words[44] := data29.bytes[540 + 17];
    proc22_23(proc22_24(g12.words[44]), g12.words[43])
  end;
  proc12_5;
  g12.words[33] := 0;
  g12.words[5] := proc22_31(data29.words[353], 1);
  if odd(g12.words[31]) then
  begin
    proc22_19(data29.bnd339, 0);
    proc22_11(1);
    if g12.words[6] > 4 then
    begin
      g12.words[33] := 1;
      work := proc22_31(data29.words[217], 2);
      proc12_8(data29.words[206] + 256, work, 42, 152, g12.words[24], g12.words[23]);
      proc12_8(-data29.words[205], work, 105, 152, g12.words[22], g12.words[21])
    end
  end
  else data29.flags82[41] := false;
  g12.words[11] := 0;
  proc22_16(data29.words[344], data29.words[346] div 7)
end;
