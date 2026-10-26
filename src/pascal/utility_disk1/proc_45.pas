{ utility_disk1:45 $1E1C..$1E32, attributes$1E3C. Slot1 number,2 caption
  address,3..10 local value-copy caption. Word8 reread after menu call. }
procedure util1_45(caption: text15; number: integer);
begin
  proc25_3(number, caption, u1.words[10], u1.words[9],
            u1.words[8], u1.words[8] + 10);
  u1.words[8] := u1.words[8] - 15
end;
