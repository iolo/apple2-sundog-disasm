# City map validation — R06a

2026-09-29: `/opt/google/chrome/google-chrome` 154.0.8037.57 passes **97 city UI
checks**, **78 browser rule/localization/storage groups**, **45 campaign checks**
and **37 component exchange checks**. The [JSON receipt](city-map-validation.json)
records each check and screenshot hashes.

The new core tests compare all57 ordinary cities with an independent packed-byte
and byte-carry reference. They cover each960-cell buffer, both bank selectors,
zero margins, preservation of base nibbles, owned rows/banks, invalid and unsupported
records, missing membership, window coordinates, column wrapping and row bounds.
The reference generator does not execute the original p-code; no new emulator
capture or original-game visual parity is claimed.

Chrome UI checks exercise:

- All57 ordinary views and three stored-only fallbacks while offline.
- Native-sized tile proportions, full-map selection coordinates, horizontal camera
  wrapping, recentering after record changes and retained manual bank selection.
- Keyboard selection, focus after panning, locale/resize stability and touch input.
- Both languages at640×480,1280×720,390×844 and844×390. City and stored-layout
  controls stay inside the stage and above the footer; the city heading stays
  above the map. Testing caught and corrected heading/footer fit issues.
- Existing campaign creation, separate preview state, save/export/import/reload,
  legacy upgrade and component-exchange persistence through the normal UI.

English/Korean city-view screenshots and the Korean stored-layout screenshot were
visually reviewed. They retain the local font, original vector tiles and fixed4:3
stage. The generated map is read-only; ship/pod overlays, city collision, airlock
exit/reentry, doors and NPCs remain pending.

Also verified:57 composition references,11 exporter tests,122 deterministic
artifacts,584 classified strings,6 captured equipment records, original disk/manual
hashes and `git diff --check`. Original inputs and generated artwork were unchanged.
