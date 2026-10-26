{ utility_disk1:49 $202E..$204B, attributes$2058. Two unused value parameters,
  no locals. Caption points at selected slot; both inputs are polled before
  redrawing all slots. Do not discard parameters from the original interface. }
procedure util1_49(unused2, unused1: integer);
begin
  proc22_52;
  proc26_7(u1.slots[u1.words[6]].caption, true);
  repeat until odd(proc22_2(0) or proc22_2(1));
  util1_6
end;
