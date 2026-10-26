{ utility_disk1:5 $1B26..$1B3E, attributes$1B4A. One value word, no locals.
  Decrement before both polls, even when the initial count is nonpositive.
  Integer OR preserves both effectful polls before testing the count. }
procedure wait_utility_input(ticks: integer);
begin
  repeat
    ticks := ticks - 1
  until odd((poll_input(0) or poll_input(1)) or ord(ticks <= 0))
end;
