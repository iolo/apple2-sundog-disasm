{ game_15 procedure15, $08B2..$08DA, attributes $08E4.
  Byte80 is word41's low field; preserve its high byte. }
procedure leave_ship_interior;
begin
  toggle_pointer_glyph(g15.cursor_x, g15.cursor_y);
  data29.nibbles45[1] := 2;
  data29.nibbles45[0] := 11;
  data29.words[40] := g15.marker_x;
  data29.bytes[80] := g15.marker_y;
  toggle_ship_marker
end;
