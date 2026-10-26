{ system6:11 $0000..$023F, attributes$0256. Result1, VAR kind3,amount4,
  filename5,volume6; value caption pointer7, copied with SAS80 to8..48.
  Original locals49 closing bracket,50 index,51 character,52 valid,
  53..93 string temporary. Two source-only pointers expose raw string words
  to the recovered core25/26/27 interfaces; no value copy of the outputs.
  Preserve partial outputs on failure, 16-bit decimal accumulation, [*] => -1,
  acceptance of [] and trailing bytes after ']', and the length>5 extension
  test. There is no invented rejection of an overlong volume prefix: when it
  exceeds7 characters, the original simply skips that copy/delete branch. }
function sys6_11(caption: text80; var volume: s4text7;
                 var filename: text15; var amount: integer;
                 var kind: integer): boolean;
var
  closing: integer;
  index: integer;
  code: integer;
  valid: boolean;
  temp: s6str80;
  rawname: s6strptr;
  rawfile: s6strptr;
begin
  rawname.text := @caption;
  rawfile.narrow := @filename;
  volume := '';
  filename := '';
  amount := 0;
  kind := 0;
  sys6_11 := false;
  index := 1;
  while index <= length(caption) do
  begin
    code := rawname.raw^.bytes[index];
    if code <= 32 then sys0_26(rawname.raw^.words[0], index, 1)
    else
    begin
      if odd(ord(code >= 97) and ord(code <= 122)) then
        rawname.raw^.bytes[index] := code - 97 + 65;
      index := index + 1
    end
  end;
  if length(caption) <= 0 then exit(sys6_11);
  if rawname.raw^.bytes[1] = 42 then
  begin
    volume := sy6e.name14;
    sys0_26(rawname.raw^.words[0], 1, 1)
  end
  else if rawname.raw^.bytes[1] = 37 then
  begin
    volume := sy6e.name529;
    sys0_26(rawname.raw^.words[0], 1, 1)
  end;
  index := sys0_27(':', rawname.raw^.words[0]);
  if index <= 1 then
  begin
    if length(volume) = 0 then volume := sy6e.name10;
    if index = 1 then sys0_26(rawname.raw^.words[0], 1, 1)
  end
  else if index - 1 <= 7 then
  begin
    sys0_25(rawname.raw^.words[0], temp.words[0], 1, index - 1);
    volume := temp.text;
    sys0_26(rawname.raw^.words[0], 1, index)
  end;
  if length(volume) <= 0 then exit(sys6_11);
  index := sys0_27('[', rawname.raw^.words[0]);
  if index > 0 then index := index - 1
  else index := length(caption);
  if index > 15 then exit(sys6_11);
  if index > 0 then
  begin
    sys0_25(rawname.raw^.words[0], temp.words[0], 1, index);
    filename := temp.text;
    sys0_26(rawname.raw^.words[0], 1, index)
  end;
  if length(caption) = 0 then valid := true
  else
  begin
    valid := false;
    closing := sys0_27(']', rawname.raw^.words[0]);
    if closing = 2 then valid := true
    else if closing > 2 then
    begin
      valid := true;
      index := 2;
      repeat
        code := rawname.raw^.bytes[index];
        if odd(ord(code >= 48) and ord(code <= 57)) then
          amount := amount * 10 + (code - 48)
        else valid := false;
        index := index + 1
      until odd(ord(index = closing) or (not ord(valid)));
      if odd(ord(index = 3) and ord(closing = 3)) then
        if rawname.raw^.bytes[index - 1] = 42 then
        begin
          amount := -1;
          valid := true
        end
    end
  end;
  sys6_11 := valid;
  if odd(ord(valid) and ord(length(filename) > 5)) then
  begin
    sys0_25(rawfile.raw^.words[0], temp.words[0], length(filename) - 4, 5);
    caption := temp.text;
    if caption = '.TEXT' then kind := 3
    else if caption = '.CODE' then kind := 2
    else if caption = '.BACK' then kind := 3
    else if caption = '.INFO' then kind := 4
    else if caption = '.GRAF' then kind := 6
    else if caption = '.FOTO' then kind := 7
  end
end;
