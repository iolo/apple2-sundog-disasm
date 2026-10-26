{ game_20 procedure10, $0642..$066A, attributes $0674.
  Both flash input outputs intentionally use the same local address. }
procedure proc20_10(caption: text15; firstlow, firsthigh, secondpos: integer);
var
  selected, code: integer;
begin
  proc25_2;
  proc25_3(1, caption, firstlow, firsthigh, secondpos, secondpos + 10);
  proc25_6(data29.bounds11);
  proc25_8(1, code, data29.bounds11, selected, selected)
end;
