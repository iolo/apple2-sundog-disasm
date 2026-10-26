{ game_16 procedure43, $1798..$1805, attributes $1810; nested in41.
  Capture the old item/origin before exchange, then reread target/count/mode
  for the transfer decision. Keep all drawing/buffer calls after it. }
procedure proc16_43;
begin
  previous := held;
  origin := target;
  proc16_40(previous, origin, ord(fromsale));
  proc27_7(held, target, held, drawx, drawy);
  if fromsale or odd(g16.words[18]) then
  begin
    if ((target <= data31.words[10]) and fromsale) or
       ((target > data31.words[10]) and odd(g16.words[18])) then
    begin
      proc16_42;
      proc27_4(held);
      proc22_11(1)
    end;
    fromsale := false
  end;
  proc22_21(0, false);
  proc16_5(held, target);
  proc22_21(0, false)
end;
