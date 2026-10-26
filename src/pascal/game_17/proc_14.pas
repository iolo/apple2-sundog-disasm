{ game_17 procedure14, $068C..$07C0, attributes $07CC. }
procedure proc17_14(origin, firstpos, secondpos: integer);
var
  distance, found, remaining, oldlife, randomv: integer;
  hit: boolean;
begin
  with g17.items[origin] do
    distance := proc22_35(first - firstpos) + proc22_35(second - secondpos);
  if origin = 1 then distance := distance - data29.bytes[95];
  hit := proc17_13(origin, firstpos, secondpos, distance, found);
  if origin = found then exit(proc17_14);
  with g17.items[origin] do
    proc22_12(first + 3, second - 3);
  proc22_13(3);
  proc22_12(firstpos + 3, secondpos - 3);
  proc22_4(8, 80, 5, 0, 0, 0, 0);
  proc22_13(0);
  with g17.items[origin] do
    proc22_12(first + 3, second - 3);
  proc22_13(3);
  proc22_12(firstpos + 3, secondpos - 3);
  proc22_13(0);
  if hit and (found > 0) then
    with g17.items[found] do
      if odd(g17.words[41]) and (found = 1) then
      begin
        g17.words[76] := g17.words[76] - 1;
        proc22_4(4, 50, 50, 0, 0, 0, 0);
        if g17.words[76] = 0 then
        begin
          proc22_4(10, 10, 50, 0, 0, 0, 1);
          data29.bytes[122 + g17.words[77]] := 7;
          proc17_6
        end
      end
      else
      begin
        proc22_4(8, 40, 10, 0, 0, 0, 1);
        oldlife := life;
        randomv := proc22_3;
        remaining := oldlife - 4 * (randomv mod 16);
        if remaining < 0 then remaining := 0;
        life := remaining;
        if life <= 32 then
        begin
          proc17_3(found);
          draw := 25;
          proc17_3(found);
          if found = 1 then proc17_5
          else if life = 0 then
          begin
            proc17_4(found);
            g17.words[39] := ord(g17.words[94] = 1);
            if odd(g17.words[39]) then data29.words[217] := 15
          end
        end
      end
end;
