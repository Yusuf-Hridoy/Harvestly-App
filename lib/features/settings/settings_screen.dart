import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../../app/app_colors.dart';
import '../../app/app_theme.dart';
import '../../data/demo_accounts.dart';
import '../../data/farm_repository.dart';
import '../../notifications/notification_service.dart';
import '../../shared/app_info/app_version_reader.dart';
import '../../shared/testing/test_id_wrapper.dart';
import '../../shared/testing/test_ids.dart';
import '../../shared/widgets/app_snackbar.dart';
import '../../shared/widgets/confirm_dialog.dart';
import '../login/login_controller.dart';
import '../tasks/task_form_screen.dart';
import 'theme_controller.dart';

/// The More tab: account, appearance, app version and log out.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _confirmReset(BuildContext context) async {
    final FarmRepository repository = context.read<FarmRepository>();
    final bool confirmed = await ConfirmDialog.show(
      context,
      dialogTestId: TestIds.resetDataDialog,
      title: 'Reset demo data?',
      message:
          'All fields and crops for this account go back to the starting '
          'sample. You can\'t undo this.',
      cancelLabel: 'Cancel',
      cancelTestId: TestIds.resetDataDialogCancelButton,
      confirmLabel: 'Reset',
      confirmTestId: TestIds.resetDataDialogConfirmButton,
      destructive: true,
    );
    if (!confirmed || !context.mounted) return;

    await repository.resetToSample();
    if (!context.mounted) return;
    AppSnackbar.show(context, 'Demo data reset.');
  }

  Future<void> _confirmLogOut(BuildContext context) async {
    final LoginController login = context.read<LoginController>();
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return TestId(
          TestIds.logoutDialog,
          container: true,
          child: AlertDialog(
            title: const Text('Log out of Harvestly?'),
            actions: <Widget>[
              TestId(
                TestIds.logoutDialogCancelButton,
                merge: true,
                child: TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(false),
                  child: const Text('Cancel'),
                ),
              ),
              TestId(
                TestIds.logoutDialogConfirmButton,
                merge: true,
                child: TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(true),
                  child: const Text('Log out'),
                ),
              ),
            ],
          ),
        );
      },
    );

    if (confirmed ?? false) {
      await login.logOut();
    }
  }

  @override
  Widget build(BuildContext context) {
    final DemoAccount? account = context.watch<LoginController>().account;
    final ThemeController theme = context.watch<ThemeController>();
    final AppVersion version = context.read<AppVersion>();
    final AppColorSet colors = context.colors;
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('More')),
      body: TestId(
        TestIds.settingsScreen,
        container: true,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSizes.screenPadding,
            8,
            AppSizes.screenPadding,
            24,
          ),
          children: <Widget>[
            _SectionTitle(text: 'Account', colors: colors),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: <Widget>[
                    Container(
                      height: 44,
                      width: 44,
                      decoration: BoxDecoration(
                        color: colors.secondarySoft,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.person_outline,
                        color: colors.onSecondarySoft,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          TestId(
                            TestIds.settingsAccountNameText,
                            child: Text(
                              account?.name ?? '',
                              style: textTheme.titleMedium,
                            ),
                          ),
                          const SizedBox(height: 2),
                          TestId(
                            TestIds.settingsAccountEmailText,
                            child: Text(
                              account?.email ?? '',
                              style: textTheme.bodySmall,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            _SectionTitle(text: 'Notifications', colors: colors),
            const _NotificationsSection(),
            const SizedBox(height: 20),
            _SectionTitle(text: 'Appearance', colors: colors),
            Card(
              child: Column(
                children: <Widget>[
                  _ThemeOption(
                    testId: TestIds.settingsThemeSystemOption,
                    label: 'System',
                    mode: ThemeMode.system,
                    selected: theme.mode == ThemeMode.system,
                    colors: colors,
                  ),
                  const Divider(),
                  _ThemeOption(
                    testId: TestIds.settingsThemeLightOption,
                    label: 'Light',
                    mode: ThemeMode.light,
                    selected: theme.mode == ThemeMode.light,
                    colors: colors,
                  ),
                  const Divider(),
                  _ThemeOption(
                    testId: TestIds.settingsThemeDarkOption,
                    label: 'Dark',
                    mode: ThemeMode.dark,
                    selected: theme.mode == ThemeMode.dark,
                    colors: colors,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _SectionTitle(text: 'About', colors: colors),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: <Widget>[
                    Icon(Icons.info_outline, color: colors.textMuted),
                    const SizedBox(width: 12),
                    TestId(
                      TestIds.settingsAppVersionText,
                      child: Text(version.label, style: textTheme.bodyMedium),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            _SectionTitle(text: 'Demo data', colors: colors),
            Card(
              child: TestId(
                TestIds.settingsResetDataButton,
                merge: true,
                child: InkWell(
                  onTap: () => _confirmReset(context),
                  borderRadius: BorderRadius.circular(AppSizes.cardRadius),
                  child: Container(
                    constraints: const BoxConstraints(
                      minHeight: AppSizes.minTapTarget,
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: <Widget>[
                        Icon(Icons.restart_alt_rounded, color: colors.text),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                'Reset demo data',
                                style: textTheme.bodyLarge,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                "Put this account's fields and crops back to "
                                'the start.',
                                style: textTheme.bodySmall?.copyWith(
                                  color: colors.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 28),
            TestId(
              TestIds.settingsLogoutButton,
              merge: true,
              child: OutlinedButton.icon(
                onPressed: () => _confirmLogOut(context),
                icon: Icon(Icons.logout_rounded, color: colors.error),
                label: Text(
                  'Log out',
                  style: textTheme.labelLarge?.copyWith(color: colors.error),
                ),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                  side: BorderSide(color: colors.border),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.text, required this.colors});

  final String text;
  final AppColorSet colors;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 8, 4, 8),
      child: Text(
        text,
        style: Theme.of(context).textTheme.titleSmall
            ?.copyWith(color: colors.textMuted),
      ),
    );
  }
}

class _ThemeOption extends StatelessWidget {
  const _ThemeOption({
    required this.testId,
    required this.label,
    required this.mode,
    required this.selected,
    required this.colors,
  });

  final String testId;
  final String label;
  final ThemeMode mode;
  final bool selected;
  final AppColorSet colors;

  @override
  Widget build(BuildContext context) {
    return TestId(
      testId,
      merge: true,
      child: InkWell(
        onTap: () => context.read<ThemeController>().setMode(mode),
        child: Container(
          constraints: const BoxConstraints(minHeight: AppSizes.minTapTarget),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
              Icon(
                selected
                    ? Icons.radio_button_checked
                    : Icons.radio_button_unchecked,
                color: selected ? colors.link : colors.border,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The Notifications part of Settings.
///
/// It reads Android's real answer every time the app comes back to the
/// front, so returning from Android's settings page shows the new state at
/// once, with no restart.
class _NotificationsSection extends StatefulWidget {
  const _NotificationsSection();

  static const String allowedTitle = 'Notifications are on';
  static const String allowedBody = 'Task reminders will show on this phone.';
  static const String offTitle = 'Notifications are off';
  static const String offBody =
      "Reminders can't show until you allow them in Android settings.";
  static const String notAskedTitle = 'Notifications are not set up yet';
  static const String notAskedBody =
      "You'll be asked the first time you add a reminder.";
  static const String testSent = 'Test notification on its way.';

  @override
  State<_NotificationsSection> createState() => _NotificationsSectionState();
}

class _NotificationsSectionState extends State<_NotificationsSection>
    with WidgetsBindingObserver {
  NotificationPermission? _state;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _read();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _read();
  }

  Future<void> _read() async {
    final NotificationService service = context.read<NotificationService>();
    final NotificationPermission found = await service.permission();
    if (!mounted) return;
    setState(() => _state = found);
  }

  Future<void> _openAndroidSettings() async {
    await context.read<NotificationService>().openAndroidSettings();
  }

  Future<void> _sendTest() async {
    final NotificationService service = context.read<NotificationService>();
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);

    final bool allowed = await TaskFormScreen.askForNotifications(context);
    if (mounted) await _read();
    if (!allowed) {
      AppSnackbar.showOn(messenger, TaskFormScreen.remindersOffMessage);
      return;
    }

    AppSnackbar.showOn(messenger, _NotificationsSection.testSent);
    // The wait happens here, inside the app. Closing the app before it is
    // over means nothing is sent, which is written up in test_ids.md.
    unawaited(service.sendTest());
  }

  @override
  Widget build(BuildContext context) {
    final AppColorSet colors = context.colors;
    final TextTheme textTheme = Theme.of(context).textTheme;
    final NotificationPermission state =
        _state ?? NotificationPermission.notAsked;
    final bool off = state == NotificationPermission.off;

    final String title;
    final String body;
    switch (state) {
      case NotificationPermission.allowed:
        title = _NotificationsSection.allowedTitle;
        body = _NotificationsSection.allowedBody;
      case NotificationPermission.off:
        title = _NotificationsSection.offTitle;
        body = _NotificationsSection.offBody;
      case NotificationPermission.notAsked:
        title = _NotificationsSection.notAskedTitle;
        body = _NotificationsSection.notAskedBody;
    }

    return TestId(
      TestIds.settingsNotificationsCard,
      container: true,
      child: Card(
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Icon(
                    state == NotificationPermission.allowed
                        ? Icons.notifications_active_outlined
                        : Icons.notifications_off_outlined,
                    color: off ? colors.warningText : colors.text,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        TestId(
                          TestIds.settingsNotificationsStateText,
                          child: Text(
                            title,
                            style: textTheme.bodyLarge?.copyWith(
                              color: off ? colors.warningText : colors.text,
                            ),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          body,
                          style: textTheme.bodySmall?.copyWith(
                            color: colors.textMuted,
                          ),
                        ),
                        if (off) ...<Widget>[
                          const SizedBox(height: 12),
                          TestId(
                            TestIds.settingsOpenAndroidSettingsButton,
                            merge: true,
                            child: OutlinedButton(
                              onPressed: _openAndroidSettings,
                              child: const Text('Open Android settings'),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text('Test notification', style: textTheme.bodyLarge),
                        const SizedBox(height: 2),
                        Text(
                          'Sends one in 10 seconds',
                          style: textTheme.bodySmall?.copyWith(
                            color: colors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  TestId(
                    TestIds.settingsTestNotificationButton,
                    merge: true,
                    child: TextButton(
                      onPressed: _sendTest,
                      child: const Text('Send'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
