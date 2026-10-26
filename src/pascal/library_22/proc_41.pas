{ library_22 procedure 41, $06FA..$070E, attributes $0718.
  The position call can change external storage: load word 374 afterwards. }
procedure proc22_41(firstpos, secondpos: integer);
begin
  proc22_11(1);
  proc22_12(firstpos - 3, secondpos + 3);
  proc22_9(data29.words[374]);
  proc22_11(0)
end;
