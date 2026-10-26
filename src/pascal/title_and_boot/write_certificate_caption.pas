{ Both library26 variants: procedure17, $06EC..$0753, attributes $0764;
  nested in7. Retain both busy-wait loops and reread the character after
  the output call before deciding whether to play its sound. }
procedure write_certificate_caption;
var
  caption_length: integer; {1}
  delay_counter: integer; {2}
  char_index: integer; {3}
  last_char: integer; {4}
  char_delay: integer; {5}
begin
  set_text_window(60, 270, 98, 110);
  caption_length := ord(caption[0]);
  delay_counter := 1;
  last_char := 2500;
  while delay_counter <= last_char do delay_counter := delay_counter + 1;
  char_index := 1;
  last_char := caption_length;
  while char_index <= last_char do
  begin
    write_text_glyph(ord(caption[char_index]));
    if ord(caption[char_index]) <> 32 then play_sound(1, 255, 2, 0, 0, 1, 1);
    delay_counter := 1;
    char_delay := 200;
    while delay_counter <= char_delay do delay_counter := delay_counter + 1;
    char_index := char_index + 1
  end
end;
