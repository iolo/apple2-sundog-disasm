{ system4:10 $057E..$05FD, attributes$0608. No parameters/locals.
  Use root command1, preserve close/init/open order, and conditionally open
  SYSTERM only on ancestor word229's low bit. All three files2 stores occur. }
procedure sys4_10;
begin
  sys6_5(syse.file6^.words[0], 0);
  sys6_2(syse.file230.words[0], nil, -1);
  sys6_5(syse.file9^.words[0], 0);
  sys6_5(syse.file8^.words[0], 0);
  s4work.command := 'CONSOLE:';
  sys6_4(syse.file9^.words[0], s4work.command, 1, nil);
  sys6_4(syse.file8^.words[0], s4work.command, 1, nil);
  if odd(syse.words[229]) then
  begin
    s4work.command := 'SYSTERM:';
    sys6_4(syse.file7^.words[0], s4work.command, 1, nil)
  end;
  syse.files2[0] := syse.file9;
  syse.files2[1] := syse.file8;
  syse.files2[2] := syse.file7
end;
