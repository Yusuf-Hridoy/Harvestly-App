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
| `home_harvest_card` | Home | Harvest soon card | `View` | Hidden when the account has no crops. From Phase 2 it reads real data and tapping it opens that Crop detail. It is a container node, so tap it by its bounds. |
| `home_tasks_empty_text` | Home | "No tasks for today." | `View` with the text | Only when the account has no sample tasks. |
| `home_harvest_progress_bar` | Home | Harvest progress | `ProgressBar` | Only appears after scrolling. It sits below the fold, and Android drops off-screen nodes from the tree, so scroll down before you look for it. |

## Home, empty account

| ID | Screen | Element | UI tree | Notes |
| --- | --- | --- | --- | --- |
| `home_empty_farm_card` | Home | Welcome card | `View` | Only for `new@harvestly.test`. |
| `home_empty_add_field_button` | Home | Add your first field | `Button`, clickable | Opens the Fields tab. |

## Placeholder tabs

Fields became a real screen in Phase 2, so `fields_coming_soon_screen` is gone.

| ID | Screen | Element | UI tree | Notes |
| --- | --- | --- | --- | --- |
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
| `settings_reset_data_button` | More | Reset demo data | `View`, clickable | Opens the reset dialog. |
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

## Fields list

List positions are what is on screen **right now**, after search, filter and
sort, counting from 1. The name inside each card has its own ID, so a test can
find a card by the name it can see.

| ID | Screen | Element | UI tree | Notes |
| --- | --- | --- | --- | --- |
| `fields_screen` | Fields | Whole screen | `View` | |
| `fields_add_button` | Fields | + button | `Button`, clickable | Opens Add field. |
| `fields_search_input` | Fields | Search box | `EditText`, clickable | Matches names that contain the text, ignoring case. |
| `fields_search_clear_button` | Fields | × in the search box | `Button`, clickable | Only in the tree while the box has text. |
| `fields_filter_all_chip` | Fields | All chip | `View`, clickable, text "All 4" | The count is part of the text. |
| `fields_filter_growing_chip` | Fields | Growing chip | `View`, clickable | Fields with at least one crop. |
| `fields_filter_empty_chip` | Fields | Empty chip | `View`, clickable | Fields with no crops. |
| `fields_filter_harvest_soon_chip` | Fields | Harvest soon chip | `View`, clickable | A crop with 14 days left or fewer. |
| `fields_count_text` | Fields | "4 fields" | `View` with the text | "1 field" for one. |
| `fields_sort_button` | Fields | Sort button | `Button`, clickable | Text reads "Sort: Name". |
| `fields_list_item_<n>` | Fields | One field card | `View` | A container, so `clickable="false"`. Tap or long press it by its bounds. |
| `fields_list_item_<n>_name_text` | Fields | Name inside card n | `View` with the text | |
| `fields_list_item_<n>_stage_chip` | Fields | Stage chip inside card n | `View` with the text | Reads "Empty" when the field has no crops. |
| `fields_no_results_text` | Fields | "No fields match." | `View` with the text | Only when search or filter match nothing. |
| `fields_no_results_clear_button` | Fields | Clear | `Button`, clickable | Clears the search and selects All. |
| `fields_empty_state` | Fields | "No fields yet" block | `View` | Only when the account has no fields at all. |
| `fields_empty_add_button` | Fields | Add field | `Button`, clickable | |

## Sort sheet

| ID | Screen | Element | UI tree | Notes |
| --- | --- | --- | --- | --- |
| `fields_sort_sheet` | Sort sheet | Whole sheet | `View` | |
| `fields_sort_name_option` | Sort sheet | Name | `View`, clickable | A to Z. The default. |
| `fields_sort_size_option` | Sort sheet | Size | `View`, clickable | Largest first. |
| `fields_sort_harvest_option` | Sort sheet | Harvest date | `View`, clickable | Soonest first; fields with no crops at the end. |

## Field long-press menu

| ID | Screen | Element | UI tree | Notes |
| --- | --- | --- | --- | --- |
| `field_menu_sheet` | Long-press menu | Whole sheet | `View` | Opens on a long press of a field card. |
| `field_menu_edit_option` | Long-press menu | Edit field | `View`, clickable | |
| `field_menu_delete_option` | Long-press menu | Delete field | `View`, clickable | Opens `delete_field_dialog`. |

## Field form (add and edit)

| ID | Screen | Element | UI tree | Notes |
| --- | --- | --- | --- | --- |
| `field_form_screen` | Field form | Whole screen | `View` | |
| `field_form_title_text` | Field form | Title | `View` with the text | "Add field" or "Edit field". |
| `field_form_name_input` | Field form | Field name | `EditText`, clickable | Stops at 30 characters. |
| `field_form_name_error_text` | Field form | Name error | `View` with the text | Only while the error shows. |
| `field_form_size_input` | Field form | Size in acres | `EditText`, clickable | Number keyboard. Letters are refused as they are typed, so typing letters and saving gives the empty-size error. |
| `field_form_size_error_text` | Field form | Size error | `View` with the text | Only while the error shows. |
| `field_form_soil_dropdown` | Field form | Soil type control | `Button`, clickable | Opens the soil sheet. Its text is the chosen soil, or "Pick a soil type". |
| `field_form_soil_option_loam` | Soil sheet | Loam | `View`, clickable | Only while the sheet is open. |
| `field_form_soil_option_clay` | Soil sheet | Clay | `View`, clickable | Only while the sheet is open. |
| `field_form_soil_option_sandy` | Soil sheet | Sandy | `View`, clickable | Only while the sheet is open. |
| `field_form_soil_option_silt` | Soil sheet | Silt | `View`, clickable | Only while the sheet is open. |
| `field_form_soil_error_text` | Field form | Soil error | `View` with the text | Only while the error shows. |
| `field_form_note_input` | Field form | Note | `EditText`, clickable | Typing stops at 120 characters. |
| `field_form_note_counter_text` | Field form | "0/120" | `View` with the text | |
| `field_form_save_button` | Field form | Save field | `Button`, clickable | |
| `field_form_cancel_button` | Field form | Cancel | `Button`, clickable | Asks before leaving when something changed. |

## Field detail

| ID | Screen | Element | UI tree | Notes |
| --- | --- | --- | --- | --- |
| `field_detail_screen` | Field detail | Whole screen | `View` | |
| `field_detail_title_text` | Field detail | Field name | `View` with the text | In the app bar. |
| `field_detail_info_text` | Field detail | "0.4 acre · Loam" | `View` with the text | The note is added after it when there is one. |
| `field_detail_edit_button` | Field detail | Pencil | `Button`, clickable | Opens Edit field. |
| `field_detail_add_crop_button` | Field detail | Add crop | `Button`, clickable | The one next to the Crops heading. The button inside the "no crops" card has its own ID. |
| `field_detail_crop_item_<n>` | Field detail | One crop card | `View` | Sorted by days left, soonest first. A container, so tap it by its bounds. |
| `field_detail_crop_item_<n>_name_text` | Field detail | Crop name in card n | `View` with the text | |
| `field_detail_crops_empty_text` | Field detail | "No crops in this field yet." | `View` with the text | Only when the field has no crops. |
| `field_detail_crops_empty_add_button` | Field detail | Add crop inside the "no crops" card | `Button`, clickable | Only when the field has no crops. Does the same thing as `field_detail_add_crop_button`. |
| `field_detail_past_harvests_section` | Field detail | Past harvests card | `View` | Only when the field has past harvests. |
| `field_detail_past_harvest_item_<n>` | Field detail | One harvest row | `View` with the text | Newest first, for example "Tomato · 6 Dec 2026 · 18.50 kg". |
| `field_detail_delete_button` | Field detail | Delete field | `Button`, clickable | At the bottom; scroll down first. |

## Field map

| ID | Screen | Element | UI tree | Notes |
| --- | --- | --- | --- | --- |
| `field_map_canvas` | Field detail | The map box | `View` | Its text is the hint "Drag corners · Pinch to zoom". |
| `field_map_corner_1` … `_4` | Field detail | Corner handles | `Button`, clickable | Clockwise from the top left. Each one is its own node, at least 44 × 44, so a drag can start from the middle of its bounds. |
| `field_map_area_text` | Field detail | "Area ≈ 0.42 acre" | `View` with the text | Updates while a corner is being dragged. |
| `field_map_zoom_text` | Field detail | "1.0×" | `View` with the text | One decimal, 1.0 to 3.0. |
| `field_map_reset_zoom_button` | Field detail | Reset zoom | `Button`, clickable | Only in the tree while the zoom is above 1.0×. It is the one ID with no saved dump: `adb shell input` has no second finger, so the zoom cannot be started from the command line. Appium's multi-finger actions can. |
| `field_map_save_shape_button` | Field detail | Save shape | `Button`, clickable | Only in the tree after a corner has moved. |
| `field_map_undo_shape_button` | Field detail | Undo | `Button`, clickable | Only in the tree after a corner has moved. |

A finger that goes down on a corner handle always drags that corner, at any
zoom level. A finger anywhere else on the map pans and pinches, and a finger
outside the map scrolls the page. Zoomed in, the corners can sit outside the
visible box, so pan the map first and then drag the handle.

## Add crop

| ID | Screen | Element | UI tree | Notes |
| --- | --- | --- | --- | --- |
| `crop_form_screen` | Add crop | Whole screen | `View` | |
| `crop_form_title_text` | Add crop | Title | `View` with the text | "Add crop to Field 2 · South bed". |
| `crop_form_search_input` | Add crop | Search crops | `EditText`, clickable | Searching never clears the chosen crop. |
| `crop_form_result_count_text` | Add crop | "4 of 40" | `View` with the text | Reads "40 crops" when the search box is empty. |
| `crop_form_crop_list` | Add crop | The catalog list | `View` | It scrolls, and only the rows on screen are in the tree, so search before looking for a crop near the bottom. |
| `crop_form_crop_option_<typeId>` | Add crop | One crop row | `View`, clickable | The type id is the name in lowercase snake_case, for example `crop_form_crop_option_green_chili`. These never change, because the catalog never changes. |
| `crop_form_no_results_text` | Add crop | "No crops match." | `View` with the text | |
| `crop_form_crop_error_text` | Add crop | "Please pick a crop." | `View` with the text | Above the list. |
| `crop_form_date_input` | Add crop | Planting date | `Button`, clickable | Its text is the date, for example "2 Oct 2026". Opens Flutter's date picker. |
| `crop_form_plants_input` | Add crop | Number of plants | `EditText`, clickable | Digits only, up to 4. |
| `crop_form_plants_minus_button` | Add crop | − | `Button`, clickable | `enabled="false"` at 1. |
| `crop_form_plants_plus_button` | Add crop | + | `Button`, clickable | `enabled="false"` at 9,999. |
| `crop_form_plants_error_text` | Add crop | Plants error | `View` with the text | |
| `crop_form_harvest_estimate_text` | Add crop | "Harvest around 6 Dec 2026" | `View` with the text | Only in the tree once a crop is chosen. |
| `crop_form_save_button` | Add crop | Save crop | `Button`, clickable | |

The date picker is Flutter's own dialog, so nothing inside it has a Harvestly
ID. Find its parts by text or content description: "Switch to input" turns on
the typing mode, each day reads like "23, Monday, November 23, 2026", and days
after today come back `enabled="false"`. The range is 365 days back up to
today, so "Next month" is disabled in the current month.

## Crop detail

| ID | Screen | Element | UI tree | Notes |
| --- | --- | --- | --- | --- |
| `crop_detail_screen` | Crop detail | Whole screen | `View` | |
| `crop_detail_name_text` | Crop detail | Crop name | `View` with the text | In the app bar. |
| `crop_detail_field_text` | Crop detail | Field name | `View` with the text | |
| `crop_detail_days_left_text` | Crop detail | "12 days left" | `View` with the text | Also "1 day left" or "Ready to harvest". |
| `crop_detail_stage_chip` | Crop detail | Stage chip | `View` with the text | |
| `crop_detail_stage_bar` | Crop detail | 4-step stage bar | `View` | Its text is "Seedling Growing Flowering Ready". |
| `crop_detail_planted_text` | Crop detail | Planting date | `View` with the text | |
| `crop_detail_harvest_date_text` | Crop detail | Harvest date | `View` with the text | |
| `crop_detail_plants_text` | Crop detail | Plants | `View` with the text | |
| `crop_detail_days_to_grow_text` | Crop detail | Days to grow | `View` with the text | |
| `crop_detail_harvest_button` | Crop detail | Mark as harvested | `Button`, clickable | Works at any stage. |
| `crop_detail_delete_button` | Crop detail | Delete crop | `Button`, clickable | |

## Harvest dialog

| ID | Screen | Element | UI tree | Notes |
| --- | --- | --- | --- | --- |
| `harvest_dialog` | Harvest dialog | Whole dialog | `View` | Title "How much did you harvest?". |
| `harvest_dialog_amount_input` | Harvest dialog | Amount (kg) | `EditText`, clickable | Number keyboard, up to 2 decimals. |
| `harvest_dialog_amount_error_text` | Harvest dialog | Amount error | `View` with the text | Only while the error shows. |
| `harvest_dialog_cancel_button` | Harvest dialog | Cancel | `Button`, clickable | |
| `harvest_dialog_save_button` | Harvest dialog | Save | `Button`, clickable | |

## Confirm dialogs

| ID | Screen | Element | UI tree | Notes |
| --- | --- | --- | --- | --- |
| `discard_dialog` | Discard dialog | Whole dialog | `View` | Title "Discard your changes?". It has no message line. |
| `discard_dialog_keep_button` | Discard dialog | Keep editing | `Button`, clickable | |
| `discard_dialog_discard_button` | Discard dialog | Discard | `Button`, clickable | |
| `delete_field_dialog` | Delete field dialog | Whole dialog | `View` | Title "Delete this field?". |
| `delete_field_dialog_message_text` | Delete field dialog | Message | `View` with the text | Says how many crops go with it. |
| `delete_field_dialog_cancel_button` | Delete field dialog | Cancel | `Button`, clickable | |
| `delete_field_dialog_confirm_button` | Delete field dialog | Delete | `Button`, clickable | |
| `delete_crop_dialog` | Delete crop dialog | Whole dialog | `View` | Title "Delete this crop?". |
| `delete_crop_dialog_message_text` | Delete crop dialog | Message | `View` with the text | |
| `delete_crop_dialog_cancel_button` | Delete crop dialog | Cancel | `Button`, clickable | |
| `delete_crop_dialog_confirm_button` | Delete crop dialog | Delete | `Button`, clickable | |
| `reset_data_dialog` | Reset data dialog | Whole dialog | `View` | Title "Reset demo data?". Its message has no ID of its own, so find it by text. |
| `reset_data_dialog_cancel_button` | Reset data dialog | Cancel | `Button`, clickable | |
| `reset_data_dialog_confirm_button` | Reset data dialog | Reset | `Button`, clickable | |
