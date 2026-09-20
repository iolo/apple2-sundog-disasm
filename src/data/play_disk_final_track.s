; Classified container fill; docs/play-disk-final-track.md
; Nibble reference track 34 has no standard sectors. These zero bytes are
; the sector-image representation, not decoded contents of that raw track.
.segment "FINAL_TRACK"
play_disk_final_track_fill:
    .res 4096, 0
.assert * - play_disk_final_track_fill = 4096, error, "Final track extent changed"
