{ utility_disk1:44 $1B4C..$1BDE, attributes$1BEA. One value word, no locals.
  Status2 is suspended and3 is being played; unlisted values print nothing. }
procedure write_save_status(save_state: integer);
begin
  case save_state of
    0: write_wrapped_text('empty');
    1: write_wrapped_text('new game');
    2: write_wrapped_text('suspended');
    3: write_wrapped_text('being played');
    4: write_wrapped_text('** died **');
    5: write_wrapped_text('** won **');
    6: write_wrapped_text('** damaged **')
  end
end;
