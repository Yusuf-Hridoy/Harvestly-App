# Upgrade test: Phase 2 to Phase 3

This checks that a real user who already had Harvestly keeps their fields and
crops when they update, and gets the new animal groups without doing anything.

Run it again whenever the saved data format changes.

## What is being checked

Phase 2 saved one key per account, `farm_data_<email>`, holding only fields:

```json
{ "fields": [ ... ] }
```

Phase 3 saves the same key with a version number and the animal groups:

```json
{ "schemaVersion": 2, "fields": [ ... ], "animals": [ ... ] }
```

Saved data with no `schemaVersion` is read as version 1. Its fields are kept
exactly as they are, the account's sample animals are added, and the whole
thing is written back as version 2 straight away. The rules live in
`lib/data/farm_storage.dart` and are covered by `test/farm_storage_test.dart`.

## Steps

1. Remove any older copy:

   ```
   adb uninstall com.harvestly.app
   ```

2. Install the Phase 2 APK (see the note on signing below):

   ```
   adb install harvestly-v0.2.0.apk
   ```

3. Open the app, tap **Use farmer**, turn **Remember me** on, and log in.
   Then go to **Fields**, add a field named `Upgrade check`, size `0.2`, soil
   `Loam`, and add one `Radish` crop to it. Close the app.

4. Install the new APK over the old one, **without uninstalling**:

   ```
   adb install -r build/app/outputs/flutter-apk/app-release.apk
   ```

5. Open the app. It must still be logged in, Fields must show the 4 sample
   fields plus `Upgrade check` with its Radish, and Animals must show the 4
   sample groups.

## Result: passed

Run on 24 Nov 2026, emulator `Harvestly` (Android 16, API 36),
Flutter 3.50.1.

| Step | What happened |
| --- | --- |
| 1 | `adb uninstall com.harvestly.app` → `Success` |
| 2 | Phase 2 installed. `dumpsys` reported `versionName=0.2.0`, `versionCode=2` |
| 3 | Logged in as the farmer with Remember me on (the dump shows the checkbox `checked="true"`). Added `Upgrade check`, 0.2 acre, Loam, with one Radish crop. Closed the app, reopened it: it went straight to Home and Fields read `5 fields`, so Phase 2 had saved both the session and the field |
| 4 | `adb install -r ...app-release.apk` → `Success`. `dumpsys` then reported `versionName=0.3.0`, `versionCode=3` |
| 5 | Opened the app: still logged in, straight to Home, and the new Animal health card was there |

What the dumps after the upgrade show:

- `docs/ui-dumps/upgrade_fields.xml` — `fields_count_text` is `5 fields`, with
  `Field 1 · North plot`, `Field 2 · South bed`, `Field 3 · Bean rows`,
  `Field 4 · Pond side` and, after a scroll, `Upgrade check` with the stage
  chip `Seedling`. Opening it shows `Upgrade check`, `0.2 acre · Loam` and the
  crop `Radish`, exactly as Phase 2 saved them.
- `docs/ui-dumps/upgrade_animals.xml` — the 4 sample groups the account could
  not have had before: `Flock A` (18 eggs today), `Duck pond` (4 eggs today),
  `Goat herd` (3.5 L milk today) and `Cow shed` (14.0 L milk today), with the
  chips `All 4`, `Birds 2`, `Goats 1`, `Cows 1`.

Nothing was lost, nothing had to be set up again, and no empty farm appeared.

## Note on signing, and which APK was used

The GitHub release APK could not be installed over, and the other way round
either:

```
INSTALL_FAILED_UPDATE_INCOMPATIBLE: Existing package com.harvestly.app
signatures do not match newer version; ignoring!
```

`android/app/build.gradle.kts` still signs release builds with the **debug**
key (`signingConfig = signingConfigs.getByName("debug")`, with the `TODO` from
`flutter create` above it). Every machine has its own debug keystore, so the
APK built by GitHub Actions and an APK built here are signed by different
keys, and Android refuses to treat one as an update of the other.

So the Phase 2 side of this test was built from the Phase 2 commit itself
(`63bb794`, `version: 0.2.0+2`) on this machine, which puts both APKs under
the same key. The saved data and the migration path are identical either way:
what Phase 2 writes does not depend on who signed it.

The release APK from
`https://github.com/Yusuf-Hridoy/Harvestly-App/releases/download/v0.2.0-build.2/harvestly.apk`
was downloaded first and is kept outside the repository. It was installed and
checked by hand as well, and it saves the same Phase 2 data.

For a real user this does not come up, because both the old and the new APK on
their phone come from the same release pipeline. It will stop being an issue
for us too once the app gets a proper release keystore.
