{ startup_7 procedure3, $003E..$00D1, attributes $00E0; nested in1.
  Integer OR forces both input calls with no extra local slots. Original
  EQU6 against true tests only bit0 of utility. Retry the whole prompt when
  the disk check fails, and just the poll pair while neither button is down. }
procedure proc7_3(utility: boolean);
begin
  repeat
    proc22_44;
    proc22_48('Please flip to the \|\');
    if utility = true then proc22_48('||||UTILITY')
    else proc22_48('||||||PLAY');
    proc22_48(' SIDE\|\of the disk and press either button\|\|');
    repeat
    until odd(proc22_2(0) or proc22_2(1))
  until proc7_2(utility)
end;
