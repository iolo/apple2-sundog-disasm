{ game_17 procedure10, $03DE..$040D, attributes $0416.
  Parent VAR slots3/2 are caller-owned addresses. Bounds are loaded after
  the optional call. }
procedure proc17_10(setup: boolean);
begin
  if setup then proc22_51(arg3, arg2);
  g17.words[87] := data29.words[14] - 2;
  g17.words[86] := data29.words[13] + 2;
  g17.words[85] := data29.words[12] - 2;
  g17.words[84] := data29.words[11] + 2
end;
