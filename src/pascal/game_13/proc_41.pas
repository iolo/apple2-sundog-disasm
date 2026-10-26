{ game_13 procedure41, $1D26..$1D4F, attributes $1D5A; nested in39.
  Packet is in grandparent27 slots4/5. Byte stores retain low eight bits;
  the mode -1 becomes255. Each mask call runs before the next byte's read. }
procedure proc13_41(mode, fromcity, tocity: integer);
begin
  packet[0] := mode;
  packet[1] := proc22_32(fromcity, 31);
  packet[2] := proc22_32(tocity, 31);
  packet[3] := data29.pos72.fields.w0low
end;
