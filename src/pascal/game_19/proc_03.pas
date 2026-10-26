{ game_19 procedure3, $0040..$00C5, attributes $00D0.
  Output stores and rereads are ordered to preserve aliasing. Input1 is polled
  only when input0 was false, as in the original branch structure. }
procedure proc19_3(var code, found: integer; mode: integer; area: bounds4;
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
