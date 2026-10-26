{ game_13 procedure39, $1D5C..$1F85, attributes $1F92; nested in27.
  Copy system-row words6/7 as raw signed words before any display calls; these
  overlap the caption view. Do not substitute the trailing words8/9.
  All four error paths self-EXIT39; the enclosing27 still performs its copies.
  Native transition mutates packet byte3; preserve the original VAR call. }
procedure proc13_39(var place: g19loc);
var
  neither: integer; {2, unused result of original complement}
  landing: boolean; {3}
  lifting: boolean; {4}
  unused5: integer;
  unused6: integer;
  unused7: integer;
  destcity: integer;{8}
  oldcity: integer; {9}
  unused10: integer;
  destname: text15; {11..18}
  oldname: text15;  {19..26}
  debts: wordpair;  {27..28}
(*$include src/pascal/game_13/proc_40.pas*)
(*$include src/pascal/game_13/proc_41.pas*)
begin
  oldcity := data29.pos72.fields.city;
  destcity := place.fields.city;
  moveleft(data29.tbl23.rows^[data29.loc37.low4].prefix8[6], debts, 4);
  lifting := (oldcity <> 0) and (destcity = 0);
  landing := oldcity = 0;
  neither := -1 - ord(lifting or landing);
  proc13_40(oldname, oldcity);
  proc13_40(destname, destcity);
  proc13_28('PLANETARY', oldname, destname);
  if data29.words[227] = 0 then
  begin
    proc13_29(0);
    exit(proc13_39)
  end
  else if data29.bytes[178 + 52] = 0 then
  begin
    proc13_29(5);
    exit(proc13_39)
  end
  else if lifting and ((debts.first < 0) or (debts.second < 0)) then
  begin
    proc13_29(6);
    exit(proc13_39)
  end
  else if odd(saved22) and lifting then
  begin
    proc13_29(3);
    exit(proc13_39)
  end;
  proc24_9;
  proc13_31(119, 2, 7, 0, 1);
  data29.clock80 := data29.clock42;
  data29.pos66 := place;
  data29.flags82[30] := (oldcity = 0) and (destcity <> 0);
  data29.flags82[38] := true;
  data29.flags82[40] := false;
  proc22_19(data29.bnd303, 5);
  data29.flags82[25] := false;
  data29.words[204] := 3;
  data29.words[203] := 3;
  data29.flags82[5] := false;
  if (oldcity = 0) or (destcity = 0) then data29.words[211] := 5
  else data29.words[211] := 20;
  proc22_26(data29.clock80, data29.words[211]);
  proc22_48('ETA:   ');
  proc22_28(data29.clock80);
  proc22_45;
  if (data29.words[224] > 0) or data29.flags82[4] or data29.flags82[12] then
  begin
    proc22_48('Turning off ');
    if data29.flags82[12] then proc22_48('cloaker ');
    if data29.flags82[4] or (data29.words[224] > 0) then
    begin
      if data29.flags82[12] then proc22_48('and ');
      proc22_48('shields')
    end;
    data29.words[224] := 0;
    data29.flags82[4] := false;
    data29.flags82[12] := false;
    proc24_7(data29.bnd315, data29.words[225], 4, 5)
  end;
  proc22_48('\Switching to viewscreen');
  if lifting then proc13_41(-1, oldcity, 0)
  else if landing then proc13_41(0, destcity, 0)
  else proc13_41(1, oldcity, destcity);
  callview(packet, 6144);
  data29.clock42 := data29.clock80;
  data29.words[354] := data29.words[353] + 1;
  proc24_9;
  data29.pos72 := data29.pos66;
  data29.words[350] := 0
end;
