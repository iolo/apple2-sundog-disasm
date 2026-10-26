{ system5:1 $05A6..$0664, attributes$066E. Integer result1, mode3;
  original lexical level0, parameter bytes6, local bytes4. Slot4 is unused;
  status occupies original slot5. No child accesses that local by offset.
  This function expresses the segment entry's RBP1 behavior; an ordinary
  Pascal host compiles it as a nested RNP1 function, so the original segment
  entry ABI and runtime ancestor link remain binding requirements.
  sy5e aliases that ancestor: depth1 here, depth2 in children.
  Successful attach returns4; startup/named code returns3; otherwise0.
  The three self-EXITs target$0664, with no extra cleanup. }
function rt_select_program(mode: integer): integer;
var outcome: integer;
(*$include src/pascal/program_loader/rt_normalize_code_name.pas*)
(*$include src/pascal/program_loader/rt_mapped_segment.pas*)
(*$include src/pascal/program_loader/rt_validate_code_header.pas*)
(*$include src/pascal/program_loader/rt_fix_legacy_header.pas*)
(*$include src/pascal/program_loader/rt_register_segments.pas*)
(*$include src/pascal/program_loader/rt_collect_segment_mask.pas*)
(*$include src/pascal/program_loader/rt_load_system_library.pas*)
(*$include src/pascal/program_loader/rt_prepare_code_file.pas*)
begin
  rt_select_program := 0;
  sy5e.common.file9^.words[2] := 0;
  sy5e.common.file8^.words[2] := 0;
  sy5e.common.file7^.words[2] := 0;
  sy5e.common.files2[0] := sy5e.common.file9;
  sy5e.common.files2[1] := sy5e.common.file8;
  if mode = 0 then
    if odd(sy5e.common.words[229]) then
    begin
      sy5e.common.words[229] := 0;
      if rt_prepare_code_file('*SYSTEM.ATTACH', 0, 0, false, outcome, true) then
      begin
        rt_select_program := 4;
        exit(rt_select_program)
      end
    end;
  if mode = 4 then mode := 0;
  if mode = 0 then
    if rt_prepare_code_file('*SYSTEM.STARTUP', 0, 0, true, outcome, false) then
    begin
      rt_reset_console;
      rt_select_program := 3;
      exit(rt_select_program)
    end;
  if length(sy5e.common.name173) > 0 then
  begin
    rt_normalize_code_name(sy5e.common.words[173], false, 23);
    if rt_prepare_code_file(sy5e.common.name173, 0, 0, true, outcome, false) then
    begin
      rt_select_program := 3;
      exit(rt_select_program)
    end
  end
end;
