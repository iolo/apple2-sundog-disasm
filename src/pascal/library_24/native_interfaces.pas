{ Native library24:4, entry $0F5E, attributes $100E.
  Pops ten bytes: return, second-result address, first-result address,
  second input, first input. Writes two bytes through each output pointer,
  first at $0F73/$0F7A, then second at $0F83/$0F8A; restores only return.
  The native lookup/arithmetic implementation remains authoritative. }
procedure proc24_4(first, second: integer;
                   var outfirst, outsecond: integer); external;
