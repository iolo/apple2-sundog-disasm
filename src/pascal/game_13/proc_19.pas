{ game_13 procedure19, $0E82..$0FEC, attributes $0FFE; nested in18.
  Parameters7..1: VAR pickcode/hit, glyph, value bounds, VAR selected/chosen, viewtype.
  Bounds copy8..11 precedes cursor setup. Keep the discarded input1 poll,
  cursor toggles around periodic updates, input0 store visible to proc24_9,
  timeout path, and post-hit selection test even when hit<=0. }
procedure proc13_19(var pickcode, hit: integer; glyph: integer; area: bounds4;
                    var selected: integer; var chosen: g19loc; viewtype: integer);
var
  countdown: integer; {12}
  unused13: integer;
  ybase: integer;     {14}
  xbase: integer;     {15}
  ycursor: integer;   {16}
  xcursor: integer;   {17}
  newcode: integer;   {18}
  second: integer;    {19}
  done: integer;      {20}
(*$include src/pascal/game_13/proc_20.pas*)
(*$include src/pascal/game_13/proc_21.pas*)
(*$include src/pascal/game_13/proc_23.pas*)
begin
  proc22_42(xcursor, ycursor, glyph, area);
  xbase := area.lower_first;
  ybase := area.lower_second;
  done := proc22_2(1);
  done := 0;
  selected := 0;
  hit := 0;
  repeat
    data29.words[354] := data29.words[354] + 1;
    if data29.words[354] >= data29.words[353] then
    begin
      proc22_41(xcursor, ycursor);
      proc24_9;
      proc22_41(xcursor, ycursor)
    end;
    proc22_43(xcursor, ycursor);
    if odd(proc22_2(0)) then
    begin
      newcode := pickcode;
      proc25_7(xcursor - xbase, ycursor - ybase, newcode, hit);
      if hit > 0 then
      begin
        proc22_4(30, 50, 10, 0, 0, 0, 0);
        proc22_41(xcursor, ycursor);
        proc22_19(data29.bnd339, 8);
        proc22_50(data29.words[342], data29.words[341],
                    data29.words[340], data29.words[339]);
        case viewtype of
          1: proc13_20(newcode);
          2: proc13_21(newcode);
          3: proc13_23(newcode, selected)
        end;
        selected := proc22_2(0);
        proc24_9;
        selected := 1;
        if not odd(allow) then selected := 0;
        countdown := 5;
        second := 0;
        if odd(selected) then
          repeat
            data29.words[354] := data29.words[354] + 1;
            if data29.words[354] >= data29.words[353] then
            begin
              countdown := countdown - 1;
              proc24_9
            end;
            proc25_8(hit, newcode, area, selected, second)
          until odd(selected) or odd(second) or (countdown = 0);
        if (not odd(second)) and (countdown = 0) then
        begin
          selected := 1;
          if not data29.flags82[31] then proc22_4(30, 50, 10, 0, 0, 0, 0)
        end;
        proc22_42(xcursor, ycursor, glyph, area)
      end;
      if odd(selected) then
      begin
        pickcode := newcode;
        done := 1
      end
      else hit := 0
    end
    else if odd(proc22_2(1)) then done := 1
  until odd(done) or odd(data29.words[347]);
  proc22_41(xcursor, ycursor)
end;
