# Live taverns and dialogue

Current extension: [R07d shop purchases](shop-purchases.md) enables cash-paid
item/equipment and bartender food/ale transfers with version14 replay saves.
The checkpoint details below retain their historical scope.

R06p enables type8 foot entry into records4–7. The player can approach the
bartender, sit at a table, talk to the opposite visitor, receive an approaching
visitor, hear small talk/jokes, offer a bartender tip, and leave/reenter.
Version10 saves preserve these visits, including open conversations and moving
visitors. All earlier save versions validate before migration.

## Source setup and return

Game18 procedure23 dispatches actor0 as kind12 in a tavern. A pending table
contact instead supplies its actor and kind21/22. Setup copies that actor's
item/mood/greeting into the workspace, with quantity1. The room controller owns
this dispatch; campaign callers cannot select an unrelated speaker.

Game16 procedure39 uses these entries:

| Kind | Entry | Additional setup |
| --- | --- | --- |
| 12, bartender | 16, `$1298` | Common counter setup only. |
| 21, player-initiated contact | 48, `$1348` | Predicate56 chooses the social greeting128 or departure message54. |
| 22, approaching visitor | 33, `$12AA–$12E7` | Local18 receives flag66, flag66 clears, local33 becomes4, and local41 receives the actor's item. No setup RNG draw. |

The ordinary source runner covers the social branch through bank97, small talk
in bank100 and jokes in bank101. A joke's answer reuses the question's selector
index rather than drawing a different joke. Source captions, transition
predicates, price quotes and mood/gate changes retain their interpreter order.

On return, Game18 procedure21 applies flag49 to the actual visitor's secondary
movement, then restores that actor's mood and greeting gate and clears flags48–51.
The bartender is unaffected by an NPC conversation. A staff conversation returns
service to `served`; a table conversation returns it to `idle` while retaining the
player's seat. Traffic remains paused until the player resumes, matching the
existing browser dialogue convention.

Bartender tips use source states22–26. The offer controls adjust local100; the
acceptance branch debits the interpreter's local104. Campaign cash changes only
when that conversation finishes. Saving mid-offer or after acceptance reconstructs
the same amount/RNG without applying the debit twice. The initial creation cash
remains unchanged and the bank displays the active balance.

Food/item purchase and item matching/transfer remain R07. Tavern inputs that
would enter these actions are disabled in the UI and rejected by the room
controller before unsupported acceptance text. Visitors can still quote goods
and finish a conversation normally. No hostile encounter branch is introduced;
combat remains R10.

## Input and presentation

Releasing pointer or keyboard movement in the seating band claims the source
seat, as does Talk while beside it. Walking releases ownership before movement
and collision validation. An empty seat waits for visitors; an occupied opposite
seat opens a conversation immediately. Source traffic can also initiate one.
Reserved-seat and temporarily busy-mover messages are localized.

Added92 Korean templates for banks90/91/92/97/100/101/102. English still uses the
original dictionary expansion. The expander now returns any randomly chosen
place names alongside its text; Korean inserts those same names without another
draw. Tone variants use localized templates rather than random Korean synonyms.
Visitor dialogues are titled “Conversation”; the bartender has its own title.
Trade availability notes appear where they inform a choice, rather than during
small talk or jokes.

## Version10 boundary

Scope is `landed-taverns-1`. Room visits require a populated, validated traffic
state. `roomState.tavern` retains the player seat, secondary mover and optional
actor/kind contact. A contact must have a talking service phase and replay record.
The persistent workspace permits actor0 or visitor2–8; this records the last
speaker and can survive leaving the room. Live references are separately checked
against the current actor list. Versions1–9 cannot introduce a tavern visit, and
version9 still rejects a visitor in its actor0-only workspace.

As before, saves contain an initial RNG and bounded input history, not arbitrary
interpreter internals. Opening a conversation after a sit request and after a
traffic arrival is atomic with recording its replay seed. Outcomes, cash, actor
writeback and resumed traffic commit together. See `campaign-saves.md` and
`tavern-traffic.md` for the shared schema and collision rules.

## Evidence

Required Chrome154.0.8037.57 passes196 rule groups and36 tavern UI checks.
Fixtures use the actual starting-city type8 door at `(395,267)`, selecting
record6. The suite enters through that door and walks to the bartender. It also
uses validated imported visits to reproduce table seating, incoming visitors and
the deterministic tip branch without production test hooks.

Recorded social path: kind21 →128 →176 →192 →193 →178 →exit. It asks and answers
the same New Faith Society/glow-globe joke in English/Korean, saves mid-question,
reloads through IndexedDB on a fresh page, and restores the exact speaker, seat,
RNG and secondary return. Pointer release/standing, a saved moving visitor,
type22 refusal, a mid-offer reload, ten-credit tip return, street exit and fresh
reentry also pass. Dialogue bounds are checked at640×480,390×844 and844×390.
The Korean punchline screenshot was visually reviewed.

Receipts are `tavern-rules-validation.json`, `tavern-ui-validation.json` and
the `tavern-*-regression.json` scene checks. No new native emulator capture is
claimed. R06 still requires the special city/service-dispatch review and final
cross-scene audit.
