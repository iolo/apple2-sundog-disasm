{ game_13 procedure3, $06AA..$06B2, attributes $06BC.
  Complete systems-display scope,42 local bytes. Polling child10 self-EXITs;
  cleanup11 still runs on its return. }
procedure run_system_status;
var
  g13s: g13status;
(*$include src/pascal/spaceflight/blank_text_row.pas*)
(*$include src/pascal/spaceflight/toggle_orbital_marker.pas*)
(*$include src/pascal/spaceflight/setup_status_window.pas*)
(*$include src/pascal/spaceflight/draw_system_bars.pas*)
(*$include src/pascal/spaceflight/write_location_label.pas*)
(*$include src/pascal/spaceflight/paint_status_contents.pas*)
(*$include src/pascal/spaceflight/poll_system_status.pas*)
(*$include src/pascal/spaceflight/close_status_window.pas*)
begin
  setup_status_window;
  paint_status_contents;
  poll_system_status;
  close_status_window
end;
