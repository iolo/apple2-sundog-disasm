{ game_16 procedure17, $0932..$0985, attributes $0992.
  Retain the104-byte frame: nested18..21 share next5, printed10, capital12,
  and line13. High-bit stream bytes expand once, then emit a space. }
procedure render_dialog_line(line_index: integer);
var
  unused2: integer;
  stream_token: integer;
  stream_count: integer;
  buffer_index: integer;
  saved_bounds: bounds4;
  text_started: integer;
  unused11: integer;
  capitalize_next: integer;
  text_buffer: g16line;
procedure expand_dialog_token(code: integer); forward;
(*$include src/pascal/dialogue/flush_dialog_text.pas*)
(*$include src/pascal/dialogue/append_dialog_char.pas*)
(*$include src/pascal/dialogue/emit_dialog_phrase.pas*)
(*$include src/pascal/dialogue/expand_dialog_token.pas*)
begin
  saved_bounds := data29.bounds11;
  data29.bounds11 := g16.dialog_bounds;
  text_started := 0;
  g16.stream_cursor := line_index * 2;
  read_dialog_byte(stream_count);
  buffer_index := 1;
  capitalize_next := 1;
  unused11 := 0;
  while stream_count > 0 do
  begin
    read_dialog_byte(stream_token);
    if stream_token > 127 then
    begin
      stream_token := stream_token - 128;
      expand_dialog_token(stream_token);
      stream_token := 32
    end;
    expand_dialog_token(stream_token);
    stream_count := stream_count - 1
  end;
  flush_dialog_text;
  data29.bounds11 := saved_bounds
end;
