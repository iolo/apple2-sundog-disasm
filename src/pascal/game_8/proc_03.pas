{ game_8 procedure3, $00A4..$00FB, attributes $0108.
  Included inside the recovered procedure1 scope, named proc8_1 for EXIT.
  Two Boolean arguments occupy original slots2/1; current callers pass 0/1. }
procedure proc8_3(drawitem, drawmark: boolean);
var
  index: integer;
  last: integer;
(*$include src/pascal/game_8/proc_04.pas*)
begin
  if data29.nibbles45[1] <= 2 then proc24_9
  else proc22_29;
  if odd(g8a3[15]) and data29.flags82[60] then begin
    proc8_4;
    index := 0;
    last := 3;
    while index <= last do begin
      proc8_2(index);
      index := index + 1
    end;
    proc8_4;
    data29.flags82[60] := false
  end;
  proc22_11(1);
  if data29.nibbles45[2] = 12 then begin
    proc22_52;
    exit(proc8_1)
  end
end;
