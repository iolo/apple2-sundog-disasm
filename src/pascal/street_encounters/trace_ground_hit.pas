{ game_17 procedure13, $0608..$067E, attributes $068A.
  Frame7=origin,6=firstpos,5=secondpos,4=distance,3=found address,1=result.
  The loop tests found<count before incrementing, so it visits entries1..count.
  The random threshold call happens even when no entries will be scanned. }
function trace_ground_hit(shooter_index, target_x, target_y, shot_distance: integer;
                   var hit_index: integer): boolean;
var
  hit, near_x, near_y: boolean;
  hit_radius, random_value, distance_gate: integer;
begin
  hit := false;
  hit_index := 0;
  if shooter_index = 1 then hit_radius := g17.items[1].radius else hit_radius := 3;
  distance_gate := 3 * hit_radius;
  random_value := random_word;
  distance_gate := distance_gate + random_value mod 128;
  if shot_distance < distance_gate then
    while (hit_index < g17.fighter_count) and not hit do
    begin
      hit_index := hit_index + 1;
      with g17.items[hit_index] do
        if life = 0 then hit := false
        else
        begin
          near_x := word_abs(first - target_x) < hit_radius;
          near_y := word_abs(second - target_y) < hit_radius;
          hit := near_x and near_y
        end
    end;
  trace_ground_hit := hit
end;
