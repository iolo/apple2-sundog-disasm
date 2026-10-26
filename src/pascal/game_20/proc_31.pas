{ game_20 procedure31, $180A..$18F3, attributes $18FC; nested in28.
  SCONCAT rejects an entire append exceeding its specified capacity. The
  first append has capacity9; the second has24. The title call retains its
  SAS15 capacity check, including failure for an overlong heading. }
procedure proc20_31;
var
  phase: integer;
  heading: string[24];
begin
  proc22_44;
  if odd(g20.words[16]) then suffix := ' Center'
  else suffix := ' Exch.';
  heading := '';
  if length(data29.names25.cities^[data29.bits37.mid6]) <= 9 then
    heading := data29.names25.cities^[data29.bits37.mid6];
  heading := concat(heading, suffix);
  proc20_10(heading, g20.words[14], g20.words[13], g20.words[12] - 85);
  proc22_46(0, 12);
  if odd(g20.words[16]) then
  begin
    phase := data29.bytes[542];
    proc22_46(0, 12);
    proc22_48('|Phases remaining: ');
    proc22_49(10 - phase, 1, false);
    proc22_46(0, 15);
    proc22_48('|||Items needed to\||complete Phase ');
    proc22_49(phase, 1, false);
    proc22_47(58)
  end
  else
  begin
    proc22_46(0, 14);
    proc22_48('|\||Lots now selling:')
  end
end;
