import 'package:material_ui/material_ui.dart';

import '../../../app/app_colors.dart';
import '../../../app/app_theme.dart';
import '../../../data/farm_models.dart';
import '../../../shared/testing/test_id_wrapper.dart';
import '../../../shared/testing/test_ids.dart';

/// The soil type picker for the field form.
///
/// It is a bottom sheet and not a Material dropdown, because a dropdown puts
/// each choice inside a node that the test IDs cannot reach: the options come
/// out as plain text with `clickable="false"`, so Appium cannot tap them.
/// Every row here is its own clickable node.
class SoilPickerSheet extends StatelessWidget {
  const SoilPickerSheet({super.key, this.current});

  /// The soil already chosen, or null when nothing is chosen yet.
  final SoilType? current;

  static const Map<SoilType, String> testIds = <SoilType, String>{
    SoilType.loam: TestIds.fieldFormSoilOptionLoam,
    SoilType.clay: TestIds.fieldFormSoilOptionClay,
    SoilType.sandy: TestIds.fieldFormSoilOptionSandy,
    SoilType.silt: TestIds.fieldFormSoilOptionSilt,
  };

  /// Shows the sheet and returns the soil picked, or null when it is closed
  /// without picking.
  static Future<SoilType?> show(BuildContext context, SoilType? current) {
    return showModalBottomSheet<SoilType>(
      context: context,
      builder: (BuildContext sheetContext) => SoilPickerSheet(current: current),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
            child: Text(
              'Soil type',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          for (final SoilType soil in SoilType.values)
            _SoilOption(soil: soil, selected: soil == current),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _SoilOption extends StatelessWidget {
  const _SoilOption({required this.soil, required this.selected});

  final SoilType soil;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final AppColorSet colors = context.colors;

    return TestId(
      SoilPickerSheet.testIds[soil]!,
      merge: true,
      child: InkWell(
        onTap: () => Navigator.of(context).pop(soil),
        child: Container(
          constraints: const BoxConstraints(minHeight: AppSizes.minTapTarget),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  soil.label,
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
