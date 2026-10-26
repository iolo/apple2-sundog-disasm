{ Game 18:7, $00F2..$0115, attributes $0120, lexical level 3.
  Nested in procedure 6; value is a VAR word, index is its parent's slot 1. }
procedure proc18_7(var value: integer);
begin
  if (value = index) or (value > g18w132) then { $00F2..$0105 }
    value := 0
  else if value > index then                 { $0107..$0114 }
    value := value - 1
end;
