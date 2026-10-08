# Native rare dialogue target224 — R10x

The [capture runner](../../tools/remake/capture_reward_reference.py) records an
owned MAME0.285 unenhanced IIe session on disposable copies of the original
media. It enters the original Comm call, then declares kind18, colony progress2,
flag125false and RNG23 at Game16 procedure39's actual `$1252` entry. This is a
parser observation fixture, not an ordinary ground visitor or colony journey.
The setup does not rewrite instructions, frames or the Game16 instruction pointer.

## Rare branch and bank load

The first source draw returns19200 and changes RNG bytes23/0/0/0 to151/11/0/0.
The eager one-percent predicate succeeds. Original procedure39 reaches `$1368`,
prepares the10000Cr quote, sets flag125 and calls procedure34 with state224.
The native long-money quote words100/101 and106/107 become10/0. This quote does
not itself add money: working cash words104/105 remain20/580 throughout capture.

Procedure34 selects bank index13 and loads utility block103 into `$4800`.
Its first32 bytes match the earlier hash-verified
[bank audit](r10f-reward-bank-audit.json). They begin with four zeros. This is
not a supported dialogue bank. Procedure32 nevertheless interprets its header,
advances the dictionary entry index52→76 and modifies the dictionary buffer.
The observation does not justify treating block103 as a fourteenth normal bank.

## Zero-divisor failure

Procedure23 reads entry offset0 and record mode0. Its selector byte is also0.
Procedure24 `$0A1E–$0A36` handles this as a random list with zero candidates,
draws again, loads the zero list length and executes `MODI`. The second draw
returns19205 and changes RNG to151/203/5/0. At the actual `$0A36` dispatch, the
6502 evaluation stack contains divisor0 and dividend19205, bytes0/0/5/75.

An owned native breakpoint then stops at CPU `$D7ED`, with the Game16 IP still
at `$0A36`. The original [integer primitive](../../src/native/pcode_primitives.s)
checks the divisor in `$90/$91` and jumps from `$D7ED` to `$D1DF` when it is zero.
That entry selects runtime error6. A subsequent paused diagnostic observes the
runtime handler activation. No successful dialogue return, reward message or
cash award is established. The native error screen is captured but contains
only the numeric error display; it is not a source reward presentation.

Personal condition, carried equipment, ship component owners, location and
clock18/21/0/0 remain unchanged through the trap. Flag125 has already been set,
and both RNG draws have occurred in the failing native activation. These native
partial writes are separate from the browser's existing atomic rejection.

## Verification and remaining work

The [verifier](../../tools/remake/verify_reward_reference.py) checks14 stopped
source/native contexts, literal stack/RNG/quote/cash owners, dictionary mutation,
breakpoint cleanup and the owned emulator's clean exit0. The
[reference manifest](../reference/remake-reward-reference.json) hashes33 artifacts.

At R10x the remake rejected224 before publishing campaign changes.
[R10y now defines browser handling](dialogue-source-fault.md): a replayable,
stopped conversation with the exact draws, no payout and explicit earlier-save
access. This
capture rules out claiming a verified10000Cr payout or inventing missing reward
text. It does not establish ordinary rare-branch reachability or close the full
[R10 requirement audit](r10-completion.md).
