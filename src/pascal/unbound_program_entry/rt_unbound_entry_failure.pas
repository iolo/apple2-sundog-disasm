{ system1:1 $0000..$0004, attributes$000E. No locals, four entry ABI
  parameter bytes, lexical0, RBP0. Core32/38/39 push two nil address words;
  expose those unused words so callers can name this recovered body directly.
  Host procedure compilation shifts lexical level and return convention. }
procedure rt_unbound_entry_failure(unused1, unused2: syswptr);
begin
  rt_system_failure(9)
end;
