{ Local declaration section of game_18 procedure 1, for its recovered children.
  The four parameter words occupy frame slots 1..4. These declarations occupy
  local slots 5..153 (298 bytes). Unknown words are retained as storage, not
  initialized or assigned invented meanings. One declaration per layout group
  also avoids this reference compiler's reversed grouped-record-field layout. }
room_actors: array[0..8] of entry10;             { Slots 5..94, stride 10 words. }
counter_slots: array[0..2] of nibbles4;            { Slots 95..97. }
station_flags: packed array[0..15] of boolean;    { Slot 98. }
service_area_bounds: bounds4;                          { Slots 99..102. }
station_strip_bounds: bounds4;                         { Slots 103..106. }
room_walk_bounds: bounds4;                         { Slots 107..110. }
active_station: integer;
room_layout_state: array[112..130] of integer;
room_left: integer;
actor_count: integer;
room_controls: array[133..143] of integer;
off_station_pattern: integer;
room_background_pattern: integer;
on_station_pattern: integer;
selected_actor: integer;
room_save_state: array[148..153] of integer;
