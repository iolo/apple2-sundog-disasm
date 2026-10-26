{ library_22 procedure 10, $001C..$0044, attributes $0050.
  SAS 80 copies the incoming string before any native calls. }
procedure draw_text(caption: text80);
var
  char_index, char_count: integer;
begin
  char_count := length(caption);
  char_index := 1;
  while char_index <= char_count do
  begin
    draw_glyph(ord(caption[char_index]));
    char_index := char_index + 1
  end
end;
