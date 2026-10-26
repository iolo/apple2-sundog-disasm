{ system_core0:38 $0C34..$0CCB, attributes$0CDC, lexical1. Separately
  loaded fragment; no parameters, one unused local word omitted.
  Original entry jumps to segment6 load; exit pointer$0CC1 releases segment6.
  goto900 expresses self-EXIT(0,38), including release. Runtime nonlocal EXIT
  must also enter that epilogue. Ancestor accesses at depth2 use sy0e's shared
  storage. Preserve both UNITBUSY calls (eager OR), ignored loader result,
  partial status updates, and close order input0 then output1. }
(*$I-*)
procedure rt_load_session_code;
label 900;
begin
  rtldseg(6);
  repeat
    if not odd(sy0e.words[226]) then
    begin
      rt_release_program_heap;
      sy0e.words[19] := rt_select_program(sy0e.words[19]);
      sy0e.name173 := '';
      if sy0e.words[19] <> 0 then
      begin
        if not odd(sy0e.words[228]) then rt_unbound_entry_failure(nil, nil)
        else
        begin
          sy0e.words[226] := 1;
          goto 900
        end
      end
    end;
    if sy0e.words[19] <> 0 then
    begin
      sy0e.words[226] := 0;
      unitclear(3);
      if rt_read_volume_directory(sy0e.state^.words[2]) then begin end
    end;
    if odd(ord(sy0e.words[19] = 1) or ord(sy0e.words[19] = 2)) then
    begin
      rt_close_file(sy0e.files2[0]^.words[0], 0);
      rt_close_file(sy0e.files2[1]^.words[0], 1)
    end;
    if odd(ord(unitbusy(1)) or ord(unitbusy(2))) then unitclear(1)
  until sy0e.words[19] = 0;
900:
  rtrlseg(6)
end;
(*$I+*)
