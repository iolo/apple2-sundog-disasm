{ game_20 procedure5, $026C..$0435, attributes $0440.
  Preserve post-random packed reads and the seven-word padding comparisons.
  The phase bonus occurs before the later cash snapshot, as in the listing. }
procedure proc20_5;
var
  template: integer;
  index: integer;
  growth: integer; {slot3, first city-1, later elapsed whole weeks}
  randomv: integer;
  systems: g19addr;
(*$include src/pascal/game_20/proc_06.pas*)
begin
  g20.words[16] := ord(data29.bits37.mid6 = 60);
  proc22_23(5120, g20.ptr18.word);
  proc22_53(5120, 2, data29.words[30] + 3, true);
  proc22_23(22528, g20.names19.word);
  if g20.names19.names^[31] <> 'cryogens' then
    proc22_53(22528, 1, data29.words[30] + 2, true);
  g20.addr20.word := 22528 + 512;
  growth := data29.bits37.mid6 - 1;
  template := (data29.loc37.mid5 - 1 + data29.bytes[543]) mod 18;
  g20.ware52 := g20.ptr18.rows^[growth];
  g20.addr21.word := 22528 + 1024;
  proc20_3(data29.words[30] + 5 + growth div 16, 32, growth mod 16, 1);
  proc20_3(data29.words[30], 28, template, 4);
  if g20.day36 < 0 then
  begin
    if odd(g20.words[16]) then
    begin
      g20.stock29 := g20.stock45;
      fillchar(g20.stock22, 14, 0)
    end
    else
    begin
      index := 1;
      while index <= 30 do
      begin
        randomv := proc22_3;
        g20.stock29.values[index] := randomv mod (g20.stock29.values[index] + 1);
        randomv := proc22_3;
        g20.stock22.values[index] := randomv mod (g20.stock22.values[index] + 1);
        index := index + 1
      end
    end;
    g20.day36 := data29.clock42.day
  end
  else if not odd(g20.words[16]) then
  begin
    growth := (data29.clock42.day - g20.day36) div 7;
    if growth > 0 then
    begin
      if g20.stock22 <> g20.stock38 then proc20_6(g20.stock38, g20.stock22);
      if g20.stock29 <> g20.stock45 then proc20_6(g20.stock45, g20.stock29);
      g20.day36 := data29.clock42.day
    end
  end;
  if odd(g20.words[16]) then
  begin
    proc20_4;
    moveleft(data29.bytes[546], g20.words[2], 2)
  end;
  g20.cash164 := data29.money46;
  systems.word := data29.words[23];
  with systems.rows^[data29.loc37.low4] do
  begin
    g20.words[8] := nibbles8[3];
    g20.words[10] := nibbles8[4];
    g20.words[9] := nibbles8[5];
    if proc28_6(amount6, g20.zero160) then
    begin
      proc28_2(amount6, g20.cash164);
      amount6 := g20.zero160
    end
  end
end;
