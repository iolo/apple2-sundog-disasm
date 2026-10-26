{ Library 22:12, $016C..$018A, attributes $0194. Two words, no result. }
procedure proc22_12(firstpos, secondpos: integer);
begin
  if data29.words[366] > 0 then          { $016C..$0172 }
    proc22_57(data29.words[365], data29.words[364],
               firstpos, secondpos);    { $0174..$017E }
  data29.words[365] := firstpos;         { $0180..$0181 }
  data29.words[364] := secondpos         { $0185..$0186 }
end;
