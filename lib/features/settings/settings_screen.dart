import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../../app/app_colors.dart';
import '../../app/app_theme.dart';
import '../../data/demo_accounts.dart';
import '../../shared/app_info/app_version_reader.dart';
import '../../shared/testing/test_id_wrapper.dart';
import '../../shared/testing/test_ids.dart';
import '../login/login_controller.dart';
import 'theme_controller.dart';

/// The More tab: account, appearance, app version and log out.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

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
