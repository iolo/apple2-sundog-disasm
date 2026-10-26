{ Raw address26 points at a15-character Pascal string. No allocation occurs. }
g15textp = record
  case integer of
    0: (word: integer);
    1: (text: ^text15)
end;
{ Original parent slots1..26,52 bytes, no parameters. }
g15frame = record
  case integer of
    0: (words: array[1..26] of integer);
    1: (before14: array[1..13] of integer;
        walk_bounds: bounds4;
        ship_signature: text15;
        overlay_text: g15textp);
    { Semantic aliases preserve every original slot and overlapping view. }
    2: (
        selected_action: integer; {1}
        cursor_y: integer; {2}
        cursor_x: integer; {3}
        previous_action: integer; {4}
        marker_y: integer; {5}
        marker_x: integer; {6}
        raw_entry_address: integer; {7}
        background_glyph: integer; {8}
        marker_glyph: integer; {9}
        signature_changed: integer; {10}
        saved_overlay_flag: integer; {11}
        walk_button_state: integer; {12}
        overlay_flag_index: integer) {13}
end;
