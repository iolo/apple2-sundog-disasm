{ utility_disk1:10 $01AA..$01BE, attributes$01C8, nested in9.
  Slots1 upper,2 lower,3 VAR value; no locals. Preserve the read before RNG.
  +0 forces parameterless function evaluation before MOD in the reference
  compiler; it emits no extra arithmetic or temporary. }
procedure util1_10(var value: integer; lower, upper: integer);
begin
  value := value + (proc22_3 + 0) mod 3 - 1;
  proc22_37(lower, value, upper)
end;
