{ system_core0:3 $00B6..$00BC, attributes$00C6. File pointer3, buffer
  pointer2, kind1; no locals; RBP0. Forward the three words to system6:2.
  Taking @buffer passes its address without loading the buffer contents. }
procedure rt_file_initialize(var f, buffer: integer; kind: integer);
begin
  rt_init_file(f, @buffer, kind)
end;
