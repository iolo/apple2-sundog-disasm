{ library_22 native procedure 7, entry $11C4.
  $11C4..$11CD removes return address and exactly one 16-bit argument;
  the low argument byte is retained at zero-page $02. No result is returned.
  Native implementation remains authoritative in src/pcode/library_22.s.
  This is an interface declaration, not an empty replacement implementation.
  Compiler wrappers must record that EXTERNAL does not bind segment 22 by itself. }
procedure proc22_7(mode: integer); external;

{ Native procedure 9, $1376: return address + one argument word popped.
  Uses the low byte; no Pascal result. In mode 2, $1470..$14BC sets DATASEG29
  word 1 to canonical 0/1. Other modes may draw and advance the position. }
procedure proc22_9(code: integer); external;

{ Native procedure 3, $0BF6: removes four reserved result bytes, updates
  external words 21..22 ($0028..$002B), and returns one nonnegative word.
  $0C1F..$0C27 pushes a high byte shifted right once and a low byte. }
function proc22_3: integer; external;

{ Native procedure 56, $112A: pops 20 bytes including the return address,
  hence nine argument words. No result; original native plotting body retained.
  Arguments correspond to caller 57 frame slots 12..5 and Boolean slot 18. }
procedure proc22_56(majorpos, majorstep, majorend, minorpos,
                    minorstep, error, axisinc, diaginc: integer;
                    steep: boolean); external;

{ Native procedure 22, $14FE: pops return address plus six argument words.
  $18/$1A hold secondpos/firstpos addresses; $1C/$1E hold second/first steps;
  $20/$22 hold code2/code1. $1583..$1594 updates the pointed-to coordinates.
  It also calls native 9 and changes external storage. No Pascal result.
  The native body, including byte-width coordinate updates, is authoritative. }
procedure proc22_22(code1, code2, firststep, secondstep: integer;
                    var firstpos, secondpos: integer); external;

{ Native procedure 15, $0E2E: pops its return address and one argument word.
  $0EA1..$0EAB selects work using its low byte. $0EAD..$0EB3 restores only
  the return address. Native screen-memory effects are not reimplemented. }
procedure proc22_15(mode: integer); external;

{ Native 2, $0C4A: consumes reserved result bytes and the selector's low byte;
  $0CB8..$0CC1 pushes the result low byte above the retained selector high byte.
  Callers here use selectors 0,1,4,5, hence get a canonical 0/1 word. The native
  hook and input-state effects mean even discarded calls must be retained. }
function proc22_2(selector: integer): integer; external;

{ Native 24, $0F26: discards the four reserved result bytes, leaving the VAR
  address word as its result. No dereference or copy of the pointed-to word. }
function proc22_24(var value: integer): integer; external;

{ Native 5, $0DAA: takes one address and writes four bytes through it at
  $0DF4/$0DF9/$0E18/$0E1D. The two words are contiguous; no result is pushed. }
procedure proc22_5(var coords: wordpair); external;

{ Native 30/31, $0FA8/$0F6C: two integer arguments, four reserved result bytes,
  one-word result. The low count byte controls the shift; count zero retains
  the input word on the stack. Original native shift behavior is authoritative. }
function proc22_30(value, count: integer): integer; external;
function proc22_31(value, count: integer): integer; external;
