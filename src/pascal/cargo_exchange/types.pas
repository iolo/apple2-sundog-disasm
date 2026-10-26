{ Seven words include30 three-bit entries plus padding compared/copied by
  the original. IXP5,3 leaves bit15 of every word outside the entries. }
g20levels = record
  case integer of
    0: (words: array[0..6] of integer);
    1: (bytes: packed array[0..13] of 0..255);
    2: (values: packed array[1..35] of 0..7)
end;
g20ware = array[1..4] of stock4;
g20wlist = array[0..59] of g20ware;
g20waddr = record
  case integer of
    0: (word: integer);
    1: (rows: ^g20wlist)
end;
g20names = array[0..31] of text15;
g20nbytes = packed array[0..511] of 0..255;
g20naddr = record
  case integer of
    0: (word: integer);
    1: (names: ^g20names);
    2: (bytes: ^g20nbytes)
end;
g20phase = packed array[0..8] of 0..31;
g20phases = array[0..8] of g20phase;
g20text = record
  case integer of
    0: (text: text15);
    1: (bytes: packed array[0..15] of 0..255)
end;
{ Parent slots2..165,328 bytes. Transfers beginning at22 and38 deliberately
  span adjacent fields, with original byte counts32 and28. }
g20frame = record
  case integer of
    0: (words: array[2..165] of integer);
    1: (before18: array[2..17] of integer;
        city_store_rows: g20waddr;
        cargo_names: g20naddr;
        phase_table: address16;
        market_buffer: address16;
        demand_levels: g20levels;
        supply_levels: g20levels;
        market_day: integer;
        word37: integer;
        demand_target: g20levels;
        supply_target: g20levels;
        warehouse_items: g20ware);
    2: (before160: array[2..159] of integer;
        empty_amount: wordpair;
        phase_bonus: wordpair;
        trading_cash: wordpair);
    3: (pad60: array[2..59] of integer;
        ticker_bytes: packed array[0..167] of 0..255;
        market_offers: array[0..7] of stock4);
    { Semantic aliases preserve every original slot and overlapping view. }
    4: (
        bonus_accumulator: integer); {2}
    5: (p5words: array[2..3] of integer;
        saved_time_step: integer; {4}
        ticker_y: integer; {5}
        ticker_x: integer; {6}
        ticker_head: integer); {7}
    6: (p6words: array[2..8] of integer;
        grade_price_scale: integer; {9}
        system_price_scale: integer; {10}
        saved_tick_limit: integer; {11}
        menu_bottom: integer; {12}
        menu_right: integer; {13}
        menu_left: integer; {14}
        button_y: integer; {15}
        contract_mode: integer; {16}
        pods_available: integer) {17}
end;
