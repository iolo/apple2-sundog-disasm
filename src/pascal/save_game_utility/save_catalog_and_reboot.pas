{ utility_disk1:42 $1A64..$1ACF, attributes$1ADC, six unused local bytes.
  Write512 bytes starting at program slot12, including storage past the four
  64-byte records. Preserve both line advances and both input polls. }
procedure save_catalog_and_reboot;
var unused: array[1..3] of integer;
begin
  require_utility_side(true);
  disk_blocks_io(word_address(u1.words[12]), 1, data29.words[31] - 1, false);
  push_text_window(20, 12);
  text_newline;
  text_newline;
  write_wrapped_text('|Press either button\');
  write_wrapped_text('||||||to reboot');
  repeat until odd(poll_input(0) or poll_input(1));
  pop_text_window;
  reboot_with_caption('DUST')
end;
