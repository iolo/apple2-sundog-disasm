g21glyphs = packed array[0..15] of 0..255;
g21row = packed array[0..39] of 0..255;
g21map = array[0..23] of g21row;
g21addr = record
  case integer of
    0: (word: integer);
    1: (rows: ^g21map)
end;
{ The eight VAR parameter words precede114 local bytes, slots9..65. }
g21frame = record
  case integer of
    0: (words: array[9..65] of integer);
    1: (pad55: array[9..54] of integer;
        map_buffer: g21addr);
    2: (pad62: array[9..61] of integer;
        pointer_bounds: bounds4);
    3: (pad39: array[9..38] of integer;
        vehicle_glyphs: g21glyphs;
        vehicle_masks: g21glyphs);
    { Semantic aliases preserve every original slot and overlapping view. }
    4: (
        check_overlay_entry: integer; {9}
        parked_y_offset: integer; {10}
        parked_x_offset: integer; {11}
        parked_y_cell: integer; {12}
        parked_x_cell: integer; {13}
        ship_y_offset: integer; {14}
        ship_x_offset: integer; {15}
        ship_y_cell: integer; {16}
        ship_x_cell: integer; {17}
        cursor_y: integer; {18}
        cursor_x: integer); {19}
    5: (p5words: array[9..20] of integer;
        tile_height_pixels: integer; {21}
        scanline_groups: integer; {22}
        view_half_rows: integer; {23}
        random_scratch: integer; {24}
        player_y: integer; {25}
        player_x: integer; {26}
        last_y_step: integer; {27}
        last_x_step: integer; {28}
        collision_glyph: integer; {29}
        even_glyph: integer; {30}
        odd_glyph: integer; {31}
        disk_checksum: integer; {32}
        planet_view: integer; {33}
        teleport_ready: integer; {34}
        contract_city: integer; {35}
        movement_poll: integer; {36}
        use_heading_glyphs: integer; {37}
        was_moving: integer); {38}
    6: (p6words: array[9..56] of integer;
        saved_time_step: integer; {57}
        saved_tick_limit: integer; {58}
        fare_discount_factor: integer; {59}
        fare_factor: integer; {60}
        chase_threshold: integer) {61}
end;
