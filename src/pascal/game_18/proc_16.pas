{ game_18 procedure 16, $0B78..$0CC3, attributes $0CCE.
  Parent slots 4/3 are addresses consumed here. The unrecovered parent keeps
  raw-word parameter declarations; address16 supplies explicit local views.
  The setup table is loaded at byte address $4000, with a 16-word stride. }
procedure proc18_16;
var
  tablebase: setupaddr;
  tableidx: integer;
  outbox: bounds4;
  argaddr: address16;
  firstarg, secondarg: integer;
(*$include src/pascal/game_18/proc_17.pas*)
begin
  argaddr.word := arg4;
  firstarg := argaddr.value^;
  argaddr.word := arg3;
  secondarg := argaddr.value^;
  proc22_51(firstarg, secondarg);
  tablebase.word := 16384;
  proc22_53(16384, 1, data29.words[27], true);
  data29.flags82[116] := false;
  if arg1 = 11 then tableidx := 1
  else
    { $0BA8..$0BBF: byte loads and MOD expose the low 6 and low 5 bits.
      Both byte values are unsigned, so MOD agrees with the packed masks. }
    tableidx := 4 * (arg1 - 7) +
                ((data29.bytes[74] mod 64) +
                 (data29.bytes[76] mod 32)) mod 4;
  with tablebase.table^[tableidx] do
  begin
    { $0BC1..$0C00: retain the table-entry pointer across drawing calls. }
    g18w145 := modes.high8;
    g18w146 := modes.next4;
    g18w144 := modes.low4;
    proc22_19(data29.bounds11, modes.high8);
    proc18_17(bounds[4], modes.next4, outbox);
    g18w131 := outbox.lower_first;
    g18a112[130] := outbox.upper_first;
    g18a112[129] := outbox.lower_second;
    g18a112[128] := outbox.upper_second;
    proc18_17(bounds[3], modes.next4, outbox);
    proc18_17(bounds[2], modes.low4, outbox);
    proc18_17(bounds[1], 0, g18b107);
    proc18_17(bounds[0], 0, outbox);
    g18a112[127] := outbox.lower_first;
    g18a112[126] := outbox.lower_second;
    g18a112[121] := outbox.upper_first;
    g18a112[120] := outbox.upper_second;
    g18a133[140] := ord(proc22_35(g18b107.lower_first -
                                 g18b107.upper_first) > 4);
    g18a112[115] := bytes11[0] - 128;
    g18a112[114] := bytes11[1] - 128;
    g18a112[113] := bytes11[2];
    if g18a112[113] < 3 then g18a112[113] := 3;
    g18a112[122] := bytes11[3];
    if g18a112[122] <= 0 then g18a112[122] := 128;
    g18w132 := proc22_40(3, g18a112[113]);
    g18a133[139] := ord(arg1 = 8);
    g18a133[136] := ord(arg1 = 11);
    proc22_19(data29.bounds11, 0)
  end
end;
