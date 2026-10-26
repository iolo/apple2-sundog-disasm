{ game_13 procedure28, $144A..$1496, attributes $14A0; nested in27.
  All three value strings are copied before any display call. The reference
  compiler puts kind/dest in private slots4/20 instead of20/4; no nested child
  or raw address consumer observes those private positions. }
procedure write_flight_plan(kind, origin, dest: text15);
begin
  clear_text_window;
  write_wrapped_text(kind);
  write_wrapped_text(' FLIGHT PLAN\From:  ');
  write_wrapped_text(origin);
  write_wrapped_text('\To:    ');
  write_wrapped_text(dest);
  text_newline
end;
