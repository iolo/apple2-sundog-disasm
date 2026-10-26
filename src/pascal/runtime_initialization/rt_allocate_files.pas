{ system4:9 $050A..$0572, attributes$057C. One local pointer word.
  Allocate four30-word headers and three one-word buffers in the exact order.
  Only the first two files2 entries are assigned here;10 assigns the third. }
procedure rt_allocate_files;
var buffer: ^integer;
begin
  syse.state^.words[4] := 0;
  new(syse.file6);
  rt_init_file(syse.file6^.words[0], nil, -1);
  new(syse.file9);
  new(buffer);
  rt_init_file(syse.file9^.words[0], buffer, 0);
  new(syse.file8);
  new(buffer);
  rt_init_file(syse.file8^.words[0], buffer, 0);
  new(syse.file7);
  new(buffer);
  rt_init_file(syse.file7^.words[0], buffer, 0);
  syse.files2[0] := syse.file9;
  syse.files2[1] := syse.file8;
  mark(syse.heap5)
end;
