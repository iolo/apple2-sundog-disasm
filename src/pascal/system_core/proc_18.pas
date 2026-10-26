{ system_core0:18 $04C2..$0522, attributes$0530. File pointer3, string
  pointer2, capacity1; locals4 index,5 character,6 file pointer.
  Extra s is a raw string view. The initial length-byte write follows the
  optional advance. Console editing35 can change index without storing a byte.
  After storing the final length, drain until flag1 is set, even if flag2
  ended the first loop. No new capacity check or EOF escape is introduced. }
procedure sys0_18(var f: sysfile; var dest: integer; capacity: integer);
var index, code: integer;
    fileptr: sysfptr;
    s: s0strptr;
begin
  fileptr := @f;
  s.word := @dest;
  index := 1;
  if fileptr^.words[3] = 1 then sys0_7(f);
  s.bytes^[0] := capacity;
  while odd(ord(index <= capacity) and
            not (fileptr^.words[1] or fileptr^.words[2])) do
  begin
    code := fileptr^.current.bytes^[0];
    if fileptr^.words[7] = 1 then
    begin
      if not sys0_35(code, index, dest) then
      begin
        s.bytes^[index] := code;
        index := index + 1
      end
    end
    else
    begin
      s.bytes^[index] := code;
      index := index + 1
    end;
    sys0_7(f)
  end;
  s.bytes^[0] := index - 1;
  while not odd(fileptr^.words[1]) do sys0_7(f)
end;
