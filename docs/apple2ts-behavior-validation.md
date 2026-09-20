# Apple2TS gameplay and saved-disk reload

Step 09b uses the installed Apple2TS frontend and server in a separately owned
localhost/browser session. The configured MCP session remained idle: its tools
lack joystick input, so the browser frontend was needed for this check. No
installed emulator source or server configuration was changed.

## Configuration and input

- Frontend commit: `62508079ea0c0e3dff314c73778d641159cec92f`.
- Server commit: `8f4cd0df38a142dbfe4212f815cff5f094715bc2`.
- Browser: HeadlessChrome 153; model `APPLE2EE`, `ramWorksKb: 64`, speed mode 0.
- The installed frontend's entry page and four JavaScript bundles are hashed in
  the JSON report. The server checkout already had a package.json modification
  and an untracked launcher; these were not changed by this work.
- Both source images were mounted by base64 upload into disposable browser
  media. The input files were never opened for writing by the emulator.
- A virtual device supplied `navigator.getGamepads()`. Apple2TS's existing
  frontend polling and worker joystick code consumed its axes and buttons.
  No CPU/register changes, RAM patches, or emulator save-state imports were used.

The virtual device has four axes (the second pair stays zero) and sixteen
buttons (all initially released). Buttons 0 and 1 were pressed for 350 ms and
then released. These normalized browser axes successfully selected the controls:

| Control | X | Y |
| --- | ---: | ---: |
| Play SunDog | 0.25 | 0.28 |
| Personal-status disk icon | -0.25 | -0.39 |
| Save Game | 0.09 | 0.38 |
| Use utilities | 0.25 | 0.44 |

These are browser gamepad axes, not MAME's 0–255 analog coordinates. Apple2TS
applies its own circular-to-square transformation. Inputs were sent through the
Playwright CLI, with screen inspection between phases. Host delays were bounded;
they are not a deterministic frame schedule or timing comparison with MAME.

## Save and reload observations

The title accepted button 0, Play SunDog requested the PLAY SIDE, and mounting
disk 2 in the same drive loaded the ship interior. Button 1 opened personal
status. Selecting the disk icon and Save Game requested the UTILITY SIDE.
Mounting a fresh disk-1 copy and pressing button 0 wrote the saved game and
returned to the title animation. The frontend's Download Disk action exported
the resulting 143,360-byte DSK, converting its internal WOZ representation.

The downloaded disk SHA-256 is
`4358c66ff69d43cdc9f489568594eb3a04cbfaa1b34579082765ec48d3f7fb1b`.
Compared with the baseline, exactly 99 bytes changed:

| Logical block | Changes | Interpretation |
| --- | ---: | --- |
| 26 | 2 | Slot 1 checksum |
| 37 | 7 | Slot 1 globals |
| 46 | 90 | Tail of the ten-block saved bank |

The bank's independently recomputed checksum is `$6F6F`, exactly the stored
slot descriptor value. Changes are limited to the same block scopes as the
MAME save. The different values are not an emulator-equivalence claim: elapsed
game time and incidental tail contents were not synchronized.

The save browser was closed. A distinct browser process then mounted that
exported DSK, cold-booted, selected Play SunDog, and swapped to a fresh play-side
copy. It loaded the ship and responded to button 1 with personal status.
No previous process memory or emulator save state was restored. The reload API
reported the play-side working disk dirty; its changed bytes were not exported,
so this report does not claim unchanged reload media.

## Utility behavior

A fresh baseline disk-1 copy was mounted and cold-booted. Use utilities loaded
the four-slot screen: slots 1, 3 and 4 suspended, slot 2 being played. Selecting
Hawkmoon with axes `(-0.4, -0.3)` and button 0 opened its attributes and Delete
game / Play game actions. Button 1 returned to the slot list. No action was
selected. Both browsers and the owned HTTP server were stopped after releasing
virtual inputs; the configured MCP lifecycle still reported idle at sequence 0.

Configuration, build hashes, save-byte changes and screenshot hashes are in
[apple2ts-save-reload.json](reference/apple2ts-save-reload.json). Representative
captures show the [ship](reference/apple2ts-rebuilt-ship.png),
[save prompt](reference/apple2ts-save-side-prompt.png),
[reloaded status](reference/apple2ts-saved-status.png),
[utility slots](reference/apple2ts-utility-slots.png) and
[slot actions](reference/apple2ts-utility-actions.png).

## Reproduction and scope

Use the installed server's `startApple2tsServer` with a fresh localhost port and
its existing frontend `dist` directory, then open `/?remoteControl=1&debug=on`
in a fresh browser profile. Check the server's actual OpenAPI schema and machine
state before mounting. The compatibility API supports base64 media mounts and
boot; gamepad input is supplied in the browser. For example, in page evaluation:

```js
window.sundogPad = {
  connected: true, index: 0, id: "validation joystick", mapping: "standard",
  timestamp: 0, axes: [0, 0, 0, 0],
  buttons: Array.from({length: 16}, () =>
    ({pressed: false, touched: false, value: 0}))
};
Object.defineProperty(navigator, "getGamepads", {
  configurable: true, value: () => [window.sundogPad]
});
```

Set axes from the table, wait for the cursor to settle, pulse the appropriate
button, and verify the expected screen before advancing. Download the saved
DSK from the drive menu and test it in a fresh browser process. Keep all media
copies disposable, release inputs, and stop only the owned sessions afterward.

This is a gameplay/save-reload smoke test. It does not verify all saved fields,
combat, travel, audio fidelity, every utility action, or synchronized timing.
MAME used unenhanced IIe ROMs while this run used enhanced IIe; cross-emulator
pixel equality is not asserted. Original inputs and baseline rebuilt outputs
remain exact. Remaining byte classification and final integration are separate
requirements.
