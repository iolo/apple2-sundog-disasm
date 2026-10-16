# remake of "SunDog for Apple II" for web

## INPUT

- reversed source/assets/documents of SunDog for Apple II as a result of PLAN.md
- original manual sundog.pdf

## OUTPUT

- implementation plan in PLAN-REMAKE.md
- implementation history in PROGRESS-REMAKE.md
- SPA webapp in `remake` directory.

## Implementation Notes

- vector(SVG) graphics based on original assets (separate SVG files instead of embedding in HTML or CSS).
- localized text(English and Korean, other languages can be added).
- fit to viewport(avoid scrollbars as possible it could).
- keep original aspect ratio(4:3).
- mulmaru web font(https://github.com/mushsooni/mulmaru) (predownload for offline use).

### Tech stack

- HTML5
- CSS3
- JavaScript (ESnext, ESM)
- Canvas(2D)
- No bundling, no frameworks, no libraries, no server
- Modern browsers only

## NOTE

- You can suggest any other tech stack if you think it is better than above.
- No strict browser compatibility tests required; modern browsers are enough.
- Step by Step plan. update PROGRESS-REMAKE.md as you progress and commit changes after each step.
- Use /opt/google/chrome/google-chrome to test the webapp in development mode.
