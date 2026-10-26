{ system_core0:29 $0852..$089F, attributes$08AA. Column2, row1;
  local3 points at configuration word37. Clamp column first to0 then word38,
  row first to0 then word37. A negative configured maximum can therefore
  produce a negative coordinate; do not replace these ordered tests with a
  different clamp. Emit30, column+32, row+32, checking IO after each call. }
procedure rt_position_console(column, row: integer);
var limits: ^s4keys;
begin
  limits := @sy0e.state^.keys;
  if column < 0 then column := 0;
  if column > limits^.words[1] then column := limits^.words[1];
  if row < 0 then row := 0;
  if row > limits^.words[0] then row := limits^.words[0];
  rt_write_character(sy0e.files2[1]^.words[0], 30, 0); rtiochk;
  rt_write_character(sy0e.files2[1]^.words[0], column + 32, 0); rtiochk;
  rt_write_character(sy0e.files2[1]^.words[0], row + 32, 0); rtiochk
end;
