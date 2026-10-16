# R12 speaker-inspired browser audio

The supplied Apple II code toggles the one-bit speaker at `$C030`. The native
warp overlay has an optional speaker toggle at `$1C09` (see
[`warp-animation.md`](../warp-animation.md)); Library 22 at `$0D50/$0D5E`
produces variable-rate tones, and native I/O at `$DA93` toggles the speaker in
a repeated delay loop. These are sources for the sound *character*, not a
recording or a measured frequency table. Existing reference sessions had sound
disabled, so no original timing or pitch match is claimed.

`remake/js/platform/audio.js` synthesizes brief square-wave cues with Web Audio.
The title, inspector and ship headers expose the same persistent Sound toggle.
The first enabled pointer or keyboard action creates and resumes the audio
context; ordinary simulation ticks never create one. Mute immediately zeros the
master gain, and the preference is stored separately from campaign saves.
Browsers without Web Audio keep the button visibly disabled and gameplay usable.

| Browser cue | Trigger |
| --- | --- |
| Select/confirm/transition | Menu actions, scene navigation, colony phase update |
| Fire | Tactical firing input accepted by the host |
| Alert/hit | Ground or ship contact; player or hull damage |
| Warp | Confirmed warp action |
| Ending | Ninth colony phase completes |

All cue pitches, note counts and durations are browser adaptations. There are
no downloaded or sampled runtime audio files. R12 validation checks gesture
activation, mute persistence, Korean labels, and no oscillator start while muted
in required Chrome, plus a pure audio state test in the browser runner.
