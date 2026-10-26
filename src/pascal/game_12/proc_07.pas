{ game_12 procedure7, $0296..$0461, attributes $0474; nested in1.
  Both absolute-distance calls precede the disabled-weapon self EXIT. That
  early exit skips charge clearing; all other paths reach the common tail.
  Slot9 is the original reused loop bound/system-row pointer. }
procedure proc12_7;
var
  unused1: integer;
  divisor: integer; {2}
  unused3: integer;
  power: integer; {4}
  reach: integer; {5}
  dy: integer; {6}
  dx: integer; {7}
  hull: integer; {8; later flag-loop index}
  scratch: g12scratch; {9}
begin
  dx := proc22_35(data29.words[206] - 512);
  dy := proc22_35(data29.words[205] - 512);
  if (data29.bytes[178 + 80] = 0) or (data29.words[226] = 0) then
    exit(proc12_7);
  if g12.words[6] > 1 then
  begin
    if odd(g12.words[30]) then callbeam(g12.words[26], 2048)
    else callbeam(g12.words[25], 2048)
  end;
  if odd(g12.words[30]) then reach := g12.words[15] - proc22_31(data29.words[217], 5)
  else reach := 2 * g12.words[15] - proc22_31(data29.words[217], 4);
  if reach < 0 then reach := 0;
  if odd(g12.words[31]) then
  begin
    data29.bytes[178 + 193] := proc22_31(data29.bytes[178 + 193] + 127, 1);
    if dx + dy <= reach then
    begin
      proc22_4(2, 100, 50, 0, 0, 0, 1);
      data29.words[354] := data29.words[354] + 1;
      data29.words[215] := 4;
      if data29.flags82[18] then power := 6 else power := 5;
      if odd(g12.words[30]) then divisor := proc22_30(dy + dx, 4)
      else divisor := proc22_30(data29.words[217] + dy + dx, 1);
      if divisor <= 0 then divisor := 1;
      hull := data29.words[216] -
                proc22_30(data29.words[226] + 1, power - data29.words[214]) div divisor;
      if hull <= 0 then
      begin
        data29.words[216] := 0;
        hull := 41;
        scratch.word := 47;
        while hull <= scratch.word do
        begin
          data29.flags82[hull] := false;
          hull := hull + 1
        end;
        g12.words[31] := 0;
        scratch.word := data29.words[23] + 20 * (data29.loc73.low4 - 1);
        scratch.row^.nibbles8[7] := scratch.row^.nibbles8[7] + data29.words[214];
        g12.words[11] := 0;
        g12.words[32] := 0;
        g12.words[44] := 128;
        g12.words[45] := data29.pos72.fields.w0low;
        if g12.words[6] > 0 then
        begin
          proc24_3(0);
          callsky(g12.words[43], 2518)
        end
        else proc22_19(data29.bnd343, 8);
        proc12_2;
        proc12_6;
        proc12_2
      end
      else
      begin
        data29.words[216] := hull;
        proc12_3
      end
    end
    else if dx + dy < proc22_30(reach, 2) then data29.words[215] := 0
  end;
  data29.words[226] := 0;
  proc24_7(data29.bnd319, data29.words[226], 4, 6)
end;
