{ game_13 procedure45, $20B0..$216B, attributes $2178; nested in1.
  Parameters: VAR code5, VAR found4, glyph3, value bounds pointer2, VAR input0 at1.
  Bounds copy6..9 precedes calls. Locals10..16 retain the original roles.
  Keep the discarded initial input1 poll and the later conditional poll.
  All stop flags use bit0; a full-word nonzero test would change behavior. }
procedure proc13_45(var code, found: integer; glyph: integer;
                    area: bounds4; var input0: integer);
var
  secondbase: integer; {10}
  firstbase: integer;  {11}
  secondpos: integer;  {12}
  firstpos: integer;   {13}
  selected: integer;   {14}
  input1: integer;     {15}
  done: integer;       {16}
begin
  firstbase := area.lower_first;
  secondbase := area.lower_second;
  proc25_6(area);
  proc22_42(firstpos, secondpos, glyph, area);
  done := proc22_2(1);
  done := 0;
  input0 := 0;
  input1 := 0;
  found := 0;
  repeat
    data29.words[354] := data29.words[354] + 1;
    if data29.words[354] >= data29.words[353] then proc24_9;
    proc22_43(firstpos, secondpos);
    if odd(proc22_2(0)) then
    begin
      selected := code;
      proc25_7(firstpos - firstbase, secondpos - secondbase, selected, found);
      if found > 0 then
      begin
        proc22_4(30, 50, 10, 0, 0, 0, 0);
        proc25_8(found, selected, area, input0, input1);
        code := selected;
        done := 1
      end
      else found := 0
    end
    else if odd(data29.words[350]) then
    begin
      data29.words[350] := 0;
      code := 255;
      input0 := 1;
      done := 1
    end
    else done := proc22_2(1)
  until odd(done) or odd(data29.words[347]);
  proc22_41(firstpos, secondpos)
end;
