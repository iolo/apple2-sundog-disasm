{ system_core0:2 $0024..$00A7, attributes$00B4. Error code1, one unused
  local word omitted. Print the exact three literal fragments and integer
  through the console, with explicit CSP0 checks, then loop forever.
  The original exit pointer targets the return after the infinite loop. }
procedure sys0_2(code: integer);
begin
  sys0_29(1, 10);
  sys0_19(sy0e.files2[1]^.words[0], 'SYSTEM FAILURE NUMBER ', 0); rtiochk;
  sys0_13(sy0e.files2[1]^.words[0], code, 0); rtiochk;
  sys0_19(sy0e.files2[1]^.words[0], '. PLEASE REFER', 0); rtiochk;
  sys0_29(1, 11);
  sys0_19(sy0e.files2[1]^.words[0],
          'TO PRODUCT MANUAL FOR EXPLANATION.', 0); rtiochk;
  repeat until false
end;
