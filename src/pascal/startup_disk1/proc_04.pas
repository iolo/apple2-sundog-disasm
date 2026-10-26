{ startup_disk1 procedure4, $00CE..$0173, attributes$0180.
  Nine local words. Slots2..8 remain initially uninitialized as in the source;
  map entry21:1 supplies them. Clear word347 and RELEASE on every iteration.
  Game18 receives raw integer addresses: ORD(@...) expresses the required
  LLA4/3/1 without calls or temporaries. The reference compiler recognizes
  this address extension but crashes lowering the pointer-to-integer cast;
  compilation of this expression remains unsupported by that compiler. }
procedure boot1_4;
var boot4: array[1..9] of integer;
(*$include src/pascal/startup_disk1/proc_05.pas*)
begin
  boot4[1] := 0;
  boot4[9] := 0;
  data29.flags82[116] := false;
  data29.flags82[117] := false;
  repeat
    data29.words[347] := 0;
    release(data29.addr33.bytes);
    case data29.nibbles45[2] of
      3, 4: proc21_1(boot4[8], boot4[7], boot4[6], boot4[5],
                      boot4[4], boot4[3], boot4[2], boot4[9]);
      5: if boot4[2] = 255 then proc17_1(boot4[4], boot4[3], boot4[1])
         else proc18_1(ord(@boot4[4]), ord(@boot4[3]), ord(@boot4[1]), boot4[2]);
      6: if boot4[2] <= 3 then proc19_1(boot4[2])
         else proc20_1(boot4[2]);
      7, 8, 10: boot1_5;
      9: proc16_1(boot4[4], boot4[3], boot4[1])
    end
  until (data29.nibbles45[2] <= 2) or (data29.nibbles45[2] >= 11)
end;
