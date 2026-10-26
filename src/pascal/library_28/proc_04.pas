{ library_28 procedure4, $008C..$00A6, attributes $00B0.
  Keep the sign multiplication around MOD1000; do not assume host MOD rules. }
procedure proc28_4(var result: wordpair; highpart, lowpart: integer);
begin
  result.second := proc22_34(lowpart) * (lowpart mod 1000);
  result.first := highpart + lowpart div 1000
end;
