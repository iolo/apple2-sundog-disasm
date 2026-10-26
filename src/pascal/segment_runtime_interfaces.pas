{ Evidenced runtime operations, not replacement implementations.
  rtldseg binds to CSP21, vector $D12A -> $E66B; rtrlseg binds to CSP22,
  vector $D12C -> $E675. Both pop one word, use its low byte as the segment
  number, call load_segment/release_segment, and return no Pascal result.
  The compile fixture leaves these EXTERNAL: it does not emit or link CSPs. }
procedure rtldseg(number: integer); external;
procedure rtrlseg(number: integer); external;
