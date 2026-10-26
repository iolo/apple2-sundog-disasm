{ system4:5 $0098..$00AF, attributes$00BA; nested in3. Parameters2 flag
  index,1 character. Set ancestor mask only when control word36's bit is0. }
procedure sys4_5(flag, code: integer);
begin
  if not syse.state^.control.flags5[flag] then syse.flags157[code] := true
end;
