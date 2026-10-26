{ utility_disk1:35 $139E..$13B4, attributes$13BE, nested in31.
  Complement the entire shift word and invert row2/key7's bounds. Consumers
  test its low bit; integer NOT avoids canonicalizing the stored word. }
procedure util1_35;
begin
  namework.shift170 := not namework.shift170;
  proc22_19(namework.keys[2, 7].bounds, 3)
end;
