{ Shared storage views recovered from the supplied SunDog assembly.
  Include in a Pascal type section. These are explicit views of known offsets,
  not claims about original type names or complete logical record boundaries. }
bounds4 = record
  upper_second: integer;
  lower_second: integer;
  upper_first: integer;
  lower_first: integer
end;

text15 = string[15];
text80 = string[80];
textaddr = record
  case integer of
    0: (word: integer);
    1: (text: ^text15)
end;
quadchars = packed array[0..3] of char;
clock4 = packed record
  minute: 0..63;
  spare1: 0..3;
  hour: 0..255;
  day: 0..16383;
  spare2: 0..3
end;

wordpair = record
  first: integer;
  second: integer
end;
nibbleword = packed array[0..3] of 0..15;
stock4 = packed record
  kind: 0..31;
  category: 0..7;
  origin: 0..255;
  word1: integer
end;
bits37view = packed record
  low9: 0..511;
  mid6: 0..63;
  high1: boolean
end;
word6 = array[0..5] of integer;
locationbits = packed record
  low4: 0..15;
  mid5: 0..31;
  spare7: 0..127
end;
table10row = record
  prefix8: array[0..7] of integer;
  nibbles8: packed array[0..7] of 0..15
end;
{ The four-bit selector addresses rows 1..15. This view describes accesses,
  not an allocation or proof that every selector/pointer is valid. }
table15 = array[1..15] of table10row;
tableaddr = record
  case integer of
    0: (word: integer);
    1: (rows: ^table15)
end;
{ Name-table strides are evidenced by game8:15. The record sizes include
  trailing non-text fields; these views do not allocate the pointed-to data. }
text11 = string[11];
name20 = record
  caption: text15;
  trailing: wordpair
end;
names20 = array[1..15] of name20;
names16 = array[1..31] of text15;
names12 = array[1..63] of text11;
nameaddr = record
  case integer of
    0: (word: integer);
    1: (systems: ^names20);
    2: (planets: ^names16);
    3: (cities: ^names12)
end;
low6view = packed record
  low6: 0..63;
  spare10: 0..1023
end;
low5view = packed record
  low5: 0..31;
  spare11: 0..2047
end;

{ These variants expose the same 16-bit address word as a pointer. They do not
  allocate a buffer or copy its contents. Pointer representation is checked
  with the UCSD reference compiler; this is not a portable host-memory API. }
bytebuffer = packed array[0..2047] of 0..255;
address16 = record
  case integer of
    0: (word: integer);
    1: (bytes: ^bytebuffer);
    2: (value: ^integer)
end;

{ The location copy is six words. Packed writes preserve every spare field. }
g19place = packed record
  w0low: 0..255;
  w0high: 0..255;
  system: 0..15;
  planet: 0..31;
  city: 0..63;
  spare1: boolean;
  kind2: 0..63;
  spare2: 0..3;
  xcoord: 0..255;
  kind3: 0..31;
  spare3: 0..7;
  ycoord: 0..255;
  word4: integer;
  w5low: 0..255;
  w5high: 0..255
end;
g19loc = record
  case integer of
    0: (words: word6);
    1: (fields: g19place)
end;

{ DATASEG 29 is allocated 760 bytes. All views start at its first data word.
  The overlays retain aliasing between word, aggregate, and packed accesses. }
data29_view = record
  case integer of
    0: (words: array[1..380] of integer);
    1: (before_bounds11: array[1..10] of integer;
        bounds11: bounds4);
    2: (before_flags82: array[1..81] of integer;
        flags82: packed array[0..127] of boolean);
    3: (bytes: packed array[0..759] of 0..255);
    4: (before_flags45: array[1..44] of integer;
        flags45: packed array[0..15] of boolean);
    5: (before_ptr372: array[1..371] of integer;
        addr372: address16;
        addr373: address16);
    6: (before_bounds3: array[1..2] of integer;
        bounds3: bounds4);
    7: (before_bounds7: array[1..6] of integer;
        bounds7: bounds4);
    8: (before_bounds375: array[1..374] of integer;
        bounds375: bounds4);
    9: (before_nibbles45: array[1..44] of integer;
        nibbles45: nibbleword);
    10: (before_bits37: array[1..36] of integer;
         bits37: bits37view);
    11: (before_clock42: array[1..41] of integer;
         clock42: clock4);
    12: (before_bounds327: array[1..326] of integer;
         bounds327: bounds4);
    13: (before_clock78: array[1..77] of integer;
         clock78: clock4;
         clock80: clock4);
    14: (before_stock234: array[1..233] of integer;
         stock234: array[1..2] of stock4;
         labels238: array[1..2] of text15);
    15: (before_bnd311: array[1..310] of integer;
         bnd311: bounds4;
         bnd315: bounds4;
         bnd319: bounds4;
         bnd323: bounds4);
    16: (before_rec36: array[1..35] of integer;
         rec36: word6);
    17: (before_rec66: array[1..65] of integer;
         rec66: word6;
         rec72: word6);
    18: (before_rec228: array[1..227] of integer;
         rec228: word6);
    19: (before_loc67: array[1..66] of integer;
         loc67: locationbits);
    20: (before_loc73: array[1..72] of integer;
         loc73: locationbits);
    21: (before_bnd303: array[1..302] of integer;
         bnd303: bounds4;
         bnd307: bounds4);
    22: (before_bnd343: array[1..342] of integer;
         bnd343: bounds4);
    23: (before_tbl23: array[1..22] of integer;
         tbl23: tableaddr);
    24: (before_names23: array[1..22] of integer;
         names23: nameaddr;
         names24: nameaddr;
         names25: nameaddr);
    25: (before_loc37: array[1..36] of integer;
         loc37: locationbits;
         bits38: low6view;
         bits39: low5view);
    26: (before_money46: array[1..45] of integer;
         money46: wordpair);
    27: (pad73: array[1..72] of integer;
         bits73: bits37view);
    28: (pad36: array[1..35] of integer;
         pos36: g19loc);
    29: (pad72: array[1..71] of integer;
         pos72: g19loc);
    30: (pad228: array[1..227] of integer;
         pos228: g19loc);
    31: (pad331: array[1..330] of integer;
         bnd331: bounds4;
         bnd335: bounds4;
         bnd339: bounds4);
    32: (pad66: array[1..65] of integer;
         pos66: g19loc);
    33: (pad35: array[1..34] of integer;
         text35: textaddr);
    34: (pad255: array[1..254] of integer;
         name255: text15);
    35: (pad33: array[1..32] of integer;
         addr33: address16;
         addr34: address16);
    36: (pad299: array[1..298] of integer;
         bnd299: bounds4);
    37: (pad21: array[1..20] of integer;
         seed21: wordpair);
    38: (pad64: array[1..63] of integer;
         seed64: wordpair);
    39: (pad56: array[1..55] of integer;
         transform56: wordpair)
end;
