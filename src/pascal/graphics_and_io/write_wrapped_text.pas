{ library_22 procedure 48, $08E4..$09C4, attributes $09DA.
  The local layout retains the original 20-byte word buffer and adjacent words.
  Validation assumes runs no longer than that buffer; no truncation is added. }
procedure write_wrapped_text(caption: text80);
var
  word_length: integer;                         { Slot 43. }
  text_length: integer;                          { Slot 44. }
  word_index: integer;                         { Slot 45. }
  text_index: integer;                           { Slot 46. }
  unused47: array[47..48] of integer;
  word_bytes: packed array[0..19] of 0..255;    { Slots 49..58. }
  char_code: integer;                            { Slot 59. }
  word_ended: boolean;                            { Slot 60. }
  last_word_char: integer;                            { Slot 61. }
begin
  set_glyph_mode(3);
  text_length := length(caption);
  text_index := 1;
  while text_index <= text_length do
  begin
    char_code := ord(caption[text_index]);
    if char_code = 32 then
    begin
      if data29.text_x > data29.words[14] + 2 then write_text_glyph(32);
      text_index := text_index + 1
    end
    else if char_code = 92 then
    begin
      if data29.text_x > data29.words[14] + 2 then text_newline;
      text_index := text_index + 1
    end
    else if char_code = 124 then
    begin
      write_text_glyph(32);
      text_index := text_index + 1
    end
    else
    begin
      word_length := 0;
      word_ended := false;
      while (text_index <= text_length) and not word_ended do
      begin
        char_code := ord(caption[text_index]);
        word_ended := (char_code = 32) or (char_code = 124) or (char_code = 92);
        if not word_ended then
        begin
          word_length := word_length + 1;
          word_bytes[word_length - 1] := char_code;
          text_index := text_index + 1
        end
      end;
      word_index := word_length;
      if data29.text_x + word_index * 6 > data29.text_right then text_newline;
      word_index := 1;
      last_word_char := word_length;
      while word_index <= last_word_char do
      begin
        write_text_glyph(word_bytes[word_index - 1]);
        word_index := word_index + 1
      end
    end
  end
end;
