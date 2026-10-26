{ utility_disk1:44 $1B4C..$1BDE, attributes$1BEA. One value word, no locals.
  Status2 is suspended and3 is being played; unlisted values print nothing. }
procedure util1_44(state: integer);
begin
  case state of
    0: proc22_48('empty');
    1: proc22_48('new game');
    2: proc22_48('suspended');
    3: proc22_48('being played');
    4: proc22_48('** died **');
    5: proc22_48('** won **');
    6: proc22_48('** damaged **')
  end
end;
