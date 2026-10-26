{ library_24 procedure15, $0BE2..$0DF4, attributes $0E04.
  Preserve parent slot15 sharing with nested16. It can overwrite the saved
  word223 value while nested17 runs, before the later comparison reads it. }
procedure update_ship_resources(var amount: integer);
var
  cost223: integer;      { 2 }
  delta223: integer;     { 3 }
  randomv: integer;      { 4: originally unused }
  delta225: integer;     { 5 }
  cost226: integer;      { 6 }
  delta226: integer;     { 7 }
  savedflag: boolean;    { 8: originally unused }
  timeok: boolean;       { 9: originally unused }
  unused10: array[10..14] of integer;
  index: integer;        { 15 }
  last: integer;         { 16 }
(*$include src/pascal/flight_and_effects/consume_reserve_resource.pas*)
(*$include src/pascal/flight_and_effects/adjust_resource_and_gauge.pas*)
begin
  if odd(data29.words[352]) then
  begin
    cost226 := 0;
    if (amount > 0) and (data29.bytes[258] > 0) and data29.flags82[2] then
    begin
      limit_directed_change(delta226, data29.weapon_charge,
                  left_shift_word(data29.bytes[258] + 1, 4), 255, 1);
      if delta226 > 0 then cost226 := 4
    end
    else if data29.weapon_charge > 0 then delta226 := -8
    else delta226 := 0;
    if delta226 <> 0 then
      adjust_resource_and_gauge(data29.weapon_charge, delta226, cost226, 255, data29.weapon_gauge_bounds, 4, 6, 4)
  end;
  if data29.words[352] = 2 then
  begin
    if data29.shield_charge <> data29.shield_setting then
    begin
      limit_directed_change(delta225, data29.shield_charge,
                  left_shift_word(data29.bytes[314], 3), data29.shield_setting, 1);
      adjust_resource_and_gauge(data29.shield_charge, delta225, 0, data29.shield_setting, data29.shield_gauge_bounds, 4, 5, 7)
    end;
    if data29.shield_setting > 0 then
      amount := amount - right_shift_word(data29.shield_setting + 1, 6)
  end;
  if (data29.words[352] = 3) and data29.flags82[12] then amount := amount - 12;
  if data29.words[352] = 4 then
    if data29.warp_charge <> data29.warp_setting then
    begin
      if data29.warp_charge < data29.warp_setting then
      begin
        randomv := random_word;
        if word_and(randomv, 15) < data29.bytes[202] then
          limit_directed_change(delta223, data29.warp_charge, 8, data29.warp_setting, 1)
        else delta223 := 0;
        cost223 := 2
      end
      else
      begin
        limit_directed_change(delta223, data29.warp_charge, -4, data29.warp_setting, -1);
        cost223 := 0
      end;
      index := data29.warp_charge;
      adjust_resource_and_gauge(data29.warp_charge, delta223, cost223, data29.warp_setting,
                  data29.warp_gauge_bounds, 8, 9, 11);
      if odd(data29.words[349]) and data29.flags82[0] and
         (data29.warp_charge = data29.warp_setting) and (index < data29.warp_setting) then
        data29.words[350] := 1
    end;
  consume_reserve_resource;
  if (amount = 0) and (data29.fuel_amount > 0) then
  begin
    index := 0;
    last := 4;
    while index <= last do
    begin
      if (index <> 2) or ((index = 0) and (data29.warp_charge < data29.warp_setting)) then
      begin
        data29.flags82[index] := false;
        data29.flags82[index + 8] := false;
        if index = 0 then data29.warp_setting := 0
      end;
      index := index + 1
    end;
    data29.shield_setting := 0
  end;
  { The timestamp function is called even when flag25 is false. }
  savedflag := data29.flags82[25];
  timeok := clock_has_reached(data29.clock78);
  if savedflag and timeok then
  begin
    amount := 255;
    play_sound(6, 20, 50, 0, 1, 10, 0);
    data29.flags82[25] := false;
    data29.words[350] := 1;
    if data29.flags82[40] then
    begin
      data29.target_motion_ticks := 128;
      data29.words[207] := 4
    end
  end
end;
