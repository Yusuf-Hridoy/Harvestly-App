/// Every Semantics identifier used in Harvestly.
///
/// These strings show up as `resource-id` in the Android UI tree, so Appium
/// can find elements by ID. Never write one of these strings inside a screen,
/// and never rename or remove one unless a task says so.
class TestIds {
  const TestIds._();

  // Login screen.
  static const String loginScreen = 'login_screen';
  static const String loginEmailInput = 'login_email_input';
  static const String loginEmailErrorText = 'login_email_error_text';
  static const String loginPasswordInput = 'login_password_input';
  static const String loginPasswordErrorText = 'login_password_error_text';
  static const String loginPasswordToggleButton =
      'login_password_toggle_button';
  static const String loginRememberMeCheckbox = 'login_remember_me_checkbox';
  static const String loginForgotPasswordLink = 'login_forgot_password_link';
  static const String loginSubmitButton = 'login_submit_button';
  static const String loginLoadingIndicator = 'login_loading_indicator';
  static const String loginErrorBanner = 'login_error_banner';
  static const String loginDemoUseFarmerButton = 'login_demo_use_farmer_button';
  static const String loginDemoUsePoultryButton =
      'login_demo_use_poultry_button';
  static const String loginDemoUseNewButton = 'login_demo_use_new_button';

  // Bottom tab bar.
  static const String tabHomeButton = 'tab_home_button';
  static const String tabFieldsButton = 'tab_fields_button';
  static const String tabAnimalsButton = 'tab_animals_button';
  static const String tabTasksButton = 'tab_tasks_button';
  static const String tabMoreButton = 'tab_more_button';

  // Home screen.
  static const String homeScreen = 'home_screen';
  static const String homeDateText = 'home_date_text';
  static const String homeGreetingText = 'home_greeting_text';
  static const String homeNotificationsButton = 'home_notifications_button';
  static const String homeNotificationsBadge = 'home_notifications_badge';
  static const String homeWeatherCard = 'home_weather_card';
  static const String homeWeatherWarningText = 'home_weather_warning_text';
  static const String homeStatFieldsCard = 'home_stat_fields_card';
  static const String homeStatCropsCard = 'home_stat_crops_card';
  static const String homeStatEggsCard = 'home_stat_eggs_card';
  static const String homeStatProfitCard = 'home_stat_profit_card';
  static const String homeTasksCard = 'home_tasks_card';
  static const String homeTasksSeeAllLink = 'home_tasks_see_all_link';
  static const String homeHarvestCard = 'home_harvest_card';
  static const String homeHarvestProgressBar = 'home_harvest_progress_bar';
  static const String homeRefreshIndicator = 'home_refresh_indicator';

  /// Task row `number`, counting from 1 in the order shown on screen.
  static String homeTaskItem(int number) => 'home_task_item_$number';

  /// Checkbox of task row `number`, counting from 1.
  static String homeTaskCheckbox(int number) => 'home_task_checkbox_$number';

  // Home screen for an empty farm.
  static const String homeEmptyFarmCard = 'home_empty_farm_card';
  static const String homeEmptyAddFieldButton = 'home_empty_add_field_button';

  /// Shown instead of the task rows when the account has no tasks today.
  static const String homeTasksEmptyText = 'home_tasks_empty_text';

  // More tab (Settings).
  static const String settingsScreen = 'settings_screen';
  static const String settingsAccountNameText = 'settings_account_name_text';
  static const String settingsAccountEmailText = 'settings_account_email_text';
  static const String settingsThemeSystemOption =
      'settings_theme_system_option';
  static const String settingsThemeLightOption = 'settings_theme_light_option';
  static const String settingsThemeDarkOption = 'settings_theme_dark_option';
  static const String settingsAppVersionText = 'settings_app_version_text';
  static const String settingsLogoutButton = 'settings_logout_button';
  static const String settingsResetDataButton = 'settings_reset_data_button';

  // Log out dialog.
  static const String logoutDialog = 'logout_dialog';
  static const String logoutDialogCancelButton = 'logout_dialog_cancel_button';
  static const String logoutDialogConfirmButton =
      'logout_dialog_confirm_button';

  // Fields list.
  static const String fieldsScreen = 'fields_screen';
  static const String fieldsAddButton = 'fields_add_button';
  static const String fieldsSearchInput = 'fields_search_input';
  static const String fieldsSearchClearButton = 'fields_search_clear_button';
  static const String fieldsFilterAllChip = 'fields_filter_all_chip';
  static const String fieldsFilterGrowingChip = 'fields_filter_growing_chip';
  static const String fieldsFilterEmptyChip = 'fields_filter_empty_chip';
  static const String fieldsFilterHarvestSoonChip =
      'fields_filter_harvest_soon_chip';
  static const String fieldsCountText = 'fields_count_text';
  static const String fieldsSortButton = 'fields_sort_button';
  static const String fieldsNoResultsText = 'fields_no_results_text';
  static const String fieldsNoResultsClearButton =
      'fields_no_results_clear_button';
  static const String fieldsEmptyState = 'fields_empty_state';
  static const String fieldsEmptyAddButton = 'fields_empty_add_button';

  /// Field card `number`, counting from 1 in the order shown on screen right
  /// now, after search, filter and sort.
  static String fieldsListItem(int number) => 'fields_list_item_$number';

  /// The name inside field card `number`, so a test can match by name.
  static String fieldsListItemName(int number) =>
      'fields_list_item_${number}_name_text';

  /// The stage chip inside field card `number`.
  static String fieldsListItemStageChip(int number) =>
      'fields_list_item_${number}_stage_chip';

  // Sort sheet.
  static const String fieldsSortSheet = 'fields_sort_sheet';
  static const String fieldsSortNameOption = 'fields_sort_name_option';
  static const String fieldsSortSizeOption = 'fields_sort_size_option';
  static const String fieldsSortHarvestOption = 'fields_sort_harvest_option';

  // Long-press menu on a field card.
  static const String fieldMenuSheet = 'field_menu_sheet';
  static const String fieldMenuEditOption = 'field_menu_edit_option';
  static const String fieldMenuDeleteOption = 'field_menu_delete_option';

  // Add and edit field form.
  static const String fieldFormScreen = 'field_form_screen';
  static const String fieldFormTitleText = 'field_form_title_text';
  static const String fieldFormNameInput = 'field_form_name_input';
  static const String fieldFormNameErrorText = 'field_form_name_error_text';
  static const String fieldFormSizeInput = 'field_form_size_input';
  static const String fieldFormSizeErrorText = 'field_form_size_error_text';
  static const String fieldFormSoilDropdown = 'field_form_soil_dropdown';
  static const String fieldFormSoilOptionLoam = 'field_form_soil_option_loam';
  static const String fieldFormSoilOptionClay = 'field_form_soil_option_clay';
  static const String fieldFormSoilOptionSandy = 'field_form_soil_option_sandy';
  static const String fieldFormSoilOptionSilt = 'field_form_soil_option_silt';
  static const String fieldFormSoilErrorText = 'field_form_soil_error_text';
  static const String fieldFormNoteInput = 'field_form_note_input';
  static const String fieldFormNoteCounterText = 'field_form_note_counter_text';
  static const String fieldFormSaveButton = 'field_form_save_button';
  static const String fieldFormCancelButton = 'field_form_cancel_button';

  // Field detail.
  static const String fieldDetailScreen = 'field_detail_screen';
  static const String fieldDetailTitleText = 'field_detail_title_text';
  static const String fieldDetailInfoText = 'field_detail_info_text';
  static const String fieldDetailEditButton = 'field_detail_edit_button';
  static const String fieldDetailAddCropButton = 'field_detail_add_crop_button';
  static const String fieldDetailCropsEmptyText =
      'field_detail_crops_empty_text';
  static const String fieldDetailCropsEmptyAddButton =
      'field_detail_crops_empty_add_button';
  static const String fieldDetailPastHarvestsSection =
      'field_detail_past_harvests_section';
  static const String fieldDetailDeleteButton = 'field_detail_delete_button';

  /// Crop card `number` in this field, counting from 1, soonest harvest first.
  static String fieldDetailCropItem(int number) =>
      'field_detail_crop_item_$number';

  /// The crop name inside crop card `number`.
  static String fieldDetailCropItemName(int number) =>
      'field_detail_crop_item_${number}_name_text';

  /// Past harvest row `number`, counting from 1, newest first.
  static String fieldDetailPastHarvestItem(int number) =>
      'field_detail_past_harvest_item_$number';

  // Field map.
  static const String fieldMapCanvas = 'field_map_canvas';
  static const String fieldMapAreaText = 'field_map_area_text';
  static const String fieldMapZoomText = 'field_map_zoom_text';
  static const String fieldMapResetZoomButton = 'field_map_reset_zoom_button';
  static const String fieldMapSaveShapeButton = 'field_map_save_shape_button';
  static const String fieldMapUndoShapeButton = 'field_map_undo_shape_button';

  /// Corner handle `number`, 1 to 4, clockwise from the top left.
  static String fieldMapCorner(int number) => 'field_map_corner_$number';

  // Add crop.
  static const String cropFormScreen = 'crop_form_screen';
  static const String cropFormTitleText = 'crop_form_title_text';
  static const String cropFormSearchInput = 'crop_form_search_input';
  static const String cropFormResultCountText = 'crop_form_result_count_text';
  static const String cropFormCropList = 'crop_form_crop_list';
  static const String cropFormNoResultsText = 'crop_form_no_results_text';
  static const String cropFormCropErrorText = 'crop_form_crop_error_text';
  static const String cropFormDateInput = 'crop_form_date_input';
  static const String cropFormPlantsInput = 'crop_form_plants_input';
  static const String cropFormPlantsMinusButton =
      'crop_form_plants_minus_button';
  static const String cropFormPlantsPlusButton = 'crop_form_plants_plus_button';
  static const String cropFormPlantsErrorText = 'crop_form_plants_error_text';
  static const String cropFormHarvestEstimateText =
      'crop_form_harvest_estimate_text';
  static const String cropFormSaveButton = 'crop_form_save_button';

  /// One crop in the catalog list. The catalog never changes, so these use
  /// the crop type id instead of a position.
  static String cropFormCropOption(String typeId) =>
      'crop_form_crop_option_$typeId';

  // Crop detail.
  static const String cropDetailScreen = 'crop_detail_screen';
  static const String cropDetailNameText = 'crop_detail_name_text';
  static const String cropDetailFieldText = 'crop_detail_field_text';
  static const String cropDetailDaysLeftText = 'crop_detail_days_left_text';
  static const String cropDetailStageChip = 'crop_detail_stage_chip';
  static const String cropDetailStageBar = 'crop_detail_stage_bar';
  static const String cropDetailPlantedText = 'crop_detail_planted_text';
  static const String cropDetailHarvestDateText =
      'crop_detail_harvest_date_text';
  static const String cropDetailPlantsText = 'crop_detail_plants_text';
  static const String cropDetailDaysToGrowText =
      'crop_detail_days_to_grow_text';
  static const String cropDetailHarvestButton = 'crop_detail_harvest_button';
  static const String cropDetailDeleteButton = 'crop_detail_delete_button';

  // Harvest dialog.
  static const String harvestDialog = 'harvest_dialog';
  static const String harvestDialogAmountInput = 'harvest_dialog_amount_input';
  static const String harvestDialogAmountErrorText =
      'harvest_dialog_amount_error_text';
  static const String harvestDialogCancelButton =
      'harvest_dialog_cancel_button';
  static const String harvestDialogSaveButton = 'harvest_dialog_save_button';

  // Confirm dialogs.
  static const String discardDialog = 'discard_dialog';
  static const String discardDialogKeepButton = 'discard_dialog_keep_button';
  static const String discardDialogDiscardButton =
      'discard_dialog_discard_button';
  static const String deleteFieldDialog = 'delete_field_dialog';
  static const String deleteFieldDialogMessageText =
      'delete_field_dialog_message_text';
  static const String deleteFieldDialogCancelButton =
      'delete_field_dialog_cancel_button';
  static const String deleteFieldDialogConfirmButton =
      'delete_field_dialog_confirm_button';
  static const String deleteCropDialog = 'delete_crop_dialog';
  static const String deleteCropDialogMessageText =
      'delete_crop_dialog_message_text';
  static const String deleteCropDialogCancelButton =
      'delete_crop_dialog_cancel_button';
  static const String deleteCropDialogConfirmButton =
      'delete_crop_dialog_confirm_button';
  static const String resetDataDialog = 'reset_data_dialog';
  static const String resetDataDialogCancelButton =
      'reset_data_dialog_cancel_button';
  static const String resetDataDialogConfirmButton =
      'reset_data_dialog_confirm_button';

  // ================================================================ Phase 3

  // Animals list.
  static const String animalsScreen = 'animals_screen';
  static const String animalsAddButton = 'animals_add_button';
  static const String animalsSearchInput = 'animals_search_input';
  static const String animalsSearchClearButton = 'animals_search_clear_button';
  static const String animalsFilterAllChip = 'animals_filter_all_chip';
  static const String animalsFilterBirdsChip = 'animals_filter_birds_chip';
  static const String animalsFilterGoatsChip = 'animals_filter_goats_chip';
  static const String animalsFilterCowsChip = 'animals_filter_cows_chip';
  static const String animalsNoResultsText = 'animals_no_results_text';
  static const String animalsNoResultsClearButton =
      'animals_no_results_clear_button';
  static const String animalsEmptyState = 'animals_empty_state';
  static const String animalsEmptyAddButton = 'animals_empty_add_button';

  /// Group card `number` in the list, counting from 1 after search and
  /// filter.
  static String animalsListItem(int number) => 'animals_list_item_$number';

  /// The group name inside card `number`.
  static String animalsListItemName(int number) =>
      'animals_list_item_${number}_name_text';

  /// Today's eggs or milk inside card `number`.
  static String animalsListItemToday(int number) =>
      'animals_list_item_${number}_today_text';

  /// The health warning inside card `number`. Only there when a task is late
  /// or due today.
  static String animalsListItemWarning(int number) =>
      'animals_list_item_${number}_warning_text';

  // Group long-press menu.
  static const String groupMenuSheet = 'group_menu_sheet';
  static const String groupMenuEditOption = 'group_menu_edit_option';
  static const String groupMenuDeleteOption = 'group_menu_delete_option';

  // Group form.
  static const String groupFormScreen = 'group_form_screen';
  static const String groupFormTitleText = 'group_form_title_text';
  static const String groupFormNameInput = 'group_form_name_input';
  static const String groupFormNameErrorText = 'group_form_name_error_text';
  static const String groupFormTypeHensChip = 'group_form_type_hens_chip';
  static const String groupFormTypeDucksChip = 'group_form_type_ducks_chip';
  static const String groupFormTypeQuailChip = 'group_form_type_quail_chip';
  static const String groupFormTypeGoatsChip = 'group_form_type_goats_chip';
  static const String groupFormTypeCowsChip = 'group_form_type_cows_chip';
  static const String groupFormTypeErrorText = 'group_form_type_error_text';
  static const String groupFormTypeHelpText = 'group_form_type_help_text';
  static const String groupFormTypeLockedText = 'group_form_type_locked_text';
  static const String groupFormCountInput = 'group_form_count_input';
  static const String groupFormCountMinusButton =
      'group_form_count_minus_button';
  static const String groupFormCountPlusButton = 'group_form_count_plus_button';
  static const String groupFormCountErrorText = 'group_form_count_error_text';
  static const String groupFormDateInput = 'group_form_date_input';
  static const String groupFormSaveButton = 'group_form_save_button';
  static const String groupFormCancelButton = 'group_form_cancel_button';
  static const String groupFormDeleteButton = 'group_form_delete_button';

  // Group detail.
  static const String groupDetailScreen = 'group_detail_screen';
  static const String groupDetailTitleText = 'group_detail_title_text';
  static const String groupDetailInfoText = 'group_detail_info_text';
  static const String groupDetailEditButton = 'group_detail_edit_button';
  static const String groupTabEggs = 'group_tab_eggs';
  static const String groupTabMilk = 'group_tab_milk';
  static const String groupTabHatching = 'group_tab_hatching';
  static const String groupTabBreeding = 'group_tab_breeding';
  static const String groupTabHealth = 'group_tab_health';

  // Eggs and Milk. One set of IDs for both, so one page object serves both.
  static const String productionTab = 'production_tab';
  static const String productionTodayTitleText = 'production_today_title_text';
  static const String productionTodayValueText = 'production_today_value_text';
  static const String productionMinusButton = 'production_minus_button';
  static const String productionPlusButton = 'production_plus_button';
  static const String productionHintText = 'production_hint_text';
  static const String productionRange7Option = 'production_range_7_option';
  static const String productionRange30Option = 'production_range_30_option';
  static const String productionChart = 'production_chart';
  static const String productionSelectedText = 'production_selected_text';
  static const String productionEditPastButton = 'production_edit_past_button';
  static const String productionAverageText = 'production_average_text';
  static const String productionRateText = 'production_rate_text';

  /// Chart bar `number`, counting from the left. Bar 1 is the oldest day, so
  /// today is bar 7 in 7-day mode and bar 30 in 30-day mode.
  static String productionChartBar(int number) =>
      'production_chart_bar_$number';

  // Amount dialogs.
  static const String amountDialog = 'amount_dialog';
  static const String amountDialogInput = 'amount_dialog_input';
  static const String amountDialogErrorText = 'amount_dialog_error_text';
  static const String amountDialogCancelButton = 'amount_dialog_cancel_button';
  static const String amountDialogSaveButton = 'amount_dialog_save_button';
  static const String pastDayDialog = 'past_day_dialog';
  static const String pastDayDialogDateInput = 'past_day_dialog_date_input';
  static const String pastDayDialogAmountInput = 'past_day_dialog_amount_input';
  static const String pastDayDialogErrorText = 'past_day_dialog_error_text';
  static const String pastDayDialogCancelButton =
      'past_day_dialog_cancel_button';
  static const String pastDayDialogSaveButton = 'past_day_dialog_save_button';

  // Hatching tab.
  static const String hatchingTab = 'hatching_tab';
  static const String hatchingNewBatchButton = 'hatching_new_batch_button';
  static const String hatchingEmptyText = 'hatching_empty_text';

  /// Active batch card `number`, newest start first.
  static String hatchingBatchItem(int number) => 'hatching_batch_item_$number';

  /// "Batch 3" inside active batch card `number`.
  static String hatchingBatchItemTitle(int number) =>
      'hatching_batch_item_${number}_title_text';

  /// "Day 14 of 21" inside active batch card `number`.
  static String hatchingBatchItemDayChip(int number) =>
      'hatching_batch_item_${number}_day_chip';

  /// Record result inside active batch card `number`.
  static String hatchingBatchItemRecordButton(int number) =>
      'hatching_batch_item_${number}_record_button';

  /// Past batch row `number`, newest result first.
  static String hatchingPastItem(int number) => 'hatching_past_item_$number';

  /// The hatch rate inside past batch row `number`.
  static String hatchingPastItemRate(int number) =>
      'hatching_past_item_${number}_rate_text';

  // Breeding tab.
  static const String breedingTab = 'breeding_tab';
  static const String breedingNewButton = 'breeding_new_button';
  static const String breedingEmptyText = 'breeding_empty_text';

  /// Active pregnancy card `number`, soonest due first.
  static String breedingItem(int number) => 'breeding_item_$number';

  /// "Lali · pregnant" inside pregnancy card `number`.
  static String breedingItemTitle(int number) =>
      'breeding_item_${number}_title_text';

  /// "47 days left" inside pregnancy card `number`.
  static String breedingItemDaysChip(int number) =>
      'breeding_item_${number}_days_chip';

  /// Record birth inside pregnancy card `number`.
  static String breedingItemRecordButton(int number) =>
      'breeding_item_${number}_record_button';

  /// Past birth row `number`, newest first.
  static String breedingPastItem(int number) => 'breeding_past_item_$number';

  /// "1 calf" inside past birth row `number`.
  static String breedingPastItemYoung(int number) =>
      'breeding_past_item_${number}_young_text';

  /// The timeline inside a batch or pregnancy card, for example
  /// `hatching_batch_item_1_timeline`.
  static String timeline(String cardId) => '${cardId}_timeline';

  /// Step `step` of that timeline, counting from 1 in date order.
  static String timelineStep(String cardId, int step) =>
      '${cardId}_timeline_step_$step';

  /// The Today dot on that timeline. It is missing when today falls on a
  /// milestone, because that milestone becomes the Today dot instead.
  static String timelineTodayMarker(String cardId) =>
      '${cardId}_timeline_today_marker';

  // Batch form and hatch result.
  static const String batchFormScreen = 'batch_form_screen';
  static const String batchFormDateInput = 'batch_form_date_input';
  static const String batchFormEggsInput = 'batch_form_eggs_input';
  static const String batchFormEggsMinusButton = 'batch_form_eggs_minus_button';
  static const String batchFormEggsPlusButton = 'batch_form_eggs_plus_button';
  static const String batchFormEggsErrorText = 'batch_form_eggs_error_text';
  static const String batchFormSaveButton = 'batch_form_save_button';
  static const String batchFormCancelButton = 'batch_form_cancel_button';
  static const String hatchResultDialog = 'hatch_result_dialog';
  static const String hatchResultDialogInput = 'hatch_result_dialog_input';
  static const String hatchResultDialogErrorText =
      'hatch_result_dialog_error_text';
  static const String hatchResultDialogCancelButton =
      'hatch_result_dialog_cancel_button';
  static const String hatchResultDialogSaveButton =
      'hatch_result_dialog_save_button';

  // Pregnancy form and birth.
  static const String pregnancyFormScreen = 'pregnancy_form_screen';
  static const String pregnancyFormNameInput = 'pregnancy_form_name_input';
  static const String pregnancyFormNameErrorText =
      'pregnancy_form_name_error_text';
  static const String pregnancyFormDateInput = 'pregnancy_form_date_input';
  static const String pregnancyFormSaveButton = 'pregnancy_form_save_button';
  static const String pregnancyFormCancelButton =
      'pregnancy_form_cancel_button';
  static const String birthDialog = 'birth_dialog';
  static const String birthDialogYoungInput = 'birth_dialog_young_input';
  static const String birthDialogYoungErrorText =
      'birth_dialog_young_error_text';
  static const String birthDialogDateInput = 'birth_dialog_date_input';
  static const String birthDialogCancelButton = 'birth_dialog_cancel_button';
  static const String birthDialogSaveButton = 'birth_dialog_save_button';

  // Health tab.
  static const String healthTab = 'health_tab';
  static const String healthCountTitleText = 'health_count_title_text';
  static const String healthCountValueText = 'health_count_value_text';
  static const String healthRecordLossButton = 'health_record_loss_button';
  static const String healthAddTaskButton = 'health_add_task_button';
  static const String healthTasksEmptyText = 'health_tasks_empty_text';
  static const String healthHistoryEmptyText = 'health_history_empty_text';

  /// Open task `number`, in the order the tab shows them.
  static String healthTaskItem(int number) => 'health_task_item_$number';

  /// The task name inside open task `number`.
  static String healthTaskItemTitle(int number) =>
      'health_task_item_${number}_title_text';

  /// "Late by 4 days" inside open task `number`.
  static String healthTaskItemState(int number) =>
      'health_task_item_${number}_state_text';

  /// Done inside open task `number`.
  static String healthTaskItemDoneButton(int number) =>
      'health_task_item_${number}_done_button';

  /// History line `number`, newest first.
  static String healthHistoryItem(int number) => 'health_history_item_$number';

  // Health task form and loss dialog.
  //
  // These were named task_form_* in Phase 3. Phase 4 added a task form of
  // its own in the Tasks tab, so the health one moved to health_task_form_*
  // and the plain names now belong to the Tasks form.
  static const String healthTaskFormScreen = 'health_task_form_screen';
  static const String healthTaskFormTitleInput = 'health_task_form_title_input';
  static const String healthTaskFormTitleErrorText =
      'health_task_form_title_error_text';
  static const String healthTaskFormDateInput = 'health_task_form_date_input';
  static const String healthTaskFormSaveButton = 'health_task_form_save_button';
  static const String healthTaskFormCancelButton =
      'health_task_form_cancel_button';
  static const String lossDialog = 'loss_dialog';
  static const String lossDialogAmountInput = 'loss_dialog_amount_input';
  static const String lossDialogAmountErrorText =
      'loss_dialog_amount_error_text';
  static const String lossDialogReasonPicker = 'loss_dialog_reason_picker';
  static const String lossDialogReasonOptionSickness =
      'loss_dialog_reason_option_sickness';
  static const String lossDialogReasonOptionPredator =
      'loss_dialog_reason_option_predator';
  static const String lossDialogReasonOptionAccident =
      'loss_dialog_reason_option_accident';
  static const String lossDialogReasonOptionSold =
      'loss_dialog_reason_option_sold';
  static const String lossDialogReasonOptionOther =
      'loss_dialog_reason_option_other';
  static const String lossDialogReasonErrorText =
      'loss_dialog_reason_error_text';
  static const String lossDialogDateInput = 'loss_dialog_date_input';
  static const String lossDialogCancelButton = 'loss_dialog_cancel_button';
  static const String lossDialogSaveButton = 'loss_dialog_save_button';

  // Delete group dialog.
  static const String deleteGroupDialog = 'delete_group_dialog';
  static const String deleteGroupDialogMessageText =
      'delete_group_dialog_message_text';
  static const String deleteGroupDialogCancelButton =
      'delete_group_dialog_cancel_button';
  static const String deleteGroupDialogConfirmButton =
      'delete_group_dialog_confirm_button';

  // Home, animal health card.
  static const String homeAnimalHealthCard = 'home_animal_health_card';
  static const String homeAnimalHealthTitleText =
      'home_animal_health_title_text';
  static const String homeAnimalHealthStateText =
      'home_animal_health_state_text';

  // ================================================================ Phase 4
  // Tasks, reminders and deep links.

  // Tasks tab.
  static const String tasksScreen = 'tasks_screen';
  static const String tasksAddButton = 'tasks_add_button';
  static const String tasksFilterAllChip = 'tasks_filter_all_chip';
  static const String tasksFilterFieldsChip = 'tasks_filter_fields_chip';
  static const String tasksFilterAnimalsChip = 'tasks_filter_animals_chip';
  static const String tasksFilterGeneralChip = 'tasks_filter_general_chip';
  static const String tasksOverdueHeader = 'tasks_overdue_header';
  static const String tasksTodayHeader = 'tasks_today_header';
  static const String tasksUpcomingHeader = 'tasks_upcoming_header';
  static const String tasksDoneToggle = 'tasks_done_toggle';
  static const String tasksEmptyState = 'tasks_empty_state';
  static const String tasksEmptyAddButton = 'tasks_empty_add_button';
  static const String tasksFilterEmptyText = 'tasks_filter_empty_text';

  /// The Undo action inside the "Marked as done." snackbar.
  static const String tasksUndoButton = 'tasks_undo_button';

  /// Task row `number` inside one group, counting from 1 down the screen.
  ///
  /// `group` is overdue, today, upcoming or done. A task that moves group
  /// gets a different ID, which is expected.
  static String tasksItem(String group, int number) =>
      'tasks_${group}_item_$number';

  /// The title of task row `number` in `group`.
  static String tasksItemTitle(String group, int number) =>
      '${tasksItem(group, number)}_title_text';

  /// The line under the title of task row `number` in `group`.
  static String tasksItemLine(String group, int number) =>
      '${tasksItem(group, number)}_line_text';

  /// The checkbox of task row `number` in `group`.
  static String tasksItemCheckbox(String group, int number) =>
      '${tasksItem(group, number)}_checkbox';

  /// The repeat icon of task row `number`, only there when it repeats.
  static String tasksItemRepeatIcon(String group, int number) =>
      '${tasksItem(group, number)}_repeat_icon';

  /// The bell of task row `number`, only there when it has a reminder.
  static String tasksItemReminderIcon(String group, int number) =>
      '${tasksItem(group, number)}_reminder_icon';

  // Add and edit task form.
  static const String taskFormScreen = 'task_form_screen';
  static const String taskFormTitleText = 'task_form_title_text';
  static const String taskFormNameInput = 'task_form_name_input';
  static const String taskFormNameErrorText = 'task_form_name_error_text';
  static const String taskFormNoteInput = 'task_form_note_input';
  static const String taskFormNoteCounterText = 'task_form_note_counter_text';
  static const String taskFormDateInput = 'task_form_date_input';
  static const String taskFormTimeInput = 'task_form_time_input';
  static const String taskFormRepeatNoneChip = 'task_form_repeat_none_chip';
  static const String taskFormRepeatDailyChip = 'task_form_repeat_daily_chip';
  static const String taskFormRepeatWeeklyChip = 'task_form_repeat_weekly_chip';
  static const String taskFormRepeatMonthlyChip =
      'task_form_repeat_monthly_chip';
  static const String taskFormLinkInput = 'task_form_link_input';
  static const String taskFormReminderNoneChip = 'task_form_reminder_none_chip';
  static const String taskFormReminderAtDueChip =
      'task_form_reminder_at_due_chip';
  static const String taskFormReminderHourBeforeChip =
      'task_form_reminder_hour_before_chip';
  static const String taskFormReminderDayBeforeChip =
      'task_form_reminder_day_before_chip';
  static const String taskFormReminderLineText = 'task_form_reminder_line_text';
  static const String taskFormReminderErrorText =
      'task_form_reminder_error_text';
  static const String taskFormSaveButton = 'task_form_save_button';
  static const String taskFormCancelButton = 'task_form_cancel_button';

  // Link picker sheet.
  static const String linkPickerSheet = 'link_picker_sheet';
  static const String linkPickerNoneOption = 'link_picker_none_option';

  /// One field row in the link picker, by field id.
  static String linkPickerFieldOption(String fieldId) =>
      'link_picker_field_option_$fieldId';

  /// One animal group row in the link picker, by group id.
  static String linkPickerGroupOption(String groupId) =>
      'link_picker_group_option_$groupId';

  // Task detail.
  static const String taskDetailScreen = 'task_detail_screen';
  static const String taskDetailTitleText = 'task_detail_title_text';
  static const String taskDetailDueChip = 'task_detail_due_chip';
  static const String taskDetailEditButton = 'task_detail_edit_button';
  static const String taskDetailLinkCard = 'task_detail_link_card';
  static const String taskDetailLinkNameText = 'task_detail_link_name_text';
  static const String taskDetailLinkOpenButton = 'task_detail_link_open_button';
  static const String taskDetailRepeatText = 'task_detail_repeat_text';
  static const String taskDetailReminderText = 'task_detail_reminder_text';
  static const String taskDetailNoteText = 'task_detail_note_text';
  static const String taskDetailDoneButton = 'task_detail_done_button';
  static const String taskDetailReopenButton = 'task_detail_reopen_button';
  static const String taskDetailRepeatLockedText =
      'task_detail_repeat_locked_text';
  static const String taskDetailDeleteButton = 'task_detail_delete_button';

  // Delete task dialog.
  static const String deleteTaskDialog = 'delete_task_dialog';
  static const String deleteTaskDialogMessageText =
      'delete_task_dialog_message_text';
  static const String deleteTaskDialogCancelButton =
      'delete_task_dialog_cancel_button';
  static const String deleteTaskDialogConfirmButton =
      'delete_task_dialog_confirm_button';

  // Reminder explainer sheet, shown before Android's permission pop-up.
  static const String reminderExplainerSheet = 'reminder_explainer_sheet';
  static const String reminderExplainerContinueButton =
      'reminder_explainer_continue_button';
  static const String reminderExplainerNotNowButton =
      'reminder_explainer_not_now_button';

  // Home, the overdue line on the tasks card.
  static const String homeTasksOverdueText = 'home_tasks_overdue_text';

  // Settings, the Notifications part.
  static const String settingsNotificationsCard = 'settings_notifications_card';
  static const String settingsNotificationsStateText =
      'settings_notifications_state_text';
  static const String settingsOpenAndroidSettingsButton =
      'settings_open_android_settings_button';
  static const String settingsTestNotificationButton =
      'settings_test_notification_button';

  // Shared.
  static const String appSnackbarText = 'app_snackbar_text';
}
