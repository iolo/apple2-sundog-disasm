{ system5:7 $0260..$02D0, attributes$02DC. VAR header2,file1; locals
  3 index,4 number,5 state,6 header,7 file,8 entry,9 limit,10 row,11 segment.
  Register only segment1 or7..31. Store unit, size, then block; kind7 gets
  block0. The mapper receives original header2, retaining the alias boundary. }
procedure sys5_7(var header: s5header; var f: sysfile);
var
  index: integer;
  number: integer;
  state: s5state;
  headptr: s5hptr;
  fileptr: sysfptr;
  entryptr: syseptr;
  limit: integer;
  row: ^wordpair;
  segmentptr: ^s5segment;
begin
  state.base := sy5e.common.state;
  headptr := @header;
  fileptr := @f;
  entryptr := @fileptr^.entry16;
  index := 0;
  limit := 15;
  while index <= limit do
  begin
    row := @headptr^.rows[index];
    if row^.second <> 0 then
    begin
      number := sys5_3(header, index);
      if odd(ord(number = 1) or (ord(number >= 7) and ord(number <= 31))) then
      begin
        segmentptr := @state.config^.segments[number];
        segmentptr^.unit0 := fileptr^.words[7];
        segmentptr^.size2 := row^.second;
        if headptr^.kinds96[index] = 7 then segmentptr^.block1 := 0
        else segmentptr^.block1 := row^.first + entryptr^.words[0]
      end
    end;
    index := index + 1
  end
end;
