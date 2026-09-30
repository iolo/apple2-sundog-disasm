# Dialogue text expansion — R06h

The remake now expands the original English dialogue text, including nested
dictionary alternatives, counter greetings, fixed reply captions and setup
substitutions. This is an interpreter component; live conversations and their
English/Korean presentation remain pending. Campaign state stays at version7.

## Source and exported content

`tools/remake/dialogue_assets.py` exports `remake/data/dialogue-text.json` from
the classified dictionary, dialogue-message and bank-storage fields. It contains
64 base dictionary entries, 57 supplemental entries across twelve banks, and all
165 classified message records. Stored characters and high-bit positions remain
separate, readable fields. No source instruction bytes are browser payloads.

Game16 procedure32 ($0ED8–$0F68) installs supplements starting at entry52 and
empties remaining entries through63. Block98 has marker16 and skips this entire
operation, preserving the preceding dictionary. `dialogueDictionary` returns an
owned copy of that state. A fresh conversation can supply the base dictionary;
bank transitions within it must pass the preceding dictionary, especially when
loading block98.

## Phrase decoding

`dialoguePhrase` follows procedures13/14 ($05BA–$06F2):

- A nonnegative choice selects a zero-based alternative. A negative choice
  counts stored, unmarked bytes65–96 and draws `random mod(count+1)`. Empty and
  single-choice entries still draw once. Index64 or above returns empty text
  without a draw.
- Counting/skipping uses stored bytes before stripping bit7. Unmarked
  punctuation in that range can count as a boundary without ending rendering;
  marked uppercase letters end rendered text without counting as a boundary.
- Uppercase A–Z emits lowercase and ends the phrase. High bits append a space.
  Vertical bar and backslash become capital I. Unmarked tilde becomes an
  apostrophe; the marked path preserves tilde and appends a space.
- An unmarked backtick rewrites the preceding output byte at the same position
  and ends the phrase; it adds no character and removes no character.

Procedure27's reply captions use fixed alternatives from dictionary entry0 and
capitalize the first character. The 25 stored captions do not draw randomness.

## Message expansion

`renderDialogueMessage` follows procedures16–22 ($0724–$0985), retaining source
spacing and sentence capitalization. It uses a private RNG initialized from the
given gameplay state and returns the resulting text and continuing random state.
Failure leaves caller-owned context, dictionary and RNG state unchanged.

| Stored code | Source behavior |
| --- | --- |
| Below32, or48–62 | Random dictionary phrase, recursively interpreted |
| 32,39,44 | Space, apostrophe, comma |
| 33,46,63 | Punctuation followed by sentence capitalization |
| 34 | Literal `O.K.` |
| 35 | Random system/world name, excluding the current one |
| 36,37 | Preformatted strings from setup locals108/124 |
| 38,40 | Fixed dictionary form selected by workspace byte11 equaling1 |
| 41–43 | Fixed dictionary alternative0, copied as text |
| 45 | Mood-selected dictionary alternative, recursively interpreted |
| 47 | Fixed dictionary form selected by setup boolean18 |
| 64 | Empty dictionary result |
| 65 and above | Literal character |

Raw copied substitutions capitalize only their first character through the
native emission path. They do not recursively interpret punctuation or tokens.
String108 explicitly clears sentence capitalization after copying. Setup must
supply these strings; the renderer does not infer live offers from immutable
campaign credits or item requirements. Numeric context names retain source
identities pending the setup/action implementation.

Procedure16 chooses system versus world using the raw RNG low bit, then draws
from1..12 or1..18 until it selects a different location. This can loop forever
with seed0 and current world1. The browser detects a repeated RNG state and
raises `dialoguePlaceUnavailable`; it does not substitute a location or advance
the caller's state. Recursive expansion has explicit depth/work/output limits,
and invalid fixed alternatives fail instead of reading beyond the entry.

Original output-buffer flushes and screen drawing are presentation operations.
The core returns their concatenated text, preserving spaces; it neither wraps
at the native buffer width nor trims the result. Korean dialogue presentation
must be implemented before this English source renderer enters the live UI.

For example, block94/word147 at seed12345 and mood3 yields
`What can I get you, fella? ` and RNG state120478901. Its three draws expand
entries21,3,50 in that order. Word150 yields `What else can I show you. ` without
advancing RNG. These are source-derived examples, not emulator captures.

## Validation

Chrome154.0.8037.57, launched using `/opt/google/chrome/google-chrome`, passes
125 browser rule groups including11 new text groups. Coverage includes all
165 messages over five moods and three seeds (2,475 deterministic cases), every
fixed caption, phrase marker quirks, nested greeting draw order, sentence/raw
copy differences, both random place branches, rejected current places, seed0
failure, missing setup values, recursion limits and caller ownership.

Sixteen exporter tests pass. Exported text reconstructs the original1,930
dictionary bytes and every counted message payload exactly. All138 generated
artifacts verify. Original dictionary/script verification and disk/PDF hashes
pass, as does `git diff --check`. No live UI or save schema changed, so this
checkpoint does not claim a new gameplay UI validation run.

Next: dialogue setup and its RNG effects, predicates, controls/actions, player
queue/return state and localized conversation presentation.
