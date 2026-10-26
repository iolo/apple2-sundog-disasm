{ library_22 procedure 43, $0806..$0829, attributes $0834. }
procedure proc22_43(var firstpos, secondpos: integer);
var
  newsecond, newfirst: integer;
begin
  proc22_61(newfirst, newsecond);
  if (newfirst <> firstpos) or (newsecond <> secondpos) then
  begin
    proc22_41(firstpos, secondpos);
    firstpos := newfirst;
    secondpos := newsecond;
    proc22_41(firstpos, secondpos)
  end
end;
