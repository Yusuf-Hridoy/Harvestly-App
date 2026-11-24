import 'package:material_ui/material_ui.dart';

import '../../app/app_colors.dart';
import '../../app/app_theme.dart';

/// The small rounded label that shows a crop stage, or the word "Empty".
///
/// Shared so the field card and the crop detail screen look the same.
class StageChip extends StatelessWidget {
  const StageChip({super.key, required this.label, this.quiet = false});

  /// The stage name, for example "Growing".
  final String label;

  /// True for "Empty", which uses the muted colors instead of the green ones.
  final bool quiet;

  @override
  Widget build(BuildContext context) {
    final AppColorSet colors = context.colors;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: quiet ? colors.background : colors.secondarySoft,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: quiet ? colors.border : colors.secondarySoft,
          width: AppSizes.borderWidth,
        ),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: quiet ? colors.textMuted : colors.onSecondarySoft,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
