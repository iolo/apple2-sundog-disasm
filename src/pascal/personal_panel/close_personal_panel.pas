{ game_8 procedure18, $0AF4..$0B48, attributes $0B52. }
procedure close_personal_panel;
begin
  toggle_pointer_glyph(personal_state[13], personal_state[12]);
  pop_text_window;
  data29.nibbles45[2] := data29.nibbles45[1];
  if data29.nibbles45[2] >= 5 then
    data29.nibbles45[1] := data29.nibbles45[0]
  else data29.nibbles45[1] := 7;
  data29.nibbles45[0] := 11;
  data29.bounds11 := saved_personal_bounds;
  data29.words[351] := personal_state[21];
  data29.words[353] := personal_state[20]
end;
