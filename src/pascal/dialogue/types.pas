{ A31-character Pascal string and its raw bytes, including the length byte.
  Procedure13 uses raw writes; compiler range checks are disabled as elsewhere. }
g16str = string[31];
g16text = record
  case integer of
    0: (text: g16str);
    1: (bytes: packed array[0..31] of 0..255);
    2: (short: text15)
end;
g16line = record
  case integer of
    0: (text: text80);
    1: (bytes: packed array[0..81] of 0..255)
end;
{ Game16 parent has three value words and278 local bytes, slots4..142.
  Views expose only the spans used by recovered children. The two text31
  buffers occupy16 words each; short108 shares the formatter's text15 prefix. }
g16frame = record
  case integer of
    0: (words: array[4..142] of integer);
    1: (before56: array[4..55] of integer;
        saved_clock_bounds: bounds4;
        dialog_bounds: bounds4;
        saved_text_bounds: bounds4;
        trade_bounds: bounds4;
        dialog_buttons: array[0..3] of bounds4);
    2: (pad100: array[4..99] of integer;
        offer_amount: wordpair;
        zero_amount: wordpair;
        cash_amount: wordpair;
        item_price: wordpair;
        price_text: string[31];
        item_caption: string[31];
        script_bytes: address16;
        phrase_bytes: address16);
    3: (pad108: array[4..107] of integer;
        price_prefix: text15);
    { Semantic aliases preserve every original slot and overlapping view. }
    4: (
        price_denominator: integer; {4}
        price_numerator: integer; {5}
        item11_weight: integer; {6}
        item12_13_weight: integer; {7}
        phrase_disk_block: integer; {8}
        script_disk_base: integer; {9}
        hit_item: integer; {10}
        hit_code: integer; {11}
        cursor_y: integer; {12}
        cursor_x: integer; {13}
        cached_choice: integer; {14}
        reuse_choice: integer); {15}
    5: (before_semantic5: array[4..16] of integer;
        amount_controls: integer; {17}
        selling_mode: integer; {18}
        trade_active: integer); {19}
    6: (before_semantic6: array[4..20] of integer;
        redirect_requested: integer; {21}
        buttons_enabled: integer; {22}
        button_hit: integer; {23}
        exit_requested: integer; {24}
        release0_poll: integer; {25}
        phrase_insert_index: integer; {26}
        last_trade_code: integer; {27}
        first_trade_code: integer); {28}
    7: (before_semantic7: array[4..29] of integer;
        price_scale: integer); {30}
    8: (before_semantic8: array[4..32] of integer;
        response_level: integer); {33}
    9: (before_semantic9: array[4..34] of integer;
        selected_caption: integer; {35}
        price_direction: integer); {36}
    10: (before_semantic10: array[4..37] of integer;
        stream_cursor: integer; {38}
        script_bank: integer; {39}
        context_amount: integer; {40}
        trade_item_code: integer; {41}
        saved_tick_limit: integer; {42}
        dialog_timeout: integer; {43}
        last_action: integer; {44}
        saved_time_step: integer; {45}
        first_icon_code: integer); {46}
    11: (before_semantic11: array[4..52] of integer;
        alt0_action: integer; {53}
        alt1_action: integer; {54}
        alt2_action: integer); {55}
    12: (before_semantic12: array[4..89] of integer;
        choice0_label: integer; {90}
        choice1_label: integer; {91}
        choice2_label: integer); {92}
    13: (before_semantic13: array[4..94] of integer;
        choice0_action: integer; {95}
        choice1_action: integer; {96}
        choice2_action: integer; {97}
        secondary_action: integer; {98}
        timeout_action: integer); {99}
    14: (before_semantic14: array[4..141] of integer;
        release1_poll: integer) {142}
end;
{20-byte system rows. These fields overlap names and amounts in other views.}
g16bits = packed record
  spare7: 0..127;
  flag7: boolean;
  spare8: 0..255
end;
g16row = record
  case integer of
    0: (words: array[0..9] of integer);
    1: (pad5: array[0..4] of integer; bits5: g16bits);
    2: (pad6: array[0..5] of integer; bank_balance: wordpair);
    3: (pad8: array[0..7] of integer; nibbles8: packed array[0..7] of 0..15)
end;
g16rows = array[1..15] of g16row;
g16addr = record
  case integer of
    0: (word: integer);
    1: (rows: ^g16rows)
end;
