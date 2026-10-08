# nightagainstudios.com

The studio's site, served by GitHub Pages from this repo (custom domain in `CNAME`; Cloudflare
holds the DNS, DNS-only; HTTPS enforced in the repo's Pages settings).

| Path | What |
|---|---|
| `index.html` | the studio page: the mark, "made after dark.", the Games card |
| `emoemu/privacy.html` | Emo Emu's privacy policy — the App Store "Privacy Policy URL" and AdMob's privacy URL |
| `emoemu/support.html` | Emo Emu's support page — the App Store "Support URL" |
| `app-ads.txt` | AdMob's authorized-sellers line (must stay at the root) |
| `assets/` | the transparent mark, the favicon set, the Emo Emu icon, fonts with their licenses |
| `assets/source/` | the logo originals as uploaded (1254); #1, the staircase in the doorway, is the mark |
| `tools/` | `knock.swift` (ground → transparency), `favicon.swift` (the monogram → the icon set), `alpha.swift` (measure, don't eyeball); recipes in `tools/README.md` |

## Editing
Edit, commit, `git push origin main`. The CDN serves the new file within one to three minutes;
verify with a cache-busting query (`?v=…`) and a cache-free renderer, never a browser that may
hold the old favicon or image.

## What the pages may claim
The privacy page is bounded by the game's code (the `emoemu` repo), not by intent:
- saves, settings and the diagnostics log stay on the phone; the App Store build has NO log
  export (the export row is compiled only into Debug/Tester builds);
- the profile syncs through the player's own iCloud key-value store (not CloudKit);
- Game Center and purchases go through Apple;
- ads are Google AdMob, non-personalized, with no App Tracking Transparency prompt — the
  consent prompt appears where the law asks; Emo Emu Plus removes ads;
- no accounts, no selling of data, nothing knowingly from under-13s (the game is 13+).
Any change in what the app collects or sends changes this page in the same batch.

## House rules
No third-party asset ships without its license beside it (Michroma — OFL). No emoji in copy.
Plain voice: short sentences, say what happens, no apologies, no marketing fog. The game's legal
rule applies here too: no references to other companies' games or trademarks.
