{ system4:7 $03A6..$04F2, attributes$0508. Five local words:
  1 unit/index,2 directory pointer,3 limit,4 unit-table pointer,5 packed flags.
  The directory lookup at$044C overwrites the loop index; increment that value,
  not the previous unit. Retain low-bit tests of words520/227/229 and gated
  UNITCLEAR/IORESULT/volume-read order. Child8 names six character devices. }
(*$I-*)
procedure rt_enumerate_devices;
var
  index: integer;
  directory: s4hptr;
  limit: integer;
  unitptr: ^s4unit;
  flags: ^s4date;
(*$include src/pascal/runtime_initialization/rt_name_character_device.pas*)
(*$I-*)
begin
  rt_init_file(s4work.words[15], nil, -1);
  index := 0;
  limit := 20;
  while index <= limit do
  begin
    unitptr := @syse.units31[index];
    unitptr^.caption := '';
    unitptr^.flag4 := ord(index = 4) or ord(index = 5) or
                      (ord(index >= 9) and ord(index <= 20));
    if odd(unitptr^.flag4) then
    begin
      unitptr^.word5 := 32767;
      if odd((not syse.words[520]) or ord(index = 4)) then
      begin
        unitclear(index);
        if ioresult = 0 then
          if rt_read_volume_directory(index) then
          begin
            unitptr^.caption := syse.state^.directory^.caption;
            if index = syse.state^.words[2] then
            begin
              syse.name14 := unitptr^.caption;
              s4work.command := '*SYSTEM.STARTUP';
              rt_open_file(s4work.words[15], s4work.command, 1, nil);
              s4work.words[14] := s4work.words[20];
              rt_close_file(s4work.words[15], 0);
              index := rt_resolve_volume(syse.name14, 0, directory);
              if directory = nil then halt;
              syse.words[18] := directory^.words[10];
              flags := @directory^.flags12;
              syse.words[228] := flags^.high7;
              syse.words[520] := flags^.high7 div 2;
              syse.words[227] := flags^.high7 div 8;
              if odd(syse.words[227]) then syse.words[228] := 1
            end
          end
      end
    end;
    index := index + 1
  end;
  if odd(syse.words[229]) then syse.name10 := syse.name14;
  rt_name_character_device(1, 'CONSOLE');
  rt_name_character_device(2, 'SYSTERM');
  rt_name_character_device(3, 'GRAPHIC');
  rt_name_character_device(6, 'PRINTER');
  rt_name_character_device(7, 'REMIN');
  rt_name_character_device(8, 'REMOUT')
end;
(*$I+*)
