{ system_core0:5 $00D8..$00DF, attributes$00EA. File pointer4, caption
  pointer3, mode2, extra pointer1; no locals; RBP0. Forward all four words
  to system6:4. VAR caption preserves the borrowed address; copying it here
  would precede the callee's early-error checks and change aliasing behavior. }
procedure rt_file_open(var f: integer; var caption: text80;
                 mode: integer; extra: s6wptr);
begin
  rt_open_file(f, caption, mode, extra)
end;
