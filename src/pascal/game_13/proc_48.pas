{ game_13 procedure48, $221C..$2307, attributes $2312; nested in47.
  Menu bounds belong to grandparent1 slots8/7/6. The city-count read always
  follows flag21's read, even if that flag is false. Use otherwise unused
  parent47 slots2..4 to retain that order without enlarging either frame. }
procedure proc13_48;
begin
  proc25_2;
  raw13[8] := 4;
  raw13[7] := 62;
  raw13[6] := 4;
  proc13_42(1, 'MAPS');
  if data29.loc73.mid5 > 0 then
  begin
    if data29.pos72.fields.city = 0 then proc13_42(4, 'LAND')
    else
    begin
      proc13_42(2, 'LIFTOFF');
      navflag := data29.flags82[21];
      navrow.word := data29.words[24] + 16 * (data29.loc73.mid5 - 1);
      navcount := navrow.planetrow^.place7.low9 mod 8;
      if navflag and (navcount > 1) then proc13_42(3, 'CITY-CITY')
    end
  end;
  if data29.pos72.fields.city = 0 then
  begin
    if data29.flags82[1] then proc13_42(5, 'HALT');
    proc13_42(6, 'SUB-LIGHT')
  end;
  if data29.flags82[0] then
  begin
    if (data29.words[223] >= data29.words[222]) and (data29.loc73.mid5 = 0) then
      proc13_42(7, 'DO WARP');
    proc13_42(9, 'STOP WARP')
  end
  else proc13_42(8, 'SET WARP')
end;
