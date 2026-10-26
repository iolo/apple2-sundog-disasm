{ Game 18:10, $03B8..$040D, attributes $0418. One index argument.
  CSP 4 at $03E4 exits procedure 10 in segment 18. }
procedure proc18_10(index: integer);
var
  remaining: integer;
  secondpos: integer;
  firstpos: integer;
begin
  with g18items[index] do                   { $03B8..$03BE: capture once. }
  begin
    if not flags.bit3 then                 { $03C0..$03DB }
      proc18_9(index, firstpos, secondpos, remaining)
    else
      proc18_8(index, firstpos, secondpos, remaining);
    if remaining = 0 then exit(proc18_10); { $03DD..$03E4 }
    if flags.bit2 then                     { $03E6..$03F9 }
      words[0] := secondpos + 10
    else
      words[0] := secondpos - 10;
    proc18_5(index, true);                  { $03FA..$03FC }
    words[1] := firstpos;                   { $03FE..$0402 }
    words[3] := firstpos;                   { $0403..$0407 }
    words[2] := secondpos                   { $0408..$040C }
  end
end;
