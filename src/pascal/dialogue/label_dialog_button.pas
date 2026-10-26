{ game_16 procedure27, $0B4C..$0BD1, attributes $0BDC.
  Write the raw caption selector before drawing and the command after drawing.
  WITH captures the bounds pointer at original slot22; later reads retain that
  pointer across drawing calls. The first text byte is read even at length0. }
procedure label_dialog_button(button_index, action_code, label_selector: integer);
var
  caption_x: integer;
  caption_width: integer;
  caption_text: g16text;
begin
  g16.words[90 + button_index] := label_selector;
  if label_selector >= 0 then
    with g16.dialog_buttons[button_index] do
    begin
      set_clip_bounds(lower_first - 2, upper_first + 2,
                lower_second - 2, upper_second + 2);
      draw_clip_pattern(9);
      apply_bounds(g16.dialog_buttons[button_index], 8);
      extract_phrase_variant(0, label_selector, caption_text);
      if caption_text.bytes[1] >= 97 then caption_text.bytes[1] := caption_text.bytes[1] - 32;
      caption_width := 6 * caption_text.bytes[0];
      caption_x := (lower_first + upper_first - caption_width) div 2;
      set_glyph_mode(3);
      move_pen(caption_x, upper_second - 2);
      draw_text(caption_text.text);
      set_glyph_mode(1)
    end;
  g16.words[95 + button_index] := action_code
end;
