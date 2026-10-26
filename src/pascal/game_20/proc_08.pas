{ game_20 procedure8, $0514..$05AE, attributes $05BA.
  Increment the shared timer before cursor/input polling. Preserve ordered
  output stores, aliased VAR outputs, and conditional input1 polling. }
procedure proc20_8(var code, found: integer; mode: integer; area: bounds4;
                   var selected: integer);
var
  firstbase, secondbase, firstpos, secondpos, newcode, input1: integer;
  done: boolean;
begin
  firstbase := area.lower_first;
  secondbase := area.lower_second;
  proc25_6(area);
  proc22_42(firstpos, secondpos, mode, area);
  done := false;
  selected := 0;
  input1 := 0;
  found := 0;
  code := 0;
  repeat
    data29.words[354] := data29.words[354] + 1;
    if data29.words[354] >= 10 then proc22_29;
    proc22_43(firstpos, secondpos);
    if odd(proc22_2(0)) then
    begin
      newcode := code;
      proc25_7(firstpos - firstbase, secondpos - secondbase, newcode, found);
      if found > 0 then
      begin
        proc22_4(30, 50, 10, 0, 0, 0, 0);
        proc25_8(found, newcode, area, selected, input1);
        code := newcode;
        done := true
      end
    end
    else if odd(proc22_2(1)) then done := true
  until done or odd(data29.words[347]);
  proc22_41(firstpos, secondpos)
end;
