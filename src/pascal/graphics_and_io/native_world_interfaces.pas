{ Native library22:4, $0D26..$0D8E: pops16 bytes including return address,
  hence seven argument words; restores only return address. Speaker access at
  $C030 and self-modifying native state remain in the original implementation.
  Parameters keep neutral ordinal names; caller constants do not prove units. }
procedure play_sound(arg7, arg6, arg5, arg4, arg3, arg2, arg1: integer); external;
