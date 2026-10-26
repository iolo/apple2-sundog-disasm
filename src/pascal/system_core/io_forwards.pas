{ Mutual recursion crosses core7/8/33 and system2/6. Include these forward
  declarations before system2/6 bodies, then include all three core bodies.
  These are declarations of recovered Pascal, not external runtime stubs. }
procedure sys0_7(var f: sysfile); forward;
procedure sys0_8(var f: sysfile); forward;
function sys0_33(var f: sysfile): boolean; forward;
