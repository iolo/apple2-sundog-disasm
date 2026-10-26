{ game_13 procedure41, $1D26..$1D4F, attributes $1D5A; nested in39.
  Packet is in grandparent27 slots4/5. Byte stores retain low eight bits;
  the mode -1 becomes255. Each mask call runs before the next byte's read. }
procedure pack_view_transition(mode, from_city, to_city: integer);
begin
  packet[0] := mode;
  packet[1] := word_and(from_city, 31);
  packet[2] := word_and(to_city, 31);
  packet[3] := data29.pos72.fields.w0low
end;
