{ library_22 procedure26, $028E..$02C1, attributes $02CC.
  Update only 6/8/14-bit fields; retain both two-bit spare fields. }
procedure proc22_26(var stamp: clock4; elapsed: integer);
var
  carry: integer;
begin
  carry := stamp.minute + elapsed;
  stamp.minute := carry mod 60;
  carry := stamp.hour + carry div 60;
  stamp.hour := carry mod 24;
  stamp.day := stamp.day + carry div 24
end;
