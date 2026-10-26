{ utility_disk1:50 $205A..$20B5, attributes$20C0. No parameters/locals.
  Choice4's certificate closes/redraws its own window; other choices including
  unmatched values close and redraw the selected slot here. Restore cursor. }
procedure util1_50;
begin
  proc22_41(u1.words[5], u1.words[4]);
  util1_46(u1.words[5], u1.words[4], u1.words[6]);
  proc22_51(u1.words[5] div 7, u1.words[4] div 8);
  util1_47;
  proc26_5(u1.words[11], 0);
  case u1.words[11] of
    1: util1_48;
    2: util1_40;
    3: util1_43;
    4: util1_49(u1.words[5] div 7, u1.words[4] div 8)
  end;
  if u1.words[11] <> 4 then
  begin
    proc22_52;
    util1_3(u1.words[6], true)
  end;
  proc22_42(u1.words[5], u1.words[4], 1, data29.bounds7)
end;
