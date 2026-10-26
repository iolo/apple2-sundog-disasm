{ library_22 procedure28, $0362..$0394, attributes $039E.
  Copies all four bytes before mode/drawing calls; leaves mode3 selected. }
procedure draw_clock(stamp: clock4);
(*$include src/pascal/graphics_and_io/draw_two_digits.pas*)
begin
  set_glyph_mode(3);
  draw_glyph(48 + (stamp.day div 100) mod 10);
  draw_two_digits(stamp.day mod 100);
  draw_glyph(126);
  draw_two_digits(stamp.hour);
  draw_glyph(58);
  draw_two_digits(stamp.minute)
end;
