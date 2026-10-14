# R11 colony contract evidence

Banville is city 60 on world 1. The verified 17 cryogen lots are placed in
distinct ordinary-city warehouses at creation (`utility_16.s` `$05B9–$061B`).
Their origin cities and four-byte cargo records are retained during transport.
`initial-economy.json` contains the nine eight-entry recipes exported from
`utility_14.s` `$04D1–$0539`; the resulting cargo-31 counts are
`0, 2, 4, 1, 2, 3, 2, 2, 1`, exactly 17.

Game20 procedure 5 (`$026C–$0274`) recognizes city 60; procedure 28
(`$18FE`) enters the exchange/Center loop. Procedure 31 (`$180D–$18C9`)
labels it Center, displays `10 - activePhase` phases remaining and lists
items needed to finish the current phase. Procedure 23 (`$106B–$10D7`)
reads the live packed demand for that commodity and prints the amount to be
delivered. Its `$1015–$1027` branch treats fuel and cryogens as zero-price
special cases. Procedure 24 (`$1258–$12DD`) offers delivery from Warehouse
or Pod. Source procedures 11–13 establish four warehouse slots and two pod
slots. The initial Banville map contains a tile-15 Center entrance for foot
and pod visits; this is the only service present at phase zero.

Procedure 4 (`$00A0–$01F1`) checks the 14-byte packed demand area before
advancing. When it advances, byte 1 of global word 271 becomes the phase just
completed and byte 2 becomes the next active phase (`$019D–$01AC`). It adds
each positive commodity from the next eight-entry recipe to the demand
(`$01AD–$01E9`). The first visit starts phase 1 from phase 0. After phase 9
it displays the fulfilled-contract text and sets the ending fields
(`$00FB–$013B`). Game21 procedure 26 uses *completed* phase, rather than
active phase, to clip Banville's expanding city map.

Delivery price/quality acceptance and the bonus amount require a further
source trace. The browser implementation should keep each consumed lot in a
bounded receipt ledger so a save cannot both retain and deliver the same
cryogen. A phase update must occur once when demand becomes zero; entering
the Center is the source-visible update point. This document distinguishes
that source behavior from the still-unresolved financial rules.
