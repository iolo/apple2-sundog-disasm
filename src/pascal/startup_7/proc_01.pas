{ startup_7 procedure1, entry$0706, body$0708..$071A, load$0724..$072A,
  release epilogue$071C..$0720, return$072C, attributes$0738.
  One Boolean parameter and36 local bytes. Nonlocal EXIT must use the original
  release epilogue; runtime EXTERNAL declarations alone do not implement it. }
procedure proc7_1(initialize: boolean);
var s7: s7frame;
(*$include src/pascal/startup_7/proc_02.pas*)
(*$include src/pascal/startup_7/proc_03.pas*)
(*$include src/pascal/startup_7/proc_04.pas*)
(*$include src/pascal/startup_7/proc_05.pas*)
(*$include src/pascal/startup_7/proc_06.pas*)
(*$include src/pascal/startup_7/proc_07.pas*)
(*$include src/pascal/startup_7/proc_08.pas*)
begin
  rtldseg(25);
  rtldseg(26);
  release(data29.addr33.bytes);
  if initialize then
  begin
    proc7_4;
    proc7_5;
    proc7_6;
    proc7_7
  end
  else proc7_8;
  rtrlseg(26);
  rtrlseg(25)
end;
