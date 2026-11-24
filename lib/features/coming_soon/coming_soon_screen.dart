import 'package:material_ui/material_ui.dart';

import '../../app/app_colors.dart';
import '../../app/app_theme.dart';
import '../../shared/testing/test_id_wrapper.dart';

/// Placeholder for a tab that is built in a later phase.
class ComingSoonScreen extends StatelessWidget {
  const ComingSoonScreen({
    super.key,
    required this.testId,
    required this.title,
    required this.icon,
  });

  /// The screen's own test ID.
  final String testId;

  /// The tab title shown in the app bar.
  final String title;

  /// The large icon in the middle.
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final AppColorSet colors = context.colors;

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: TestId(
        testId,
        container: true,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.screenPadding),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Container(
                  height: 96,
                  width: 96,
                  decoration: BoxDecoration(
                    color: colors.secondarySoft,
                    borderRadius: BorderRadius.circular(AppSizes.cardRadius),
                  ),
                  child: Icon(icon, size: 48, color: colors.onSecondarySoft),
                ),
                const SizedBox(height: 20),
                Text(
                  'This part comes in a later phase.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge
                      ?.copyWith(color: colors.textMuted),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
