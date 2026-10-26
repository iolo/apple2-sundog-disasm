{ library_27 procedure 11, $0346..$03DB, attributes $03E6.
  Slots5..12 retained to make the nested procedure's lexical accesses explicit. }
procedure proc27_11(action: integer; var itemcode, firstpos, secondpos: integer);
var
  byteidx: integer;    { 5 }
  basecode: integer;   { 6 }
  amount: integer;     { 7 }
  index: integer;      { 8 }
  change: integer;     { 9 }
  highcode: boolean;   { 10 }
  changed: boolean;    { 11 }
  clearit: boolean;    { 12 }
(*$include src/pascal/library_27/proc_14.pas*)
begin
  proc22_21(0, false);
  basecode := itemcode mod 32;
  byteidx := basecode - 15;
  highcode := itemcode > 127;
  clearit := false;
  changed := false;
  if action = 0 then clearit := true
  else if action = 2 then proc27_14(10, 2)
  else if action = 1 then
  begin
    proc27_14(8, 3);
    proc27_14(9, -1);
    proc27_14(15, -3);
    proc27_14(16, -1);
    proc27_14(17, -2);
    proc27_14(18, -2)
  end;
  if changed then
    if amount > 0 then
    begin
      change := data29.bytes[118 + amount] + change;
      proc22_37(0, change, 255);
      data29.bytes[118 + amount] := change;
      data29.flags82[60] := true
    end;
  if clearit then
  begin
    proc27_9('');
    itemcode := 0
  end;
  proc22_21(0, false);
  if clearit then proc27_3(firstpos, secondpos)
end;
