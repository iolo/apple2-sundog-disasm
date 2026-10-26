{ Utility program local frame:1044 bytes, slots3..524 after the implicit
  four-byte program parameter area. Declare u1: utilframe as the first program
  variable when binding the original layout. This is not DATASEG29 storage.
  Four save-slot records start at slot12, with a32-word stride. More views can
  be added as consumers establish their meaning; do not resize the frame. }
utilslot = record
  case integer of
    0: (words: array[0..31] of integer);
    1: (caption: text15);
    2: (before16: array[0..15] of integer; saved_clock: clock4);
    3: (before18: array[0..17] of integer; saved_location: g19loc);
    4: (before10: array[0..9] of integer;
        stored_attributes: packed array[0..9] of 0..255)
end;
{ Scope9 local words1..17. Children12/13/21 retain its reused counters and
  initially unknown word9; entry9 does not initialize that word. }
utilinit = record
  case integer of
    0: (words: array[1..17] of integer);
    { Semantic aliases preserve every original slot and overlapping view. }
    1: (
        inventory_buffer_address: integer; {1}
        save_block: integer); {2}
    2: (padding2: array[1..8] of integer;
        prior_planet_byte: integer; {9}
        loop_index: integer) {10}
end;
utilplanet = record
  case integer of
    0: (words: array[0..7] of integer);
    1: (bytes: packed array[0..15] of 0..255);
    2: (before7: array[0..6] of integer;
        flags7: packed record
          count: 0..7;
          firstcity: 0..63;
          spare: 0..63;
          marked: boolean
        end)
end;
utilcity = record
  before5: array[0..4] of integer;
  fields5: packed record
    low6: 0..63;
    middle5: 0..31;
    spare5: 0..31
  end
end;
utilwork = record
  case integer of
    0: (word: integer);
    1: (system: ^table10row);
    2: (amount: ^wordpair);
    3: (planet: ^utilplanet);
    4: (city: ^utilcity)
end;
u14seven = array[0..6] of integer;
u14templ = record
  first: u14seven;
  second: u14seven
end;
u14row = record
  first: u14seven;
  second: u14seven;
  flag14: integer;
  bytes15: packed record
    low: 0..255;
    high: 0..255
  end
end;
u14rows = array[0..63] of u14row;
u14temps = array[1..18] of u14templ;
u14addr = record
  case integer of
    0: (word: integer);
    1: (bytes: ^bytebuffer);
    2: (rows: ^u14rows);
    3: (table: ^u14temps);
    4: (row: ^u14row);
    5: (template: ^u14templ)
end;
{ UCSD packs three five-bit values per word, leaving one spare bit.
  Nine values occupy three words;15 writes eight, preserving all spare bits. }
u14codes = packed array[0..8] of 0..31;
u14frame = record
  case integer of
    0: (words: array[1..50] of integer);
    1: (before9: array[1..8] of integer;
        template_address: u14addr;
        city_output_buffer: u14addr);
    2: (before18: array[1..17] of integer;
        packed_seed_rows: array[0..8] of u14codes);
    3: (before46: array[1..45] of integer;
        work46: u14addr;
        planet_record: utilwork;
        seed_template: u14addr;
        city_count: integer;
        output_city_record: u14addr);
    { Semantic aliases preserve every original slot and overlapping view. }
    4: (
        chosen_template: integer; {1}
        rotation_index: integer; {2}
        code_row: integer; {3}
        city_index: integer; {4}
        write_block: integer); {5}
    5: (padding5: array[1..6] of integer;
        output_row: integer; {7}
        planet_index: integer) {8}
end;
u16rows = array[1..64, 1..4] of stock4;
u16addr = record
  case integer of
    0: (word: integer);
    1: (bytes: ^bytebuffer);
    2: (rows: ^u16rows)
end;
utilptr = ^utilslot;
utilframe = record
  case integer of
    0: (words: array[3..524] of integer);
    1: (before12: array[3..11] of integer;
        slots: array[0..3] of utilslot);
    2: (before269: array[3..268] of integer;
        place269: g19loc; stamp275: clock4);
    3: (before278: array[3..277] of integer; state278: nibbleword);
    4: (bytes: packed array[0..1043] of 0..255);
    { Semantic aliases preserve every original slot and overlapping view. }
    5: (padding5: array[3..3] of integer;
        cursor_y: integer; {4}
        cursor_x: integer; {5}
        picked_slot: integer; {6}
        menu_bottom: integer; {7}
        button_y: integer; {8}
        menu_right: integer; {9}
        menu_left: integer; {10}
        menu_action: integer); {11}
    6: (padding6: array[3..267] of integer;
        exit_word: integer) {268}
end;
utiltext = record
  case integer of
    0: (word: integer);
    1: (caption: ^text80)
end;
utilsector = record
  case integer of
    0: (words: array[0..255] of integer);
    1: (bytes: packed array[0..511] of 0..255)
end;
{ Name-entry scope31: VAR parameter1, locals2..171 (340 bytes).
  Keyboard entries are five words; three rows of ten start at slot2. }
utilkey = record
  bounds: bounds4;
  code: packed record
    low: 0..255;
    high: 0..255
  end
end;
utilkptr = ^utilkey;
{ Attribute editor22:35 local words, five four-word bars at9..28 and
  points bounds29..32. Poll results33/34 retain their full input words. }
u22frame = record
  case integer of
    0: (words: array[1..35] of integer);
    1: (before9: array[1..8] of integer;
        bars: array[0..4] of bounds4;
        points: bounds4);
    { Semantic aliases preserve every original slot and overlapping view. }
    2: (padding2: array[1..2] of integer;
        cursor_y: integer; {3}
        cursor_x: integer; {4}
        first_bar_y: integer; {5}
        caption_x: integer; {6}
        selected_stat: integer; {7}
        unspent_points: integer); {8}
    3: (padding3: array[1..32] of integer;
        edit_poll: integer; {33}
        done_poll: integer; {34}
        confirmed: integer) {35}
end;
{ Editor29 has a VAR parameter in1, locals2..17. Several saved/unused words
  remain explicit, including the initially unspecified direction in2. }
u29frame = record
  case integer of
    0: (words: array[2..17] of integer);
    1: (before17: array[2..16] of integer; bar: ^bounds4);
    { Semantic aliases preserve every original slot and overlapping view. }
    2: (
        step: integer; {2}
        cursor_y: integer; {3}
        cursor_x: integer; {4}
        saved_points: integer; {5}
        candidate_points: integer; {6}
        rejected_value: integer; {7}
        edited_value: integer; {8}
        next_stat: integer; {9}
        minimum_value: integer; {10}
        minus_y: integer; {11}
        minus_x: integer; {12}
        plus_y: integer; {13}
        plus_x: integer; {14}
        discarded_poll: integer; {15}
        selection_found: integer) {16}
end;
utilname = record
  case integer of
    0: (words: array[2..171] of integer);
    1: (keys: array[0..2, 0..9] of utilkey;
        name_pointer_bounds: bounds4;
        previous_text_bounds: bounds4;
        unused160: integer;
        entered_name: text15;
        name_confirmed: boolean;
        uppercase_next: integer;
        typed_length: integer);
    2: (before161: array[2..160] of integer;
        namebytes: packed array[0..15] of 0..255)
end;
