import 'package:material_ui/material_ui.dart';

import '../../../app/app_colors.dart';
import '../../../app/app_theme.dart';
import '../../../data/animal_models.dart';
import '../../../data/farm_models.dart';
import '../../../data/task_models.dart';
import '../../../shared/testing/test_id_wrapper.dart';
import '../../../shared/testing/test_ids.dart';

/// What the link picker gave back.
///
/// A choice of "None" and closing the sheet without choosing are different
/// things, so the sheet returns this instead of a bare [TaskLink].
class LinkChoice {
  const LinkChoice(this.link);

  /// The field or group picked, or null for "None".
  final TaskLink? link;
}

/// Picks the field or animal group a task belongs to.
///
/// A sheet rather than a dropdown, for the same reason as the soil picker:
/// a dropdown's options come out of the Android tree as not clickable, so
/// Appium cannot tap them.
class LinkPickerSheet extends StatelessWidget {
  const LinkPickerSheet({
    super.key,
    required this.fields,
    required this.groups,
    required this.chosen,
  });

  final List<Field> fields;
  final List<AnimalGroup> groups;

  /// What the form has now, so that row can show a tick.
  final TaskLink? chosen;

  /// Shows the sheet. Returns null when it is closed without choosing.
  static Future<LinkChoice?> show(
    BuildContext context, {
    required List<Field> fields,
    required List<AnimalGroup> groups,
    required TaskLink? chosen,
  }) {
    // A to Z, so a long list is easy to read.
    final List<Field> sortedFields = List<Field>.of(fields)
      ..sort(
        (Field a, Field b) =>
            a.name.toLowerCase().compareTo(b.name.toLowerCase()),
      );
    final List<AnimalGroup> sortedGroups = List<AnimalGroup>.of(groups)
      ..sort(
        (AnimalGroup a, AnimalGroup b) =>
            a.name.toLowerCase().compareTo(b.name.toLowerCase()),
      );

    return showModalBottomSheet<LinkChoice>(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext sheetContext) => LinkPickerSheet(
        fields: sortedFields,
        groups: sortedGroups,
        chosen: chosen,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final AppColorSet colors = context.colors;
    final TextTheme textTheme = Theme.of(context).textTheme;

    return TestId(
      TestIds.linkPickerSheet,
      container: true,
      child: SafeArea(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.7,
          ),
          child: ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.only(bottom: 8),
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                child: Text('Linked to', style: textTheme.titleMedium),
              ),
              _Option(
                testId: TestIds.linkPickerNoneOption,
                label: 'None',
                icon: Icons.block_outlined,
                selected: chosen == null,
                choice: const LinkChoice(null),
              ),
              if (fields.isNotEmpty) _Heading(text: 'Fields', colors: colors),
              for (final Field field in fields)
                _Option(
                  testId: TestIds.linkPickerFieldOption(field.id),
                  label: field.name,
                  icon: Icons.grid_view_rounded,
                  selected:
                      chosen?.kind == TaskLinkKind.field &&
                      chosen?.id == field.id,
                  choice: LinkChoice(
                    TaskLink(kind: TaskLinkKind.field, id: field.id),
                  ),
                ),
              if (groups.isNotEmpty) _Heading(text: 'Animals', colors: colors),
              for (final AnimalGroup group in groups)
                _Option(
                  testId: TestIds.linkPickerGroupOption(group.id),
                  label: group.name,
                  icon: Icons.egg_outlined,
                  selected:
                      chosen?.kind == TaskLinkKind.group &&
                      chosen?.id == group.id,
                  choice: LinkChoice(
                    TaskLink(kind: TaskLinkKind.group, id: group.id),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Heading extends StatelessWidget {
  const _Heading({required this.text, required this.colors});

  final String text;
  final AppColorSet colors;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 6),
      child: Text(
        text,
        style: Theme.of(context).textTheme.titleSmall
            ?.copyWith(color: colors.textMuted),
      ),
    );
  }
}

class _Option extends StatelessWidget {
  const _Option({
    required this.testId,
    required this.label,
    required this.icon,
    required this.selected,
    required this.choice,
  });

  final String testId;
  final String label;
  final IconData icon;
  final bool selected;
  final LinkChoice choice;

  @override
  Widget build(BuildContext context) {
    final AppColorSet colors = context.colors;

    return TestId(
      testId,
      merge: true,
      child: InkWell(
        onTap: () => Navigator.of(context).pop(choice),
        child: Container(
          constraints: const BoxConstraints(minHeight: AppSizes.minTapTarget),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(
            children: <Widget>[
              Icon(icon, size: 20, color: colors.textMuted),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
              if (selected)
                Icon(Icons.check_rounded, size: 20, color: colors.link),
            ],
          ),
        ),
      ),
    );
  }
}
