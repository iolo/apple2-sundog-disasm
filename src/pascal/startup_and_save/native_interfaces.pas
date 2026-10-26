{ Raw22:25 target$0F40 after startup7:5 loads relative block153 (physical156).
  src/native/raw_buffer_transform.s $0F40..$0F9C consumes return2 and one
  pointer2, restores only return, then reads four parameter bytes: destination
  page, block count, additive value, increment. The low count doubles modulo256;
  zero means256 pages. Each byte is added modulo256, and the additive value
  advances modulo256. Address page wraps; parameter bytes are captured first.
  It then writes SHIP at$1801..$1804 and returns no Pascal result. Clobbers
  ZP$00..$08, A/Y/flags; X is untouched. No replacement native body is supplied.
  This is a target contract for the already-reviewed22:25 trampoline. }
procedure call_state_transform(var params: wordpair; target: integer); external;
