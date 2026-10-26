{ system_core0:3 $00B6..$00BC, attributes$00C6. File pointer3, buffer
  pointer2, kind1; no locals; RBP0. Forward the three words to system6:2.
  Taking @buffer passes its address without loading the buffer contents. }
procedure sys0_3(var f, buffer: integer; kind: integer);
begin
  sys6_2(f, @buffer, kind)
end;
