import 'package:material_ui/material_ui.dart';

import '../../../app/app_colors.dart';
import '../../../app/app_theme.dart';
import '../../../shared/testing/test_id_wrapper.dart';
import '../../../shared/testing/test_ids.dart';

/// What the long-press menu on a group card can do.
enum GroupMenuAction { edit, delete }

/// The small sheet that opens when a group card is long pressed.
class GroupMenuSheet extends StatelessWidget {
  const GroupMenuSheet({super.key, required this.groupName});

  final String groupName;

  /// Shows the sheet and returns what was picked, or null when it is closed.
  static Future<GroupMenuAction?> show(
    BuildContext context, {
    required String groupName,
  }) {
    return showModalBottomSheet<GroupMenuAction>(
      context: context,
      builder: (BuildContext sheetContext) =>
          GroupMenuSheet(groupName: groupName),
    );
  }

  @override
  Widget build(BuildContext context) {
    final AppColorSet colors = context.colors;
    final TextTheme textTheme = Theme.of(context).textTheme;

    return TestId(
      TestIds.groupMenuSheet,
      container: true,
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
              child: Text(groupName, style: textTheme.titleMedium),
            ),
            _MenuOption(
              testId: TestIds.groupMenuEditOption,
              label: 'Edit group',
              icon: Icons.edit_outlined,
              action: GroupMenuAction.edit,
            ),
            _MenuOption(
              testId: TestIds.groupMenuDeleteOption,
              label: 'Delete group',
              icon: Icons.delete_outline,
              action: GroupMenuAction.delete,
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
  final GroupMenuAction action;

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
