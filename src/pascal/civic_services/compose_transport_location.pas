{ game_19 procedure10, $04F8..$05D7, attributes $05E0.
  Copy all six source words before selective packed updates. Table selection
  uses the just-stored (possibly truncated) packed index, as in the listing. }
procedure compose_transport_location(place_kind, place_index: integer; var destination: g19loc);
var
  systems: g19addr;
  planets: g19paddr;
  cities: g19caddr;
begin
  destination.words := data29.rec36;
  with destination.fields do
  begin
    if place_kind > 1 then
    begin
      if place_kind > 2 then
      begin
        system := place_index;
        systems.word := data29.words[23];
        with systems.rows^[system].bits5 do planet := mid5 + low2 - 1
      end
      else planet := place_index;
      planets.word := data29.words[24];
      w0high := planets.rows^[planet].coords6.high;
      planets.word := data29.words[24];
      w0low := planets.rows^[planet].coords6.low;
      planets.word := data29.words[24];
      city := planets.rows^[planet].place7.mid6
    end
    else city := place_index;
    cities.word := data29.words[25];
    xcoord := cities.rows^[city].coords5.low6;
    cities.word := data29.words[25];
    ycoord := cities.rows^[city].coords5.mid5;
    kind2 := 9;
    kind3 := 6;
    word4 := 6;
    w5low := 26
  end
end;
