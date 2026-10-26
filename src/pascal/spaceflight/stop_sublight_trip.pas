{ game_13 procedure38, $1C3E..$1CEF, attributes $1CFA; nested in27.
  Copy the complete location before rendering; subsequent reads remain live. }
procedure stop_sublight_trip;
begin
  data29.flags82[1] := false;
  data29.pos66 := data29.pos72;
  apply_bounds(data29.bnd339, 8);
  set_text_window(data29.words[342], data29.words[341],
            data29.words[340], data29.words[339]);
  write_wrapped_text('Sub-light engines turned off\');
  write_wrapped_text('Current location:  ');
  if data29.pos72.fields.planet = 0 then
  begin
    write_integer(data29.pos72.fields.w0low, 3, true);
    write_wrapped_text(' MARK ');
    write_integer(14 + left_shift_word(data29.pos72.fields.w0high, 1), 3, true)
  end
  else write_wrapped_text(data29.names24.planets^[data29.pos72.fields.planet]);
  text_newline
end;
