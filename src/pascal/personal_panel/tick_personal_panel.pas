{ game_8 procedure3, $00A4..$00FB, attributes $0108.
  Included inside the recovered procedure1 scope, named proc8_1 for EXIT.
  Two Boolean arguments occupy original slots2/1; current callers pass 0/1. }
procedure tick_personal_panel(item_overlay, cursor_overlay: boolean);
var
  bar_index: integer;
  last_condition: integer;
(*$include src/pascal/personal_panel/hide_panel_overlay.pas*)
begin
  if data29.nibbles45[1] <= 2 then update_flight_state
  else advance_clock_and_conditions;
  if odd(personal_state[15]) and data29.flags82[60] then begin
    hide_panel_overlay;
    bar_index := 0;
    last_condition := 3;
    while bar_index <= last_condition do begin
      draw_condition_bar(bar_index);
      bar_index := bar_index + 1
    end;
    hide_panel_overlay;
    data29.flags82[60] := false
  end;
  set_glyph_mode(1);
  if data29.nibbles45[2] = 12 then begin
    pop_text_window;
    exit(run_personal_panel)
  end
end;
