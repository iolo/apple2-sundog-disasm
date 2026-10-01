# Live counter conversations and version8 saves — R06l

Current extension: [R07d shop purchases](shop-purchases.md) enables cash-paid
item/equipment and bartender food/ale transfers with version14 replay saves.
The checkpoint details below retain their historical scope.

R06n extends this checkpoint with [lodging](lodging.md), active cash and version9
saves. The version8 details below describe the original replay format, retained
under strict migration validation.

The player can now approach a counter in the eight type9/10 interiors and use
Talk or Enter. Staff approach using the source queue rules, then the dialogue
panel opens. Moving away while waiting cancels service. Information, item
descriptions, quotes, replies and return run through the source interpreter.
Buying/selling remain disabled pending R07's atomic inventory/cash operations.

English displays the original expanded message. Korean provides full-sentence
templates for every message in counter bank94 and information banks98/99, plus
all25 reply captions. Item names reuse the existing localized glossary. Language
switches only change presentation; they do not rerun the interpreter or consume
RNG. The Korean rendering preserves each message's meaning and tone without
attempting to reproduce English dictionary synonym combinations.

The modal uses existing external item SVGs and local Mulmaru. Keyboard focus
stays inside it, Escape follows the script's back/exit transition, and language
and save controls remain available. Continue emits the source timeout event.
This is an explicit browser timing adaptation: reading, saving and translating
the conversation do not advance survival time or NPC traffic. Returning leaves
the room paused; Resume resumes ordinary walking/traffic. Native delay units
remain in the interpreter but are not treated as measured wall-clock seconds.

## Persistent state

Campaign version8, scope `landed-dialogue-1`, adds `dialogue`:

```json
{
  "attributes": [30, 30, 30, 30, 0],
  "flags": [false],
  "workspace": {"lastCity": 0, "mood": 3, "quantity": 1, "gate": 0, "item": 0, "actor": 0}
}
```

The abbreviated flag array above illustrates the field; real records require
exactly128 booleans. Attributes are active bytes independent of the immutable
creation recipe. Counter outcomes atomically commit these fields with staff
mood/gate, room state and RNG. R06 does not promote cash or inventory transactions;
an unsupported outcome cannot silently change or discard them. Fresh room entry
clears flags64–71 following Game18.

`encounters.counter` is null without a populated room, otherwise it records the
service phase and nullable conversation:

```json
{"service":"talking","conversation":{"seed":12345,"inputs":[{"type":"reply","slot":2}]}}
```

Only the conversation's initial RNG and exact input records are stored. On import
the codec derives setup from the validated campaign, speaker and current place;
replays the input sequence; requires an unfinished conversation and matching final
RNG; and derives text, targets and interpreter locals. Extra fields, invalid
inputs, impossible sequences, orphan conversations and unsupported return effects
fail before replacing the live state. Input objects and persistent fields are
normalized independently of JSON key order.

History is bounded to1024 inputs and the existing131072-character import limit.
If the history limit is reached, an input that would keep the conversation open
fails atomically with a localized message; an exit can still complete normally.
This guards import/replay work without saving unvalidated executable internals.
The format is a validity check, not an anti-cheat or full campaign-history proof.

Versions1–7 validate using their original fields and scene restrictions before
adding fresh dialogue state. Populated legacy rooms receive idle counter state;
legacy empty interiors remain empty until reentry. Old slots are never rewritten
on load. Version7 cannot smuggle new speaker mood/gate fields or dialogue metadata.

## Evidence

`dialogue-rules-validation.json` records169 passing rule groups in required
Chrome154.0.8037.57. New tests cover version7 migration, queued and open-dialogue
round trips, replay continuity, outcome commits, malformed imports, scene exit
and localization coverage for every message in the three enabled banks.

`dialogue-ui-validation.json` records19 browser checks using a controlled imported
room fixture and ordinary UI actions thereafter. The recorded branch is equipment
counter83 → Information160 → item161 → Continue162 → counter83 → exit. It displays
the same shunt description in English and Korean, preserves state across locale
switches and JSON export, saves through IndexedDB, reloads the page and resumes
the exact source English message/RNG. Returning preserves cash and inventory.
The Korean panel fits640×480,1280×720,1920×1080 and390×844; its portrait screenshot
was visually reviewed. No native emulator capture is claimed by these UI checks.

`dialogue-room-regression.json` also records102 passing existing room UI checks:
ordinary walking to both building types, entry/exit/reentry, NPC traffic, legacy
imports, inventory/equipment preservation, fresh-page saves and viewport checks.

`tools/remake/browser_check.py` keeps a local static server alive for each
Playwright CLI run and shuts it down afterward. It uses the repository's required
Chrome configuration; it adds no application dependency or runtime server.

R06 is still incomplete. See [the completion audit](r06-completion.md) for the
remaining interiors and city behavior rather than treating this dialogue branch
as proof of all city exploration.
