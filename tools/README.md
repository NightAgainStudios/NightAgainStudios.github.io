# Tools (how the served assets were made)

- `knock.swift` — knocks a logo's flat ground out to transparency with a soft edge.
  Build: `swiftc -O -o knock knock.swift`. Run: `./knock <in.png> <out.png> 22 26`
  (`22` = fully transparent within that color distance of the sampled ground,
  `26` = fade to opaque by 22+26). `assets/night-again-studios.png` is
  `assets/source/night-again-studios-logo-1-original-1254.png` through this tool
  at 22 / 26 (ground sampled `#0A0C12`, 85.4 % of pixels cleared).
- `alpha.swift` — prints an RGBA PNG's alpha coverage and the content's bounding
  box, so centring can be measured rather than eyeballed (the mark sits at
  canvas center 627/627 in the 1254 original). Build the same way.

`assets/source/` holds the two logo candidates as uploaded by the owner (2026-10-07);
#1 (the staircase in the doorway) is the chosen mark. Fonts: `assets/fonts/` with
their licenses beside them (Michroma — OFL).
