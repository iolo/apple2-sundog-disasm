{ game_16 procedure22, $0844..$0851, attributes $085C.
  Nested in18: extract into its slot3 string, then pass the same string to21. }
procedure emit_phrase_record(recordid, variant: integer; expand: boolean);
begin
  extract_phrase_variant(recordid, variant, phrase);
  emit_dialog_phrase(phrase.text, expand)
end;
