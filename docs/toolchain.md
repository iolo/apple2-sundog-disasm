# Observed tool environment

Inventory taken 2026-09-18:

| Tool | Observed version / location |
| --- | --- |
| a2kit | 4.4.2, `/home/iolo/.cargo/bin/a2kit` |
| ca65, da65, ld65, cl65 | V2.19, Git `a028ac414`, `/home/iolo/.local/bin/` |
| MAME | 0.285, `/usr/games/mame` |
| pdfinfo, pdftoppm, pdftotext | Poppler 26.01.0 |
| Tesseract | Not installed; relevant manual pages read visually |
| apple2ts source | `/home/iolo/workspace/retro/apple2ts`, Git `62508079ea0c0e3dff314c73778d641159cec92f` |
| apple2ts server | `/home/iolo/workspace/retro/apple2ts-server`, 0.1.0, Git `8f4cd0df38a142dbfe4212f815cff5f094715bc2` |

The default HTTP server at `127.0.0.1:6502` was unavailable. The installed
apple2ts MCP connector successfully starts its own private headless session.
Its machine resource reports `APPLE2EE`, `ramWorksKb: 64`, speed mode 0, one
mounted floppy in `fd1`, and no other mounted media. Uploads use the connector's
path-bound ticket and `node .../apple2ts-server/cli/apple2ts-upload.mjs`; the
upload command is not on PATH. The initial debugger setting is disabled.

MAME's default ROM search path did not find Apple II ROMs. The existing local
ROM directory `/home/iolo/workspace/retro/a2x/mame/roms` passes
`mame -rompath <directory> -verifyroms apple2e`. ROMs are external prerequisites
and are not copied into this project. Use `-gameio joy` to attach analog
joysticks; the default configuration does not expose joystick axes.

MAME reference automation uses its documented
[Lua input fields](https://docs.mamedev.org/luascript/ref-input.html) and
[autoboot scripts](https://docs.mamedev.org/luascript/index.html).

`a2kit catalog -d <image>` reports `FileSystemMismatch` for both originals.
This rules out a recognized filesystem in this tool invocation; it does not by
itself prove a specific custom format or sector ordering.
