{ game_19 procedure8, $037C..$03B5, attributes $03BE.
  Unlisted selectors leave the destination unchanged. Table strides are
  respectively6,8,10 words, shared with the established name-table views. }
procedure proc19_8(kind, index: integer; var caption: text15);
begin
  case kind of
    1: caption := data29.names25.cities^[index];
    2: caption := data29.names24.planets^[index];
    3: caption := data29.names23.systems^[index].caption
  end
end;
