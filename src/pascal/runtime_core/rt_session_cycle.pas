{ system_core0:39 $0BA6..$0BD4, attributes$0BE2, lexical1. No parameters
  or locals. Load segment2 before the loop. Original self-EXIT(0,39) targets
  release$0BCA, represented by goto900; nonlocal runtime exits must enter that
  epilogue as well. The low-bit condition combines NOT227 with226 eagerly. }
procedure rt_session_cycle;
label 900;
begin
  rtldseg(2);
  repeat
    rt_release_program_heap;
    rt_load_session_code;
    if odd((not sy0e.words[227]) and sy0e.words[226]) then rt_unbound_entry_failure(nil, nil)
    else goto 900
  until sy0e.words[19] = 0;
900:
  rtrlseg(2)
end;
