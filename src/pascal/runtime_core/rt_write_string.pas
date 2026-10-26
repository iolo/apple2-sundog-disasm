{ system_core0:19 $0532..$0546, attributes$0550. File pointer3, borrowed
  string pointer2, width1; no locals. Nonpositive width becomes string length.
  Core20 receives the byte address immediately after the length byte. The
  string is not copied before calling20, so aliases retain their behavior.
  Extra payload pointer expresses the original byte-address +1 operation. }
procedure rt_write_string(var f: integer; var caption: text80; width: integer);
var payload: s0strptr;
begin
  if width <= 0 then width := length(caption);
  payload.text := @caption;
  payload.address := payload.address + 1;
  rt_write_bytes(f, payload.bytes, width, length(caption))
end;
