# Sprout: notes for Claude

A Finch-like self-care app: finish quests, earn seeds, grow a garden. Flutter, Android only, portrait, local-first.
The owner is GL-328 (repo GL-328/Sprout, renamed from GL328). Read this first in every session.

## Toolchain and checks
- Flutter 3.47.7, `dart format -l 120`, `flutter analyze` must be clean, `flutter test` must pass (213 tests).
- Riverpod 3 (unlistened providers pause: don't await `.future` from a Notifier, read repositories directly), drift
  (in-memory DB in tests), game rules in `assets/config/game_config.yaml`.
- Visual checks: `test/visual/*` render PNGs to `build/visual/` (`loadAppFonts`, `setPhoneScreen`, `shot`,
  `savePng`). Always render and look at UI changes before calling them done.
- Style: the owner prefers no outlines and no 3D/lip styling (tried in build 33, reverted). Keep art flat and soft.
- AppBar titles need an explicit font size in the theme (the text theme has no sizes when the theme is built).
- Sound: `lib/core/sound_service.dart`. Effects are made by `tool/generate_sounds.py`, music (one seamless OGG
  loop per plot) by `tool/generate_music.py` (numpy + ffmpeg); Settings has separate Sounds and Music switches.
  Every button ticks via the global `TapSounds` listener (`lib/ui/widgets/tap_sounds.dart`, anything with
  `Semantics(button: true)`), so don't add tap sounds by hand.
- No emoji anywhere in the app: flat painted icons via `ArtIcon(id)` / `IconText` in `lib/ui/art/icon_art.dart`
  (guarded by `test/widget/no_emoji_test.dart`).

## Builds and updates
- `.github/workflows/build-apk.yml`: build number = Actions run number. `main` publishes the **latest** release;
  other branches publish **dev-latest** (prerelease). Each has `sprout.apk` + `version.json` (versionCode, sha256,
  size, notes). Check a build landed with
  `curl -sL https://github.com/GL-328/Sprout/releases/download/latest/version.json`.
- Releases need the signing secrets (`SPROUT_KEYSTORE_*`, `SPROUT_KEY_*`). Never commit keystores or passwords.
  Never ask the owner to paste secrets in chat.
- In-app updater: `lib/core/updater.dart` (follows `latest`), `lib/features/settings/update_controller.dart`, and
  Kotlin in `android/app/src/main/kotlin/app/sprout/sprout/` (PackageInstaller session, one confirm per session,
  falls back once to Android's installer screen, shows Android's reason on the card).
- Owner's phone is a Samsung. Build 24 fixed "Update was cancelled" there; confirmed working on the device.
- Commits are authored as `GL-328 <331449904+GL-328@users.noreply.github.com>` (the owner's GitHub private
  email blocks pushes that expose their real address).

## Developer mode (hidden)
- Settings → About Sprout → tap "Version …" 7 times → password (only its SHA-256 is in `lib/core/dev_mode.dart`;
  never write the password itself into the repo). Turning it on saves a full backup snapshot to a file, then
  unlocks every plot. "Reset and turn off" (card at the top of Settings) restores that snapshot exactly.

## Friends (built, off until Firebase is set up)
- Add friends by 8-letter code, accept/decline/block/remove, visit friends' gardens read-only, once-a-day visit
  reward (+3 coins) and "visited you" notes; a butterfly visits your garden on days a friend dropped by.
- Code: `lib/domain/logic/friends.dart`, `lib/features/friends/*`, `lib/core/firebase_setup.dart`,
  `firestore.rules` (tested in `firestore-tests/` on the emulator, 17 tests).
- Firebase config comes from the optional GitHub secret `GOOGLE_SERVICES_JSON` (CI turns it into
  `--dart-define`s). Without it the app builds and Friends says it isn't set up.
- **Next step:** guide the owner through Firebase setup one screen at a time (README "Friends (optional)"):
  project, Anonymous sign-in, Firestore, publish `firestore.rules`, Android app `app.sprout.sprout`, then they add
  the `GOOGLE_SERVICES_JSON` secret themselves.
- Later (not started): seed trading.

## Owner's rules
- Plan first and get an OK for big changes; commit, push and confirm the build after each step.
- Friends never shares quests, quest history, moods, notes, helpful contacts or personal data.
- Trading is seeds only: no coins, fruit or real money. No chat, free-text messages, comments or photos.
- The app must always build and run with Friends switched off.
- New users pick their own starting quests (zero by default). Home shows two quests plus "See all (N)".
