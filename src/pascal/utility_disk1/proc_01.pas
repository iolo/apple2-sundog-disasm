{ utility_disk1:1 entry$20C2, body$20C4..$2124, release$2126..$2138,
  load$213A..$214C, RBP$214E, attributes$215C. Program-block include after
  declarations/dependencies, ending in end. Declare u1:utilframe as the first
  program variable: original slots3..524 are1044 local bytes after four ABI
  parameter bytes. DATA29/30/31 are external segments, not additional locals.
  Preserve duplicate segment30 loads/releases. Nonlocal EXIT must enter$2126;
  runtime error dispatch must bind utility procedure2 to util1_2. The external
  rtldseg/rtrlseg declarations alone do not provide these runtime bindings. }
(*$include src/pascal/utility_disk1/proc_02.pas*)
(*$include src/pascal/utility_disk1/proc_41.pas*)
(*$include src/pascal/utility_disk1/proc_07.pas*)
(*$include src/pascal/utility_disk1/proc_04.pas*)
(*$include src/pascal/utility_disk1/proc_05.pas*)
(*$include src/pascal/utility_disk1/proc_42.pas*)
(*$include src/pascal/utility_disk1/proc_43.pas*)
(*$include src/pascal/utility_disk1/proc_44.pas*)
(*$include src/pascal/utility_disk1/proc_45.pas*)
(*$include src/pascal/utility_disk1/proc_46.pas*)
(*$include src/pascal/utility_disk1/proc_03.pas*)
(*$include src/pascal/utility_disk1/proc_06.pas*)
(*$include src/pascal/utility_disk1/proc_08.pas*)
(*$include src/pascal/utility_disk1/proc_40.pas*)
(*$include src/pascal/utility_disk1/proc_47.pas*)
(*$include src/pascal/utility_disk1/proc_49.pas*)
(*$include src/pascal/utility_disk1/proc_31.pas*)
(*$include src/pascal/utility_disk1/proc_09.pas*)
(*$include src/pascal/utility_disk1/proc_22.pas*)
(*$include src/pascal/utility_disk1/proc_48.pas*)
(*$include src/pascal/utility_disk1/proc_50.pas*)
begin
  rtldseg(30);
  rtldseg(29);
  rtldseg(22);
  rtldseg(30);
  rtldseg(25);
  rtldseg(26);
  proc22_1;
  proc25_1;
  proc26_1;
  mark(data29.text35.text);
  mark(data29.addr34.bytes);
  data29.words[33] := 16384;
  release(data29.addr33.bytes);
  proc22_53(16384, 1, 80, true);
  proc22_54(data29.addr33.bytes^[6] - 3);
  util1_8;
  proc22_42(u1.words[5], u1.words[4], 1, data29.bounds7);
  repeat
    proc22_43(u1.words[5], u1.words[4]);
    if odd(proc22_2(0)) then util1_50
  until odd(proc22_2(1) or u1.words[268]);
  proc22_41(u1.words[5], u1.words[4]);
  util1_42;
  rtrlseg(26);
  rtrlseg(25);
  rtrlseg(30);
  rtrlseg(22);
  rtrlseg(29);
  rtrlseg(30)
end.
