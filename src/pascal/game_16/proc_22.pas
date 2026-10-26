{ game_16 procedure22, $0844..$0851, attributes $085C.
  Nested in18: extract into its slot3 string, then pass the same string to21. }
procedure proc16_22(recordid, variant: integer; expand: boolean);
begin
  proc16_13(recordid, variant, phrase);
  proc16_21(phrase.text, expand)
end;
