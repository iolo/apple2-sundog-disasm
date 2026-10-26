{ game_13 procedure31, $15DC..$1606, attributes $1610; nested in27.
  Cached overlays share address6144; install both cache flags only after I/O.
  Raw integer arguments are narrowed to bit0 by their packed destination. }
procedure proc13_31(flag, count, offset, warp, transit: integer);
begin
  if not data29.flags82[flag] then
  begin
    proc22_53(6144, count, data29.words[27] + offset, true);
    data29.flags82[118] := odd(warp);
    data29.flags82[119] := odd(transit)
  end
end;
