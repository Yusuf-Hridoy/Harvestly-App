# Harvestly

Harvestly is a small farm manager app for Android: fields, crops, flocks and
herds, eggs and milk, tasks with real Android reminders, and money. It is a
practice app for mobile test automation with Appium, not a real product.
Every element a test needs has a stable test ID.

## Screenshots

| Screen | Light | Dark |
| --- | --- | --- |
| Login | ![Login, light](docs/screenshots/login-light.png) | ![Login, dark](docs/screenshots/login-dark.png) |
| Home, farmer account | ![Home, light](docs/screenshots/home-farmer-light.png) | ![Home, dark](docs/screenshots/home-farmer-dark.png) |
| Home, new account | ![Empty home, light](docs/screenshots/home-new-light.png) | ![Empty home, dark](docs/screenshots/home-new-dark.png) |
| More (Settings) | ![Settings, light](docs/screenshots/settings-light.png) | ![Settings, dark](docs/screenshots/settings-dark.png) |
| Fields list | ![Fields, light](docs/screenshots/fields-list-light.png) | ![Fields, dark](docs/screenshots/fields-list-dark.png) |
| Field form with errors | ![Field form, light](docs/screenshots/field-form-errors-light.png) | ![Field form, dark](docs/screenshots/field-form-errors-dark.png) |
| Field detail | ![Field detail, light](docs/screenshots/field-detail-light.png) | ![Field detail, dark](docs/screenshots/field-detail-dark.png) |
| Add crop | ![Add crop, light](docs/screenshots/add-crop-light.png) | ![Add crop, dark](docs/screenshots/add-crop-dark.png) |
| Crop detail | ![Crop detail, light](docs/screenshots/crop-detail-light.png) | ![Crop detail, dark](docs/screenshots/crop-detail-dark.png) |
| Harvest dialog | ![Harvest dialog, light](docs/screenshots/harvest-dialog-light.png) | ![Harvest dialog, dark](docs/screenshots/harvest-dialog-dark.png) |
| Animals list | ![Animals list, light](docs/screenshots/animals-list-light.png) | ![Animals list, dark](docs/screenshots/animals-list-dark.png) |
| Group form with errors | ![Group form with errors, light](docs/screenshots/group-form-light.png) | ![Group form with errors, dark](docs/screenshots/group-form-dark.png) |
| Eggs tab | ![Eggs tab, light](docs/screenshots/eggs-tab-light.png) | ![Eggs tab, dark](docs/screenshots/eggs-tab-dark.png) |
| Hatching tab | ![Hatching tab, light](docs/screenshots/hatching-tab-light.png) | ![Hatching tab, dark](docs/screenshots/hatching-tab-dark.png) |
| Health tab | ![Health tab, light](docs/screenshots/health-tab-light.png) | ![Health tab, dark](docs/screenshots/health-tab-dark.png) |
| Milk tab | ![Milk tab, light](docs/screenshots/milk-tab-light.png) | ![Milk tab, dark](docs/screenshots/milk-tab-dark.png) |
| Breeding tab | ![Breeding tab, light](docs/screenshots/breeding-tab-light.png) | ![Breeding tab, dark](docs/screenshots/breeding-tab-dark.png) |
| Tasks list | ![Tasks list, light](docs/screenshots/tasks-list-light.png) | ![Tasks list, dark](docs/screenshots/tasks-list-dark.png) |
| Task form | ![Task form, light](docs/screenshots/task-form-light.png) | ![Task form, dark](docs/screenshots/task-form-dark.png) |
| Task detail | ![Task detail, light](docs/screenshots/task-detail-light.png) | ![Task detail, dark](docs/screenshots/task-detail-dark.png) |
| Reminder explainer | ![Reminder explainer, light](docs/screenshots/reminder-explainer-light.png) | ![Reminder explainer, dark](docs/screenshots/reminder-explainer-dark.png) |
| Settings, notifications | ![Settings notifications, light](docs/screenshots/settings-notifications-light.png) | ![Settings notifications, dark](docs/screenshots/settings-notifications-dark.png) |
| A reminder in the shade | ![Reminder in the shade](docs/screenshots/notification-shade.png) | |

## Download the app

The newest APK is always at this link:

```
https://github.com/Yusuf-Hridoy/Harvestly-App/releases/latest/download/harvestly.apk
```

Every push to `main` builds a fresh APK and publishes it as a release, so the
link never changes. The repository is public, so the test repo can download it
without a token.

## Demo accounts

There is no server. These three accounts are built into the app. The password
for all of them is `Farm@123`. The email ignores upper and lower case and spaces
at the start or end. The password is case-sensitive.

| Email | Name | Note | Home shows |
| --- | --- | --- | --- |
| `farmer@harvestly.test` | Rahim Uddin | Full farm with sample data | Full home |
| `poultry@harvestly.test` | Nadia Akter | Hens only, no fields | Home without the harvest card |
| `new@harvestly.test` | Sam Hossain | Empty farm, first-time setup | Empty farm card |

## Fields and crops

The Fields tab holds the real data. A field has a name, a size in acres, a
soil type, an optional note and a drawn shape. A crop belongs to one field and
has a type from a list of 40, a planting date and a number of plants.

- The list can be searched by name, filtered by All, Growing, Empty or
  Harvest soon, and sorted by name, size or harvest date. A long press on a
  card offers Edit field and Delete field.
- Field detail draws the field as a four-corner shape on a grid. Drag a corner
  to move it, pinch to zoom from 1.0x to 3.0x, and the area line updates while
  you drag. The drawing is only a picture; it never changes the size you typed
  in the form.
- A crop shows its stage (Seedling, Growing, Flowering, Ready to harvest), how
  far along it is, and how many days are left. Mark as harvested asks for the
  amount in kilograms and moves the crop to Past harvests. There is no editing
  a crop yet: delete it and add it again.
- Everything is saved on the phone, one record per account, so it survives
  closing the app. There is still no backend and no network call.

## Animals

The Animals tab holds flocks and herds. A flock of hens, ducks or quail tracks
eggs, hatching and health. A herd of goats or cows tracks milk, breeding and
health. One screen serves both: only the three tabs change.

- The list can be searched by name and filtered by All, Birds, Goats or Cows,
  with live counts. A long press on a card offers Edit group and Delete group.
  The animal type is fixed once a group is made.
- **Eggs and Milk** keep one amount per day. Tap − or + to move by 1 egg or
  0.5 litres, long press for 10 or 5, or tap the big number to type an amount.
  The chart shows the last 7 or 30 days; tap a bar to read that day, and use
  Edit a past day to fix one you missed.
- **Hatching** counts a batch of eggs from day 1 to hatch day (21 days for
  hens, 28 for ducks, 17 for quail) with a timeline of set eggs, candling,
  stop turning and hatch day. Record result moves it to Past batches with its
  hatch rate.
- **Breeding** counts a pregnancy to its due date (150 days for goats, 283 for
  cows) with a timeline of mated, check, dry off and due. Record birth moves
  it to Past births.
- **Health** shows how many animals are left, the open tasks in the order they
  need doing (late first, then due today, then coming up), and a history of
  done tasks and losses. Record loss takes animals off the count.
- Home adds up today's eggs across every flock and shows the one health task
  that needs attention most.

## Tasks and reminders

The Tasks tab holds the real jobs on the farm, in four groups: Overdue,
Today, Upcoming, and a Done list that is folded away until you tap it. Chips
narrow the list to the tasks on a field, on an animal group, or on neither.

A task has a due date and time, an optional note, a repeat of daily, weekly
or monthly, and a reminder at the due time, an hour before or a day before.
Finishing a repeating task makes the next one straight away, keeping the same
day of the month where that fits. A checkbox or a swipe to the right finishes
a task, and Undo takes it back for a few seconds.

Reminders are real Android notifications. The first time you save a task with
one, Harvestly explains why before Android asks, and the task is kept
whatever you answer. A reminder carries two buttons, **Mark done** and
**Snooze 1 hour**, and both work with the app closed. Reminders are
deliberately inexact, so Harvestly needs no alarm permission and a reminder
may arrive a few minutes late. They survive a restart.

Settings has a Notifications part that reads Android's real answer, with a
way into Android's own page when they are off, and a test notification that
arrives 10 seconds later.

## Deep links

A link that starts with `harvestly://app/` opens a screen from outside the
app, which is how a notification, `adb` or an Appium test can jump straight
to one:

```
adb shell am start -W -a android.intent.action.VIEW \
  -d "harvestly://app/tasks/task-4" com.harvestly.app
```

Home, the Fields and Animals lists, one field, one group with a tab, the
Tasks list and one task all have a link. Anything else opens Home and says
the link does not work. Logged out, the link waits at the login screen and
opens once you are in. The full list is in
[test_ids.md](test_ids.md#deep-links).

## Safe upgrades

Saved data carries a version number. When the app meets data from an older
version it upgrades it in place, keeping everything the user had. If it meets
data it cannot read at all, it copies that data to a backup key and starts the
account from the sample, so a bad save can never show an empty farm.

The upgrade from Phase 2 to Phase 3 was run on a real emulator and written up
in [docs/upgrade-test.md](docs/upgrade-test.md).

## Run it yourself

Built and tested with **Flutter 3.50.1 (stable), Dart 3.14.0**.

On Windows:

1. Install Flutter. Follow the steps at <https://docs.flutter.dev/get-started/install/windows>
   and add `flutter\bin` to your PATH.
2. Install Android Studio, then open **Settings > Languages & Frameworks >
   Android SDK > SDK Tools** and install the Android SDK, the platform tools and
   the NDK. If a build says the NDK is missing, install exactly version
   `28.2.13676358`.
3. Run `flutter doctor` and fix anything it reports. Accept the Android licences
   with `flutter doctor --android-licenses`.
4. Start an Android emulator from Android Studio's Device Manager, or plug in a
   phone with USB debugging on. Minimum Android version is 7.0 (API 24).
5. In this folder, run `flutter pub get`.
6. Run `flutter run`.

To build the APK yourself: `flutter build apk --release`. The file lands in
`build/app/outputs/flutter-apk/app-release.apk`. Without a release key that
APK is signed with the debug key and is fine for trying the app out, but it
cannot be installed over a published release. See **Signing** below.

## Signing

For maintainers. Every published release must be signed with the same key, or
Android will not let people update: it refuses an APK whose signer differs
from the one already on the phone.

Release builds take the key from `android/key.properties` if that file is
there:

```
storeFile=C:/keys/harvestly-release.jks
storePassword=...
keyAlias=harvestly
keyPassword=...
```

Otherwise they take it from the environment variables
`HARVESTLY_KEYSTORE_PATH`, `HARVESTLY_KEYSTORE_PASSWORD`,
`HARVESTLY_KEY_ALIAS` and `HARVESTLY_KEY_PASSWORD`. Use an absolute path for
the keystore. With neither, the build falls back to the debug key and prints a
warning starting with `Harvestly signing:`.

The keystore, `key.properties` and any `*.jks` or `*.keystore` file are
git-ignored. Keep the keystore and its passwords outside the repository and
back them up somewhere safe: lose the key and the app can never be updated
again, only installed fresh.

### Setting it up once

1. Make the key:

   ```
   keytool -genkeypair -v -keystore harvestly-release.jks -storetype JKS      -keyalg RSA -keysize 2048 -validity 10000 -alias harvestly
   ```

2. Add the four GitHub Actions secrets the release workflow reads:
   `HARVESTLY_KEYSTORE_BASE64` (the `.jks` file base64-encoded),
   `HARVESTLY_KEYSTORE_PASSWORD`, `HARVESTLY_KEY_ALIAS` and
   `HARVESTLY_KEY_PASSWORD`. In PowerShell, copy the encoded keystore to the
   clipboard with:

   ```
   [Convert]::ToBase64String([IO.File]::ReadAllBytes("C:\dev\keys\harvestly-release.jks")) | Set-Clipboard
   ```

   and paste that straight into the secret. The workflow strips spaces, tabs
   and line endings before decoding, so the line breaks a clipboard paste adds
   are safe. If the secret still will not decode, the build stops and says so.

3. The workflow decodes the keystore into the runner's temp folder, builds
   with it, and deletes it afterwards. The job **fails before building** if
   `HARVESTLY_KEYSTORE_BASE64` is not set, so an unsigned release can never be
   published by mistake. It also checks that the keystore opens with the
   password and holds the alias, and stops with a clear message if either of
   those secrets is wrong.

To check which key an APK carries:

```
apksigner verify --print-certs build/app/outputs/flutter-apk/app-release.apk
```

The `SHA-256 digest` it prints must be the same for every release.

## For testers

Test IDs are Flutter `Semantics` identifiers. On Android they show up as the
element's `resource-id`. The full list, with the screen and element each one
belongs to, is in [test_ids.md](test_ids.md).

In Appium, set the capability `appium:disableIdLocatorAutocompletion` to `true`,
then find elements with `AppiumBy.ID`:

```python
driver.find_element(AppiumBy.ID, "login_submit_button").click()
```

Things worth knowing before you write tests:

- Tapping **Log in** waits 800 ms on purpose before the result. `login_loading_indicator`
  is in the tree during that wait. Pull to refresh on Home waits 800 ms too.
- `login_email_error_text`, `login_password_error_text` and `login_error_banner`
  are only in the tree while they are on screen.
- `app_snackbar_text` closes itself after 3 seconds.
- `home_harvest_progress_bar` sits below the fold; scroll down before looking
  for it.
- Ticked tasks live in memory only and reset when the app restarts. Fields and
  crops are saved and do survive a restart.
- **Reset demo data** on the More tab puts one account's fields and crops back
  to the starting sample. Use it between test runs instead of reinstalling. It
  leaves the other accounts, the theme and the login alone.
- Every planting date in the sample is counted back from today, so the
  days-left numbers are the same on every run.
- The crop list in Add crop is long and only the rows on screen are in the UI
  tree. Search for the crop first, then tap it.
- A **long press** on + or − in Eggs or Milk is the only way to move by 10
  eggs or 5 litres. A tap moves by 1 or 0.5.
- The 30-day chart scrolls sideways and opens at today, so the oldest bars are
  not in the UI tree until you scroll it.
- `home_animal_health_card` sits low on Home. Scroll down before looking for
  the text inside it, or Android hands back a clipped card with no children.
- Every tab of a group keeps its own scroll position, and the URL follows the
  tab, so `/animals/<id>?tab=health` opens straight on Health.
- **Reset demo data** now puts the animal groups back as well as the fields.

Saved UI tree dumps for each screen are in `docs/ui-dumps/`.

## Project structure

```
lib/
  main.dart                  app start: loads saved settings, runs the app
  app/                       MaterialApp, router, colors, themes
  data/                      the 3 demo accounts, the crop catalog, the animal
                             and task rules, the saved farm data with its
                             version and migration, and the starting sample
  notifications/             the reminder service, the Mark done and Snooze
                             handlers, and the bridge to Android's settings
  features/
    login/                   login screen and its controller
    fields/                  the Fields tab, the field form, field detail and
                             the drawn map
    crops/                   add a crop, crop detail and the harvest dialog
    animals/                 the Animals tab, the group form, group detail and
                             its Eggs, Milk, Hatching, Breeding and Health tabs
    tasks/                   the Tasks tab, the task form, task detail, the
                             link picker and the reminder explainer
    shell/                   the bottom tab bar around the 5 tabs
    home/                    home screen and its cards
    settings/                the More tab, the theme choice and notifications
  shared/
    session/                 remember me and the logged-in account
    logic/                   today's date, date text, crop growth and field
                             area maths
    testing/                 the TestId wrapper and every test ID
    widgets/                 the shared snackbar, confirm dialog, discard
                             guard, stage chip and missing item screen
    app_info/                reads the app version from the build
assets/fonts/                Inter and Space Grotesk, with their licences
test/                        widget tests
docs/screenshots/            the screenshots above
docs/ui-dumps/               Android UI tree dumps, one per screen
docs/upgrade-test.md         how each upgrade was checked on a real phone
android/app/src/main/kotlin/ MainActivity and its small settings channel
```

## Roadmap

- Phase 1 - Foundation (done)
- Phase 2 - Fields and crops (done)
- Phase 3 - Animals and poultry (done)
- Phase 4 - Tasks and reminders (done)
- Phase 5 - Camera and diary
- Phase 6 - Money, weather and offline
- Phase 7 - Testing gym
