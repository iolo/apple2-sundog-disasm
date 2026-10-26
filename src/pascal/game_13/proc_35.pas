{ game_13 procedure35, $1760..$19F5, attributes $1A04; nested in27.
  Original locals1/5/6/7 are unused;1 supplies dynamic byte index4 and5 holds
  the random result. Keep the18-byte frame and parent27's six-byte frame.
  packet[spill] intentionally writes one byte past the parent's declared
  locals. Range checks must remain disabled; runtime binding must preserve
  the original caller/frame context. Do not silently allocate a larger packet.
  LNOT is a word complement: byte0 must be255/254, not canonical Boolean1/0. }
procedure proc13_35;
var
  spill: integer;    {1}
  height: integer;   {2}
  heading: integer;  {3}
  chance: integer;   {4}
  randomv: integer;  {5}
  unused6: integer;
  unused7: integer;
  spread: integer;   {8}
  passed: boolean;   {9}
begin
  proc13_31(118, 3, 4, 1, 0);
  proc22_44;
  proc22_48('Engaging warp engines');
  proc22_16(data29.words[344], data29.words[346] div 7);
  if data29.pos72.fields.planet > 0 then chance := 0
  else chance := proc22_30(data29.pos72.fields.w0high + 7, 1);
  randomv := proc22_3;
  passed := chance > randomv mod 100;
  packet[0] := 255 - ord(data29.flags82[122]);
  packet[1] := 20 + proc22_31(data29.words[222], 1);
  packet[2] := 17 * data29.loc73.low4;
  packet[3] := 13 * data29.words[221];
  if passed then
  begin
    height := data29.pos72.fields.w0high;
    if height < 43 then
    begin
      heading := 32 + proc22_31(data29.pos72.fields.w0low + 8, 4);
      spread := proc22_31(43 - height, 2) + 1;
      heading := proc22_30(proc22_32(proc22_40(heading - spread,
                                             heading + spread), 15), 4)
    end
    else heading := proc22_30(proc22_31(data29.pos72.fields.w0low + 8, 4), 4);
    spill := 4;
    packet[spill] := 0;
    fillchar(data29.pos72, 12, data29.words[293]);
    data29.pos72.fields.system := data29.words[221];
    data29.pos72.fields.w0low := heading;
    data29.pos72.fields.w0high := 43;
    proc22_48('\Switching to viewscreen\');
    proc22_19(data29.bnd343, 8);
    callwarp(packet, 6144);
    data29.words[354] := data29.words[353] + 1;
    data29.flags82[1] := false;
    data29.flags82[40] := false;
    data29.flags82[25] := false;
    data29.flags82[47] := false;
    proc24_9;
    proc22_19(data29.bnd303, 5);
    proc22_44;
    proc22_48('Warp successfully completed\');
    proc13_2
  end
  else
  begin
    spread := 3 * (20 + data29.pos72.fields.w0high);
    spill := 4;
    packet[spill] := 1;
    proc22_48('\Switching to viewscreen\');
    proc22_19(data29.bnd343, 8);
    callwarp(packet, 6144);
    spread := 63;
    proc22_4(spread, 255 - 3 * spread, 1 + spread, 3, 255, 0, 0);
    proc22_50(data29.words[342], data29.words[341],
              data29.words[340], data29.words[339]);
    proc22_44;
    proc22_48('Instability due to gravity field')
  end;
  data29.flags82[5] := false;
  data29.words[203] := 2;
  data29.words[221] := 0;
  data29.words[223] := 0;
  data29.words[222] := 0;
  proc22_19(data29.bnd307, 8);
  proc22_12(data29.words[310] + 2, data29.words[307]);
  proc22_39(14 + 2 * data29.pos72.fields.w0high, 3, true);
  proc22_19(data29.bnd311, 8);
  data29.flags82[0] := false
end;
