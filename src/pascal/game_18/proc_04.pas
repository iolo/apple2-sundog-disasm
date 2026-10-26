{ Game 18:4, $0040..$005C, attributes $0066. One index argument. }
procedure proc18_4(index: integer);
begin
  with g18items[index] do               { $0040..$0046: capture address. }
  begin
    proc22_11(1);                       { $0048..$0049 }
    proc22_12(words[5], words[4]);       { $004C..$0050 }
    proc22_9(split6.high)               { $0053..$0059: word 6 bits 8..15. }
  end
end;
