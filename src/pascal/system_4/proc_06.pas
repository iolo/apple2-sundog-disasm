{ system4:6 $00BC..$00D3, attributes$00DE; nested in3. Parameters2 flag
  index,1 character. The flag source is word47, distinct from5's word36. }
procedure sys4_6(flag, code: integer);
begin
  if not syse.state^.keys.flags10[flag] then syse.flags157[code] := true
end;
