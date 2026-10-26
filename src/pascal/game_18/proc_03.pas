{ Game 18:3, $0022..$0034, attributes $003E. Frame 5=code, 4=first,
  3=second, 1..2=result reservation. Native 22:9 mode 2 writes 0/1 to word 1. }
function proc18_3(code, firstpos, secondpos: integer): boolean;
begin
  proc22_11(2);                         { $0022..$0023 }
  proc22_12(firstpos, secondpos);        { $0026..$0028 }
  proc22_9(code);                       { $002B..$002C }
  proc18_3 := odd(data29.words[1])       { $002F..$0032; known canonical 0/1. }
end;
