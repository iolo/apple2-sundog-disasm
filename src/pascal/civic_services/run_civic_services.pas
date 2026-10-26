{ game_19 procedure1, $13AC..$140C, attributes $1418.
  Segment loads precede setup; normal cleanup precedes releases28/25.
  The original exit attribute targets the release epilogue at $13FB. }
procedure run_civic_services(service_kind: integer);
var
(*$include src/pascal/civic_services/locals.pas*)
(*$include src/pascal/civic_services/open_service_title.pas*)
(*$include src/pascal/civic_services/poll_service_menu.pas*)
(*$include src/pascal/civic_services/add_service_button_row.pas*)
(*$include src/pascal/civic_services/pool_service_funds.pas*)
(*$include src/pascal/civic_services/settle_service_funds.pas*)
(*$include src/pascal/civic_services/lookup_place_caption.pas*)
(*$include src/pascal/civic_services/setup_civic_window.pas*)
(*$include src/pascal/civic_services/pick_transfer_amount.pas*)
(*$include src/pascal/civic_services/choose_service_destination.pas*)
(*$include src/pascal/civic_services/compose_transport_location.pas*)
(*$include src/pascal/civic_services/service_route_distance.pas*)
(*$include src/pascal/civic_services/book_passenger_transport.pas*)
(*$include src/pascal/civic_services/run_transstation.pas*)
(*$include src/pascal/civic_services/send_bank_transfer.pas*)
(*$include src/pascal/civic_services/run_uniteller.pas*)
(*$include src/pascal/civic_services/buy_service_units.pas*)
(*$include src/pascal/civic_services/refuel_at_depot.pas*)
(*$include src/pascal/civic_services/repair_at_depot.pas*)
(*$include src/pascal/civic_services/buy_auxiliary_fuel.pas*)
(*$include src/pascal/civic_services/run_ship_depot.pas*)
begin
  rtldseg(25);
  rtldseg(28);
  setup_civic_window;
  case service_kind of
    1: run_transstation;
    2: run_uniteller;
    3: run_ship_depot
  end;
  if not odd(data29.words[347]) then
  begin
    data29.nibbles45[2] := data29.nibbles45[1];
    data29.nibbles45[1] := 6;
    data29.nibbles45[0] := 11
  end;
  data29.words[353] := g19.saved_tick_limit;
  data29.words[351] := g19.saved_time_step;
  pop_text_window;
  { Runtime binding must also route nonlocal EXIT to these releases. }
  rtrlseg(28);
  rtrlseg(25)
end;
