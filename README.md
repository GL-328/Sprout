# 🌱 Sprout

A gentle self-care app. Finish small quests, earn seeds, and grow a garden of
big, permanent plants. Everything stays on your phone: no accounts, no
tracking. The only network use is a daily check for app updates, which you
can turn off.

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
   from the Play Store. Tap **More details → Install anyway**. Sprout sends
   none of your data anywhere.

**Updating from inside the app.** Once a day, Sprout checks the
**Sprout (latest)** release. If there's a newer build, it downloads it
quietly and then asks whether to install it. Android asks you to confirm every
install, so you'll see an **Update this app?** screen: tap **Update**. Sprout
closes while it updates, and your garden is kept. If a phone (some Samsungs)
throws the update away after you tap Install, Sprout opens Android's own
installer screen with the same file once, and the card shows Android's reason
if it still doesn't finish. Open Sprout again and you'll see
"Sprout is updated to build N".

You can also update by hand under **Settings → Updates → Check for updates now**.
The card there shows each step: checking, downloading, verifying, waiting for
you, installing, and done. If something goes wrong it says what happened (for
example "Install permission is off" or "Download failed, try again") and what
to do next. If the normal way doesn't work, **Open in Android's installer**
hands the same verified file to Android's own installer screen.

### Releases and build numbers

- Every push to `main` or a `claude/**` branch runs **Build APK**. The build
  number (Android `versionCode`) is the GitHub Actions run number, so it goes
  up by at least one with every build.
- The build checks that the number inside the APK equals the run number, and
  writes `version.json` next to the APK with that same number, the APK's
  size and its SHA-256 checksum. The app compares its own build number with
  `version.json`, downloads `sprout.apk`, and refuses the file unless the size
  and checksum both match.
- `main` publishes **Sprout (latest)** (tag `latest`), which the app follows.
  Other branches publish **Sprout (dev preview)** (tag `dev-latest`). Each new
  build replaces the previous one.
- Every release is signed with the same key, from the secrets below. A build
  without them is still uploaded as a workflow artifact, but never published
  as a release, because it couldn't update an installed copy.
- Settings → Updates shows the installed build, e.g. "Version 0.1.0 (build 15)".

**Testing an update end to end:** install build N by hand from the Releases
page. Push any commit and wait for the green **Build APK** run that publishes
build N+1. In the app, tap **Settings → Updates → Check for updates now**, then
**Update**, then **Update** on Android's screen. Reopen Sprout: it should say
"Sprout is updated to build N+1", and Settings should show build N+1.

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

Without the secrets the build still works, but it uses a temporary key and
isn't published as a release.

Keep a backup of the keystore and password somewhere safe outside GitHub (a
password manager works well). Secrets can't be read back once saved, and a
lost key means every phone has to uninstall once to switch to a new one.

## Friends (optional)

Friends lets you add friends with a code and visit each other's gardens. It is
**off by default** and only works in builds made with a Firebase project.

**What is shared when Friends is on:** your display name, your friend code,
who your friends are, once-a-day "visited you" notes, and a picture of your
garden (your plots, what grows in each spot and how far along it is, and your
decorations). **Never shared:** quests, moods, notes, helpful contacts or any
history. Turning Friends off in Settings deletes what was shared.

**Setting it up (free Firebase Spark plan):**

1. At console.firebase.google.com, create a project. Analytics can stay off.
2. **Build → Authentication → Sign-in method**: turn on **Anonymous**.
3. **Build → Firestore Database → Create database**, in production mode, in a
   region near you.
4. **Firestore → Rules**: paste the contents of `firestore.rules` from this
   repository and tap **Publish**.
5. **Project settings → Your apps → Add app → Android**, package name
   `app.sprout.sprout`. Download `google-services.json`.
6. In this GitHub repository: **Settings → Secrets and variables → Actions →
   New repository secret**, name `GOOGLE_SERVICES_JSON`, value: the whole
   contents of that file.

The next build switches Friends on. Without the secret, builds still work and
Friends simply says it isn't set up. The security rules are tested against the
Firestore emulator in `firestore-tests/` (`npm install && npm test`).

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
- **Stage 3: the garden.** The Home screen shows your plot as a drawn scene:
  the sky follows the time of day, ambient details suit the environment, and
  plants sway gently. The top bar has coins, a fruit basket, the Seed Meter
  and the Seed Bag. Tap an empty spot to choose a seed from your bag (seeds
  that don't fit show a gentle "This one would love a Forest plot" hint).
  Plants grow in real time through seed, sprout, young, mature and fruiting,
  even while the app is closed. Common plants take a few hours, rare ones a
  day or more. Mature plants are permanent and fruit again and again.
  Harvests wait for you (up to 3) and nothing ever wilts. Tap a ready plant
  to harvest it, and the fruit flies into your basket. Tap a growing plant
  to see its stage and time left, or to move it on into a keepsake (asks
  first). The first seed from onboarding is planted in the Meadow. All plant
  art is drawn with CustomPainter behind an art provider keyed by species
  and growth stage, so real illustrations can be swapped in later.
- **Stage 4: economy.** Coins come from selling fruit (each species has its own
  price), with coins flying to your counter. All 7 environments (Meadow,
  Forest, Orchard, Pond, Desert, Tropical, Alpine) and their 28 plants
  (4 native to each) are in. Swipe between plots on Home: locked ones appear
  as silhouettes showing their price and what grows there, with an unlock
  button. Each plot has its own look, its own 3 spots, and seasons that turn
  slowly from the day you unlock it (spring blossom, autumn leaves, winter
  snow). The Shop has plots, sell and compost, recipes, decorations and
  mystery seeds. Recipes turn fruit into coins, a growth boost for every
  plant, or a lure that brings more visitors. Decorations (paths, fences,
  ponds, benches, lanterns, sky themes) can be placed in each plot. Mystery
  seed packs are a deliberately worse deal than quests. Garden visitors
  (butterflies, bees, birds, frogs at the pond, fireflies in the forest, and
  more) appear when a plot is thriving or you're on a streak. Tap one to
  share its favourite fruit for a small thank-you gift.
- **Stage 5: mood, journal, reminders and data.** A daily check-in on Today
  (5 faces plus an optional note) that changes the garden's weather: soft rain
  on hard days, sunshine and a rainbow on great ones. A gentle streak counts
  "days of caring for yourself", and a **Rest day** switch keeps it going.
  The Journal has a mood calendar, quest history by day, the plant collection
  (with keepsakes of plants you moved on from), discovered visitors, and
  achievements (quests, seeds, fruit, coins and more). A support card holds
  the not-medical-advice note and your own **helpful contacts** list. Gentle
  reminders use local notifications and are off by default: a daily check-in
  nudge at the time you choose, plus optional per-quest reminders (daily or on
  chosen weekdays), with no guilt-trip wording. Settings can export
  everything to a JSON file, import it again, and delete all data (two
  confirmations, the second asking you to type DELETE). Bottom sheets now open
  above the navigation bar.
- **Stage 6: polish.**
  - **Sound:** soft sound effects for completing quests, earning seeds,
    planting, harvesting and coins, plus a gentle garden ambience (wind and
    distant birds) while the garden is on screen. All off by default; switch
    them on under Settings → Sounds. The sounds are generated by
    `tool/generate_sounds.py`, so they're original and free to use.
  - **Visuals and motion:** a Sprout launcher icon. Bigger, layered plants
    that fill the garden. Quest cards fade in and the coin counter rolls up.
    Everything respects Reduce motion.
  - **Fixes:** invisible chip labels and extra space under grids.
  - **Tests:** more unit tests for quests, scheduling, the Seed Meter, the
    seed roller, growth and harvesting, the economy, reminders and
    backup/restore, plus widget tests for every tab.
    `flutter test test/screenshots --run-skipped --update-goldens` renders
    the main screens to PNGs for a visual check.
- **Automatic updates.** Once a day, and on demand from Settings → Updates,
  Sprout checks the latest release's `version.json`. If there's a newer
  build, it downloads `sprout.apk`, checks its SHA-256, and installs it through
  Android's package installer, falling back to Android's installer screen once
  if the first try is thrown away. This
  adds the internet permission, used only for this check, and it can be
  switched off.
- **Redesign: calmer, more like Finch.**
  - **Home:** just coins and one Bag button (seeds and fruit tabs) at the top,
    and a short greeting with a tappable plot name for switching plots. One
    large plant at a time sits centred, with its neighbours peeking in from
    the sides, arrows, swipes and three small dots. The plant "talks" in a
    little bubble. Empty spots pulse "Plant a seed", and ripe plants glow
    "Tap to harvest". Below sits a draggable **Today's quests** panel with the
    Seed Meter as a slim bar and today's quests. Tap a circle to complete one,
    with undo and the seed reveal as before. A smaller sun or moon, far fewer
    particles, and three skippable first-run tips.
  - **Today:** the date, one slim Seed Meter card, a small mood check-in that
    disappears once done, and spacious quest rows (check circle, title, tiny
    category icon, faint size dots). Edit, skip, later and delete moved into
    a long-press or "⋯" menu. "Done today" is collapsed. The "+" button
    offers make a quest, browse ideas, or **All quests**.
  - **Shop:** Ben the shopkeeper stands at his striped market stall. He
    blinks, his hair sways, and he has a fun fact of the day. Tap him for a
    greeting, tip or kind word, and he reacts warmly when you buy, sell or
    compost. His lines live in one file, `assets/content/ben_lines.json`,
    generated from `tool/ben_lines_source.py`. Below him, four big tiles
    (Plots, Sell, Recipes, Decor) lead to a two-column grid of soft cards,
    each opening a sheet with one clear button. Items you can't afford yet
    are gently faded.
  - **Also:** one consistent rounded icon set for quest categories, used on
    quest rows and in a new tile-style interest picker in onboarding.
    Better screen-reader labels and tap actions.
  - Game rules, config values and saved data are unchanged.
