{ system5:4 $0170..$01B5, attributes$01C2. Boolean result1, VAR header3,
  locals4 index,5 limit. Validate entries1..15, without an early false return;
  both legacy words are read before the final OR test. }
function rt_validate_code_header(var header: s5header): boolean;
var
  index: integer;
  limit: integer;
begin
  rt_validate_code_header := true;
  index := 1;
  limit := 15;
  while index <= limit do
  begin
    if header.rows[index].second <> 0 then
      if rt_mapped_segment(header, index) = 0 then rt_validate_code_header := false;
    index := index + 1
  end;
  if odd(ord(header.legacy146.first <> 0) or
         ord(header.legacy146.second <> 0)) then rt_validate_code_header := false
end;
