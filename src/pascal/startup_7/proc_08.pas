{ startup_7 procedure8, $042E..$06EE, attributes $0704; nested in1.
  Preserve both identical ten-block writes around checksum3, save/restart
  selection and all calls52. Integer OR retains both certificate input polls.
  The final DUST transfer invokes26:2, whose native boot call does not return. }
procedure proc7_8;
var
  checksum: integer; {1}
  slot: integer; {2}
  choice: integer; {3}
  unused: integer; {4}
  won: integer; {5}
  saved: integer; {6; original store retained though not subsequently read}
begin
  while data29.words[20] > 0 do proc22_52;
  if (data29.nibbles45[2] = data29.nibbles45[1]) and
     (data29.nibbles45[2] = 11) then
  begin
    if data29.loc37.mid5 = 0 then data29.nibbles45[1] := 2
    else if data29.bits37.mid6 = 0 then
    begin
      if data29.bytes[75] = 0 then data29.nibbles45[1] := 2
      else data29.nibbles45[1] := 4
    end
    else data29.nibbles45[1] := 3
  end;
  data29.seed64 := data29.seed21;
  won := 0;
  choice := 2;
  saved := 0;
  proc22_51(20, 12);
  if data29.nibbles45[2] = 12 then
  begin
    proc22_48('Sorry, ');
    proc22_48(data29.name255);
    proc22_48(', you didn''t make it.\');
    proc22_48('Restart at last saved point?');
    s7.words[13] := 4;
    s7.words[12] := data29.words[13] - data29.words[14] - 4;
    s7.words[11] := (s7.words[12] + s7.words[13]) div 2;
    s7.words[5] := data29.words[11] - data29.words[12] - 12;
    proc25_2;
    proc25_3(1, 'Yes', s7.words[13], s7.words[11] - 2, s7.words[5], s7.words[5] + 10);
    proc25_3(2, 'No', s7.words[11] + 2, s7.words[12], s7.words[5], s7.words[5] + 10);
    repeat proc26_5(choice, 0) until choice > 0
  end
  else if data29.nibbles45[2] = 13 then won := 1
  else
  begin
    saved := 1;
    if data29.nibbles45[1] < 5 then data29.nibbles45[2] := data29.nibbles45[1]
    else data29.nibbles45[2] := data29.nibbles45[0];
    data29.nibbles45[1] := 11;
    data29.nibbles45[0] := 11
  end;
  proc26_4(proc22_24(data29.words[36]), 16384, 512);
  proc22_53(16384 + 512, 6, data29.words[30] + 3, true);
  proc26_4(-5887, 16384 + 3584, 1440);
  proc7_3(true);
  if choice = 2 then
  begin
    proc22_53(16384, 10, data29.words[31], false);
    checksum := proc26_3(16384, 10);
    proc22_53(16384, 10, data29.words[31], false);
    proc22_53(16384, 1, 23, true);
    slot := (data29.words[31] - 24) div 10;
    proc26_4(proc22_24(checksum), 16384 + 64 * slot + 30, 2);
    proc22_53(16384, 1, 23, false);
    if odd(won) then
    begin
      proc22_44;
      proc22_48('Congratulations, ');
      proc22_48(data29.name255);
      proc22_48('!  You completed the contract in just ');
      proc22_49(data29.clock42.day, 3, false);
      proc22_48(' days. ');
      proc22_48('You now own the SunDog.');
      proc26_7(data29.name255, true);
      repeat
      until odd(proc22_2(0) or proc22_2(1))
    end
    else proc22_52
  end
  else proc22_52;
  proc26_2('DUST')
end;
