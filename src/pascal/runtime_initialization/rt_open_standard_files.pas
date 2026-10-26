{ system4:10 $057E..$05FD, attributes$0608. No parameters/locals.
  Use root command1, preserve close/init/open order, and conditionally open
  SYSTERM only on ancestor word229's low bit. All three files2 stores occur. }
procedure rt_open_standard_files;
begin
  rt_close_file(syse.file6^.words[0], 0);
  rt_init_file(syse.file230.words[0], nil, -1);
  rt_close_file(syse.file9^.words[0], 0);
  rt_close_file(syse.file8^.words[0], 0);
  s4work.command := 'CONSOLE:';
  rt_open_file(syse.file9^.words[0], s4work.command, 1, nil);
  rt_open_file(syse.file8^.words[0], s4work.command, 1, nil);
  if odd(syse.words[229]) then
  begin
    s4work.command := 'SYSTERM:';
    rt_open_file(syse.file7^.words[0], s4work.command, 1, nil)
  end;
  syse.files2[0] := syse.file9;
  syse.files2[1] := syse.file8;
  syse.files2[2] := syse.file7
end;
