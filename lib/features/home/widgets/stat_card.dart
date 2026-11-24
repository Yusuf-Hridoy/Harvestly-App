import 'package:material_ui/material_ui.dart';

import '../../../app/app_colors.dart';
import '../../../app/app_theme.dart';
import '../../../shared/testing/test_id_wrapper.dart';

/// One number on the home screen, such as "Fields" or "Eggs today".
class StatCard extends StatelessWidget {
  const StatCard({
    super.key,
    required this.testId,
    required this.label,
    required this.value,
    required this.icon,
  });

  /// The card's own test ID.
  final String testId;

  /// What the number means, for example "Eggs today".
  final String label;

  /// The number itself, already formatted.
  final String value;

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final AppColorSet colors = context.colors;
    final TextTheme textTheme = Theme.of(context).textTheme;

    return TestId(
      testId,
      container: true,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Container(
                height: 36,
                width: 36,
                decoration: BoxDecoration(
                  color: colors.secondarySoft,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 20, color: colors.secondary),
              ),
              const SizedBox(height: 12),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(value, style: textTheme.headlineMedium),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: textTheme.bodySmall?.copyWith(color: colors.textMuted),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
