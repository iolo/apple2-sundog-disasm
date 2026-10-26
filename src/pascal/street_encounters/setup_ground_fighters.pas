{ game_17 procedure9, $0212..$03CC, attributes $03DC. }
procedure setup_ground_fighters;
var
  fighter_index, radius_roll, radius_noise, base_delay: integer;
begin
  fillchar(g17.items[0], 70, 0);
  with g17.items[1] do
  begin
    first := g17.arena_left + 67;
    second := g17.arena_top + 51;
    draw := 22;
    code := 24;
    toggle_fighter_glyph(1);
    delay := 0;
    life := data29.bytes[120] * data29.bytes[94] div 90;
    radius := data29.bytes[96] div 10;
    if life <= 32 then life := 33;
    active := true
  end;
  fighter_index := 0;
  while fighter_index <= 6 do
  begin
    with g17.trail[fighter_index] do
    begin
      first := g17.items[1].first;
      second := g17.items[1].second;
      word1 := 0;
      word0 := 0
    end;
    fighter_index := fighter_index + 1
  end;
  data29.bytes[548] := 0;
  data29.bytes[549] := 4;
  data29.bytes[550] := 2;
  data29.bytes[551] := g17.fighter_count - 1;
  data29.bytes[552] := 0;
  data29.flags82[65] := false;
  data29.flags82[66] := false;
  fighter_index := 2;
  while fighter_index <= g17.fighter_count do
  begin
    with g17.items[fighter_index] do
    begin
      draw := 23;
      code := 24;
      life := random_between(70, 250);
      radius_roll := random_word;
      radius_roll := radius_roll mod 5;
      radius_noise := random_word;
      radius := radius_roll + radius_noise mod 5;
      base_delay := random_between(10, 15);
      delay := base_delay - radius;
      first := g17.items[1].first;
      second := g17.items[1].second;
      if fighter_index > 2 then place_ground_fighter(fighter_index)
      else
      begin
        case data29.words[292] div 3 of
          0: first := first - 7;
          2: first := first + 7
        end;
        case data29.words[292] mod 3 of
          0: second := second - 8;
          2: second := second + 8
        end
      end;
      toggle_fighter_glyph(fighter_index);
      active := true
    end;
    fighter_index := fighter_index + 1
  end
end;
