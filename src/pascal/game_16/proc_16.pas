{ game_16 procedure16, $0724..$0769, attributes $0778.
  Choose the name table by the random word's low bit, then retry until the
  selected index differs from the current location. No retry limit is added.
  SAS15 writes through the original VAR address. One address-view local is new. }
procedure proc16_16(var caption: text15);
var
  systemid: integer;
  planetid: integer;
  names: nameaddr;
begin
  if odd(proc22_3) then
  begin
    repeat
      systemid := proc22_40(1, 12)
    until systemid <> data29.loc37.low4;
    names.word := data29.words[23];
    caption := names.systems^[systemid].caption
  end
  else
  begin
    repeat
      planetid := proc22_40(1, 18)
    until planetid <> data29.loc37.mid5;
    names.word := data29.words[24];
    caption := names.planets^[planetid]
  end
end;
