{ Mutual recursion crosses core7/8/33 and system2/6. Include these forward
  declarations before system2/6 bodies, then include all three core bodies.
  These are declarations of recovered Pascal, not external runtime stubs. }
procedure rt_get_file_element(var f: sysfile); forward;
procedure rt_put_file_element(var f: sysfile); forward;
function rt_extend_file(var f: sysfile): boolean; forward;
