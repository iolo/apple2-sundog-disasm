{ game_13 procedure32, $1630..$170A, attributes $1714; nested in27.
  Copy both full20-byte system rows before displaying their16-byte prefixes.
  Preserve signed16-bit cost arithmetic and the priority of failure checks. }
procedure proc13_32(var place: g19loc);
var
  destsys: integer; {2}
  oldsys: integer;  {3}
  cost: integer;    {4}
  distance: integer;{5}
  destrow: name20;  {6..15}
  oldrow: name20;   {16..25}
(*$include src/pascal/game_13/proc_33.pas*)
begin
  oldsys := data29.loc73.low4;
  destsys := place.fields.system;
  oldrow := data29.names23.systems^[oldsys];
  destrow := data29.names23.systems^[destsys];
  proc13_28('J-SPACE', oldrow.caption, destrow.caption);
  proc24_9;
  distance := proc24_6(oldsys, destsys);
  proc22_48('Dist:  ');
  proc22_49(distance, 2, false);
  proc22_48(' j-secs\');
  cost := 3 * (distance * distance) + 10;
  if cost > 255 then proc13_33(1)
  else if data29.words[227] = 0 then proc13_33(0)
  else if data29.bytes[178 + 24] = 0 then proc13_33(4)
  else
  begin
    if cost > data29.words[223] + 2 * data29.words[227] then proc13_29(2);
    data29.flags82[0] := true;
    data29.words[222] := cost;
    data29.words[221] := place.fields.system;
    proc22_48('Warp engines charging')
  end
end;
