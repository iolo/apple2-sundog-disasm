{ game_21 procedure39, $198C..$1A17, attributes $1A22; nested in38.
  Value string is copied before effects. The shared button bounds occupy
  parent slots5..8; the second call replaces the first button's rectangle. }
procedure proc21_39(caption: text80; heading: boolean);
var
  xpos: integer;
begin
  if heading then
    proc22_18(button, data29.words[14] + 4, data29.words[13] - 4,
                data29.words[12] + 2, data29.words[12] + 12)
  else
    proc22_18(button, data29.words[14] + 4, data29.words[13] - 4,
                data29.words[11] - 12, data29.words[11] - 2);
  proc22_14(button.lower_first - 2, button.upper_first + 2,
              button.lower_second - 2, button.upper_second + 2);
  proc22_7(10);
  proc22_19(button, 8);
  xpos := (button.lower_first + button.upper_first) div 2 - 3 * length(caption);
  proc22_12(xpos, button.upper_second - 1);
  proc22_10(caption);
  if heading then proc22_19(button, 3)
end;
