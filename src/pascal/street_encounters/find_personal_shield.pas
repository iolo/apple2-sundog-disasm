{ game_17 procedure6, $00DC..$0125, attributes $0130.
  DATASEG29 word62 byte0 is absolute byte122. The scan still reads byte126
  when index reaches4: do not move the index guard ahead of the native call. }
procedure find_personal_shield;
begin
  g17.shield_inventory_index := 0;
  while (word_and(data29.bytes[122 + g17.shield_inventory_index], 31) <> 11)
        and (g17.shield_inventory_index < 4) do
    g17.shield_inventory_index := g17.shield_inventory_index + 1;
  g17.personal_shield_active := ord(g17.shield_inventory_index < 4);
  if odd(g17.personal_shield_active) then
    g17.shield_hits_left := right_shift_word(data29.bytes[122 + g17.shield_inventory_index], 5)
  else g17.shield_hits_left := 0
end;
