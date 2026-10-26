{ Three parameter words precede204 local bytes, slots4..105.
  Eight text15 captions occupy10..73; seven four-word bounds occupy74..101. }
g14frame = record
  case integer of
    0: (words: array[4..105] of integer);
    1: (before10: array[4..9] of integer;
        captions: array[0..7] of text15;
        status_meter: bounds4;
        component_bounds: bounds4;
        caption_bounds: bounds4;
        row_lamps: array[0..3] of bounds4);
    { Semantic aliases preserve every original slot and overlapping view. }
    2: (
        group_byte_base: integer; {4}
        hit_item: integer; {5}
        hit_code: integer; {6}
        cursor_y: integer; {7}
        cursor_x: integer; {8}
        selected_page: integer); {9}
    3: (before_semantic3: array[4..101] of integer;
        cancel_poll: integer; {102}
        cargo_mode: integer; {103}
        inventory_mode: integer; {104}
        page_changed: integer) {105}
end;
