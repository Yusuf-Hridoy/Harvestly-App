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

  // Placeholder tabs.
  static const String fieldsComingSoonScreen = 'fields_coming_soon_screen';
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

  // Log out dialog.
  static const String logoutDialog = 'logout_dialog';
  static const String logoutDialogCancelButton = 'logout_dialog_cancel_button';
  static const String logoutDialogConfirmButton =
      'logout_dialog_confirm_button';

  // Shared.
  static const String appSnackbarText = 'app_snackbar_text';
}
