{ game_13 procedure44, $2082..$20A3, attributes $20AE; nested in1.
  Undo the title strip's15-unit bounds shift before filling that area. }
procedure close_space_menu;
begin
  assign_bounds(data29.bnd335, data29.words[338], data29.words[337],
            data29.words[336] - 15, data29.words[335]);
  apply_bounds(data29.bnd335, 8)
end;
