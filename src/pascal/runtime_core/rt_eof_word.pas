{ system_core0:10 $0282..$0286, attributes$0290. File pointer3,
  result1/2; no locals; RBP1. Return the full flag word at file offset2.
  No IO, masking, or normalization to Boolean is present in the listing. }
function rt_eof_word(var f: sysfile): integer;
begin
  rt_eof_word := f.words[2]
end;
