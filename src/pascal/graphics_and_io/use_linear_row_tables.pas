{ library_22 procedure 17, $01CE..$01DD, attributes $01E8.
  FJP consumes bit zero; the Boolean interface writes a canonical 0 or 1. }
procedure use_linear_row_tables(enabled: boolean);
begin
  if enabled then data29.words[359] := 1
  else data29.words[359] := 0
end;
