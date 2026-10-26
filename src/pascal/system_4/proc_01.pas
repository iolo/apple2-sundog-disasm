{ system4:1 entry$060A, body$060C..$0794, release$0796, load$079B,
  RBP$07A0, attributes$07B6. Callable entry with ZERO parameter bytes;
  s4work represents306 original local words (612 bytes).
  syse is the lexical-minus-one system ancestor frame. Ordinary compiler
  program headers/storage do not establish this ABI or its static link.
  Nonlocal EXIT must enter the release epilogue$0796. Both incompatibility
  paths print with explicit CSP0 checks and then loop forever, without release.
  The named procedure permits direct calls from recovered core1. }
procedure sys4_1;
var s4work: s4root;
(*$include src/pascal/system_4/proc_02.pas*)
(*$include src/pascal/system_4/proc_03.pas*)
(*$include src/pascal/system_4/proc_07.pas*)
(*$include src/pascal/system_4/proc_09.pas*)
(*$include src/pascal/system_4/proc_10.pas*)
begin
  rtldseg(6);
  syse.words[229] := ord(syse.heap5 = nil);
  if odd(syse.words[229]) then sys4_9
  else release(syse.heap5);
  syse.name529 := '';
  syse.words[520] := 0;
  sys4_7;
  fillchar(syse.bytes533, 4, 0);
  sys4_2;
  sys4_10;
  sys4_3;
  syse.name173 := '';
  syse.text185 := '';
  sys0_31;
  s4work.raw306.word := -16607;
  if s4work.raw306.bytes^[0] <> 3 then
  begin
    sys0_22(syse.files2[1]^.words[0]); rtiochk;
    sys0_22(syse.files2[1]^.words[0]); rtiochk;
    sys0_19(syse.files2[1]^.words[0],
            'Version 1.2 of SYSTEM.PASCAL cannot run', 0); rtiochk;
    sys0_22(syse.files2[1]^.words[0]); rtiochk;
    sys0_19(syse.files2[1]^.words[0],
            'with a non-1.2 version of the interpreter', 0); rtiochk;
    sys0_22(syse.files2[1]^.words[0]); rtiochk;
    repeat until false
  end;
  s4work.raw306.word := -16606;
  s4work.words[305] := ord(s4work.raw306.flags^[6]);
  if odd(s4work.words[305]) then
  begin
    sys0_22(syse.files2[1]^.words[0]); rtiochk;
    sys0_22(syse.files2[1]^.words[0]); rtiochk;
    sys0_19(syse.files2[1]^.words[0],
            'The 64K version of SYSTEM.PASCAL cannot ', 0); rtiochk;
    sys0_22(syse.files2[1]^.words[0]); rtiochk;
    sys0_19(syse.files2[1]^.words[0],
            'run with the 128K version of SYSTEM.APPLE', 0); rtiochk;
    sys0_22(syse.files2[1]^.words[0]); rtiochk;
    repeat until false
  end;
  rtrlseg(6)
end;
