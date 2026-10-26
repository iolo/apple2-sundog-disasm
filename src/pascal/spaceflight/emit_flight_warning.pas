{ game_13 procedure30, $14A2..$14C1, attributes $14CC; nested in29.
  Copy up to22 characters before drawing the prefix. }
procedure emit_flight_warning(message: g13text22);
begin
  write_wrapped_text('*** ');
  write_wrapped_text(message);
  write_wrapped_text(' ***\')
end;
