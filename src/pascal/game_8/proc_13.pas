{ game_8 procedure13, $0552..$05BF, attributes $05CA.
  Original eight local words are unread. Keep the two-word currency format,
  including its ordered nonpositive test and exact display strings. }
procedure proc8_13;
begin
  proc27_9('');
  proc22_12(data31.words[9], data31.words[6]);
  if (data29.words[47] <= 0) and (data29.words[46] <= 0) then
    proc22_10(' no money')
  else begin
    if data29.words[46] = 0 then proc22_39(data29.words[47], 8, false)
    else begin
      proc22_39(data29.words[46], 5, false);
      proc22_39(data29.words[47], 3, true)
    end;
    proc22_10(' Cr')
  end;
  proc22_10(' on hand');
  proc8_11;
  proc27_9('')
end;
