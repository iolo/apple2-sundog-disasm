{ Game 18:6, $0122..$019F, attributes $01AC. Removes an indexed entry.
  DATASEG29 address(word271)+10 is byte offset 550 from the data base. }
procedure proc18_6(index: integer);
var
  cursor: integer;
  last: integer;
(*$include src/pascal/game_18/proc_07.pas*)
begin
  proc18_4(index);                          { $0122..$0123 }
  g18w147 := data29.bytes[550];             { $0125..$012B }
  if index = g18w147 then                   { $012F..$013E }
    data29.bytes[550] := 0
  else if index < g18w147 then              { $0140..$0153 }
    data29.bytes[550] := g18w147 - 1;
  g18w147 := data29.bytes[550];             { $0154..$015A }
  cursor := index + 1;                      { $015E..$0161 }
  last := g18w132;                          { $0163..$0167: captured bound. }
  while cursor <= last do                   { $0169..$0189 }
  begin
    g18items[cursor - 1] := g18items[cursor]; { $016E..$017C: MOV 10. }
    proc18_5(cursor - 1, false);
    cursor := cursor + 1
  end;
  proc18_7(g18a112[124]);                    { $018B..$018E }
  proc18_7(g18a112[123]);                    { $0190..$0193 }
  g18w132 := g18w132 - 1                    { $0195..$019B: after both calls. }
end;
