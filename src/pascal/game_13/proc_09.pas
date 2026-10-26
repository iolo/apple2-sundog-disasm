{ game_13 procedure9, $0264..$04C9, attributes $04D6; nested in3.
  Retain original text, spaces, bounds, and state values0/1/2. No name-table
  selector guards or string-length limits absent from the listing are added. }
procedure proc13_9;
var
  labels: string[9];
  index: integer;
  last: integer;
begin
  proc22_51(data29.words[346] div 7 + 10, proc22_31(data29.words[344], 3) + 6);
  proc22_46(2, 1);
  proc22_48('SYSTEMS  ');
  g13s.words[3] := 7 * ((data29.words[19] + 6) div 7);
  g13s.words[2] := data29.words[18];
  proc13_7;
  proc22_46(3, 3);
  labels := 'WEG TSP H';
  index := 0;
  last := 8;
  while index <= last do
  begin
    proc22_12(g13s.words[3] + index * 7, data29.words[18] + 2);
    proc22_9(ord(labels[index + 1]));
    index := index + 1
  end;
  proc22_46(0, 6);
  proc22_48('WARP DRIVES: ');
  proc22_18(g13s.charge14, data29.words[19] - 2, data29.words[19] + 42,
            data29.words[18] - 7, data29.words[18]);
  if not data29.flags82[0] then
  begin
    proc22_48('no charge');
    g13s.words[5] := 0
  end
  else
  begin
    proc22_48('charg');
    if data29.words[223] >= data29.words[222] then
    begin
      proc22_48('ed');
      g13s.words[5] := 2
    end
    else
    begin
      proc22_48('ing');
      g13s.words[5] := 1;
      g13s.words[16] := g13s.words[16] + 6
    end;
    proc22_19(g13s.charge14, 3);
    proc22_19(data29.bounds11, 0)
  end;
  proc22_46(0, 8);
  proc22_48('SUB-C ENGNS: ');
  proc22_18(g13s.engine10, data29.words[19] - 2, data29.words[19] + 48,
            data29.words[18] - 7, data29.words[18]);
  if not data29.flags82[1] then
  begin
    proc22_48('power off');
    g13s.words[7] := 0
  end
  else
  begin
    proc22_48('power on');
    g13s.words[7] := 1;
    proc22_19(g13s.engine10, 3);
    proc22_19(data29.bounds11, 0)
  end;
  proc22_46(0, 11);
  proc22_48('SYSTEM:   ');
  proc22_48(data29.names23.systems^[data29.loc73.low4].caption);
  proc22_46(0, 13);
  proc22_48('LOCATION: ');
  proc13_8(10, 13, data29.pos72);
  proc22_46(0, 15);
  proc22_48('WARP TO:  ');
  if data29.words[221] = 0 then proc22_48('(none)')
  else proc22_48(data29.names23.systems^[data29.words[221]].caption);
  proc22_46(0, 17);
  proc22_48('SYS DEST: ');
  if not data29.flags82[1] then proc22_48('(none)')
  else proc13_8(10, 17, data29.pos66);
  if data29.flags82[25] then
  begin
    proc22_46(0, 20);
    proc22_48('RESCUE ETA: ');
    proc22_28(data29.clock78);
    g13s.words[6] := 1
  end
  else g13s.words[6] := 0
end;
