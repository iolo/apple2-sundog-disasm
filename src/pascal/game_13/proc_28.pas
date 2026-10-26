{ game_13 procedure28, $144A..$1496, attributes $14A0; nested in27.
  All three value strings are copied before any display call. The reference
  compiler puts kind/dest in private slots4/20 instead of20/4; no nested child
  or raw address consumer observes those private positions. }
procedure proc13_28(kind, origin, dest: text15);
begin
  proc22_44;
  proc22_48(kind);
  proc22_48(' FLIGHT PLAN\From:  ');
  proc22_48(origin);
  proc22_48('\To:    ');
  proc22_48(dest);
  proc22_45
end;
