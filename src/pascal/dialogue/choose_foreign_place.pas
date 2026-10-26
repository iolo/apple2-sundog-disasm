{ game_16 procedure16, $0724..$0769, attributes $0778.
  Choose the name table by the random word's low bit, then retry until the
  selected index differs from the current location. No retry limit is added.
  SAS15 writes through the original VAR address. One address-view local is new. }
procedure choose_foreign_place(var caption: text15);
var
  system_index: integer;
  planet_index: integer;
  place_names: nameaddr;
begin
  if odd(random_word) then
  begin
    repeat
      system_index := random_between(1, 12)
    until system_index <> data29.loc37.low4;
    place_names.word := data29.words[23];
    caption := place_names.systems^[system_index].caption
  end
  else
  begin
    repeat
      planet_index := random_between(1, 18)
    until planet_index <> data29.loc37.mid5;
    place_names.word := data29.words[24];
    caption := place_names.planets^[planet_index]
  end
end;
