{ library_22 procedure6, $0000..$000F, attributes $001A.
  The fixed address denotes existing memory, not allocated Pascal storage. }
procedure proc22_6;
var
  screen: address16;
begin
  screen.word := 8192;
  fillchar(screen.bytes^, 8192, 128)
end;
