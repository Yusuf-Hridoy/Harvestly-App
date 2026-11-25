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

## Animals list

| ID | Screen | Element | UI tree | Notes |
| --- | --- | --- | --- | --- |
| `animals_screen` | Animals | Whole screen | `View` | A container, so tap things inside it, not it. |
| `animals_add_button` | Animals | + | `Button`, clickable | Opens Add animal group. |
| `animals_search_input` | Animals | Search groups | `EditText`, clickable | Matches group names, ignoring capitals. |
| `animals_search_clear_button` | Animals | × in the search box | `Button`, clickable | Only there while the box has text. |
| `animals_filter_all_chip` | Animals | All chip | `View`, clickable | Text is "All 4", with the live count. |
| `animals_filter_birds_chip` | Animals | Birds chip | `View`, clickable | Hens, ducks and quail together. |
| `animals_filter_goats_chip` | Animals | Goats chip | `View`, clickable | |
| `animals_filter_cows_chip` | Animals | Cows chip | `View`, clickable | |
| `animals_list_item_<n>` | Animals | One group card | `View` | Counted from 1 by place on screen, after the search and the chip. A container, so tap it by its bounds. |
| `animals_list_item_<n>_name_text` | Animals | Group name in card n | `View` with the text | |
| `animals_list_item_<n>_today_text` | Animals | Today's amount in card n | `View` with the text | "18 eggs today", "3.5 L milk today" or "Nothing logged today". |
| `animals_list_item_<n>_warning_text` | Animals | Health warning in card n | `View` with the text | Only when a task is late or due today. Late wins: "Late: Deworming" beats "Newcastle booster due today". |
| `animals_no_results_text` | Animals | "No groups match." | `View` with the text | |
| `animals_no_results_clear_button` | Animals | Clear | `Button`, clickable | Empties the search box and puts the chip back to All. |
| `animals_empty_state` | Animals | Empty state | `View` | Only when the account has no groups at all. |
| `animals_empty_add_button` | Animals | Add group | `Button`, clickable | Inside the empty state. |

Groups stay in the order they were added. There is no sort on this screen.

## Group long-press menu

| ID | Screen | Element | UI tree | Notes |
| --- | --- | --- | --- | --- |
| `group_menu_sheet` | Group menu | Whole sheet | `View` | Opens on a long press of a group card. |
| `group_menu_edit_option` | Group menu | Edit group | `View`, clickable | |
| `group_menu_delete_option` | Group menu | Delete group | `View`, clickable | Opens the same dialog as the form's Delete group. |

## Group form (add and edit)

| ID | Screen | Element | UI tree | Notes |
| --- | --- | --- | --- | --- |
| `group_form_screen` | Group form | Whole screen | `View` | |
| `group_form_title_text` | Group form | App bar title | `View` with the text | "Add animal group" or "Edit animal group". |
| `group_form_name_input` | Group form | Group name | `EditText`, clickable | Stops at 30 characters. |
| `group_form_name_error_text` | Group form | Name error | `View` with the text | Only while the error shows. |
| `group_form_type_hens_chip` | Group form | Hens | `View`, clickable | |
| `group_form_type_ducks_chip` | Group form | Ducks | `View`, clickable | |
| `group_form_type_quail_chip` | Group form | Quail | `View`, clickable | |
| `group_form_type_goats_chip` | Group form | Goats | `View`, clickable | |
| `group_form_type_cows_chip` | Group form | Cows | `View`, clickable | |
| `group_form_type_error_text` | Group form | Type error | `View` with the text | "Please pick an animal type." |
| `group_form_type_help_text` | Group form | Help line | `View` with the text | Hidden until a type is picked. Changes with the kind. |
| `group_form_type_locked_text` | Group form | Locked line | `View` with the text | Only on Edit. The chips are still there but tapping one does nothing. |
| `group_form_count_input` | Group form | Number of animals | `EditText`, clickable | Digits only, 4 at most. |
| `group_form_count_minus_button` | Group form | − | `Button`, clickable | Off at 1. |
| `group_form_count_plus_button` | Group form | + | `Button`, clickable | Off at 9,999. |
| `group_form_count_error_text` | Group form | Count error | `View` with the text | |
| `group_form_date_input` | Group form | Start date | `Button`, clickable | Opens the date picker. 10 years back up to today. |
| `group_form_save_button` | Group form | Save group | `Button`, clickable | |
| `group_form_cancel_button` | Group form | Cancel | `Button`, clickable | With errors on screen this can be below the fold; scroll first. |
| `group_form_delete_button` | Group form | Delete group | `Button`, clickable | Only on Edit, at the bottom. Scroll to it. |

## Group detail

| ID | Screen | Element | UI tree | Notes |
| --- | --- | --- | --- | --- |
| `group_detail_screen` | Group detail | Whole screen | `View` | |
| `group_detail_title_text` | Group detail | Group name | `View` with the text | In the app bar. |
| `group_detail_info_text` | Group detail | Info line | `View` with the text | "Hens · 24 birds · since 1 Feb 2026". |
| `group_detail_edit_button` | Group detail | Pencil | `Button`, clickable | Opens Edit animal group. |
| `group_tab_eggs` | Group detail | Eggs tab | `View`, clickable | Flocks only. |
| `group_tab_milk` | Group detail | Milk tab | `View`, clickable | Herds only. |
| `group_tab_hatching` | Group detail | Hatching tab | `View`, clickable | Flocks only. |
| `group_tab_breeding` | Group detail | Breeding tab | `View`, clickable | Herds only. |
| `group_tab_health` | Group detail | Health tab | `View`, clickable | Both kinds. |

A flock shows Eggs, Hatching and Health. A herd shows Milk, Breeding and
Health. Only the three tabs of that kind are in the tree, so looking for
`group_tab_milk` on a flock finds nothing.

Tabs can be tapped or swiped. The URL follows the tab
(`/animals/<id>?tab=health`), so a deep link opens on that tab, and a tab name
that does not fit the kind opens the first tab instead.

## Eggs and Milk

Eggs and Milk are one screen with one set of IDs, so a single page object can
drive both. Only the words, the step sizes and the number format change.

| ID | Screen | Element | UI tree | Notes |
| --- | --- | --- | --- | --- |
| `production_tab` | Eggs / Milk | Whole tab | `View` | |
| `production_today_title_text` | Eggs / Milk | Card title | `View` with the text | "Eggs today" or "Milk today". |
| `production_today_value_text` | Eggs / Milk | Big number | `View` with the text | Whole for eggs, 1 decimal for milk ("14.0"). Tapping it opens `amount_dialog`. |
| `production_minus_button` | Eggs / Milk | − | `Button`, clickable | Off at 0. |
| `production_plus_button` | Eggs / Milk | + | `Button`, clickable | Off at the top of the range. |
| `production_hint_text` | Eggs / Milk | Hint line | `View` with the text | "Long press + to add 10" or "... add 5". |
| `production_range_7_option` | Eggs / Milk | 7 days | `View`, clickable | The range the tab opens on. |
| `production_range_30_option` | Eggs / Milk | 30 days | `View`, clickable | |
| `production_chart` | Eggs / Milk | Chart | `View` | Scrolls sideways on 30 days. |
| `production_chart_bar_<n>` | Eggs / Milk | One bar | `View`, clickable | Counted from the left, so bar 1 is the oldest day. Today is bar 7 on 7 days and bar 30 on 30 days. |
| `production_selected_text` | Eggs / Milk | Line under the chart | `View` with the text | "Tue 24 Nov · 18 eggs" or "... · 14.0 L". Today is picked when the tab opens. |
| `production_edit_past_button` | Eggs / Milk | Edit a past day | `Button`, clickable | Opens `past_day_dialog`. |
| `production_average_text` | Eggs / Milk | Daily average | `View` with the text | Over the chosen range, counting only days that have a log. "–" when none do. Scroll down to it. |
| `production_rate_text` | Eggs / Milk | Second stat | `View` with the text | Laying rate ("75%") for a flock, per animal ("7.0 L") for a herd. "–" with no animals. Scroll down to it. |

**A long press is the only way to add 10 eggs or 5 litres.** A tap on + or −
moves 1 egg or 0.5 litres. Appium needs a real long press on
`production_plus_button` or `production_minus_button` for the bigger step;
there is no other control for it.

**Which bars are in the tree.** On 7 days all 7 bars are there at once. On 30
days the chart is a sideways scroll that opens scrolled to today, so the
oldest bars are **not** in the tree until the chart is scrolled. In the saved
dump `production_chart_30_days.xml` only the bars around today are present.
Scroll the chart right before looking for a low bar number.

## Amount dialogs

| ID | Screen | Element | UI tree | Notes |
| --- | --- | --- | --- | --- |
| `amount_dialog` | Amount dialog | Whole dialog | `View` | Opened by tapping the big number. Title "Eggs today" or "Milk today". |
| `amount_dialog_input` | Amount dialog | Amount | `EditText`, clickable | Starts with today's amount, already filled in. Digits only for eggs, one decimal for milk. |
| `amount_dialog_error_text` | Amount dialog | Error | `View` with the text | |
| `amount_dialog_cancel_button` | Amount dialog | Cancel | `Button`, clickable | |
| `amount_dialog_save_button` | Amount dialog | Save | `Button`, clickable | |
| `past_day_dialog` | Past day dialog | Whole dialog | `View` | Title "Edit a past day". |
| `past_day_dialog_date_input` | Past day dialog | Date | `Button`, clickable | Opens on yesterday. 365 days back up to yesterday. |
| `past_day_dialog_amount_input` | Past day dialog | Amount | `EditText`, clickable | Starts empty. |
| `past_day_dialog_error_text` | Past day dialog | Error | `View` with the text | |
| `past_day_dialog_cancel_button` | Past day dialog | Cancel | `Button`, clickable | |
| `past_day_dialog_save_button` | Past day dialog | Save | `Button`, clickable | Snackbar: "Saved 17 eggs for 20 Nov." |

The milk input stops a second decimal as it is typed, so typing `12.55` leaves
`12.5` in the box. There is no error for it.

## Hatching

| ID | Screen | Element | UI tree | Notes |
| --- | --- | --- | --- | --- |
| `hatching_tab` | Hatching | Whole tab | `View` | Flocks only. |
| `hatching_new_batch_button` | Hatching | New batch | `Button`, clickable | Under the active batches. |
| `hatching_batch_item_<n>` | Hatching | Active batch card | `View` | Newest start first. A container. |
| `hatching_batch_item_<n>_title_text` | Hatching | "Batch 3" | `View` with the text | |
| `hatching_batch_item_<n>_day_chip` | Hatching | Day chip | `View` with the text | "Day 14 of 21", or "Hatch day passed" once the day has gone by. |
| `hatching_batch_item_<n>_record_button` | Hatching | Record result | `Button`, clickable | |
| `hatching_past_item_<n>` | Hatching | Past batch row | `View` | Newest result first. Hidden when there are none. |
| `hatching_past_item_<n>_rate_text` | Hatching | Hatch rate | `View` with the text | Rounded down, so 8 of 12 is "66%". |
| `hatching_empty_text` | Hatching | "No hatching batches yet." | `View` with the text | Only with no batches at all. |

## Breeding

| ID | Screen | Element | UI tree | Notes |
| --- | --- | --- | --- | --- |
| `breeding_tab` | Breeding | Whole tab | `View` | Herds only. |
| `breeding_new_button` | Breeding | New pregnancy | `Button`, clickable | |
| `breeding_item_<n>` | Breeding | Active pregnancy card | `View` | Soonest due first. A container. |
| `breeding_item_<n>_title_text` | Breeding | "Lali · pregnant" | `View` with the text | |
| `breeding_item_<n>_days_chip` | Breeding | Days chip | `View` with the text | "47 days left", "1 day left", or "Due date passed". |
| `breeding_item_<n>_record_button` | Breeding | Record birth | `Button`, clickable | |
| `breeding_past_item_<n>` | Breeding | Past birth row | `View` | Newest first. Hidden when there are none. |
| `breeding_past_item_<n>_young_text` | Breeding | Young | `View` with the text | "1 calf", "2 calves", "1 kid", "2 kids" or "None survived". |
| `breeding_empty_text` | Breeding | "No pregnancies yet." | `View` with the text | |

## Milestone timeline

The timeline is the same widget on a hatch batch and on a pregnancy. Its IDs
are built from the card it sits in, so they say which card they belong to.

| ID | Screen | Element | UI tree | Notes |
| --- | --- | --- | --- | --- |
| `<card id>_timeline` | Hatching / Breeding | Whole timeline | `View` | For example `hatching_batch_item_1_timeline`. |
| `<card id>_timeline_step_<m>` | Hatching / Breeding | One milestone | `View` | Counted from 1 in date order. Four per card. |
| `<card id>_timeline_today_marker` | Hatching / Breeding | Today dot | `View` | Sits in date order among the steps. |

**Every step is its own node with its own bounds**, so a test can read the
order from left to right and check where Today sits. The step numbers never
move: the Today dot is not counted as a step.

**The Today dot is missing when today is a milestone day.** That milestone
becomes the Today dot instead of adding a second one, so a batch started today
has `..._timeline_step_1` and no `..._timeline_today_marker`. Check for the
marker only when today falls between two milestones.

A hatch step shows "Day 7" under its label; a pregnancy step shows a date
("2 Apr"). The timeline opens scrolled so Today is on screen, which means the
first steps may be off to the left and out of the tree until it is scrolled.

## Batch form and hatch result

| ID | Screen | Element | UI tree | Notes |
| --- | --- | --- | --- | --- |
| `batch_form_screen` | Batch form | Whole screen | `View` | A pushed screen, not a route. Android back leaves it. |
| `batch_form_date_input` | Batch form | Start date | `Button`, clickable | 60 days back up to today. |
| `batch_form_eggs_input` | Batch form | Number of eggs | `EditText`, clickable | Digits only, 3 at most. |
| `batch_form_eggs_minus_button` | Batch form | − | `Button`, clickable | Off at 1. |
| `batch_form_eggs_plus_button` | Batch form | + | `Button`, clickable | Off at 500. |
| `batch_form_eggs_error_text` | Batch form | Eggs error | `View` with the text | |
| `batch_form_save_button` | Batch form | Save batch | `Button`, clickable | Snackbar: "Batch 4 started." |
| `batch_form_cancel_button` | Batch form | Cancel | `Button`, clickable | |
| `hatch_result_dialog` | Hatch result | Whole dialog | `View` | Title "How many hatched?". Works on any day. |
| `hatch_result_dialog_input` | Hatch result | How many | `EditText`, clickable | 0 up to the batch's own egg count. |
| `hatch_result_dialog_error_text` | Hatch result | Error | `View` with the text | The range in the text is the batch's egg count. |
| `hatch_result_dialog_cancel_button` | Hatch result | Cancel | `Button`, clickable | |
| `hatch_result_dialog_save_button` | Hatch result | Save | `Button`, clickable | |

## Pregnancy form and birth

| ID | Screen | Element | UI tree | Notes |
| --- | --- | --- | --- | --- |
| `pregnancy_form_screen` | Pregnancy form | Whole screen | `View` | A pushed screen, not a route. |
| `pregnancy_form_name_input` | Pregnancy form | Name or tag | `EditText`, clickable | 1 to 20 characters. It is only a label. |
| `pregnancy_form_name_error_text` | Pregnancy form | Name error | `View` with the text | |
| `pregnancy_form_date_input` | Pregnancy form | Mating date | `Button`, clickable | 365 days back up to today. |
| `pregnancy_form_save_button` | Pregnancy form | Save pregnancy | `Button`, clickable | Snackbar: "Pregnancy added for Lali." |
| `pregnancy_form_cancel_button` | Pregnancy form | Cancel | `Button`, clickable | |
| `birth_dialog` | Birth dialog | Whole dialog | `View` | Title "Record birth". |
| `birth_dialog_young_input` | Birth dialog | Number of young | `EditText`, clickable | One digit, 0 to 5. Zero means none survived. |
| `birth_dialog_young_error_text` | Birth dialog | Young error | `View` with the text | |
| `birth_dialog_date_input` | Birth dialog | Birth date | `Button`, clickable | The mating date up to today. |
| `birth_dialog_cancel_button` | Birth dialog | Cancel | `Button`, clickable | |
| `birth_dialog_save_button` | Birth dialog | Save | `Button`, clickable | Snackbar: "Birth saved for Lali." |

## Health

| ID | Screen | Element | UI tree | Notes |
| --- | --- | --- | --- | --- |
| `health_tab` | Health | Whole tab | `View` | Both kinds. |
| `health_count_title_text` | Health | Count title | `View` with the text | "Birds now" or "Animals now". |
| `health_count_value_text` | Health | Count | `View` with the text | Goes down when a loss is recorded, and can reach 0. |
| `health_record_loss_button` | Health | Record loss | `Button`, clickable | |
| `health_add_task_button` | Health | Add | `Button`, clickable | Next to the Health tasks heading. |
| `health_task_item_<n>` | Health | Open task row | `View` | Late first (most late), then due today, then coming up (soonest first). |
| `health_task_item_<n>_title_text` | Health | Task name | `View` with the text | |
| `health_task_item_<n>_state_text` | Health | State line | `View` with the text | "Late by 4 days", "Due today" or "Coming up · 12 Dec 2026". |
| `health_task_item_<n>_done_button` | Health | Done | `Button`, clickable | Marks it done today and moves it to the history. There is no undo. |
| `health_tasks_empty_text` | Health | Caught-up line | `View` with the text | "No health tasks. You're all caught up." |
| `health_history_item_<n>` | Health | History line | `View` with the text | Newest first. Done tasks and losses are mixed in one list. Scroll down to them. |
| `health_history_empty_text` | Health | "Nothing here yet." | `View` with the text | |

## Health task form and loss dialog

**These six IDs were renamed in Phase 4.** They were `task_form_*` in
Phase 3. Phase 4 gave the Tasks tab a task form of its own, and two screens
cannot share an ID, so the health one moved to `health_task_form_*` and the
plain names now belong to the Tasks form.

| ID | Screen | Element | UI tree | Notes |
| --- | --- | --- | --- | --- |
| `health_task_form_screen` | Health task form | Whole screen | `View` | A pushed screen, not a route. Was `task_form_screen`. |
| `health_task_form_title_input` | Health task form | Task name | `EditText`, clickable | 2 to 40 characters. Was `task_form_title_input`. |
| `health_task_form_title_error_text` | Health task form | Name error | `View` with the text | Was `task_form_title_error_text`. |
| `health_task_form_date_input` | Health task form | Due date | `Button`, clickable | 365 days back to 365 days ahead. Was `task_form_date_input`. |
| `health_task_form_save_button` | Health task form | Save task | `Button`, clickable | Snackbar: "Health task added." Was `task_form_save_button`. |
| `health_task_form_cancel_button` | Health task form | Cancel | `Button`, clickable | Was `task_form_cancel_button`. |
| `loss_dialog` | Loss dialog | Whole dialog | `View` | Title "Record loss". |
| `loss_dialog_amount_input` | Loss dialog | How many | `EditText`, clickable | 1 up to the group's count. |
| `loss_dialog_amount_error_text` | Loss dialog | Amount error | `View` with the text | "You only have 24 birds." when it is too many. |
| `loss_dialog_reason_picker` | Loss dialog | Pick a reason | `Button`, clickable | Opens the reason sheet. |
| `loss_dialog_reason_option_sickness` | Reason sheet | Sickness | `View`, clickable | |
| `loss_dialog_reason_option_predator` | Reason sheet | Predator | `View`, clickable | |
| `loss_dialog_reason_option_accident` | Reason sheet | Accident | `View`, clickable | |
| `loss_dialog_reason_option_sold` | Reason sheet | Sold | `View`, clickable | |
| `loss_dialog_reason_option_other` | Reason sheet | Other | `View`, clickable | |
| `loss_dialog_reason_error_text` | Loss dialog | Reason error | `View` with the text | |
| `loss_dialog_date_input` | Loss dialog | Date | `Button`, clickable | 365 days back up to today. |
| `loss_dialog_cancel_button` | Loss dialog | Cancel | `Button`, clickable | |
| `loss_dialog_save_button` | Loss dialog | Save | `Button`, clickable | Snackbar: "Loss saved." |

The reason sheet is a bottom sheet, not a dropdown, for the same reason the
soil picker is: every option has to be its own clickable node. The sheet
itself has no ID; find its options by theirs.

## Delete group dialog

| ID | Screen | Element | UI tree | Notes |
| --- | --- | --- | --- | --- |
| `delete_group_dialog` | Delete group dialog | Whole dialog | `View` | Title "Delete this group?". The same dialog from the long-press menu and from the form. |
| `delete_group_dialog_message_text` | Delete group dialog | Message | `View` with the text | "Flock A and all its records will be removed. You can't undo this." |
| `delete_group_dialog_cancel_button` | Delete group dialog | Cancel | `Button`, clickable | |
| `delete_group_dialog_confirm_button` | Delete group dialog | Delete | `Button`, clickable | |

## Home, animal health card

| ID | Screen | Element | UI tree | Notes |
| --- | --- | --- | --- | --- |
| `home_animal_health_card` | Home | Animal health card | `View` | Between Today's tasks and Harvest soon. Hidden when nothing is late, due today or due inside 7 days. A container, so tap it by its bounds. |
| `home_animal_health_title_text` | Home | Task and group | `View` with the text | "Foot-and-mouth vaccine · Cow shed". |
| `home_animal_health_state_text` | Home | State line | `View` with the text | Same words as the Health tab. |

Tapping the card opens that group on its Health tab.

**Scroll Home before looking for this card.** It sits low enough that on a
1080 x 2400 screen it is clipped to a few pixels at the bottom of the first
view, and Android drops the text nodes inside a clipped card. The first dump
of `home_farmer_phase3.xml` showed the card with 22 pixels of height and no
children at all; `home_farmer_phase3_scrolled.xml` shows all three IDs.

## Notes for Phase 3 testers

- **The date pickers still have no custom IDs.** `group_form_date_input`,
  `batch_form_date_input`, `pregnancy_form_date_input`,
  `health_task_form_date_input`, `task_form_date_input`,
  `birth_dialog_date_input`, `loss_dialog_date_input` and
  `past_day_dialog_date_input` all open Flutter's own `showDatePicker`. Inside
  it, find things by content description: "Switch to input", "Previous month",
  "Next month", "Cancel", "OK", and a day as
  `"24, Tuesday, November 24, 2026"`. Days outside the allowed range come out
  with `enabled="false"`. See `docs/ui-dumps/group_form_date_picker.xml`.
- **Saved data has a version now.** The account key `farm_data_<email>` holds
  `{"schemaVersion": 2, "fields": [...], "animals": [...]}`. Data saved by
  Phase 2 is upgraded the first time Phase 3 opens it, and data that cannot be
  read is copied to `farm_data_backup_<email>` and replaced by the sample, so
  the app never starts with an empty farm. See `docs/upgrade-test.md`.
- **Reset demo data now resets the animals too**, for the logged-in account
  only.
- **Every date in the sample is counted back from today**, so the day numbers,
  days left and averages are the same on every run. The start dates on the
  group cards are fixed.

## Tasks list

The rows are numbered inside their own group, starting at 1, in the order
they are drawn. `<group>` is `overdue`, `today`, `upcoming` or `done`, so the
first row under Today is `tasks_today_item_1`. **A task gets a different ID
when it moves group.** Finishing the first Today task makes it
`tasks_done_item_1`, and what was `tasks_today_item_2` becomes
`tasks_today_item_1`. Find a task by its title through
`tasks_<group>_item_<n>_title_text` rather than trusting a number to stay put.

| ID | Screen | Element | UI tree | Notes |
| --- | --- | --- | --- | --- |
| `tasks_screen` | Tasks | Whole screen | `View` | |
| `tasks_add_button` | Tasks | Plus in the app bar | `Button`, clickable | Opens Add task. |
| `tasks_filter_all_chip` | Tasks | All chip | `Button`, clickable | Text is "All 6": the label and the count of open tasks. |
| `tasks_filter_fields_chip` | Tasks | Fields chip | `Button`, clickable | Open tasks linked to a field. |
| `tasks_filter_animals_chip` | Tasks | Animals chip | `Button`, clickable | Open tasks linked to an animal group. |
| `tasks_filter_general_chip` | Tasks | General chip | `Button`, clickable | Open tasks with no link. |
| `tasks_overdue_header` | Tasks | Overdue heading | `View` with the text | "Overdue · 1", in the warning colour. Hidden when empty. |
| `tasks_today_header` | Tasks | Today heading | `View` with the text | "Today · 3". Hidden when empty. |
| `tasks_upcoming_header` | Tasks | Upcoming heading | `View` with the text | "Upcoming · 2". Hidden when empty. |
| `tasks_done_toggle` | Tasks | Done heading | `Button`, clickable | "Done · 4". Folded to start; tapping opens and closes the list. |
| `tasks_<group>_item_<n>` | Tasks | One row | `View` | Tapping it opens Task detail. |
| `tasks_<group>_item_<n>_title_text` | Tasks | Row title | `View` with the text | Struck through on a done row. |
| `tasks_<group>_item_<n>_line_text` | Tasks | Row line | `View` with the text | "Field 2 · South bed · 7:00 AM". Overdue rows are in the warning colour. |
| `tasks_<group>_item_<n>_checkbox` | Tasks | Row checkbox | `CheckBox`, clickable | Completes an open task, reopens a plain done one. |
| `tasks_<group>_item_<n>_repeat_icon` | Tasks | Repeat icon | `View` | **Only there when the task repeats.** |
| `tasks_<group>_item_<n>_reminder_icon` | Tasks | Bell | `View` | **Only there when the task has a reminder.** |
| `tasks_empty_state` | Tasks | Empty card | `View` | Only when the account has no tasks at all. |
| `tasks_empty_add_button` | Tasks | Add task | `Button`, clickable | Inside the empty card. |
| `tasks_filter_empty_text` | Tasks | No-result line | `View` with the text | "Nothing here. Try another filter." Only when the chosen chip has no open tasks. |
| `tasks_undo_button` | Snackbar | Undo | `Button`, clickable | Inside the "Marked as done." snackbar, for about 5 seconds. |

**Swipe right to complete.** A swipe from the left edge of a row towards the
right finishes the task, with a soft secondary background and "Done" showing
under it as it moves. A swipe left does nothing. Done rows do not swipe at
all. The row is never really removed: completing it moves it to the Done
group, so the row count under Today drops by one and `tasks_done_toggle`
counts one more.

**Undo.** Both the checkbox and the swipe show "Marked as done." with
`tasks_undo_button`. Undo reopens the task, and for a repeating task also
deletes the task that finishing it had just created.

## Task form (add and edit)

| ID | Screen | Element | UI tree | Notes |
| --- | --- | --- | --- | --- |
| `task_form_screen` | Task form | Whole screen | `View` | Route `/tasks/new` or `/tasks/<id>/edit`. |
| `task_form_title_text` | Task form | App bar title | `View` with the text | "Add task" or "Edit task". |
| `task_form_name_input` | Task form | Task | `EditText`, clickable | 2 to 60 characters. |
| `task_form_name_error_text` | Task form | Name error | `View` with the text | "Please enter a task." / "Use 2 to 60 characters." |
| `task_form_note_input` | Task form | Note | `EditText`, clickable | Up to 200 characters, 3 lines. |
| `task_form_note_counter_text` | Task form | Note counter | `View` with the text | "14 / 200", updated as you type. |
| `task_form_date_input` | Task form | Due date | `Button`, clickable | "25 Nov". 365 days back to 365 ahead. A past date is how an overdue task is made. |
| `task_form_time_input` | Task form | Time | `Button`, clickable | "9:00 AM". Opens Flutter's time picker. |
| `task_form_repeat_none_chip` | Task form | None | `Button`, clickable | Picked to start. |
| `task_form_repeat_daily_chip` | Task form | Daily | `Button`, clickable | |
| `task_form_repeat_weekly_chip` | Task form | Weekly | `Button`, clickable | |
| `task_form_repeat_monthly_chip` | Task form | Monthly | `Button`, clickable | |
| `task_form_link_input` | Task form | Linked to | `Button`, clickable | Shows "General", or the name with a "Fields" or "Animals" tag. Opens the link picker. |
| `task_form_reminder_none_chip` | Task form | None | `Button`, clickable | Picked to start. |
| `task_form_reminder_at_due_chip` | Task form | At due time | `Button`, clickable | |
| `task_form_reminder_hour_before_chip` | Task form | 1 hour before | `Button`, clickable | |
| `task_form_reminder_day_before_chip` | Task form | 1 day before | `Button`, clickable | |
| `task_form_reminder_line_text` | Task form | Reminder line | `View` with the text | "Reminder on Wed 25 Nov at 4:00 PM". **Only there once a reminder is picked**, and it follows the date, the time and the chip. |
| `task_form_reminder_error_text` | Task form | Reminder error | `View` with the text | "This reminder time has already passed." |
| `task_form_save_button` | Task form | Save task | `Button`, clickable | "Task added." or "Task updated." |
| `task_form_cancel_button` | Task form | Cancel | `Button`, clickable | Asks "Discard your changes?" when something was changed. |

**The form is longer than one screen.** With the keyboard up, the save and
cancel buttons and often the reminder chips are below the fold. Scroll the
form before looking for them, and start the swipe inside the form's own
bounds: with the keyboard up the scrollable ends around y=1500 on a
1080 x 2400 screen, and a swipe starting lower lands on the keyboard and does
nothing.

## Link picker sheet

| ID | Screen | Element | UI tree | Notes |
| --- | --- | --- | --- | --- |
| `link_picker_sheet` | Link picker | Whole sheet | `View` | Title "Linked to". |
| `link_picker_none_option` | Link picker | None | `View`, clickable | Makes it a general task. |
| `link_picker_field_option_<fieldId>` | Link picker | One field | `View`, clickable | For example `link_picker_field_option_field-2`. Fields are listed A to Z. |
| `link_picker_group_option_<groupId>` | Link picker | One group | `View`, clickable | For example `link_picker_group_option_group-1`. Groups are listed A to Z. |

The headings "Fields" and "Animals" carry no IDs, and the same two words are
on the tab bar behind the sheet, so look for them inside `link_picker_sheet`
and nowhere else. A sheet with no fields or no groups leaves that heading out.

## Task detail

| ID | Screen | Element | UI tree | Notes |
| --- | --- | --- | --- | --- |
| `task_detail_screen` | Task detail | Whole screen | `View` | Route `/tasks/<id>`. |
| `task_detail_title_text` | Task detail | Title | `View` with the text | Space Grotesk. |
| `task_detail_due_chip` | Task detail | Due chip | `View` with the text | "Today · 5:00 PM", "Fri 27 Nov · 10:00 AM", "Late by 2 days" in the warning colour, or "Done Wed 25 Nov". |
| `task_detail_edit_button` | Task detail | Pencil | `Button`, clickable | Opens Edit task. |
| `task_detail_link_card` | Task detail | Linked card | `View` | **Only there when the task is linked.** |
| `task_detail_link_name_text` | Task detail | Linked name | `View` with the text | "Duck pond · 6 birds" or "Field 2 · South bed · 0.4 acre". |
| `task_detail_link_open_button` | Task detail | Open | `Button`, clickable | Opens that field or group. |
| `task_detail_repeat_text` | Task detail | Repeat | `View` with the text | "Does not repeat", "Every day", "Every week, on Wed", "Every month, on the 25th". |
| `task_detail_reminder_text` | Task detail | Reminder | `View` with the text | "4:00 PM, 1 hour before", "Snoozed until 5:00 PM" or "None". |
| `task_detail_note_text` | Task detail | Note | `View` with the text | **Only there when the task has a note.** |
| `task_detail_done_button` | Task detail | Mark as done | `Button`, clickable | Only on an open task. |
| `task_detail_reopen_button` | Task detail | Mark as not done | `Button`, clickable | Only on a done task that does not repeat. |
| `task_detail_repeat_locked_text` | Task detail | Why no reopen | `View` with the text | Only on a done repeating task: "Repeating tasks can't be reopened. The next one is already in your list." |
| `task_detail_delete_button` | Task detail | Delete task | `Button`, clickable | Opens the delete dialog. |

Exactly one of `task_detail_done_button`, `task_detail_reopen_button` and
`task_detail_repeat_locked_text` is on screen at a time.

## Delete task dialog and the reminder explainer

| ID | Screen | Element | UI tree | Notes |
| --- | --- | --- | --- | --- |
| `delete_task_dialog` | Delete dialog | Whole dialog | `View` | Title "Delete this task?". |
| `delete_task_dialog_message_text` | Delete dialog | Message | `View` with the text | "Clean water pots will be removed. You can't undo this." |
| `delete_task_dialog_cancel_button` | Delete dialog | Cancel | `Button`, clickable | |
| `delete_task_dialog_confirm_button` | Delete dialog | Delete | `Button`, clickable | Cancels the reminder, goes to the list, snackbar "Task deleted." |
| `reminder_explainer_sheet` | Explainer | Whole sheet | `View` | "Turn on reminders?". Only on Android 13 and up, and only before the first time Android's own pop-up is shown. |
| `reminder_explainer_continue_button` | Explainer | Continue | `Button`, clickable | Then Android's pop-up opens. |
| `reminder_explainer_not_now_button` | Explainer | Not now | `Button`, clickable | Keeps the task, books nothing, and the sheet shows again next time. |

## Home and Settings, Phase 4

| ID | Screen | Element | UI tree | Notes |
| --- | --- | --- | --- | --- |
| `home_tasks_overdue_text` | Home | Overdue line | `Button`, clickable | "1 overdue task" / "3 overdue tasks", in the warning colour. **Only there when something is late.** Tapping it opens the Tasks tab. |
| `settings_notifications_card` | More | Notifications card | `View` | Above Appearance. |
| `settings_notifications_state_text` | More | State | `View` with the text | "Notifications are on", "Notifications are off" in the warning colour, or "Notifications are not set up yet". |
| `settings_open_android_settings_button` | More | Open Android settings | `Button`, clickable | **Only there when notifications are off.** Opens Android's own page for Harvestly. |
| `settings_test_notification_button` | More | Send | `Button`, clickable | Snackbar "Test notification on its way." |

The Phase 1 Home task IDs are unchanged and now sit on real tasks:
`home_tasks_card`, `home_tasks_see_all_link`, `home_tasks_empty_text`,
`home_task_item_<n>` and `home_task_checkbox_<n>`. Home shows up to three
tasks due today, the open ones by time first and then the ones already done
today.

## System UI

Android's permission pop-up and the notification shade are drawn by the
system, so nothing in them carries a Harvestly ID. What tests can rely on,
taken from dumps on this emulator (Android 16, API 36):

**The notification permission pop-up** — `docs/ui-dumps/system_permission.xml`,
package `com.google.android.permissioncontroller`:

| What | How to find it |
| --- | --- |
| The dialog | `com.android.permissioncontroller:id/grant_dialog` |
| The question | `com.android.permissioncontroller:id/permission_message`, text "Allow Harvestly to send you notifications?" |
| Allow | `com.android.permissioncontroller:id/permission_allow_button`, text "Allow" |
| Don't allow | `com.android.permissioncontroller:id/permission_deny_button`, text "Don't allow" |

The two button IDs are the stable part; the words change with the phone's
language, and the apostrophe in "Don't allow" is a right single quote
(U+2019), not a plain one.

**The notification shade** — `docs/ui-dumps/notification_shade.xml`. Open it
with `adb shell cmd statusbar expand-notifications`, then dump. A Harvestly
reminder reads:

| What | Text |
| --- | --- |
| App name | "Harvestly" |
| Title | The task title, for example "Clean water pots" |
| Text | "Duck pond · due at 5:00 PM", or "General · due at 5:00 PM" |
| First button | "Mark done" |
| Second button | "Snooze 1 hour" |

The test notification has the title "Test reminder", the text "Notifications
are working." and **no buttons**.

## Deep links

Links that start with `harvestly://app/` open a screen from outside the app.
The host is always `app`, because Flutter hands the router only the path of a
link: in `harvestly://tasks/12` the word `tasks` would be read as the host and
lost, while in `harvestly://app/tasks/12` the path is `/tasks/12`, which is
already a route.

| Link | Opens |
| --- | --- |
| `harvestly://app/home` | Home |
| `harvestly://app/fields` | The Fields list |
| `harvestly://app/fields/<fieldId>` | That field |
| `harvestly://app/animals` | The Animals list |
| `harvestly://app/animals/<groupId>` | That group, on its first tab |
| `harvestly://app/animals/<groupId>?tab=health` | That group, on its Health tab |
| `harvestly://app/tasks` | The Tasks list |
| `harvestly://app/tasks/<taskId>` | That task |

Run one with:

```
adb shell am start -W -a android.intent.action.VIEW -d "harvestly://app/tasks/task-4" com.harvestly.app
```

- Any other path opens Home with the snackbar "That link doesn't work."
- An ID that is gone falls back the way that kind already does: a missing
  task goes to `/tasks` with "That task no longer exists.", a missing field to
  `/fields`, a missing group to `/animals`.
- A link cannot open a form. `harvestly://app/tasks/new` is refused like any
  other unknown path.
- Links work with the app closed and with it in the background.
- **Logged out, the link waits.** The router goes to
  `/login?from=%2Ftasks%2Ftask-4` and opens that screen once the login works.
  A `from` that is not one of the links above is ignored and Home opens.

## Notes for Phase 4 testers

- **A busy Tasks screen can break `uiautomator dump`.** With the Done list
  open the tree runs to around 85 nodes, and at that size the dump quietly
  comes back without the snackbar on top: `tasks_undo_button` and
  `app_snackbar_text` are simply missing, however fast the dump is taken,
  while a screenshot shows the snackbar plainly. Folding Done first takes the
  tree to about 56 nodes and the snackbar appears on the first try. Appium's
  own page source goes through the same uiautomator service, so fold Done, or
  use a narrower chip, before looking for anything transient there.
- **The time picker needs care from a test.** `task_form_time_input` opens
  Flutter's own `showTimePicker`, which has no custom IDs. Find things in it
  by content description: "Switch to text input mode", "Switch to dial picker
  mode", "AM", "PM", "Cancel" and "OK". In typing mode the hour and the
  minute are the two `android.widget.EditText` nodes, and three things catch
  tests out: the keyboard moves the dialog, so find the minute box again
  after typing the hour or the tap lands on the scrim and closes the picker;
  the minute box never really empties, since a delete leaves a `0`; and it
  holds two digits, so a second typed digit is refused. Typing one digit `D`
  into an emptied minute box lands on `D0`, which means whole tens are the
  easy case and anything else needs the dial. Check the form afterwards:
  `task_form_time_input` reads the time that was really set.
- **A force-stopped app gets no reminders.** `adb shell am force-stop` puts
  the app in Android's stopped state, which cancels its alarms until someone
  opens it again. Swiping it off the recents list does not. Use
  `adb shell am kill com.harvestly.app` when a test needs the app closed but
  its reminders still live.
- **Reminders are inexact, so they can be late.** Harvestly asks for no
  exact-alarm permission on purpose, and schedules with
  `inexactAllowWhileIdle`. A reminder usually lands within a minute on an
  emulator but Android may hold it for several; allow about ten minutes
  before calling one missing.
- **The test notification only arrives if the app stays open.** Settings ›
  Send waits 10 seconds inside the app and then shows it. Swiping Harvestly
  away during those 10 seconds means nothing is sent. Tapping it opens Home.
  Holding the notification shade open through those 10 seconds also stops it:
  the activity pauses and the wait pauses with it. Wait with the shade shut,
  then open it.
- **A reminder you have not read stays in the shade.** Opening Harvestly
  books the reminders again, but that only clears the ones still waiting. A
  reminder already on screen is left where it is, so a test can open the
  app, look around, and still press **Mark done** or **Snooze 1 hour**
  afterwards. A shown reminder is taken away only when its task has moved
  on: finished, deleted, its reminder turned off, moved to a later time,
  renamed or relinked, or belonging to an account that is no longer logged
  in. Logging out clears every one.
- **The two buttons work with the app closed.** Mark done and Snooze 1 hour
  run on a background isolate that reads and writes shared_preferences
  directly. The app reads the store again when it next comes to the front, so
  a change made from the shade shows the moment the app is opened.
- **Android only asks once.** After Don't allow, Harvestly never shows the
  pop-up again; the explainer stops appearing too and Settings reads
  "Notifications are off" with an Open Android settings button. To get back
  to a fresh state, `adb shell pm clear com.harvestly.app` or reinstall.
- **Saved data is at version 3 now.** The account key `farm_data_<email>`
  holds `{"schemaVersion": 3, "fields": [...], "animals": [...],
  "tasks": [...]}`. Phase 2 and Phase 3 data is upgraded the first time
  Phase 4 opens it, keeping everything that was there. See
  `docs/upgrade-test.md`.
- **The Done fold goes back to closed when the app closes.** It survives
  opening a task and coming back, but not a restart.
- **Every date in the sample is counted from today**, so the groups, the
  counts and the "Late by" numbers read the same on every run.
