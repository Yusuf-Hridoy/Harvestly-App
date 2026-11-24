import 'package:material_ui/material_ui.dart';

import '../../../app/app_colors.dart';
import '../../../app/app_theme.dart';
import '../../../data/sample_farm_data.dart';
import '../../../shared/testing/test_id_wrapper.dart';
import '../../../shared/testing/test_ids.dart';

/// Today's weather and the warning line under it. Static text in Phase 1.
class WeatherCard extends StatelessWidget {
  const WeatherCard({super.key, required this.weather});

  final FarmWeather weather;

  @override
  Widget build(BuildContext context) {
    final AppColorSet colors = context.colors;
    final TextTheme textTheme = Theme.of(context).textTheme;

    return TestId(
      TestIds.homeWeatherCard,
      container: true,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                height: 44,
                width: 44,
                decoration: BoxDecoration(
                  color: colors.secondarySoft,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.wb_sunny_outlined,
                  color: colors.onSecondarySoft,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(weather.summary, style: textTheme.headlineSmall),
                    const SizedBox(height: 6),
                    TestId(
                      TestIds.homeWeatherWarningText,
                      child: Text(
                        weather.warning,
                        style: textTheme.bodyMedium?.copyWith(
                          color: colors.warningText,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
