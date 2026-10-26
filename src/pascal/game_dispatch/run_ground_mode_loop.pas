{ startup_disk1 procedure4, $00CE..$0173, attributes$0180.
  Nine local words. Slots2..8 remain initially uninitialized as in the source;
  map entry21:1 supplies them. Clear word347 and RELEASE on every iteration.
  Game18 receives raw integer addresses: ORD(@...) expresses the required
  LLA4/3/1 without calls or temporaries. The reference compiler recognizes
  this address extension but crashes lowering the pointer-to-integer cast;
  compilation of this expression remains unsupported by that compiler. }
procedure run_ground_mode_loop;
var boot4: array[1..9] of integer;
(*$include src/pascal/game_dispatch/open_panel_mode.pas*)
begin
  boot4[1] := 0;
  boot4[9] := 0;
  data29.flags82[116] := false;
  data29.flags82[117] := false;
  repeat
    data29.words[347] := 0;
    release(data29.addr33.bytes);
    case data29.nibbles45[2] of
      3, 4: run_surface_maps(boot4[8], boot4[7], boot4[6], boot4[5],
                      boot4[4], boot4[3], boot4[2], boot4[9]);
      5: if boot4[2] = 255 then run_street_encounter(boot4[4], boot4[3], boot4[1])
         else run_building_interior(ord(@boot4[4]), ord(@boot4[3]), ord(@boot4[1]), boot4[2]);
      6: if boot4[2] <= 3 then run_civic_services(boot4[2])
         else run_cargo_exchange(boot4[2]);
      7, 8, 10: open_panel_mode;
      9: run_dialogue_session(boot4[4], boot4[3], boot4[1])
    end
  until (data29.nibbles45[2] <= 2) or (data29.nibbles45[2] >= 11)
end;
