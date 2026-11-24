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

  // Placeholder tabs. Fields became a real screen in Phase 2.
  static const String animalsComingSoonScreen = 'animals_coming_soon_screen';
  static const String tasksComingSoonScreen = 'tasks_coming_soon_screen';

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

  // Shared.
  static const String appSnackbarText = 'app_snackbar_text';
}
