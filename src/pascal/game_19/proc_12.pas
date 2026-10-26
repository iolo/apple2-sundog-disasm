{ game_19 procedure12, $0790..$09A9, attributes $09BA.
  Retain parent slots8..28 consumed by nested13/14. Extra input snapshots
  follow those slots and preserve both calls even when the timeout expires. }
procedure proc19_12(kind, index: integer; area: bounds4);
var
  placename: text15; {8..15}
  arrival: g19loc;   {16..21}
  elapsed: integer; {22}
  distance: integer; {23}
  work: integer;    {24}
  cost: wordpair;   {25..26}
  eta: clock4;      {27..28}
  timedout: boolean;
  input0: integer;
  input1: integer;
(*$include src/pascal/game_19/proc_13.pas*)
(*$include src/pascal/game_19/proc_14.pas*)
begin
  proc22_19(area, 8);
  proc22_19(data29.bounds11, 0);
  proc19_10(kind, index, arrival);
  proc22_46(0, 5);
  proc22_48('|||||Destination');
  g19.amount2 := g19.amount10;
  work := 1;
  proc19_13('City:      ', arrival.fields.city);
  proc19_13('Planet:    ', arrival.fields.planet);
  proc19_13('System:    ', arrival.fields.system);
  case kind of
    1: proc19_14(kind, arrival.fields.city, data29.bits37.mid6);
    2: proc19_14(kind, arrival.fields.planet, data29.loc37.mid5);
    3: proc19_14(kind, arrival.fields.system, data29.loc37.low4)
  end;
  proc22_46(0, 13);
  proc28_5('Cost:      ', cost);
  proc22_46(20, 13);
  proc22_48('Cr');
  if proc28_6(cost, g19.amount2) then
  begin
    proc22_46(0, 15);
    proc22_48('||Insufficient funds');
    work := 1000;
    repeat
      work := work - 1;
      timedout := work = 0;
      input0 := proc22_2(0);
      input1 := proc22_2(1)
    until timedout or odd(input0) or odd(input1);
    exit(proc19_12)
  end;
  proc22_46(0, 15);
  proc22_48('E.T.A.:      ');
  proc22_28(eta);
  proc25_2;
  proc25_3(1, 'TRANSPORT', g19.words[23], g19.words[22],
            g19.words[20] - 10, g19.words[20]);
  work := 0;
  g19.words[29] := 0;
  proc19_3(work, g19.words[24], data29.words[297], data29.bounds11, g19.words[29]);
  if work <> 1 then exit(proc19_12);
  proc28_3(cost, g19.amount10);
  proc19_6;
  proc22_46(0, 15);
  proc22_14(data29.words[14], data29.words[13], data29.words[18] + 1, data29.words[11]);
  proc22_7(8);
  proc22_19(data29.bounds11, 0);
  proc22_46(0, 17);
  proc22_48('Time:        ');
  proc22_46(13, 17);
  repeat
    proc22_26(data29.clock42, 5);
    proc22_12(data29.words[19], data29.words[18]);
    proc22_28(data29.clock42)
  until proc22_27(eta);
  g19.words[28] := 1;
  data29.flags82[28] := true;
  data29.flags82[116] := false;
  data29.flags82[117] := false;
  data29.rec36 := arrival.words
end;
