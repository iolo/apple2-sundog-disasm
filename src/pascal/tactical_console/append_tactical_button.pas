{ game_12 procedure16, $0CB8..$0CD9, attributes $0CE4; nested in15.
  The value labeltext occupies slots3..10. Parent slots3/4/5 hold bounds. }
procedure append_tactical_button(itemcode: integer; labeltext: text15);
begin
  add_menu_button(itemcode, labeltext, left, right, top, top + 10);
  top := top + 15
end;
