import 'package:material_ui/material_ui.dart';

import '../../../app/app_colors.dart';
import '../../../app/app_theme.dart';
import '../../../shared/testing/test_id_wrapper.dart';
import '../../../shared/testing/test_ids.dart';

/// Explains why Harvestly wants to send notifications, before Android's own
/// permission pop-up.
///
/// Android only lets an app ask once, so the user sees why first. Tapping
/// Not now keeps the task and shows this sheet again next time.
class ReminderExplainerSheet extends StatelessWidget {
  const ReminderExplainerSheet({super.key});

  static const String title = 'Turn on reminders?';
  static const String body =
      'Harvestly can send you a reminder when a task is due, so you do not '
      'have to open the app to remember. Android will ask you next.';

  /// Shows the sheet. True means the user wants to carry on to Android's
  /// pop-up; false or null means not now.
  static Future<bool> show(BuildContext context) async {
    final bool? carryOn = await showModalBottomSheet<bool>(
      context: context,
      builder: (BuildContext sheetContext) => const ReminderExplainerSheet(),
    );
    return carryOn ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final AppColorSet colors = context.colors;
    final TextTheme textTheme = Theme.of(context).textTheme;

    return TestId(
      TestIds.reminderExplainerSheet,
      container: true,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Container(
                    height: 44,
                    width: 44,
                    decoration: BoxDecoration(
                      color: colors.secondarySoft,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.notifications_active_outlined,
                      color: colors.onSecondarySoft,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: Text(title, style: textTheme.titleMedium)),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                body,
                style: textTheme.bodyMedium?.copyWith(color: colors.textMuted),
              ),
              const SizedBox(height: 20),
              TestId(
                TestIds.reminderExplainerContinueButton,
                merge: true,
                child: FilledButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('Continue'),
                ),
              ),
              const SizedBox(height: 8),
              TestId(
                TestIds.reminderExplainerNotNowButton,
                merge: true,
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                  ),
                  child: const Text('Not now'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
