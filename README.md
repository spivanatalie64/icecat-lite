# icecat-lite

A stripped-down, minimal distribution of [GNU IceCat](https://www.gnu.org/software/gnuzilla/) —
the fully free-software browser based on Mozilla Firefox ESR — trimmed for
[AcreetIONOS](https://acreetionos.org).

Based on upstream gnuzilla `makeicecat` (Firefox ESR 140.14.0esr / IceCat 140.14.0-1).

## What was stripped from upstream gnuzilla

| Removed | Reason |
|---|---|
| All non-en-US locales (`fetch_l10n`, `compare-locales` clone) | en-US ships in-tree; l10n git fetch was the heaviest network step (~hundreds of MB) |
| Mobile support (`icecatmobile` branding, `android-images`, Fennec seds) | already disabled upstream; dead weight |
| Windows/macOS packaging art (`.bmp`, `.icns`, NSIS, `dsstore`) | ~3.5 MB of installer-only assets; GNU/Linux target only |
| `prepare_macos_packaging`, `configure_onboarding` | dead code paths |
| `data/vendor.js` | never referenced by any upstream script (dead file) |
| `data/{abouthome,adblock_artwork,searchplugins,onboarding,newtab-partial}` | unreferenced by upstream build |
| Release tooling (`AddonsScraper.py`, `gnupload`, `createdebsrcrepo`, `buildbinaries`) | GNU release-infrastructure specific |
| 6 of 8 bundled extensions | see below |

Repo size: **~12 MB → <1.5 MB**.

## Heavy components → light replacements

| Upstream component | Size | Replacement in lite |
|---|---|---|
| Searxes Third-party Request Blocker (`tprb.addon@searxes...`) | 444 KB, queries a remote filtering API | **`lite-request-blocker`** (built here): Manifest V3 `declarativeNetRequest`, one static ruleset, zero JavaScript, zero network access |
| JShelter (`jsr@javascriptrestrictor`) | 1.8 MB | Native `privacy.resistFingerprinting` + tracking protection (already enabled in `data/settings.js`) |
| Privacy Redirect, SubmitMe, LibrifyJS, FreeUSPS, gnuzilla-ext-workarounds | ~900 KB combined | Dropped (site-specific conveniences; install manually if wanted) |
| GnuPG keyserver round-trip during build | required gpg + network | sha256 always; GPG opt-in via `./makeicecat --gpg` |

Kept: **GNU LibreJS** (core to IceCat's free-JS enforcement) and all privacy patches/prefs.

## Build

```sh
./makeicecat            # produces output/icecat-lite-<version>.tar.bz2 source tree
# then, from the unpacked tree:
cd icecat-140.14.0
../buildscripts/build-gnulinux.sh   # or follow data/README.IceCat
```

Requirements: `git`, `wget`, `python3`, `python3-jsonschema` (+ `gpg` only with `--gpg`).
Building Firefox itself needs the usual toolchain (`build-dep firefox`, cbindgen, clang).

Note: langpacks are not supported in lite (`--with-l10n-base` removed from mozconfig).

## License

Same as upstream GNU IceCat: GPL-2.0-or-later (see `COPYING`). Branding assets are
LGPL-3+ per FSF (see `data/branding/icecat/LICENSE`). The `lite-request-blocker`
extension is GPL-2.0-or-later.
