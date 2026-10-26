{ system_core0:4 $00C8..$00CC, attributes$00D6. File pointer1; no locals;
  RBP0. The complete body forwards the pointer to system6:3. }
procedure rt_file_rewind(var f: integer);
begin
  rt_rewind_file(f)
end;
