{ game_15 procedure14, $07CC..$08A1, attributes $08B0.
  Signed DIV and all case priorities are retained. Unlisted columns/rows
  return0. Locals5..8 are rowa,column,rowb,action; arguments4=x,3=y. }
function proc15_14(x, y: integer): integer;
var
  rowa: integer;
  column: integer;
  rowb: integer;
  action: integer;
begin
  column := (x + 3) div 7;
  rowb := (y - 5) div 8;
  rowa := (y - 3) div 8;
  action := 0;
  case column of
    6: if rowa = 12 then action := 1;
    8: if (rowa = 14) and (data29.bits38.low6 + data29.bits39.low5 > 0)
       then action := 4
       else if rowa = 10 then action := 6;
    12: if rowa = 13 then action := 5;
    14: if (rowa = 14) and (data29.bits38.low6 + data29.bits39.low5 > 0)
        then action := 3;
    16: if rowa = 8 then action := 10
        else if rowa = 16 then action := 11
        else if rowa = 18 then action := 13
        else if rowb = 6 then action := 8;
    17: if rowa = 15 then action := 7
        else if rowa = 7 then action := 9
        else if rowa = 17 then action := 12
  end;
  proc15_14 := action
end;
