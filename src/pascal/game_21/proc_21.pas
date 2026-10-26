{ game_21 procedure21, $0AEA..$0BBA, attributes $0BC4.
  The map is24 rows of40 bytes. Keep proximity calls unconditional at their
  original predicate sites and capture preceding flags before each call. }
procedure proc21_21;
var
  mapx, mapy, changed: integer;
  allowed, nearx, neary: boolean;
begin
  mapx := (arg6 + (g21.words[26] + 3) div 28) mod 40;
  mapy := (arg5 + (g21.words[25] - 3) div g21.words[21]) mod 24;
  arg2 := g21.map55.rows^[mapy][mapx];
  changed := 0;
  allowed := (data29.bits37.mid6 = data29.pos228.fields.city) and
             data29.flags45[13] and not data29.flags82[7];
  nearx := proc21_14(mapx, data29.pos228.fields.kind2, 1);
  neary := proc21_14(mapy, data29.pos228.fields.kind3, 1);
  if allowed and nearx and neary then proc21_16(changed);
  if not odd(changed) and (data29.nibbles45[2] = 3) and (arg2 > 6) then
    proc21_19(changed);
  allowed := not odd(changed) and (data29.bits37.mid6 = data29.bits73.mid6);
  nearx := proc21_14(mapx, data29.pos72.fields.kind2, 3);
  if allowed and nearx and (mapy = data29.pos72.fields.kind3) then proc21_15(changed);
  if not odd(changed) and (data29.nibbles45[2] = 4) then
    if arg2 = 13 then proc21_18(mapx, mapy)
end;
