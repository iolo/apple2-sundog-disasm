{ system_core0:6 $00EC..$00F1, attributes$00FC. File pointer2, mode1;
  no locals; RBP0. The complete body forwards both words to system6:5. }
procedure rt_file_close(var f: integer; mode: integer);
begin
  rt_close_file(f, mode)
end;
