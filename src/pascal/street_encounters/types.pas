{ game17 parent frame views, derived from IXA5, MOV5 and packed accesses.
  Entry fields occupy words0..4; active is bit8 of word4. }
g17entry = packed record
  second: integer;
  first: integer;
  code: 0..255;
  draw: 0..255;
  radius: 0..255;
  life: 0..255;
  delay: 0..255;
  active: boolean;
  spare: 0..127
end;
g17trail = record
  word0: integer;
  word1: integer;
  second: integer;
  first: integer
end;
g17frame = record
  case integer of
    0: (words: array[4..101] of integer);
    { Initialization clears entries0..6 (70 bytes). This is an access view,
      not proof that every restored count or caller-supplied index is valid. }
    1: (items: array[0..6] of g17entry);
    2: (before43: array[4..42] of integer;
        resume_bounds: bounds4);
    3: (before47: array[4..46] of integer;
        trail: array[0..6] of g17trail);
    4: (before100: array[4..99] of integer;
        resume_image: address16);
    { Semantic aliases preserve every original slot and overlapping view. }
    5: (p5words: array[4..38] of integer;
        victory_pending: integer; {39}
        spread_weapon_active: integer; {40}
        personal_shield_active: integer; {41}
        exit_requested: integer); {42}
    6: (p6words: array[4..74] of integer;
        spread_shots_left: integer; {75}
        shield_hits_left: integer; {76}
        shield_inventory_index: integer; {77}
        player_status: integer; {78}
        saved_y: integer; {79}
        saved_x: integer; {80}
        saved_clock_step: integer); {81}
    7: (p7words: array[4..83] of integer;
        arena_bottom: integer; {84}
        arena_top: integer; {85}
        arena_right: integer; {86}
        arena_left: integer); {87}
    8: (p8words: array[4..88] of integer;
        oldest_trail_index: integer; {89}
        current_trail_index: integer); {90}
    9: (p9words: array[4..91] of integer;
        enemy_y_step: integer; {92}
        enemy_x_step: integer; {93}
        fighter_count: integer; {94}
        trail_distance: integer); {95}
    10: (p10words: array[4..96] of integer;
        cursor_y: integer; {97}
        cursor_x: integer; {98}
        save_anchor: integer) {99}
end;
