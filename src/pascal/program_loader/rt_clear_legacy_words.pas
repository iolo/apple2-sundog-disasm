{ system5:6 $01C4..$01DA, attributes$01E4; nested in5. No locals/params.
  Resolve the parent's header pointer for each of the two stores. }
procedure rt_clear_legacy_words;
begin
  header.legacy146.first := 0;
  header.legacy146.second := 0
end;
