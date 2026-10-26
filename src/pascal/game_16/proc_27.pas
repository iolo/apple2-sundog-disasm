{ game_16 procedure27, $0B4C..$0BD1, attributes $0BDC.
  Write the raw caption selector before drawing and the command after drawing.
  WITH captures the bounds pointer at original slot22; later reads retain that
  pointer across drawing calls. The first text byte is read even at length0. }
procedure proc16_27(button, command, labelid: integer);
var
  xpos: integer;
  width: integer;
  labelbuf: g16text;
begin
  g16.words[90 + button] := labelid;
  if labelid >= 0 then
    with g16.buttons72[button] do
    begin
      proc22_14(lower_first - 2, upper_first + 2,
                lower_second - 2, upper_second + 2);
      proc22_7(9);
      proc22_19(g16.buttons72[button], 8);
      proc16_13(0, labelid, labelbuf);
      if labelbuf.bytes[1] >= 97 then labelbuf.bytes[1] := labelbuf.bytes[1] - 32;
      width := 6 * labelbuf.bytes[0];
      xpos := (lower_first + upper_first - width) div 2;
      proc22_11(3);
      proc22_12(xpos, upper_second - 2);
      proc22_10(labelbuf.text);
      proc22_11(1)
    end;
  g16.words[95 + button] := command
end;
