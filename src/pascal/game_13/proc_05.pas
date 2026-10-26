{ game_13 procedure5, $00A0..$00FF, attributes $010A; nested in3.
  Capture each lower bound before the native shift, then derive and draw
  coordinates through native24:4. The code is read after positioning. }
procedure proc13_5;
var
  y: integer;
  x: integer;
  midy: integer;
  midx: integer;
begin
  midx := data29.words[346] + proc22_31(data29.words[345] - data29.words[346], 1);
  midy := data29.words[344] + proc22_31(data29.words[343] - data29.words[344], 1);
  proc22_19(data29.bnd343, 0);
  proc24_4(data29.pos72.fields.w0low, data29.pos72.fields.w0high, x, y);
  proc22_11(1);
  proc22_12((x + midx) - 3, (y + midy) + 3);
  proc22_9(data29.words[294])
end;
