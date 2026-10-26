{ system_core0:1 $0000..$0016, attributes$0022, owned by runtime_entry.s.
  Program-block include. Original lexical level-1, zero parameter bytes,
  1068 local bytes exposed by sy0e: s4env. All other ancestor views must alias
  this same storage, not allocate independent copies. Heap marker5 is the
  only field initialized before clearing unit1 and calling system4:1.
  The original constant-false repeat test loops forever; its otherwise
  unreachable exit pointer is XIT$0016. Host program layout is not this ABI. }
(*$I-*)
begin
  sy0e.heap5 := nil;
  unitclear(1);
  rt_initialize_system;
  repeat
    rt_dispatch_session;
    if sy0e.heap5 <> nil then rt_initialize_system
  until false
end.
