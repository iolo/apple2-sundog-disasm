{ system1:1 $0000..$0004, attributes$000E. No locals, four entry ABI
  parameter bytes, lexical0, RBP0. Core32/38/39 push two nil address words;
  expose those unused words so callers can name this recovered body directly.
  Host procedure compilation shifts lexical level and return convention. }
procedure sys1_1(arg1, arg2: syswptr);
begin
  sys0_2(9)
end;
