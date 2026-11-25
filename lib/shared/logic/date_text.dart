/// Turns dates into the short text Harvestly shows on screen.
///
/// Kept in one file so every screen writes a date the same way, and so no
/// screen needs a date formatting package.
class DateText {
  const DateText._();

  static const List<String> _shortMonths = <String>[
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  /// "2 Oct 2026".
  static String dayMonthYear(DateTime when) =>
      '${when.day} ${_shortMonths[when.month - 1]} ${when.year}';

  /// "2 Oct", used where the year is not needed.
  static String dayMonth(DateTime when) =>
      '${when.day} ${_shortMonths[when.month - 1]}';

  static const List<String> _shortWeekdays = <String>[
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
    'Sun',
  ];

  /// "Tue", the short weekday used under the 7-day chart bars.
  static String weekdayShort(DateTime when) => _shortWeekdays[when.weekday - 1];

  /// "Tue 24 Nov", the line under the production chart.
  static String weekdayDayMonth(DateTime when) =>
      '${weekdayShort(when)} ${dayMonth(when)}';

  /// "7:00 AM". Harvestly always shows times in 12-hour form.
  static String timeOfDay(DateTime when) {
    final int hour = when.hour % 12 == 0 ? 12 : when.hour % 12;
    final String minute = when.minute.toString().padLeft(2, '0');
    return '$hour:$minute ${when.hour < 12 ? 'AM' : 'PM'}';
  }

  /// "1st", "2nd", "3rd", "25th": the day of the month in words.
  static String ordinalDay(int day) {
    // 11th, 12th and 13th break the pattern, so they are checked first.
    if (day >= 11 && day <= 13) return '${day}th';
    switch (day % 10) {
      case 1:
        return '${day}st';
      case 2:
        return '${day}nd';
      case 3:
        return '${day}rd';
      default:
        return '${day}th';
    }
  }
}
