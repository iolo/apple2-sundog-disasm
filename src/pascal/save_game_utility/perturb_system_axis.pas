{ utility_disk1:10 $01AA..$01BE, attributes$01C8, nested in9.
  Slots1 upper,2 lower,3 VAR value; no locals. Preserve the read before RNG.
  +0 forces parameterless function evaluation before MOD in the reference
  compiler; it emits no extra arithmetic or temporary. }
procedure perturb_system_axis(var value: integer; lower, upper: integer);
begin
  value := value + (random_word + 0) mod 3 - 1;
  clamp_word(lower, value, upper)
end;
