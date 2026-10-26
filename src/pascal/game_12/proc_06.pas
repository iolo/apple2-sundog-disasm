{ game_12 procedure6, $017C..$0289, attributes $0294; nested in1.
  Bounty adds to only system-row word6, without carry into7. Capture that
  row across printing. Cargo chance runs even without a bounty, and cargo
  field addresses are evaluated before their respective random calls. }
procedure proc12_6;
var
  rate: integer;   {1}
  rating: integer; {2}
  bounty: integer; {3}
  systemrow: g12scratch; {4}
begin
  proc22_44;
  proc22_48('|TARGET DESTROYED\');
  rating := data29.tbl23.rows^[data29.loc73.low4].nibbles8[3];
  if rating + data29.words[214] > 12 then
  begin
    systemrow.word := data29.words[23] + 20 * (data29.loc73.low4 - 1);
    rate := systemrow.row^.nibbles8[4];
    proc22_48('|Bounty:');
    bounty := proc22_31((data29.words[214] + 1) * rate, 3);
    if bounty = 0 then bounty := 1;
    proc22_49(bounty, 3, false);
    proc22_48('000 Cr\');
    systemrow.row^.words[6] := systemrow.row^.words[6] + bounty
  end;
  if proc22_40(0, 5) <= data29.words[214] then
  begin
    proc22_48('|Cargo detected\|in wreckage');
    g12.words[27] := 1;
    data29.flags82[36] := true;
    if data29.flags82[1] then data29.words[207] := 2
    else data29.words[207] := 1;
    g12.cargo34.kind := proc22_40(1, 30);
    g12.cargo34.category := proc22_40(4, 7);
    g12.cargo34.origin := 0;
    g12.words[35] := 0
  end
end;
