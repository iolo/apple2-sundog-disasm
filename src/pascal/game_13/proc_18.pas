{ game_13 procedure18, $124E..$12DA, attributes $12E4; nested in12.
  Parameters4..1: mapkind, VAR targetloc/found, allow (low-bit flag).
  The original condition reads the current planet's city count even when
  mapkind<>3 or saved flag21 is clear. Use local5 for that mandatory read
  before the Boolean test, then as the hit output supplied to19. }
procedure proc13_18(mapkind: integer; var targetloc: g19loc;
                    var found: integer; allow: integer);
var
  probe: g13rowptr; {5}
  code: integer;   {6}
(*$include src/pascal/game_13/proc_19.pas*)
(*$include src/pascal/game_13/proc_24.pas*)
(*$include src/pascal/game_13/proc_25.pas*)
(*$include src/pascal/game_13/proc_26.pas*)
begin
  proc24_9;
  code := 0;
  if data29.flags82[32] then
  begin
    found := 1;
    targetloc := data29.pos72;
    data29.flags82[32] := false
  end
  else
  begin
    probe.word := data29.words[24] + 16 * (data29.loc73.mid5 - 1);
    probe.word := probe.planetrow^.place7.low9 mod 8;
    if (mapkind = 3) and ((not odd(mapstate[11])) or (probe.word = 1)) and
       odd(mode2) then
    begin
      found := 1;
      targetloc := data29.pos72;
      code := 1
    end
    else proc13_19(code, probe.word, data29.words[298], data29.bnd343,
                    found, targetloc, mapkind)
  end;
  if odd(found) then
    case mapkind of
      1: proc13_24(code, targetloc);
      2: proc13_25(code, targetloc);
      3: proc13_26(code, targetloc)
    end
end;
