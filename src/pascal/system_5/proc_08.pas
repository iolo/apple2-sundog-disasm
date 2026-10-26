{ system5:8 $02DE..$032A, attributes$0336. Result1, allowed pointer3,
  output pointer4,header5; value-copy allowed6, index7,header pointer8,limit9.
  Copy the one-word allowed mask before clearing four output bytes, even when
  arguments alias. A rejected row sets false but does not stop later updates. }
function sys5_8(var header: s5header; var mask: s5mask32;
                allowed: s5mask16): boolean;
var
  index: integer;
  headptr: s5hptr;
  limit: integer;
begin
  fillchar(mask, 4, 0);
  sys5_8 := true;
  headptr := @header;
  index := 0;
  limit := 15;
  while index <= limit do
  begin
    if headptr^.rows[index].second <> 0 then
    begin
      if allowed[headptr^.kinds96[index]] then
        mask[sys5_3(header, index)] := true
      else sys5_8 := false
    end;
    index := index + 1
  end
end;
