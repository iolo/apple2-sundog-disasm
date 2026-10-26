{ utility_disk1:42 $1A64..$1ACF, attributes$1ADC, six unused local bytes.
  Write512 bytes starting at program slot12, including storage past the four
  64-byte records. Preserve both line advances and both input polls. }
procedure util1_42;
var unused: array[1..3] of integer;
begin
  util1_7(true);
  proc22_53(proc22_24(u1.words[12]), 1, data29.words[31] - 1, false);
  proc22_51(20, 12);
  proc22_45;
  proc22_45;
  proc22_48('|Press either button\');
  proc22_48('||||||to reboot');
  repeat until odd(proc22_2(0) or proc22_2(1));
  proc22_52;
  proc26_2('DUST')
end;
