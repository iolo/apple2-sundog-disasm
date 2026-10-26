{ game_13 procedure51, $246A..$2505, attributes $2510; nested in1.
  Missing entries still consume15 units of vertical space. Original unused
  local1 holds the city predicate so call50 always runs after that read. }
procedure proc13_51;
var
  cityfree: boolean;
begin
  raw13[8] := 4;
  raw13[7] := 62;
  raw13[6] := 4;
  proc25_2;
  if not proc13_50(5, 3) then proc13_42(1, 'STATUS')
  else raw13[6] := raw13[6] + 15;
  if not proc13_50(5, 1) then proc13_42(2, 'NAVIGATE')
  else raw13[6] := raw13[6] + 15;
  cityfree := data29.pos72.fields.city = 0;
  if not proc13_50(3, 0) and cityfree then proc13_42(3, 'TACTICAL')
  else raw13[6] := raw13[6] + 15;
  if not data29.flags82[25] and (data29.pos72.fields.city = 0) then
    proc13_42(4, 'DISTRESS')
end;
