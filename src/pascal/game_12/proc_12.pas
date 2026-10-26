{ game_12 procedure12, $09F4..$0BF6, attributes $0C02; nested in1.
  Native joystick writes local1(vertical)/2(horizontal); local3 is scratch.
  Both conditional input0 polls and both movement10 calls remain separate.
  Update31 uses the low-bit typed NEQ6 comparison against global flag40. }
procedure proc12_12;
var
  motion: wordpair; {1/2}
  speed: integer; {3}
begin
  if odd(g12.words[29]) then callstick(motion, 2675)
  else if data29.flags82[19] and odd(g12.words[31]) then
  begin
    if odd(g12.words[32]) then
    begin
      speed := 3 - proc22_31(data29.words[217], 5);
      if speed < 0 then speed := 0;
      motion.second := -proc22_31(speed * data29.words[209], 1);
      motion.first := -proc22_31(speed * data29.words[208], 1)
    end
    else
    begin
      motion.second := proc22_30(proc22_34(512 - data29.words[206]), 3);
      motion.first := proc22_30(proc22_34(512 - data29.words[205]), 3)
    end
  end
  else
  begin
    motion.second := 0;
    motion.first := 0
  end;
  if odd(g12.words[29]) then
    if odd(proc22_2(0)) then proc12_7;
  if odd(g12.words[27]) then
  begin
    data29.words[217] := data29.words[217] + data29.words[207];
    if data29.words[217] <= 2 then data29.words[217] := 1
    else if data29.words[217] > 128 then
    begin
      g12.words[27] := 0;
      data29.flags82[36] := false
    end
  end;
  if (not odd(g12.words[32])) or (data29.words[354] = g12.words[5]) or
     (g12.words[3] > 0) then
  begin
    proc22_19(data29.bnd339, 0);
    proc22_11(1);
    g12.words[3] := g12.words[3] - 1;
    if odd(g12.words[33]) then
    begin
      proc22_12(g12.words[24], g12.words[23]);
      proc22_9(g12.words[42]);
      proc22_12(g12.words[22], g12.words[21]);
      proc22_9(g12.words[42])
    end;
    if (odd(g12.words[31]) or odd(g12.words[27])) and (g12.words[6] > 4) then
    begin
      g12.words[33] := 1;
      speed := proc22_31(data29.words[217], 2);
      proc12_8(data29.words[206] + 256, speed, 42, 152, g12.words[24], g12.words[23]);
      proc12_8(-data29.words[205], speed, 105, 152, g12.words[22], g12.words[21])
    end
    else g12.words[33] := 0
  end;
  proc12_10(motion.second, motion.first);
  if odd(g12.words[29]) then
    if odd(proc22_2(0)) then proc12_7;
  if data29.words[354] >= data29.words[353] then
  begin
    if data29.flags82[45] then proc12_11;
    proc24_9;
    if odd(g12.words[28]) then
    begin
      if g12.words[14] > 0 then g12.words[14] := g12.words[14] - 1
      else
      begin
        g12.words[28] := 0;
        data29.flags82[44] := true
      end
    end;
    g12.words[6] := data29.bytes[178 + 108];
    proc12_10(motion.second, motion.first);
    g12.words[11] := ord(data29.flags82[41]);
    if data29.flags82[40] <> odd(g12.words[31]) then
    begin
      g12.words[31] := ord(data29.flags82[40]);
      if odd(g12.words[31]) then g12.words[16] := proc22_30(data29.words[214], 5);
      proc12_2;
      proc12_4;
      proc12_2
    end
  end
end;
