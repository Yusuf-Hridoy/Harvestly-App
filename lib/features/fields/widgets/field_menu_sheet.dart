import 'package:material_ui/material_ui.dart';

import '../../../app/app_colors.dart';
import '../../../app/app_theme.dart';
import '../../../shared/testing/test_id_wrapper.dart';
import '../../../shared/testing/test_ids.dart';

/// What the long-press menu on a field card can do.
enum FieldMenuAction { edit, delete }

/// The small sheet that opens when a field card is long pressed.
class FieldMenuSheet extends StatelessWidget {
  const FieldMenuSheet({super.key, required this.fieldName});

  final String fieldName;

  /// Shows the sheet and returns what was picked, or null when it is closed.
  static Future<FieldMenuAction?> show(
    BuildContext context, {
    required String fieldName,
  }) {
    return showModalBottomSheet<FieldMenuAction>(
      context: context,
      builder: (BuildContext sheetContext) =>
          FieldMenuSheet(fieldName: fieldName),
    );
  }

  @override
  Widget build(BuildContext context) {
    final AppColorSet colors = context.colors;
    final TextTheme textTheme = Theme.of(context).textTheme;

    return TestId(
      TestIds.fieldMenuSheet,
      container: true,
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
              child: Text(fieldName, style: textTheme.titleMedium),
            ),
            _MenuOption(
              testId: TestIds.fieldMenuEditOption,
              label: 'Edit field',
              icon: Icons.edit_outlined,
              action: FieldMenuAction.edit,
            ),
            _MenuOption(
              testId: TestIds.fieldMenuDeleteOption,
              label: 'Delete field',
              icon: Icons.delete_outline,
              action: FieldMenuAction.delete,
              color: colors.error,
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _MenuOption extends StatelessWidget {
  const _MenuOption({
    required this.testId,
    required this.label,
    required this.icon,
    required this.action,
    this.color,
  });

  final String testId;
  final String label;
  final IconData icon;
  final FieldMenuAction action;

  /// Set for Delete, which uses the error color.
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return TestId(
      testId,
      merge: true,
      child: InkWell(
        onTap: () => Navigator.of(context).pop(action),
        child: Container(
          constraints: const BoxConstraints(minHeight: AppSizes.minTapTarget),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(
            children: <Widget>[
              Icon(icon, size: 20, color: color),
              const SizedBox(width: 14),
              Text(label, style: textTheme.bodyLarge?.copyWith(color: color)),
            ],
          ),
        ),
      ),
    );
  }
}
