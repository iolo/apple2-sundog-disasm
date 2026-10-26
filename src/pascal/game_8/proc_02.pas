{ game_8 procedure 2, $0000..$006D, attributes $0078. }
procedure proc8_2(index: integer);
var
  edge, mode: integer;
begin
  with g8bars[index] do
  begin
    edge := data29.bytes[118 + index];
    if edge < 64 then mode := 6
    else if edge < 128 then mode := 9
    else if edge < 192 then mode := 5
    else mode := 10;
    edge := lower_first + (edge + 7) div 8;
    proc22_14(lower_first, edge, lower_second, upper_second);
    proc22_7(mode);
    if edge < upper_first then
    begin
      proc22_14(edge + 1, upper_first, lower_second, upper_second);
      if mode < 9 then proc22_7(4)
      else proc22_7(8)
    end
  end
end;
