{ system_core0:12 $02A2..$0380, attributes$0392. File pointer2, VAR
  integer1; locals3..48 represented by work (92 bytes). Console input fills
  exactly81 bytes with80 ('P'), not spaces; editing35 only needs printable
  dummy bytes. The output is cleared before advancing/skipping spaces.
  Arithmetic remains16-bit, with no invented overflow or length rejection.
  Editing can clear digits without clearing the remembered sign or digits4.
  The editing loop rereads a character after each consumed key, then calls35
  again without another unit test. EOF after leading spaces returns directly. }
procedure sys0_12(var f: sysfile; var value: integer);
label 999;
var work: s0numin;
begin
  work.file48 := @f;
  if work.file48^.words[7] = 1 then fillchar(work.temp7, 81, 80);
  value := 0;
  work.minus5 := false;
  work.digits4 := false;
  if work.file48^.words[3] = 1 then sys0_7(f);
  while odd(ord(work.file48^.current.bytes^[0] = 32) and
            not work.file48^.words[2]) do sys0_7(f);
  if odd(work.file48^.words[2]) then goto 999;
  work.code3 := work.file48^.current.bytes^[0];
  if odd(ord(work.code3 = 43) or ord(work.code3 = 45)) then
  begin
    work.index6 := 2;
    work.minus5 := work.code3 = 45;
    sys0_7(f);
    work.code3 := work.file48^.current.bytes^[0]
  end
  else work.index6 := 1;
  if odd(ord(work.code3 >= 48) and ord(work.code3 <= 57)) then
  begin
    work.digits4 := true;
    repeat
      value := value * 10 + work.code3 - 48;
      sys0_7(f);
      work.code3 := work.file48^.current.bytes^[0];
      work.index6 := work.index6 + 1;
      if work.file48^.words[7] = 1 then
        while sys0_35(work.code3, work.index6, work.temp7.words[0]) do
        begin
          if work.index6 = 1 then value := 0 else value := value div 10;
          sys0_7(f);
          work.code3 := work.file48^.current.bytes^[0]
        end
    until odd(not (ord(work.code3 >= 48) and ord(work.code3 <= 57)) or
              work.file48^.words[1])
  end;
  if odd(ord(work.digits4) or work.file48^.words[2]) then
  begin
    if work.minus5 then value := -value
  end
  else sy0e.state^.words[0] := 14;
999:
end;
