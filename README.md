# 🌱 Sprout

A gentle self-care app. Finish small quests, earn seeds, and grow a garden of
big, permanent plants. Everything stays on your phone: no accounts, no
tracking, no internet needed.

## Download and install (Android)

**Get the APK**

1. On your phone, open the repository on GitHub and tap **Releases** (on the
   main page, or add `/releases` to the URL).
2. Open **Sprout (latest)**. For the newest test build, open
   **Sprout (dev preview)** instead.
3. Under **Assets**, tap **sprout.apk** to download it.

Another way: **Actions** tab → **Build APK** → the newest green run → **Artifacts** →
**sprout-apk**. This gives you a .zip with the APK inside, and you need to be
signed in to GitHub.

**Install it**

1. Open the downloaded `sprout.apk`, from the browser's downloads or the Files app.
2. If Android says installing from this source isn't allowed, tap **Settings**,
   turn on **Allow from this source**, then go back and tap **Install**.
3. **Play Protect** may warn that the app is from an unknown developer or hasn't
   been scanned. That's normal for an app you build yourself, because it isn't
   from the Play Store. Tap **More details → Install anyway**. Sprout has no
   internet permission and sends nothing anywhere.

**Updating:** install the new APK over the old one. Your garden is kept.

### One-time setup: the signing key

Android only installs an update over an existing app if both are signed with
the same key. The build reads that key from four repository secrets. Add them
once in **Settings → Secrets and variables → Actions → New repository secret**:

| Name | Value |
| --- | --- |
| `SPROUT_KEYSTORE_BASE64` | the long base64 text you were given |
| `SPROUT_KEYSTORE_PASSWORD` | the password you were given |
| `SPROUT_KEY_ALIAS` | `sprout` |
| `SPROUT_KEY_PASSWORD` | the same password |

Without the secrets the build still works, but it uses a temporary key. You'd
then have to uninstall before each update, which deletes your garden.

## Tweaking the game

All game rules live in one file:
[`assets/config/game_config.yaml`](assets/config/game_config.yaml). It covers
seeds per quest, the daily limit, rarity odds, plant growth times, fruit
prices, plot prices, visitors, cosmetics and recipes. Each setting has a
comment. Edit it on GitHub and the next build uses the new values. A check
runs on every build and stops it if the file has a mistake.

## How it's built

- Flutter, Android only for now. The code is platform-neutral, so other
  platforms can be added later.
- State management: **Riverpod**. Providers can be swapped out in tests (a fake
  clock, an in-memory database) without needing a `BuildContext`.
- Storage: **drift** (SQLite), local only.
- Game logic (`lib/domain`) is plain Dart, kept separate from the UI
  (`lib/features`, `lib/ui`), so it's easy to test.
- All art sits behind an art provider, so real illustrations can replace the
  drawn placeholders later.

```
lib/
  config/     game config model and loader
  core/       clock, providers, haptics, small helpers
  domain/     models and game rules (pure Dart)
  data/       database, repositories
  features/   screens: onboarding, home, today, journal, shop, settings
  ui/         theme, shared widgets, art
assets/       game_config.yaml, fonts
test/         domain, data and widget tests
```

## What each stage added

- **Stage 1: foundations.** Project setup. A GitHub Actions workflow that
  analyses, tests and builds a signed release APK, then publishes it to
  Releases. The bottom navigation, light and dark themes, five accent colours
  and the bundled Nunito font. A local SQLite database for settings. The
  validated game config. A five-step onboarding (welcome, name, focus areas,
  reminders, first seed) where every step can be skipped. A first drawn
  Meadow scene whose sky follows the time of day. Settings for theme, accent,
  reduced motion, sound and reminder preferences. An About page with a
  not-medical-advice note.
- **Stage 2: quests.** A library of 41 premade quests in 7 categories, added
  with one tap, plus your own custom quests (title, category, notes, size,
  and repeat: once, daily or chosen weekdays). Quests can be edited,
  archived and deleted (deleting asks first, and history is kept). A
  "My quests" screen chooses what shows on Today. The Today screen has
  rounded quest cards: tap the circle to complete one (with confetti and a
  soft haptic), swipe to skip today, save for later, or edit. Done quests
  fold into a "Done today" section. You can undo a completion for 10
  seconds. The Seed Meter fills one dot per quest, and every 3 earns a seed
  with a "You earned a seed!" reveal. The seed's family comes from your
  quest categories and its rarity from their sizes. Up to 9 completions a
  day fill the meter; anything beyond that still counts as done. Undo rolls
  the meter back, and takes the seed back too if that quest had just earned
  one. Onboarding now adds starter quests for your focus areas.
