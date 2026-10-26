{ system5:5 $01E6..$0252, attributes$025E. VAR header1; locals2 kind,
  3 index,4..7 scratch. Only original scratch words6/7 are used; represent
  those as a pair without the unused words4/5. Search for mapped segment1
  with no invented bound. Clear legacy words for kind1, or kind2 with42 and
  either1566 or1567. Preserve eager comparison/mask evaluation. }
procedure rt_fix_legacy_header(var header: s5header);
var
  kind: integer;
  index: integer;
  legacy: wordpair;
(*$include src/pascal/program_loader/rt_clear_legacy_words.pas*)
begin
  index := 0;
  while rt_mapped_segment(header, index) <> 1 do index := index + 1;
  kind := header.tags128[index].kind;
  if kind = 1 then rt_clear_legacy_words
  else if kind = 2 then
  begin
    legacy.first := header.legacy146.first;
    legacy.second := header.legacy146.second;
    if odd(ord(legacy.first = 42) and
           (ord(legacy.second = 1566) or ord(legacy.second = 1567))) then rt_clear_legacy_words
  end
end;
