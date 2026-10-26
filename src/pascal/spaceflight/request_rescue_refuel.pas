{ game_13 procedure52, $2512..$257A, attributes $2584; nested in1.
  Preserve the literal 'Refuel ETA:  ', flag writes, two-word time copy and
  conditional random delay. The displayed value is read after the text call. }
procedure request_rescue_refuel;
var
  refuel_delay: integer;
begin
  set_text_window(data29.words[342], data29.words[341],
            data29.words[340], data29.words[339]);
  clear_text_window;
  data29.flags82[25] := true;
  data29.flags82[51] := false;
  data29.clock78 := data29.clock42;
  refuel_delay := 30;
  if data29.pos72.fields.planet = 0 then refuel_delay := refuel_delay + random_between(30, 120);
  add_clock_minutes(data29.clock78, refuel_delay);
  write_wrapped_text('Refuel ETA:  ');
  draw_clock(data29.clock78)
end;
