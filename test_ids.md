# Harvestly test IDs

Every ID below is a Flutter `Semantics(identifier: ...)` value, added with the
`TestId` wrapper in `lib/shared/testing/test_id_wrapper.dart`. The string values
live in `lib/shared/testing/test_ids.dart`.

On Android each ID shows up as the element's `resource-id`. In Appium, set
`appium:disableIdLocatorAutocompletion` to `true` and find elements with
`AppiumBy.ID`.

Naming: `<screen>_<element>_<type>`, lowercase snake_case, unique across the app.
IDs are never renamed or removed unless a task says so.

The "UI tree" column is what the ID looked like in the dumps in `docs/ui-dumps/`.

## Login

| ID | Screen | Element | UI tree | Notes |
| --- | --- | --- | --- | --- |
| `login_screen` | Login | Whole screen | `View` | Use it to check the user is on Login. |
| `login_email_input` | Login | Email field | `EditText`, clickable | Email keyboard. "Next" moves to the password. |
| `login_email_error_text` | Login | Email error | `View` with the text | Only in the tree while an email error shows. |
| `login_password_input` | Login | Password field | `EditText`, clickable | Hidden text. "Done" submits the form. |
| `login_password_error_text` | Login | Password error | `View` with the text | Only in the tree while a password error shows. |
| `login_password_toggle_button` | Login | Show / hide password | `Button`, clickable | Text reads "Show password" or "Hide password". |
| `login_remember_me_checkbox` | Login | Remember me | `CheckBox`, checkable | Off by default. |
| `login_forgot_password_link` | Login | Forgot password? | `Button`, clickable | Shows a snackbar. |
| `login_submit_button` | Login | Log in | `Button`, clickable | Not clickable while the 800 ms wait runs. While the spinner shows, this node is not merged, so it carries no text and no child button: wait for `login_loading_indicator` to disappear before you use it again. |
| `login_loading_indicator` | Login | Spinner in the button | `View` | Only in the tree during the 800 ms wait. |
| `login_error_banner` | Login | "Email or password is wrong." | `View` with the text | Only after a failed login. |
| `login_demo_use_farmer_button` | Login | Use, farmer row | `Button`, clickable | Fills the form. Does not log in. |
| `login_demo_use_poultry_button` | Login | Use, poultry row | `Button`, clickable | Fills the form. Does not log in. |
| `login_demo_use_new_button` | Login | Use, new account row | `Button`, clickable | Fills the form. Does not log in. |

## Bottom tab bar

| ID | Screen | Element | UI tree | Notes |
| --- | --- | --- | --- | --- |
| `tab_home_button` | All tabs | Home tab | `View`, clickable, text "Home" | |
| `tab_fields_button` | All tabs | Fields tab | `View`, clickable, text "Fields" | |
| `tab_animals_button` | All tabs | Animals tab | `View`, clickable, text "Animals" | |
| `tab_tasks_button` | All tabs | Tasks tab | `View`, clickable, text "Tasks" | |
| `tab_more_button` | All tabs | More tab | `View`, clickable, text "More" | |

## Home

| ID | Screen | Element | UI tree | Notes |
| --- | --- | --- | --- | --- |
| `home_screen` | Home | Whole screen | `View` | |
| `home_refresh_indicator` | Home | Pull to refresh | `View` | Wraps the scrolling list. Refresh waits 800 ms. |
| `home_date_text` | Home | Today's date | `View` with the text | For example "Tuesday, 24 November". |
| `home_greeting_text` | Home | Greeting | `View` with the text | "Good morning / afternoon / evening, <first name>". |
| `home_notifications_button` | Home | Bell | `Button`, clickable | Shows a snackbar. |
| `home_notifications_badge` | Home | Badge on the bell | `View` with the text "3" | |
| `home_weather_card` | Home | Weather card | `View` | Hidden for the empty account. |
| `home_weather_warning_text` | Home | Weather warning | `View` with the text | |
| `home_stat_fields_card` | Home | Fields stat | `View` | |
| `home_stat_crops_card` | Home | Crops growing stat | `View` | |
| `home_stat_eggs_card` | Home | Eggs today stat | `View` | |
| `home_stat_profit_card` | Home | Profit this month stat | `View` | |
| `home_tasks_card` | Home | Today's tasks card | `View` | |
| `home_tasks_see_all_link` | Home | See all | `Button`, clickable | Opens the Tasks tab. |
| `home_task_item_1` … `_n` | Home | One task row | `View` with the task text | Numbered from 1, in the order shown. |
| `home_task_checkbox_1` … `_n` | Home | Tick of that row | `CheckBox`, checkable | Ticks live in memory only in Phase 1. |
| `home_harvest_card` | Home | Harvest soon card | `View` | Hidden when the account has no crops. |
| `home_harvest_progress_bar` | Home | Harvest progress | `ProgressBar` | Only appears after scrolling. It sits below the fold, and Android drops off-screen nodes from the tree, so scroll down before you look for it. |

## Home, empty account

| ID | Screen | Element | UI tree | Notes |
| --- | --- | --- | --- | --- |
| `home_empty_farm_card` | Home | Welcome card | `View` | Only for `new@harvestly.test`. |
| `home_empty_add_field_button` | Home | Add your first field | `Button`, clickable | Opens the Fields tab. |

## Placeholder tabs

| ID | Screen | Element | UI tree | Notes |
| --- | --- | --- | --- | --- |
| `fields_coming_soon_screen` | Fields | Whole screen | `View` with the text | "This part comes in a later phase." |
| `animals_coming_soon_screen` | Animals | Whole screen | `View` with the text | "This part comes in a later phase." |
| `tasks_coming_soon_screen` | Tasks | Whole screen | `View` with the text | "This part comes in a later phase." |

## More (Settings)

| ID | Screen | Element | UI tree | Notes |
| --- | --- | --- | --- | --- |
| `settings_screen` | More | Whole screen | `View` | |
| `settings_account_name_text` | More | Account name | `View` with the text | |
| `settings_account_email_text` | More | Account email | `View` with the text | |
| `settings_theme_system_option` | More | System | `View`, clickable, text "System" | Default choice. |
| `settings_theme_light_option` | More | Light | `View`, clickable, text "Light" | |
| `settings_theme_dark_option` | More | Dark | `View`, clickable, text "Dark" | |
| `settings_app_version_text` | More | App version | `View` with the text | For example "Version 0.1.0 (1)". |
| `settings_logout_button` | More | Log out | `Button`, clickable | Opens the log out dialog. |

## Log out dialog

| ID | Screen | Element | UI tree | Notes |
| --- | --- | --- | --- | --- |
| `logout_dialog` | Log out dialog | Whole dialog | `View` | Title "Log out of Harvestly?". |
| `logout_dialog_cancel_button` | Log out dialog | Cancel | `Button`, clickable | Closes the dialog, stays logged in. |
| `logout_dialog_confirm_button` | Log out dialog | Log out | `Button`, clickable | Clears the session, goes to Login. |

## Shared

| ID | Screen | Element | UI tree | Notes |
| --- | --- | --- | --- | --- |
| `app_snackbar_text` | Any screen | Snackbar message | `View` with the text | The snackbar closes itself after 3 seconds. |
