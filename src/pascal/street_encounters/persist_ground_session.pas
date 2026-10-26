{ game_17 procedure12, $0528..$05FD, attributes $0606.
  Keep exactly one local word, count in slot1. This slot has the same physical
  address as child11's slot2 under the original call-frame allocator.
  The raw save includes memory beyond the declared parent frame; see notes. }
procedure persist_ground_session;
var
  copy_size_or_vigor: integer;
begin
  if odd(g17.personal_shield_active) then
    data29.bytes[122 + g17.shield_inventory_index] := 11 + left_shift_word(g17.shield_hits_left, 5);
  if odd(g17.spread_weapon_active) then
    data29.bytes[122] := 13 + left_shift_word(g17.spread_shots_left, 5);
  data29.bytes[120] := 90 * g17.items[1].life div data29.bytes[94];
  copy_size_or_vigor := 2 * data29.bytes[120];
  if copy_size_or_vigor < data29.bytes[118] then data29.bytes[118] := copy_size_or_vigor;
  if (data29.nibbles45[2] < 7) or (data29.nibbles45[2] > 10) then
  begin
    pop_text_window;
    apply_bounds(data29.bounds7, 0);
    if not odd(data29.words[347]) then
    begin
      data29.nibbles45[2] := data29.nibbles45[1];
      data29.nibbles45[1] := 5;
      data29.nibbles45[0] := 11
    end;
    data29.words[351] := g17.saved_clock_step;
    resume_selector := 0
  end
  else
  begin
    g17.resume_bounds := data29.bounds11;
    copy_size_or_vigor := word_address(g17.save_anchor) - word_address(copy_size_or_vigor);
    g17.resume_image.word := -9408;
    moveleft(g17, g17.resume_image.bytes^, copy_size_or_vigor)
  end
end;
