{ game_8 procedure4, $007A..$0098, attributes $00A2; nested inside3.
  First flag takes precedence. Both branches use the grandparent's live
  coordinates, so the second call after drawing rereads them. }
procedure proc8_4;
begin
  if drawitem then proc27_3(g8a3[7], g8a3[6])
  else if drawmark then proc22_41(g8a3[13], g8a3[12])
end;
