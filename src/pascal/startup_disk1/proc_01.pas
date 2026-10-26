{ startup_disk1 procedure1 (identical startup_disk2), entry$01E8,
  body$01EA..$01FF, load$0212..$0221, release$0201..$020E, RBP$0223,
  attributes$0230. This is a program-block include after the program header,
  shared declarations and recovered dependencies, not an ordinary procedure.
  Original four parameter bytes belong to the program ABI; zero local bytes.
  Preserve repeated loads/releases. Nonlocal EXIT must enter$0201. }
(*$include src/pascal/startup_disk1/proc_02.pas*)
(*$include src/pascal/startup_disk1/proc_03.pas*)
(*$include src/pascal/startup_disk1/proc_04.pas*)
(*$include src/pascal/startup_disk1/proc_06.pas*)
begin
  rtldseg(30);
  rtldseg(31);
  rtldseg(29);
  rtldseg(30);
  rtldseg(31);
  proc22_1;
  proc23_1;
  proc24_1;
  proc25_1;
  proc26_1;
  proc27_1;
  proc28_1;
  boot1_6;
  rtrlseg(31);
  rtrlseg(30);
  rtrlseg(29);
  rtrlseg(31);
  rtrlseg(30)
end.
