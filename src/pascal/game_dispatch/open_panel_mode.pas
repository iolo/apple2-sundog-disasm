{ startup_disk1 procedure5, nested in4, entry$0092, body$0094..$00B2,
  load$00BA..$00BD, release$00B5, RNP$00BF, attributes$00CC.
  Only game14 gets the address of parent slot1. Nonlocal EXIT must enter$00B5. }
procedure open_panel_mode;
begin
  rtldseg(27);
  if data29.nibbles45[2] = 8 then run_component_panel(boot4[1], boot4[4], boot4[3])
  else run_personal_panel(boot4[4], boot4[3]);
  rtrlseg(27)
end;
