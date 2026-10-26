{ game_17 procedure15, $07CE..$08C8, attributes $08D2.
  Parent args3/2/1 are caller-owned VAR integers.
  Read the original coordinates before clamping; apply case1..9 exactly.
  VAR references preserve aliasing between caller-owned outputs. }
procedure proc17_15(chosen: boolean);
var
  direction: integer;
begin
  if not odd(data29.words[347]) then
  begin
    data29.nibbles45[0] := data29.nibbles45[1];
    data29.nibbles45[1] := data29.nibbles45[2]
  end;
  g17.words[42] := 1;
  g17.words[80] := arg3;
  g17.words[79] := arg2;
  direction := 5 - 3 * proc22_34(arg3 - 20) - proc22_34(arg2 - 12);
  proc22_37(10, arg3, 39);
  proc22_37(7, arg2, 23);
  case direction of
    1, 2, 4, 5:
      begin
        arg3 := arg3 - 2;
        arg2 := arg2 - 2
      end;
    3, 6:
      begin
        arg3 := arg3 - 2;
        arg2 := arg2 + 2
      end;
    7, 8:
      begin
        arg3 := arg3 + 2;
        arg2 := arg2 - 2
      end;
    9:
      begin
        arg3 := arg3 + 2;
        arg2 := arg2 + 2
      end
  end;
  if chosen then
  begin
    data29.nibbles45[2] := 9;
    arg1 := data29.words[217]
  end
  else
  begin
    if not odd(data29.words[347]) then data29.nibbles45[2] := 7;
    arg1 := 1
  end
end;
