{ library_22 procedure6, $0000..$000F, attributes $001A.
  The fixed address denotes existing memory, not allocated Pascal storage. }
procedure clear_hires_page1;
var
  screen: address16;
begin
  screen.word := 8192;
  fillchar(screen.bytes^, 8192, 128)
end;
