{ system_core0:21 $05B0..$05CF, attributes$05DC. File pointer1, no locals.
  Consume through flag1. Then mode3=0 advances once more; otherwise set mode3
  to1 followed by flag1 to0. Preserve the low-bit flag test. }
procedure sys0_21(var f: sysfile);
begin
  while not odd(f.words[1]) do sys0_7(f);
  if f.words[3] = 0 then sys0_7(f)
  else
  begin
    f.words[3] := 1;
    f.words[1] := 0
  end
end;
