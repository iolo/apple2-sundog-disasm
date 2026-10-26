{ Both library26 variants: procedure7, $0766..$0790, attributes $079A.
  Copy caption to slots3..10 before effects. Native reveal consumes the
  ADDRESS of uninitialized local11 without reading/writing that word. }
procedure proc26_7(caption: text15; animate: boolean);
var unused: integer; {11}
(*$include src/pascal/library_26/proc_17.pas*)
begin
  proc22_11(1);
  if animate then
  begin
    proc22_53(16384, 18, 2, true);
    callcert(unused, 24576)
  end
  else proc22_53(8192, 16, 2, true);
  proc26_17
end;
