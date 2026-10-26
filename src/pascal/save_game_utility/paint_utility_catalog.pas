{ utility_disk1:6 $1964..$1A55, attributes$1A62. Two local words.
  Word34 becomes raw address8192; fill8192 bytes without allocator semantics.
  Display all four slots before printing the instruction panel. }
procedure paint_utility_catalog;
var
  index: integer;
  limit: integer;
begin
  data29.words[34] := 8192;
  fillchar(data29.addr34.bytes^, 8192, 0);
  set_clip_bounds(data29.words[10], data29.words[9], data29.words[8], data29.words[8] + 37);
  draw_clip_pattern(10);
  set_clip_bounds(data29.words[10], data29.words[9], data29.words[8] + 38, data29.words[7]);
  draw_clip_pattern(5);
  index := 0;
  limit := 3;
  while index <= limit do
  begin
    draw_save_slot(index, true);
    index := index + 1
  end;
  set_text_window(data29.words[10] + 4, data29.words[9] - 4,
              data29.words[8] + 4, data29.words[8] + 32);
  clear_text_window;
  write_wrapped_text('||||||||||SunDog> Utility Program\');
  write_wrapped_text('Select box with cursor to play or delete a\');
  write_wrapped_text('||suspended game, or to start a new one.')
end;
