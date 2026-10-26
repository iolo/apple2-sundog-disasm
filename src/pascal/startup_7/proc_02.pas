{ startup_7 procedure2, $0000..$0031, attributes $003C; nested in1.
  Return reservation slots1/2, Boolean argument3,512-byte local buffer at4.
  Read unit4 block0. On positive IORESULT, self EXIT returns the initialized
  false result. Byte252 must equal0 for utility,9 for play; no bit0 shortcut. }
(*$I-*) { Read/check errors explicitly, as in the original. }
function proc7_2(utility: boolean): boolean;
var sector: packed array[0..511] of 0..255;
begin
  proc7_2 := false;
  unitread(4, sector, 512, 0, 0);
  if ioresult > 0 then exit(proc7_2);
  if utility then proc7_2 := sector[252] = 0
  else proc7_2 := sector[252] = 9
end;
(*$I+*)
