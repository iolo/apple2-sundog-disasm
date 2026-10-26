{ game_16 procedure36, $118A..$11A7, attributes $11B2.
  Nested in35; capture the grandparent's selected bounds address once. }
function proc16_36(posx, posy, itemidx: integer): boolean;
begin
  with g16.buttons72[itemidx] do
    proc16_36 := (lower_first <= posx) and (posx <= upper_first) and
                 (lower_second <= posy) and (posy <= upper_second)
end;
