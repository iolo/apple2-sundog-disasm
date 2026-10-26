# SunDog p-code assembly to Pascal source recovery plan

## Objective and deliverable

Translate the existing disassembled p-code in `src/pcode/*.s` directly into
readable, reviewed UCSD Pascal source in `src/pascal/`. Recover declarations,
procedure interfaces, control flow, and storage operations, with references
back to the assembly.

**The deliverable is recovered source code.** Read each procedure's listing,
write its Pascal body, and review their correspondence. Direct translation is
the default and needs no decompiler implementation. Building a decompiler is
outside this plan; difficult procedures call for focused analysis, not a new
tool-development phase.

## Scope and feasibility

Use the existing [inventory](docs/decompilation/inventory.json): 570 targeted
p-code procedures across active game, startup, utility, system, and library
modules, plus contracts for 38 native interfaces. Reuse completed recovery;
current coverage belongs in the [source index](src/pascal/README.md) and
[progress notes](docs/decompilation/README.md), not duplicated here.

Existing recovered Pascal demonstrates that direct translation is practical.
It does not establish that every remaining routine is understood or that the
source runs correctly. The system core's shared storage and runtime
interactions may require more analysis than ordinary game
logic. Procedure counts alone are not a reliable completion-time estimate.

Recover observable behavior without promising original names, comments, or
formatting. Neutral names are acceptable when operations are understood;
unknown behavior must remain explicitly unresolved. Target the evidenced UCSD
Pascal dialect rather than portable Pascal.

Retained fragments and alternate versions remain explicitly deferred in the
inventory. Native 6502 bodies and custom dialogue bytecode are outside this
Pascal recovery task. Preserve the assembly, reconstruction inputs, original
disks, and accepted unidentified-data exception. A runnable replacement game,
compiler, VM, or replacement runtime is outside this plan.

## Work procedure by procedure

Work in small connected groups, reusing reviewed dependencies. For each routine:

1. Read the listing and frame metadata. Use relevant callers to establish
   parameter order, widths, result slots, lexical access, and by-reference use.
2. Trace stack values, addresses, branches, loops, and exits directly from the
   listing. Notes or a worksheet are sufficient; no intermediate representation
   or complete program model is required.
3. Write the complete Pascal declaration and body. Prefer ordinary variables,
   expressions, and structured control flow. Preserve arithmetic, signedness,
   packed fields, aggregate copies, aliasing, and observable evaluation order.
4. Review every instruction path and effect against the source, including exit
   and cleanup paths. Account for inline data and metadata separately. Record
   assembly references and explain non-obvious choices in source comments.
5. Update the existing inventory with `not started`, `partial`, or `recovered`.
   Record unresolved facts and validation separately, and check affected callers
   when an interface or layout changes.

Accept a routine when its complete body has been reviewed, required interfaces
are consistent, and references and status are recorded. A source file or compiler
receipt alone is insufficient. Placeholder bodies and external declarations for
pending p-code do not count as recovery. An empty body is valid when the original
routine itself performs only a return and its interface has been reviewed.

If behavior cannot yet be represented faithfully, record the assembly range and
missing fact, mark the routine partial, and continue independent work. A separate
annotation for every instruction is unnecessary when an expression or block
clearly accounts for its effects.

## Handle difficult semantics only where they occur

| Risk | Recovery approach |
| --- | --- |
| Packed fields and overlapping storage | Preserve evidenced word/byte accesses; introduce records only where layout is established. |
| Aliasing and effectful calls | Preserve load/store and call order, including calls that Pascal evaluation might otherwise omit. |
| Lexical-parent access and frame copies | Recover nesting and accessed storage; retain physical layout where behavior depends on it. |
| Branches, loops, and nonlocal exits | Trace all paths; retain labels and `goto` where restructuring would obscure behavior. |
| Dialect and runtime differences | Check SunDog interpreter semantics and document required runtime bindings. |

Use raw storage views for actual layout dependencies, including address
arithmetic, overlapping accesses, bulk copies, and runtime interfaces. Do not
model every routine as a VM frame or recreate compiler temporary slots merely
to match frame size. Introduce meaningful names and shared types when accesses
and callers establish them, without speculative abstractions.

Preserve known frame and segment-release requirements from existing notes.
External declarations may describe evidenced native or runtime interfaces;
they must not hide untranslated p-code bodies or imply that runtime bindings
have been implemented.

## Evidence and tools

Use the existing repository evidence as needed:

- `src/pcode/*.s` and `src/pcode/encoding.inc`: instructions, labels, data,
  encodings, and procedure metadata.
- `src/native/pcode_primitives.s` and `docs/pcode-toolchain.md`: SunDog-specific
  semantics, which take precedence over generic UCSD assumptions.
- `src/pcode/evidence/` and `docs/reference/pcode-modules/`: module identities,
  mixed-code boundaries, and prior analysis.
- `tools/pcode_source.py` and `tools/pascal_inventory.py`: existing decoding,
  control-flow, call, frame, and inventory assistance.
- `../../tmp/ucsd-psystem-xc`: optional reference compilation and disassembly.
  Record its revision and options when used.

Consult callers, callees, and interpreter handlers to answer specific recovery
questions. If inspection and existing commands suffice, translate immediately.
Use a small disposable helper only for a concrete obstacle they cannot handle
efficiently; state the question, keep it narrowly scoped, and return to recovery.
Possible future reuse does not justify new infrastructure.

Do not add a parser, IR, automatic emitter, general type inference, control-flow
structurer, plugin architecture, or general equivalence engine. Do not create a
new reporting or testing framework. Measure progress by reviewed source bodies.

## Validation proportional to recovery

Source review against the assembly is the acceptance gate. Check instruction
effects, operand order, arithmetic, aliasing, copies, branch paths, lexical
access, and result handling. Use a focused check when it resolves an actual
semantic or interface uncertainty.

Compilation is optional evidence for syntax and interfaces. Reuse an existing
fixture where practical; add a small fixture only for a named uncertainty.
Label stand-in storage, stubs, and runtime assumptions. Compiler incompatibility
need not block source review; unresolved behavior does, even if the code compiles.
Compiler setup and fixture expansion are not recovery milestones.

Compare emitted bytes only for a specific semantic or layout question in a
compatible context. Do not pad frames, add unused temporaries, or tune faithful
source to reproduce compiler output. Different bytes alone do not demonstrate
incorrect recovery; compilation alone does not demonstrate runtime equivalence.

Report source review, compilation, semantic checks, byte comparisons, and runtime
execution as distinct claims. Existing exact disk builds validate the assembly
reconstruction, not recovered Pascal. Run applicable affected checks; decoder
tests are needed when decoder code changes, and disk-identity checks when assembly
or reconstruction changes. No emulator session is required for source recovery.

## Artifacts, next work, and completion

Maintain reviewed Pascal in `src/pascal/`, organized by existing component
identity. Preserve manual edits. Put any generated drafts or temporary compiler
fixtures under `build/decompile/`. Keep routine-specific decisions in source
comments and reuse the existing inventory, interface/layout notes, and receipts;
a new report for each routine or group is unnecessary. Retain component identity
as well as segment/procedure numbers, since segment numbers can recur.

Use the inventory to select unfinished procedures and their callers, then
reconcile the completed scope and interfaces. Review any existing drafts before
counting them. Pending system calls remain explicit
recovery dependencies; temporary compilation declarations do not fulfill them.
Do not restart completed recovery or require a repository-wide audit before
proceeding. Resolve discrepancies in the group being worked on.

Each delivery should advance reviewed source coverage or resolve a named semantic
blocker. Supply the Pascal bodies, necessary declarations, assembly references,
updated inventory status, and concise validation results.

Completion means all 570 targeted p-code procedures have reviewed translations
accounting for every instruction path, and all 38 targeted native interfaces have
evidenced contracts. Resolve partial bodies and reconcile shared declarations;
leave required runtime bindings and deferred variants/fragments clearly documented.
Full source recovery is the completion criterion. Compilation, exact-byte
reproduction, and runtime equivalence remain separately reported evidence.
