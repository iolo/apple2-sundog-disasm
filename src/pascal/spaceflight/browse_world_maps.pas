{ game_13 procedure46, $217A..$2209, attributes $221A; nested in1.
  Three nested map levels retain their title/pop order. After returning from
  a deeper level, store the full complement of word347, not a Boolean1/0.
  All12 location bytes are copied before flag31 is enabled. }
procedure browse_world_maps;
var
  map_selected: integer; {1}
  browsed_place: g19loc; {2..7}
begin
  open_space_menu('MAPS');
  browsed_place := data29.pos36;
  map_selected := 0;
  data29.flags82[31] := true;
  repeat
    select_map_location(1, browsed_place, map_selected, 0, 0);
    if odd(map_selected) then
    begin
      open_space_menu(data29.names23.systems^[browsed_place.fields.system].caption);
      repeat
        select_map_location(2, browsed_place, map_selected, 0, 0);
        if odd(map_selected) and (browsed_place.fields.planet > 0) then
        begin
          open_space_menu(data29.names24.planets^[browsed_place.fields.planet]);
          repeat
            select_map_location(3, browsed_place, map_selected, 0, 1)
          until (not odd(map_selected)) or odd(data29.words[347]);
          close_space_menu;
          map_selected := -1 - data29.words[347]
        end
      until not odd(map_selected);
      close_space_menu;
      map_selected := -1 - data29.words[347]
    end
  until not odd(map_selected);
  close_space_menu;
  data29.flags82[31] := false
end;
