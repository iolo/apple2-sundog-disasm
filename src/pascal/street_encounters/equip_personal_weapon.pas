{ game_17 procedure7, $0132..$01B9, attributes $01C4. }
procedure equip_personal_weapon;
var
  saved_item, weapon_kind, inventory_index: integer;
begin
  inventory_index := 0;
  g17.items[1].active := false;
  g17.spread_weapon_active := 0;
  while inventory_index < 4 do
  begin
    weapon_kind := word_and(data29.bytes[122 + inventory_index], 31);
    if (weapon_kind = 12) or (weapon_kind = 13) then
    begin
      if inventory_index <> 0 then
      begin
        saved_item := data29.bytes[122];
        data29.bytes[122] := data29.bytes[122 + inventory_index];
        data29.bytes[122 + inventory_index] := saved_item;
        if g17.shield_inventory_index = 0 then g17.shield_inventory_index := inventory_index
      end;
      inventory_index := 5;
      g17.items[1].active := true;
      g17.spread_weapon_active := ord(weapon_kind = 13);
      if odd(g17.spread_weapon_active) then
        g17.spread_shots_left := right_shift_word(data29.bytes[122], 5)
    end
    else inventory_index := inventory_index + 1
  end
end;
