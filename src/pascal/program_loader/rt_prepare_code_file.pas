{ system5:10 $03BC..$0591, attributes$05A4. Result1, version3,
  VAR status4, fatal5, spare6/7, value caption pointer8 (copy9..49).
  Header50..305, mask306..307, work caption308..348, saved volume349..352,
  parsed volume353..356/name357..364, outputs365/366, parsed367,
  allowed368, zero mask369..370, index371, unused state372.
  Calls to core0:2 are preserved with their following paths if they return.
  Success closes once and EXIT(5,10) jumps to$0591, bypassing$0580..$058E:
  only local failure cleanup closes and restores the saved ancestor name.
  CSP4 vector$D108 -> native_shared.s $E75C..$E797 selects that exit pointer.
  External unwinding to10 likewise skips local cleanup; do not add finally. }
(*$I-*)
function rt_prepare_code_file(caption: text80; spare7: integer; spare6: integer;
                 fatal: boolean; var status: integer;
                 version: boolean): boolean;
label 900, 999;
var
  header: s5header;
  mask: s5mask32;
  workname: text80;
  savedvolume: s4text7;
  volume: s4text7;
  filename: text15;
  parta: integer;
  partb: integer;
  parsed: boolean;
  allowed: s5mask16;
  empty: s5mask32;
  index: integer;
  state: s5state;
begin
  status := 2;
  rt_prepare_code_file := false;
  savedvolume := sy5e.common.name529;
  workname := caption;
  parsed := rt_parse_file_spec(workname, volume, filename, parta, partb);
  sy5e.common.name529 := volume;
  if not parsed then sy5e.common.name529 := '';
  rt_open_file(sy5e.common.file230.words[0], caption, 1, nil);
  if ioresult <> 0 then
  begin
    if fatal then rt_system_failure(2)
    else goto 999
  end;
  status := 1;
  state.base := sy5e.common.state;
  if sy5e.common.file230.entry16.kind2.kind <> 2 then
  begin
    rt_system_failure(3);
    goto 900
  end;
  unitread(sy5e.common.file230.words[7], header, 512,
           sy5e.common.file230.words[16], 0);
  if ioresult <> 0 then rt_system_failure(4);
  if version then
    if header.tags128[1].kind <> 5 then
    begin
      rt_write_newline(sy5e.common.files2[1]^.words[0]);
      rtiochk;
      rt_write_string(sy5e.common.files2[1]^.words[0], caption, 0);
      rtiochk;
      rt_write_string(sy5e.common.files2[1]^.words[0], ' is not version 1.2', 0);
      rtiochk;
      goto 999
    end;
  if not version then rt_fix_legacy_header(header);
  if not rt_validate_code_header(header) then rt_system_failure(11);
  fillchar(allowed, 2, 0);
  allowed[0] := true;
  if not rt_collect_segment_mask(header, mask, allowed) then rt_system_failure(5);
  index := 0;
  while index <= 31 do
  begin
    if odd(ord(mask[index]) and ord(header.needs144[index])) then rt_system_failure(6);
    index := index + 1
  end;
  fillchar(empty, 4, 0);
  if header.needs144 <> empty then
  begin
    if not rt_load_system_library('*SYSTEM.LIBRARY') then rt_system_failure(10);
    index := 0;
    while index <= 31 do
    begin
      if odd(ord(header.needs144[index]) and
             (not ord(sy5e.mask533[index]))) then rt_system_failure(8);
      index := index + 1
    end
  end;
  rt_register_segments(header, sy5e.common.file230);
900:
  status := 0;
  rt_prepare_code_file := true;
  rt_close_file(sy5e.common.file230.words[0], 0);
  exit(rt_prepare_code_file);
999:
  rt_close_file(sy5e.common.file230.words[0], 0);
  sy5e.common.name529 := savedvolume
end;
(*$I+*)
