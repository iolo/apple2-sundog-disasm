{ game_21 procedure33, $17B4..$1843, attributes $1850.
  Nested34 uses the bases at slots5/4. Input1 must execute even when input0
  chose a cell. Snapshot chosen before input1, then reread it after the loop. }
procedure proc21_33(var chosen: integer);
var
  row: integer;         {2}
  column: integer;      {3}
  ybase: integer;       {4}
  xbase: integer;       {5}
  saved: integer;
  input1: integer;
(*$include src/pascal/game_21/proc_34.pas*)
(*$include src/pascal/game_21/proc_35.pas*)
begin
  chosen := 0;
  column := 0;
  row := 0;
  xbase := 7 * (data29.words[14] div 7) + 10;
  ybase := 8 * (data29.words[12] div 8) + 12;
  data29.bits38.low6 := arg6 + g21.words[26] div 28;
  data29.bits39.low5 := arg5 + g21.words[25] div g21.words[21];
  proc21_32(xbase, ybase, data29.bits38.low6, data29.bits39.low5);
  proc21_34(column, row);
  repeat
    proc21_35(column, row);
    chosen := proc22_2(0);
    saved := chosen;
    input1 := proc22_2(1)
  until odd(saved) or odd(input1);
  if odd(chosen) then
  begin
    data29.words[40] := 0;
    data29.bytes[80] := 13;
    data29.bits38.low6 := column + 10;
    data29.bits39.low5 := row + 6
  end
end;
