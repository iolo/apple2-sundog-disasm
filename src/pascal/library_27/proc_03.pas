{ library_27 procedure 3, $0044..$0081, attributes $008C.
  The native OR forces the low bit of the first coordinate. }
procedure proc27_3(firstpos, secondpos: integer);
begin
  firstpos := proc22_33(firstpos, 1);
  proc22_12(firstpos - 7, secondpos);
  proc22_9(data31.words[76]);
  proc22_12(firstpos - 7, secondpos + 8);
  proc22_9(data31.words[74]);
  proc22_12(firstpos, secondpos);
  proc22_9(data31.words[75]);
  proc22_12(firstpos, secondpos + 8);
  proc22_9(data31.words[73])
end;
