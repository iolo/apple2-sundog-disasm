{ game_17 procedure13, $0608..$067E, attributes $068A.
  Frame7=origin,6=firstpos,5=secondpos,4=distance,3=found address,1=result.
  The loop tests found<count before incrementing, so it visits entries1..count.
  The random threshold call happens even when no entries will be scanned. }
function proc17_13(origin, firstpos, secondpos, distance: integer;
                   var found: integer): boolean;
var
  hit, nearfirst, nearsecond: boolean;
  radiusval, randomv, threshold: integer;
begin
  hit := false;
  found := 0;
  if origin = 1 then radiusval := g17.items[1].radius else radiusval := 3;
  threshold := 3 * radiusval;
  randomv := proc22_3;
  threshold := threshold + randomv mod 128;
  if distance < threshold then
    while (found < g17.words[94]) and not hit do
    begin
      found := found + 1;
      with g17.items[found] do
        if life = 0 then hit := false
        else
        begin
          nearfirst := proc22_35(first - firstpos) < radiusval;
          nearsecond := proc22_35(second - secondpos) < radiusval;
          hit := nearfirst and nearsecond
        end
    end;
  proc17_13 := hit
end;
