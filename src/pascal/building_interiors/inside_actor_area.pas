{ game_18 procedure 2, entry $0000, attributes $0020, lexical level 2.
  Source: src/pcode/building_interiors.s. Interface evidence: docs/decompilation/game_18.md.
  The value parameter bounds is copied to local words 6..9 by $0000..$0003.
  Frame words: 1=result, 2=reserved, 3=bounds address, 4=second, 5=first. }
function inside_actor_area(x, y: integer;
                  bounds: bounds4): boolean;
begin
  { $0005..$0014: all four signed comparisons; LAND combines 0/1 results. }
  inside_actor_area := (bounds.lower_first <= x) and
              (x <= bounds.upper_first) and
              (bounds.lower_second <= y) and
              (y <= bounds.upper_second)
  { $0016: RNP 1 returns frame word 1. }
end;
