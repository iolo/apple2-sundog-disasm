{ utility_disk1:5 $1B26..$1B3E, attributes$1B4A. One value word, no locals.
  Decrement before both polls, even when the initial count is nonpositive.
  Integer OR preserves both effectful polls before testing the count. }
procedure util1_5(ticks: integer);
begin
  repeat
    ticks := ticks - 1
  until odd((proc22_2(0) or proc22_2(1)) or ord(ticks <= 0))
end;
