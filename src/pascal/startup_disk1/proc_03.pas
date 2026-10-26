{ startup_disk1 procedure3, entry$0020, body$0022..$0076,
  load$007D..$0080, release$0078, RNP$0082, attributes$0090.
  Clear word347 once, before the dispatch loop. Unlisted cases do nothing.
  Nonlocal EXIT must enter the segment24 release epilogue at$0078. }
procedure boot1_3;
begin
  rtldseg(24);
  data29.words[347] := 0;
  repeat
    case data29.nibbles45[2] of
      0, 1: proc13_1;
      2: proc15_1;
      9: proc16_1(22, 9, 19)
    end
  until (data29.nibbles45[2] >= 11) or
        (data29.nibbles45[2] = 3) or (data29.nibbles45[2] = 4);
  rtrlseg(24)
end;
