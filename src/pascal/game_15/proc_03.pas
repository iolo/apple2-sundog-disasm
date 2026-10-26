{ game_15 procedure3, $002A..$0074, attributes $007E.
  Original: copy bounds first (slots44..47), then caption with SAS80
  (slots3..43). The reference compiler relocates these private copies to
  slots3..6 and7..47, retaining copy order and90 local bytes. No raw slot
  observer or nested child depends on those private offsets.
  Exactly four bytes are drawn, without a caption-length test. }
procedure proc15_3(bounds: bounds4; caption: text80);
begin
  proc22_12(bounds.lower_first, bounds.upper_second + 9);
  proc22_9(ord(caption[1]));
  proc22_12(bounds.lower_first, bounds.upper_second + 17);
  proc22_9(ord(caption[2]));
  proc22_12(bounds.lower_first, bounds.upper_second + 25);
  proc22_9(ord(caption[3]));
  proc22_12(bounds.lower_first, bounds.upper_second + 33);
  proc22_9(ord(caption[4]))
end;
