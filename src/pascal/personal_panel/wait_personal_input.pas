{ game_8 procedure11, $04D0..$0502, attributes $050E.
  Poll selector4 on every iteration, including when word347's low bit is set. }
procedure wait_personal_input;
var
  random_value: integer;
  release_poll: integer;
begin
  repeat
    random_value := random_word;
    if random_value mod 8 = 0 then
      data29.words[354] := data29.words[354] + 1;
    if data29.words[354] >= data29.words[353] then tick_personal_panel(false, false);
    release_poll := poll_input(4)
  until not odd(release_poll) or odd(data29.words[347])
end;
