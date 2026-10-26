{ game_12 procedure14, $0C72..$0CAC, attributes $0CB6; nested in1.
  Unlike13, flag35 suppresses the origin snapshot as well as drawing. }
procedure close_tactical_menu;
begin
  if not data29.flags82[35] then
  begin
    assign_bounds(data29.bnd335, data29.words[338], data29.words[337],
                data29.words[336] - 15, data29.words[335]);
    apply_bounds(data29.bnd335, 8);
    g12.menu_x_origin := data29.words[338];
    g12.menu_y_origin := data29.words[336]
  end
end;
