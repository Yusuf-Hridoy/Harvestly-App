# Harvestly - rules for AI agents

## What this app is
Harvestly is a Flutter farm manager app for Android. It exists to practice mobile test automation with Appium + Python. Tests live in a separate repo.

## Test IDs (most important rule)
- Every element a user can tap, type into, toggle, or read in a test gets a Semantics identifier.
- Use the TestId wrapper in lib/shared/testing/test_id_wrapper.dart. Never write a raw identifier string inside a screen.
- All IDs are constants in lib/shared/testing/test_ids.dart.
- Every new or renamed ID is added to test_ids.md in the same change.
- Naming: <screen>_<element>_<type>, lowercase snake_case, unique across the whole app. Example: login_submit_button.
- Never rename or remove an existing ID unless the task says so. Tests depend on them.

## Look
- All colors come from lib/app/app_colors.dart. No hex colors anywhere else.
- Fonts: Space Grotesk for titles and big numbers, Inter for everything else. Both are bundled in assets/fonts.
- Every screen must work in light and dark mode.

## Text
- Plain, short, everyday English in all user-facing text. No hard words.
- No real company names. Use the sample data in lib/data only.

## Code
- Keep it simple and standard: go_router, provider, shared_preferences. Ask before adding any other package.
- File names must say what the file does.
- No backend, no network calls.
- Before saying a task is done: flutter analyze shows no issues, flutter test passes, and the app runs on the emulator.
