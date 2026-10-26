{ library_27 procedure 6, $00FE..$0148, attributes $0154. }
procedure proc27_6(after: integer);
var
  secondpos: integer;
  firstpos: integer;
  index: integer;
  last: integer;
begin
  proc22_21(0, false);
  firstpos := data29.words[14];
  secondpos := data29.words[12];
  index := after + 1;
  last := data31.words[16];
  while index <= last do
  begin
    with data31.items[index] do
    begin
      proc27_4(code);
      proc27_3(firstoff + firstpos, secondoff + secondpos)
    end;
    index := index + 1
  end;
  proc22_21(0, false)
end;
