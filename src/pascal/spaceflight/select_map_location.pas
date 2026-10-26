{ game_13 procedure12, $12E6..$1437, attributes $1448; nested in1.
  Parameters5..1: kind, VAR destloc/result, mode2/mode1 low-bit flags.
  The six local words are shared by the rendering/selection descendants.
  Preserve both self EXIT paths, the repeat condition, and flag0's temporary
  setting around the system-map redraw. Unknown kinds retain the result. }
procedure select_map_location(view_kind: integer; var destination: g19loc;
                    var selection_result: integer; set_destination, inspect_only: integer);
var mapstate: array[6..11] of integer;
(*$include src/pascal/spaceflight/render_map_view.pas*)
(*$include src/pascal/spaceflight/pick_map_destination.pas*)
begin
  selection_result := 0;
  mapstate[11] := ord(data29.flags82[21]);
  if not data29.flags82[39] then render_map_view(view_kind, destination)
  else data29.flags82[39] := false;
  if odd(set_destination) and odd(inspect_only) then exit(select_map_location);
  repeat
    pick_map_destination(view_kind, destination, selection_result, -1 - inspect_only)
  until odd(set_destination) or not (odd(inspect_only) and odd(selection_result)) or
        odd(data29.words[347]);
  if not odd(set_destination) then exit(select_map_location);
  use_linear_row_tables(false);
  set_line_mode(0);
  apply_bounds(data29.bnd339, 8);
  set_text_window(data29.words[342], data29.words[341],
              data29.words[340], data29.words[339]);
  if not odd(selection_result) then write_wrapped_text('No destination selected\')
  else
  begin
    case view_kind of
      1: begin
           selection_result := ord((destination.fields.system <> data29.loc73.low4) or
                         data29.flags82[18]);
           if odd(selection_result) then
           begin
             data29.warp_destination_system := destination.fields.system;
             data29.flags82[0] := true;
             render_map_view(view_kind, data29.pos72);
             data29.flags82[0] := false
           end
         end;
      2: if destination.fields.planet > 0 then
           selection_result := ord(destination.fields.planet <> data29.loc73.mid5)
         else selection_result := ord((destination.fields.w0high <> data29.pos72.fields.w0high) or
                            (destination.fields.w0low <> data29.pos72.fields.w0low));
      3: selection_result := ord(destination.fields.city <> data29.pos72.fields.city)
    end;
    if not odd(selection_result) then write_wrapped_text('Current location selected\')
  end
end;
