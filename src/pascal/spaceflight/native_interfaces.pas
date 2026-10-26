{ Two loaded targets of library22:25's raw-call trampoline. Both consume one
  VAR address after the trampoline removes target; neither returns a Pascal
  result. Bind to the currently loaded native overlay, not to a stub.

  Warp: src/native/warp_animation.s $1800..$1836 consumes the pointer and
  reads FIVE bytes: sound bit0, delay byte, two random seed bytes, failure bit0.
  Its byte4 lies beyond procedure27's declared packet/frame. The native code
  reads it before reusing its zero-page pointer for drawing. It updates HGR,
  speaker/code patches and workspace beyond the loaded three-block image.
  The return address is restored at $18AE..$18B4.

  Transition: src/native/viewscreen_transition.s $1800..$1822 consumes the
  pointer and reads four bytes. Byte0 selects zero/positive/negative paths;
  bytes1/2 select city values, byte3 supplies the current coordinate. The
  shared return $193D..$1949 writes byte3 and restores the return address.
  Drawing depends on row tables and the loaded $0800 overlay's $09F5 helper.
  See docs/warp-animation.md and docs/viewscreen-transition.md. }
procedure call_warp_animation(var packet: g13packet; target: integer); external;
procedure call_planet_transition(var packet: g13packet; target: integer); external;
