{ system_core0:32 $0912..$0931, attributes$093E. No parameters or locals.
  Clear status19 and flag226, then dispatch repeatedly until status19 is zero.
  The flag226 call supplies two zero address words to system1's entry ABI. }
procedure sys0_32;
begin
  sy0e.words[19] := 0;
  sy0e.words[226] := 0;
  repeat
    sys0_37;
    sys0_39;
    if odd(sy0e.words[226]) then sys1_1(nil, nil)
  until sy0e.words[19] = 0
end;
