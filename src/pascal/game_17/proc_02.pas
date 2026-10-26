{ game_17 procedure2, $0000..$0013, attributes $001C.
  Same native mode2 query as game18:3; result word1 is canonical0/1. }
function proc17_2(code, firstpos, secondpos: integer): boolean;
begin
  proc22_11(2);
  proc22_12(firstpos, secondpos);
  proc22_9(code);
  proc17_2 := odd(data29.words[1])
end;
