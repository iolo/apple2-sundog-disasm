{ system4:8 $0382..$039A, attributes$03A4; nested in7. Parameters2 unit,
  1 caption address; value caption copy3..6 (8 local bytes). Clear the unit,
  then name its six-word table entry only on IORESULT=0. }
(*$I-*)
procedure sys4_8(unitnum: integer; caption: s4text7);
begin
  unitclear(unitnum);
  if ioresult = 0 then syse.units31[unitnum].caption := caption
end;
(*$I+*)
