{ Both library26 variants: procedure6, $02C8..$06DA, attributes $06EA.
  id26 is the disk-specific20-byte literal at$03F7; select exactly one
  identity.pas in the CONST section. All other instructions agree.
  Keep the original disk reads/writes, random calls, seed copies and reboot
  transfer. Private unused slots4/5 save BOTH title-screen input polls.
  Header byte0 is compared with zero (not bit0); other Boolean slots use bit0. }
procedure proc26_6(mode: boolean);
var
  header: address16; {2}
  bootblock: integer; {3}
  poll0: integer; {4}
  poll1: integer; {5}
  stored: integer; {6}
  checksum: integer; {7}
  timeout: integer; {8}
  bootimage: integer; {9}
  switchto: integer; {10}
  choice: integer; {11}
  top: integer; {12}
  right: integer; {13}
  slot: integer; {14; later random scratch}
  blocked: integer; {15}
  invalid: integer; {16}
  damaged: integer; {17}
  won: integer; {18}
  dead: integer; {19}
  newgame: integer; {20}
  started: integer; {21}
begin
  damaged := 0;
  invalid := 0;
  header.word := 5120;
  proc22_53(5120, 1, 80, true);
  started := ord(header.bytes^[0] <> 0);
  slot := header.bytes^[1];
  bootblock := header.bytes^[7] - 3;
  moveleft(header.bytes^[2], data29.words[21], 4);
  data29.words[31] := 10 * slot + 24;
  if slot < 4 then
    proc22_53(proc22_24(data29.words[36]), 1, data29.words[31], true)
  else data29.flags82[122] := false;
  if not odd(started) then proc26_13;
  if mode then
  begin
    switchto := 1;
    bootimage := 77
  end
  else
  begin
    switchto := 2;
    bootimage := 78
  end;
  if slot < 4 then
  begin
    proc22_53(16384, 10, data29.words[31], true);
    if mode then proc22_53(22528, 4, 194, true);
    checksum := proc26_3(16384, 10);
    proc22_53(5632, 1, 23, true);
    proc26_4(5662 + 64 * slot, proc22_24(stored), 2);
    if stored <> checksum then
    begin
      damaged := 1;
      header.bytes^[1] := 255
    end
  end
  else
  begin
    invalid := 1;
    data29.name255 := 'there'
  end;
  if (not odd(started)) or mode then proc22_51(40, 24);
  if not odd(started) then
  begin
    proc22_44;
    proc22_48('|||||||SunDog>\');
    proc22_48('||||Frozen Legacy\');
    proc22_48('|||||Version 2.0\|\');
    proc22_48(id26);
    proc22_48('|by FTL Games, Inc.\');
    proc22_48('|All rights reserved\|\');
    proc22_48('|Press either joystick\');
    proc22_48('||||button to begin');
    timeout := 11400;
    repeat
      slot := proc22_3;
      timeout := timeout - 1;
      poll0 := proc22_2(0);
      poll1 := proc22_2(1)
    until odd(poll0) or odd(poll1) or (timeout <= 0);
    moveleft(data29.words[21], header.bytes^[2], 4);
    proc22_44;
    dead := ord(data29.nibbles45[2] = 12);
    won := ord(data29.nibbles45[2] = 13);
    newgame := ord((data29.clock42.day = 0) and
                   (data29.clock42.hour = 0) and (data29.clock42.minute = 0));
    if odd(dead) or odd(damaged) then proc22_48('Too bad, ')
    else if odd(won) then proc22_48('Well done, ')
    else proc22_48('Hello, ');
    proc22_48(data29.name255);
    blocked := dead or won or damaged or invalid; {bitwise OR of0/1 words}
    if odd(blocked) then
    begin
      if odd(dead) or odd(won) then
      begin
        if odd(dead) then proc22_48('.  You died')
        else proc22_48('!  You won');
        proc22_48(', so your game is over')
      end
      else if odd(damaged) then proc22_48('.  Your game is damaged')
    end;
    proc22_48('.  You can ');
    if not odd(blocked) then
    begin
      if odd(newgame) then proc22_48('start') else proc22_48('continue');
      proc22_48(' your game, ')
    end;
    proc22_48('use the utilities or run the demo.');
    right := data29.words[13] - data29.words[14] - 4;
    top := data29.words[11] - data29.words[12] - 42;
    proc25_2;
    if not odd(blocked) then proc25_3(2, 'Play SunDog>', 4, right, top, top + 10);
    top := top + 15;
    proc25_3(1, 'Use utilities', 4, right, top, top + 10);
    top := top + 15;
    proc25_3(3, 'Run demo', 4, right, top, top + 10);
    repeat
      proc26_5(choice, 1)
    until choice > 0;
    if (choice = switchto) or (choice = 3) then
    begin
      if choice = 3 then bootimage := 79
      else
      begin
        header.bytes^[0] := 255;
        proc22_53(5120, 1, 80, false)
      end;
      proc22_53(5120, 1, bootimage, true);
      proc22_53(5120, 1, bootblock, false);
      proc22_52;
      proc26_2('MUST')
    end
    else if not mode then proc22_52
  end
  else
  begin
    header.bytes^[0] := 0;
    proc22_53(5120, 1, 80, false)
  end
end;
