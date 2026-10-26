{ game12 entry1 has94 local bytes, slots1..47. Keep the shared frame's
  evidenced aliases; these names do not imply a complete original type model. }
g12frame = record
  case integer of
    0: (words: array[1..47] of integer);
    1: (before34: array[1..33] of integer;
        cargo34: stock4);
    2: (before37: array[1..36] of integer;
        hull37: bounds4);
    3: (
        cursor_y: integer; {1}
        cursor_x: integer; {2}
        radar_countdown: integer; {3}
        menu_mode: integer; {4}
        radar_interval: integer; {5}
        display_level: integer; {6}
        menu_action: integer; {7}
        menu_item: integer; {8}
        menu_y_origin: integer; {9}
        menu_x_origin: integer); {10}
    4: (before_named4: array[1..11] of integer;
        exit_requested: integer); {12}
    5: (before_named5: array[1..14] of integer;
        weapon_base_range: integer; {15}
        target_glyph_base: integer; {16}
        view_y_origin: integer; {17}
        view_x_origin: integer; {18}
        target_y_offset: integer; {19}
        target_x_offset: integer; {20}
        right_y: integer; {21}
        right_x: integer; {22}
        left_y: integer; {23}
        left_x: integer; {24}
        cannon_beam_style: integer; {25}
        laser_beam_style: integer; {26}
        wreck_cargo_present: integer); {27}
    6: (before_named6: array[1..28] of integer;
        manual_mode: integer; {29}
        laser_selected: integer; {30}
        target_present: integer; {31}
        target_visible: integer; {32}
        radar_visible: integer); {33}
    7: (before_named7: array[1..35] of integer;
        saved_flight_mode: integer); {36}
    8: (before_named8: array[1..40] of integer;
        pointer_glyph: integer; {41}
        radar_glyph: integer; {42}
        background_address: integer; {43}
        back_y_offset: integer; {44}
        back_x_offset: integer) {45}
end;
g12scratch = record
  case integer of
    0: (word: integer);
    1: (row: ^g19row);
    2: (caption: ^text80)
end;
