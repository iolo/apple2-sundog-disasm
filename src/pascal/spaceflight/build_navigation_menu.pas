{ game_13 procedure48, $221C..$2307, attributes $2312; nested in47.
  Menu bounds belong to grandparent1 slots8/7/6. The city-count read always
  follows flag21's read, even if that flag is false. Use otherwise unused
  parent47 slots2..4 to retain that order without enlarging either frame. }
procedure build_navigation_menu;
begin
  reset_menu;
  space_ui[8] := 4;
  space_ui[7] := 62;
  space_ui[6] := 4;
  append_space_button(1, 'MAPS');
  if data29.loc73.mid5 > 0 then
  begin
    if data29.pos72.fields.city = 0 then append_space_button(4, 'LAND')
    else
    begin
      append_space_button(2, 'LIFTOFF');
      city_access := data29.flags82[21];
      planet_row.word := data29.words[24] + 16 * (data29.loc73.mid5 - 1);
      city_count := planet_row.planetrow^.place7.low9 mod 8;
      if city_access and (city_count > 1) then append_space_button(3, 'CITY-CITY')
    end
  end;
  if data29.pos72.fields.city = 0 then
  begin
    if data29.flags82[1] then append_space_button(5, 'HALT');
    append_space_button(6, 'SUB-LIGHT')
  end;
  if data29.flags82[0] then
  begin
    if (data29.warp_charge >= data29.warp_setting) and (data29.loc73.mid5 = 0) then
      append_space_button(7, 'DO WARP');
    append_space_button(9, 'STOP WARP')
  end
  else append_space_button(8, 'SET WARP')
end;
