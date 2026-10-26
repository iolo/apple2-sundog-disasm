{ Game 18:9, $032A..$03A9, attributes $03B6. Four argument words:
  index plus three VAR words. Both collision calls in each trial are effectful. }
procedure proc18_9(index: integer; var firstpos, secondpos, remaining: integer);
var
  secondstep: integer;
  firststep: integer;
  code: integer;
  hitlow: boolean;
  hithigh: boolean;
begin
  remaining := 10;                         { $032A..$032C }
  code := 24;                              { $032D..$032E }
  firststep := 5 * proc22_34(
    (g18b107.upper_first - g18b107.lower_first) div 4); { $0330..$0340 }
  secondstep := 3 * proc22_34(
    (g18b107.upper_second - g18b107.lower_second) div 4); { $0342..$0352 }
  repeat
    firstpos := proc22_40(g18b107.lower_first, g18b107.upper_first);
    secondpos := proc22_40(g18b107.lower_second, g18b107.upper_second);
    remaining := remaining - 1;            { $0354..$0373 }
    { $0374..$038C: evaluate both calls, in this order, before OR.
      Re-read VAR arguments for the second call, after native effects. }
    hitlow := proc18_3(code, firstpos - firststep, secondpos - secondstep);
    hithigh := proc18_3(code, firstpos + firststep, secondpos + secondstep)
  until (not (hitlow or hithigh)) or (remaining = 0); { $038E..$0395 }
  if remaining > 0 then                    { $0397..$03A8 }
    g18items[index].flags.high_byte := 3
end;
