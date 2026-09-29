# Dialogue selection foundation — R06g

The browser now has structured data for all 96 classified records in disk2
blocks 90–102 and pure selection/transition helpers. This checkpoint does not
open conversations or execute dialogue actions. It prepares the shared reader
needed by counter interactions without changing version7 campaign state.

## Counter dispatch and remaining dependencies

Game18 procedure26 ($149A–$1614) places the player in the counter queue when
pointer release finds the player inside the population bounds. Procedure27
scans actor 1 before visitors 2..N. Upon reaching actor 1, it calls procedure23
($114A–$1370). Types9/10 select dialogue kinds 13/14 and counter actor 0. Game16
procedure39 ($1252–$13E2) maps these kinds to states 80/81.

Game16 procedure34 maps state to bank `(state div16)-1` and entry `state mod16`.
Both counter entries are in block 94. They test predicate100, then redirect to
82/83 respectively on either outcome, and action5 records that same state in
the first continuation slot. The predicate must still be evaluated: predicates
are not generally pure. States82/83 share greeting candidates but use different
reply destinations and action3 operands. A greeting is therefore not sufficient
to implement a transaction or complete conversation.

Before connecting this to the room UI, implement the source dictionary/message
renderer, predicate evaluator and dialogue setup (including setup RNG draws),
control/action effects, return-to-room behavior and save state for player
queue/conversation progress. Then enable only fully handled branches. The
secondary room mover and fixtures for other building types remain separate.

## Exported records

`tools/remake/dialogue_assets.py` converts the existing audited source operations
in `docs/reference/dialogue-scripts.json` into `remake/data/dialogue.json`:

- Bank/entry addresses and original record offsets.
- Header mode, doubled source delay, packed controls and early redirect marker.
- Literal, random, conditional and four distinct mood selectors.
- Two transitions and any replies, with explicit `unless` overrides.
- Action opcode and operands, retained without inventing gameplay semantics.

The export is a build-time development step; the browser remains plain ESM with
no build system or runtime dependency. Provenance hashes include the audit and
generated catalogue. Runtime lookup returns an owned record and rejects empty
entries, built-in states below16 and banks outside the exported range.

## Selection semantics

`remake/js/core/dialogue.js` follows Game16 procedures24/25 and29. Its explicit
context mirrors outer locals33 (mood),20 (gate),14 (previous random index) and15
(reuse flag). The caller supplies the shared RNG and predicate evaluator; the
module does not mutate the caller's context or catalogue.

- Random selectors draw once even for a single candidate. Reuse consumes no
  draw and clears the one-shot reuse flag. If the saved index exceeds the new
  list, native code leaves the selector count as its result ($0A41–$0A5C); the
  port preserves that behavior instead of wrapping it.
- Conditional selectors test candidates in order and stop evaluating predicates
  after the first match. Predicate0 is true. The final candidate is the default.
- Selectors20/22 choose among three candidates with thresholds2,1,0. Selector23
  chooses among four with thresholds3,2,1,0. No random draw is involved.
- Selector21 reads its extra byte **into the result**, then uses outer local20
  to decide whether to replace it with a mood candidate ($09D4–$0A1A). The byte
  called `condition` by the source-format macro is therefore a fallback value,
  not a predicate. The counter greeting's fallback is word 147 (byte 294).
- Procedure29 overrides a transition when its nonzero predicate is **false**.
  Zero consumes no replacement operand and invokes no predicate.

The selector21 fallbacks at block 90/word 89, block 94/word 147 and block 95/word 180
are already classified messages in `assets/dialogue-bank-storage`. They were
absent from the earlier script audit's `text_words` list. The historical audit
and source bytes remain unchanged; the new normalized data includes these
fallbacks explicitly and tests that every message candidate names classified
message data.

Text rendering may itself consume RNG. Future execution must apply controls,
select and render a message, resolve following transition/reply predicates, and
then perform actions in source order. Do not eagerly resolve a whole record's
predicates before rendering. Packed controls, actions and built-in transition
states are data only in this checkpoint.

## Validation

Chrome 154.0.8037.57 at `/opt/google/chrome/google-chrome` passes 114 browser rule
groups, including 11 new dialogue groups. Those exercise all 96 records, both
counter roots, every mood/gate combination, random list lengths 1..10, singleton
draws, random reuse and its out-of-range case, predicate order, false overrides,
caller ownership and explicit errors for missing predicate support.

Fifteen exporter tests pass. Independently re-encoding the normalized records
and entry tables reproduces all 1,175 source bytes and their audited SHA256.
All 137 generated artifacts verify. The original parser still verifies 160
messages/3,434 bytes and its complete bank audit against the rebuilt disk.
Original disk/PDF hashes pass. This is source-derived validation, not an
original-emulator dialogue capture. No UI, save schema or campaign mutation
changed, so this checkpoint adds no gameplay UI validation claim.
