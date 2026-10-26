{ game_16 procedure15, $0706..$0718, attributes $0722.
  Store through the VAR address first, then reread/increment parent38 so
  aliasing that index retains the original behavior. }
procedure read_dialog_byte(var value: integer);
begin
  value := g16.script_bytes.bytes^[g16.stream_cursor];
  g16.stream_cursor := g16.stream_cursor + 1
end;
