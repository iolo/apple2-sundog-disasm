{ Both library26 variants: procedure7, $0766..$0790, attributes $079A.
  Copy caption to slots3..10 before effects. Native reveal consumes the
  ADDRESS of uninitialized local11 without reading/writing that word. }
procedure show_certificate(caption: text15; animate: boolean);
var unused: integer; {11}
(*$include src/pascal/title_and_boot/write_certificate_caption.pas*)
begin
  set_glyph_mode(1);
  if animate then
  begin
    disk_blocks_io(16384, 18, 2, true);
    call_certificate_reveal(unused, 24576)
  end
  else disk_blocks_io(8192, 16, 2, true);
  write_certificate_caption
end;
