{ library_22 procedure 42, $079A..$07F9, attributes $0804.
  The value bounds parameter is copied before any external-data writes. }
procedure initialize_pointer(var firstpos, secondpos: integer; code: integer;
                    bounds: bounds4);
(*$include src/pascal/graphics_and_io/configure_pointer_axis.pas*)
begin
  data29.words[374] := code;
  assign_bounds(data29.bounds375, bounds.lower_first + 3, bounds.upper_first - 5,
            bounds.lower_second + 5, bounds.upper_second - 3);
  configure_pointer_axis(data29.words[378], data29.words[377] - data29.words[378],
            140, data29.words[380], data29.words[369]);
  configure_pointer_axis(data29.words[376], data29.words[375] - data29.words[376],
            96, data29.words[379], data29.words[368]);
  apply_bounds(data29.bounds375, 0);
  read_pointer_position(firstpos, secondpos);
  toggle_pointer_glyph(firstpos, secondpos)
end;
