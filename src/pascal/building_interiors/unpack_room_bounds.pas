{ game_18 procedure 17, $0B2C..$0B6B, attributes $0B76, lexical level 3.
  Nested in procedure 16. The incoming two-word value is copied to slots 4..5
  before destination writes, including when the source aliases destination. }
procedure unpack_room_bounds(boxbytes: packedbounds; mode: integer;
                    var bounds: bounds4);
begin
  assign_bounds(bounds,
            (data29.words[14] - 2) + boxbytes.first.high,
            (data29.words[14] - 2) + boxbytes.first.low,
            (data29.words[12] - 2) + boxbytes.second.high,
            (data29.words[12] - 2) + boxbytes.second.low);
  if mode <> 0 then apply_bounds(bounds, mode)
end;
