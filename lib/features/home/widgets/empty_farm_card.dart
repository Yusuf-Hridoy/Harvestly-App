import 'package:material_ui/material_ui.dart';

import '../../../app/app_colors.dart';
import '../../../app/app_theme.dart';
import '../../../shared/testing/test_id_wrapper.dart';
import '../../../shared/testing/test_ids.dart';

/// Shown on the home screen when the account has nothing on the farm yet.
class EmptyFarmCard extends StatelessWidget {
  const EmptyFarmCard({super.key, required this.onAddFirstField});

  /// Called when "Add your first field" is tapped.
  final VoidCallback onAddFirstField;

  @override
  Widget build(BuildContext context) {
    final AppColorSet colors = context.colors;
    final TextTheme textTheme = Theme.of(context).textTheme;

    return TestId(
      TestIds.homeEmptyFarmCard,
      container: true,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                height: 48,
                width: 48,
                decoration: BoxDecoration(
                  color: colors.secondarySoft,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.spa_outlined, color: colors.onSecondarySoft),
              ),
              const SizedBox(height: 16),
              Text('Welcome to Harvestly', style: textTheme.headlineSmall),
              const SizedBox(height: 8),
              Text(
                'Your farm is empty. Add your first field to get started.',
                style: textTheme.bodyMedium?.copyWith(color: colors.textMuted),
              ),
              const SizedBox(height: 20),
              TestId(
                TestIds.homeEmptyAddFieldButton,
                merge: true,
                child: FilledButton(
                  onPressed: onAddFirstField,
                  child: const Text('Add your first field'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
