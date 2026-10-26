{ system_core0:39 $0BA6..$0BD4, attributes$0BE2, lexical1. No parameters
  or locals. Load segment2 before the loop. Original self-EXIT(0,39) targets
  release$0BCA, represented by goto900; nonlocal runtime exits must enter that
  epilogue as well. The low-bit condition combines NOT227 with226 eagerly. }
procedure sys0_39;
label 900;
begin
  rtldseg(2);
  repeat
    sys0_37;
    sys0_38;
    if odd((not sy0e.words[227]) and sy0e.words[226]) then sys1_1(nil, nil)
    else goto 900
  until sy0e.words[19] = 0;
900:
  rtrlseg(2)
end;
