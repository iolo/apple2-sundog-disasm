{ library_22 procedure54, $0BB6..$0BDE, attributes $0BE8.
  Enter graphics before disk I/O, load the selected block at3712, then call
  its raw entry at3904 with the address of global20. Reset globals only after
  that call returns. Startup_disk1 $0199..$01A9 supplies the relative block. }
procedure proc22_54(block: integer);
begin
  proc22_55;
  proc22_53(3712, 1, block, true);
  callinit(data29.words[20], 3904);
  data29.words[20] := 0;
  data29.words[373] := 8192 - 2048;
  data29.words[372] := 16384
end;
