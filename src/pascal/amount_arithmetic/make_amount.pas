{ library_28 procedure4, $008C..$00A6, attributes $00B0.
  Keep the sign multiplication around MOD1000; do not assume host MOD rules. }
procedure make_amount(var result: wordpair; high_part, low_part: integer);
begin
  result.second := word_sign(low_part) * (low_part mod 1000);
  result.first := high_part + low_part div 1000
end;
