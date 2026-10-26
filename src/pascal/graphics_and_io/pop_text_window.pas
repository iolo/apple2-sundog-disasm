{ library_22 procedure 52, $0B2E..$0B7A, attributes $0B84.
  The inverse transition paired with procedure 51. The counter is reread
  after native 15, then again after decrement; no underflow repair is added. }
procedure pop_text_window;
var
  secondpos, firstpos: integer;
begin
  if data29.words[20] <= 0 then exit(pop_text_window);
  window_image_transfer(0);
  data29.words[20] := data29.words[20] - 1;
  if data29.words[20] > 0 then
  begin
    copy_window_buffer(false);
    firstpos := data29.addr373.bytes^[2000];
    secondpos := data29.addr373.bytes^[2001];
    set_window_image_origin(secondpos, firstpos);
    set_text_window(firstpos * 7 + 2, firstpos * 7 + 137,
              secondpos + 2, secondpos + 93)
  end
end;
