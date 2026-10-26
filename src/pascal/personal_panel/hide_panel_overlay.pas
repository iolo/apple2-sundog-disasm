{ game_8 procedure4, $007A..$0098, attributes $00A2; nested inside3.
  First flag takes precedence. Both branches use the grandparent's live
  coordinates, so the second call after drawing rereads them. }
procedure hide_panel_overlay;
begin
  if item_overlay then plot_item_icon(personal_state[7], personal_state[6])
  else if cursor_overlay then toggle_pointer_glyph(personal_state[13], personal_state[12])
end;
