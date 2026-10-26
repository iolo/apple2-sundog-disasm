{ utility_disk1:6 $1964..$1A55, attributes$1A62. Two local words.
  Word34 becomes raw address8192; fill8192 bytes without allocator semantics.
  Display all four slots before printing the instruction panel. }
procedure util1_6;
var
  index: integer;
  limit: integer;
begin
  data29.words[34] := 8192;
  fillchar(data29.addr34.bytes^, 8192, 0);
  proc22_14(data29.words[10], data29.words[9], data29.words[8], data29.words[8] + 37);
  proc22_7(10);
  proc22_14(data29.words[10], data29.words[9], data29.words[8] + 38, data29.words[7]);
  proc22_7(5);
  index := 0;
  limit := 3;
  while index <= limit do
  begin
    util1_3(index, true);
    index := index + 1
  end;
  proc22_50(data29.words[10] + 4, data29.words[9] - 4,
              data29.words[8] + 4, data29.words[8] + 32);
  proc22_44;
  proc22_48('||||||||||SunDog> Utility Program\');
  proc22_48('Select box with cursor to play or delete a\');
  proc22_48('||suspended game, or to start a new one.')
end;
