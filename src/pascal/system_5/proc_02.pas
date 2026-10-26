{ system5:2 $0000..$0122, attributes$0138. VAR name3, text flag2,
  capacity1; original locals180 bytes. Remove spaces before any other work.
  A trailing dot is removed and returns immediately, suppressing uppercasing,
  extension and bracket-suffix handling. Otherwise preserve the suffix from
  the first '[' (SAS40), uppercase the non-volume name and conditionally append
  .TEXT/.CODE. The original tests length>5, not >=5, before comparing endings.
  Core23/25/26/27 remain explicit p-code dependencies, not replacement bodies.
  The view pointer below is a source convenience, not an original frame slot. }
procedure sys5_2(var nameword: integer; textfile: boolean; capacity: integer);
var
  n: integer;
  index: integer;
  suffix: s5str40;
  extension: s5str5;
  trailing: s5str5;
  temp: s5temp;
  caption: s5nameptr;
begin
  caption.word := @nameword;
  index := sys0_27(' ', nameword);
  while index > 0 do
  begin
    sys0_26(nameword, index, 1);
    index := sys0_27(' ', nameword)
  end;
  n := caption.name^.bytes[0];
  if n <= 0 then exit(sys5_2);
  if caption.name^.bytes[n] = 46 then
  begin
    caption.name^.bytes[0] := n - 1;
    exit(sys5_2)
  end;
  suffix.text := '';
  trailing.text := suffix.text;
  index := sys0_27('[', nameword);
  if index > 0 then
  begin
    n := caption.name^.bytes[0] - index + 1;
    sys0_25(nameword, temp.words[0], index, n);
    suffix.text := temp.text;
    sys0_26(nameword, index, n)
  end;
  n := caption.name^.bytes[0];
  if n > 0 then
    if caption.name^.bytes[n] <> 58 then
    begin
      if textfile then extension.text := '.TEXT'
      else extension.text := '.CODE';
      index := 1;
      temp.words[0] := n;
      while index <= temp.words[0] do
      begin
        if odd(ord(caption.name^.bytes[index] >= 97) and
               ord(caption.name^.bytes[index] <= 122)) then
          caption.name^.bytes[index] := caption.name^.bytes[index] - 97 + 65;
        index := index + 1
      end;
      if n > 5 then
      begin
        sys0_25(nameword, temp.words[0], n - 5 + 1, 5);
        trailing.text := temp.text
      end;
      if odd(ord(trailing.text <> extension.text) and
             ord(n + length(suffix.text) <= capacity - 5)) then
      begin
        moveleft(extension.bytes[1], caption.name^.bytes[n + 1], 5);
        caption.name^.bytes[0] := n + 5
      end
    end;
  temp.words[0] := 0;
  sys0_23(temp.words[0], nameword, 80);
  sys0_23(temp.words[0], suffix.words[0], 120);
  caption.name^.text := temp.text
end;
