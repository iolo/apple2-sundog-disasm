{ game_12 procedure13, $0C04..$0C65, attributes $0C70; nested in1.
  Value caption is copied to slots2..9. Both poll outputs alias slot11.
  The origin snapshot is unconditional, even when flag35 skips drawing. }
procedure proc12_13(caption: text15);
var
  code: integer; {10; initially unspecified}
  poll: integer; {11; initially unspecified}
begin
  if not data29.flags82[35] then
  begin
    proc25_2;
    proc25_3(1, caption, 4, 62, 3, 13);
    proc22_19(data29.bnd335, 8);
    proc25_6(data29.bnd335);
    proc25_8(1, code, data29.bnd335, poll, poll);
    proc22_18(data29.bnd335, data29.words[338], data29.words[337],
                data29.words[336] + 15, data29.words[335])
  end;
  g12.words[10] := data29.words[338];
  g12.words[9] := data29.words[336]
end;
