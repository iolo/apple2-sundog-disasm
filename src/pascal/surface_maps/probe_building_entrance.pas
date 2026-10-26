{ game_21 procedure19, $09EA..$0ADA, attributes $0AE8.
  Nested20 uses coordinates at parent slots5/4. Raw char tables retain their
  one-based offsets. Cases14/15 make both calls, with a fresh flag read. }
procedure probe_building_entrance(var changed: integer);
var
  entrance_tile: integer;         {2}
  spare3: integer;
  local_y: integer;         {4}
  local_x: integer;         {5}
  y_entrances: string[8];       {6..10}
  x_entrances: string[8];       {11..15}
(*$include src/pascal/surface_maps/apply_entrance_mode.pas*)
begin
  local_x := (g21.player_x - 3) mod 28;
  local_y := (g21.player_y + 3) mod g21.tile_height_pixels;
  entrance_tile := tile_or_action mod 16;
  x_entrances := 'ABAA';
  y_entrances := 'OPOU';
  data29.nibbles45[1] := data29.nibbles45[2];
  case entrance_tile of
    7: begin
         apply_entrance_mode(data29.flags45[13], 14, 30, 3, 1);
         g21.teleport_ready := ord(tile_or_action = 1)
       end;
    8, 9, 10, 11:
       apply_entrance_mode(data29.flags45[13], ord(x_entrances[entrance_tile - 7]) - 64,
                   ord(y_entrances[entrance_tile - 7]) - 64, 5, entrance_tile);
    12: apply_entrance_mode(data29.flags45[13], 6, 28, 6, 1);
    13: apply_entrance_mode(data29.flags45[13], 1, 18, 6, 2);
    14: begin
          apply_entrance_mode(data29.flags45[13], 1, 15, 6, 3);
          apply_entrance_mode(not data29.flags45[13], 2, 22, 6, 3)
        end;
    15: begin
          apply_entrance_mode(not data29.flags45[13], 14, 21, 6, 4);
          apply_entrance_mode(data29.flags45[13], 2, 15, 6, 5)
        end
  end;
  changed := ord(data29.nibbles45[1] <> data29.nibbles45[2])
end;
