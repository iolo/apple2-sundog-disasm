{ game_19 procedure8, $037C..$03B5, attributes $03BE.
  Unlisted selectors leave the destination unchanged. Table strides are
  respectively6,8,10 words, shared with the established name-table views. }
procedure lookup_place_caption(place_kind, place_index: integer; var caption: text15);
begin
  case place_kind of
    1: caption := data29.names25.cities^[place_index];
    2: caption := data29.names24.planets^[place_index];
    3: caption := data29.names23.systems^[place_index].caption
  end
end;
