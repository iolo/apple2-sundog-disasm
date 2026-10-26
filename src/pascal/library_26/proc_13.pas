{ Both library26 variants: procedure13, $01C0..$01C4, attributes $01CE.
  Preserve17 local words shared by14/16 and grandchild15. }
procedure proc26_13;
var
  lasty: integer; {1}
  firsty: integer; {2}
  right: integer; {3}
  left: integer; {4}
  buffer: integer; {5}
  positions: array[0..5] of wordpair; {6..17}
(*$include src/pascal/library_26/proc_14.pas*)
(*$include src/pascal/library_26/proc_16.pas*)
begin
  proc26_14;
  proc26_16
end;
