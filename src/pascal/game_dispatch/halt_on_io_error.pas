{ startup_disk1 procedure2, $0000..$0012, attributes$001E.
  Display IORESULT then spin forever. Ordinary flow cannot reach RNP.
  Runtime error dispatch must bind this body to original procedure2. Its
  original exit attribute targets RNP at$0012; the reference compiler instead
  points its exit attribute at the spin, so runtime EXIT binding is separate. }
(*$I-*)
procedure halt_on_io_error;
begin
  clear_hires_page1;
  move_pen(0, 10);
  draw_integer(ioresult, 3, false);
  repeat until false
end;
(*$I+*)
