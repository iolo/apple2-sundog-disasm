{ library_22 procedure 51, $0A9A..$0B21, attributes $0B2C.
  Counter and buffer accesses are reread in their original order. }
procedure push_text_window(firstarg, secondarg: integer);
var
  secondpos, firstpos: integer;
begin
  if data29.words[20] > 1 then exit(push_text_window);
  if data29.words[20] > 0 then copy_window_buffer(true);
  data29.words[20] := data29.words[20] + 1;
  use_linear_row_tables(true);
  apply_bounds(data29.bounds3, 11);
  set_clip_bounds(data29.words[6] + 2, data29.words[5] - 2,
            data29.words[4] + 1, data29.words[3] - 1);
  draw_clip_pattern(8);
  firstpos := firstarg - 10;
  clamp_word(1, firstpos, 19);
  secondpos := secondarg * 8 - 48;
  clamp_word(7, secondpos, 88);
  data29.addr373.bytes^[2000] := firstpos;
  data29.addr373.bytes^[2001] := secondpos;
  set_window_image_origin(secondpos, firstpos);
  set_text_window(firstpos * 7 + 2, firstpos * 7 + 137,
            secondpos + 2, secondpos + 93);
  window_image_transfer(1);
  use_linear_row_tables(false)
end;
