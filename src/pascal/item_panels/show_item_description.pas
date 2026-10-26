{ library_27 procedure 10, $0276..$02BA, attributes $02C4.
  Word1 holds an existing address of 32 consecutive 16-byte strings. }
procedure show_item_description(code: integer);
var
  index: integer;
begin
  index := word_and(word_abs(code), 31);
  write_item_caption(data31.captions.table^[index]);
  if (index = 11) or (index = 13) then
  begin
    index := right_shift_word(word_abs(code), 5);
    if index > 0 then
    begin
      draw_text(' (');
      draw_integer(index, 1, false);
      draw_glyph(41)
    end
  end
end;
