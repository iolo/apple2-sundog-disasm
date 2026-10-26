{ game_21 procedure3, $004C..$0078, attributes $0082. }
procedure proc21_3;
(*$include src/pascal/game_21/proc_04.pas*)
begin
  if data29.nibbles45[2] = 3 then
  begin
    proc21_4(116, 16384, arg8);
    proc21_4(117, 16384 + 2048, arg7)
  end
  else proc21_4(116, 16384, 4)
end;
