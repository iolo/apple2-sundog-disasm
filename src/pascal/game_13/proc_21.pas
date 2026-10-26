{ game_13 procedure21, $0D88..$0DF7, attributes $0E02; nested in19.
  Code0 and codes>3 are warp points; negative values retain the planet path.
  Row pointer3 is reused for the planet and retained across display calls. }
procedure proc13_21(codevalue: integer);
var
  planet: integer; {2}
  row: g13rowptr;  {3}
(*$include src/pascal/game_13/proc_22.pas*)
begin
  if (codevalue = 0) or (codevalue > 3) then
  begin
    proc22_48('Warp point\');
    proc13_22(codevalue, 100)
  end
  else
  begin
    row.word := data29.words[23] + 20 * (chosen.fields.system - 1);
    planet := row.sysrow^.bits5.mid5 + codevalue - 1;
    row.word := data29.words[24] + 16 * (planet - 1);
    proc22_48('Planet:  ');
    proc22_48(row.caption^);
    proc22_45;
    proc13_22(row.planetrow^.coords6.low, 2 * row.planetrow^.coords6.high + 14)
  end
end;
