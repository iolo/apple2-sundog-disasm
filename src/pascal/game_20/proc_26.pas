{ game_20 procedure26, $1522..$1578, attributes $1582. }
function proc20_26(var slot: integer): boolean;
begin
  proc20_26 := true;
  proc20_11(slot, false);
  if (slot <= 0) and odd(g20.words[17]) then proc20_11(slot, true);
  if slot <= 0 then
  begin
    proc22_44;
    proc22_48('No space left in warehouse');
    if odd(g20.words[17]) then proc22_48(' or pod');
    proc20_2;
    proc20_26 := false
  end
end;
