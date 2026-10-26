{ utility_disk1:49 $202E..$204B, attributes$2058. Two unused value parameters,
  no locals. Caption points at selected slot; both inputs are polled before
  redrawing all slots. Do not discard parameters from the original interface. }
procedure show_slot_certificate(unused2, unused1: integer);
begin
  pop_text_window;
  show_certificate(u1.slots[u1.picked_slot].caption, true);
  repeat until odd(poll_input(0) or poll_input(1));
  paint_utility_catalog
end;
