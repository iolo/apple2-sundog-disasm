{ Explicit CSP0 IO-check binding, not a replacement error implementation.
  Vector$D100 -> $EEDC reads the low I/O-result byte at$BDDE; zero resumes
  through$EEE4, nonzero jumps to$D1EB. It consumes no arguments/results and
  does not clear the result. Unlike IORESULT followed by a Pascal error call,
  this retains the interpreter's error dispatch. Fixture leaves it external. }
procedure rtiochk; external;
