{ game_16 procedure10, $0234..$0251, attributes $025C.
  Capture the byte before calling9. For index4, halve that captured value
  afterward, regardless of the Boolean result. }
function test_player_attribute(stat_index, chance_adjustment: integer): boolean;
var
  captured_attribute: integer;
begin
  captured_attribute := data29.bytes[94 + stat_index];
  test_player_attribute := roll_dialog_chance(captured_attribute + chance_adjustment);
  if stat_index = 4 then data29.bytes[94 + stat_index] := captured_attribute div 2
end;
