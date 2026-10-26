{ Target-specific contracts of the already reviewed library22:25 raw-call
  trampoline. The viewscreen_io overlay is loaded to2048 by game13 before
  tactical entry. These declarations do not implement or link the overlay.

  $0800 removes return and one address ($0800..$080A), restores only return,
  then reads byte1 and byte0 through that address ($0812..$081B). Low byte
  selects the pattern; high byte controls optional speaker accesses. }
procedure call_beam_overlay(var modes: integer; target: integer); external;

{ $09D6 removes return and one address ($09D6..$09E0), restores only return,
  then reads bytes0/2/4/6 into $2D/$2C/$2B/$2A ($09E8..$09F3). The call sites
  push the address value already held in parent word43, not its VAR address.
  No Pascal result or argument writes; native screen effects are retained. }
procedure call_sky_overlay(address, target: integer); external;

{ $0A73 removes return and one address ($0A73..$0A7D), restores only return,
  measures paddle counters, then writes two sign-extended words through the
  pointer ($0ABB..$0AD0): first the Y-table result, then the X-table result.
  Caller12 supplies its contiguous local words1/2. No Pascal result. }
procedure call_joystick_overlay(var motion: wordpair; target: integer); external;
