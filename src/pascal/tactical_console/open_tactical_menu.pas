{ game_12 procedure13, $0C04..$0C65, attributes $0C70; nested in1.
  Value caption is copied to slots2..9. Both poll outputs alias slot11.
  The origin snapshot is unconditional, even when flag35 skips drawing. }
procedure open_tactical_menu(caption: text15);
var
  code: integer; {10; initially unspecified}
  poll: integer; {11; initially unspecified}
begin
  if not data29.flags82[35] then
  begin
    reset_menu;
    add_menu_button(1, caption, 4, 62, 3, 13);
    apply_bounds(data29.bnd335, 8);
    draw_menu(data29.bnd335);
    activate_menu_item(1, code, data29.bnd335, poll, poll);
    assign_bounds(data29.bnd335, data29.words[338], data29.words[337],
                data29.words[336] + 15, data29.words[335])
  end;
  g12.menu_x_origin := data29.words[338];
  g12.menu_y_origin := data29.words[336]
end;
