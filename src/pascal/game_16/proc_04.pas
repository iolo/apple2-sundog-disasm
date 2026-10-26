{ game_16 procedure4, $00E2..$010C, attributes $0116.
  Copy both value words before changing draw mode. Negative high words take
  the original single-low-word path, without normalization. }
procedure proc16_4(amount: wordpair);
begin
  proc22_11(3);
  if amount.first > 0 then
  begin
    proc22_39(amount.first, 5, false);
    proc22_9(44);
    proc22_39(amount.second, 3, true)
  end
  else
  begin
    proc22_9(32);
    proc22_39(amount.second, 8, false)
  end
end;
