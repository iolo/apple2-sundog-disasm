{ utility_disk1:16 $0592..$0640, attributes$064E, nested in9.
  Nine local words;1/4/5 unused,2 number,3 index,6 buffer,7 source,8 limit,
  9 item pointer. Retry occupied entries without advancing index. Preserve
  random-call order,1024-byte clear,32-byte copy and final two-block write. }
procedure util1_16;
var
  unused1: integer;
  number: integer;
  index: integer;
  unused4: array[4..5] of integer;
  buffer: u16addr;
  source: address16;
  limit: integer;
  item: ^stock4;
begin
  data29.flags82[112] := true;
  data29.bytes[541] := 0;
  data29.bytes[542] := 0;
  initwork.words[1] := 2048;
  buffer.word := initwork.words[1];
  source.word := 5120;
  fillchar(buffer.bytes^, 1024, 0);
  number := proc22_40(1, 57);
  index := 1;
  limit := 17;
  while index <= limit do
  begin
    repeat
      number := (number + ((proc22_3 + 0) mod 4 + 1)) mod 57 + 1
    until buffer.rows^[number, 1].kind = 0;
    item := @buffer.rows^[number, 1];
    item^.kind := 31;
    item^.category := 7;
    item^.origin := number;
    index := index + 1
  end;
  proc22_53(source.word, 1, initwork.words[2] + 6, true);
  moveleft(source.bytes^[352], buffer.bytes^[960], 32);
  proc22_53(buffer.word, 2, initwork.words[2] + 1, false)
end;
