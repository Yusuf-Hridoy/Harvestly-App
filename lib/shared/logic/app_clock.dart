/// The one place the app asks what today is.
///
/// Every date rule goes through this, so a test can fix the date and get the
/// same days-left numbers on every run.
class AppClock {
  const AppClock._();

  static DateTime Function() _source = DateTime.now;

  /// Right now, with the time of day included.
  static DateTime now() => _source();

  /// Today with the time of day cut off, so day maths is exact.
  static DateTime today() => dateOnly(_source());

  /// The same date with hours, minutes and smaller parts removed.
  static DateTime dateOnly(DateTime when) =>
      DateTime(when.year, when.month, when.day);

  /// Whole days from [from] to [to]. Negative when [to] is earlier.
  static int daysBetween(DateTime from, DateTime to) =>
      dateOnly(to).difference(dateOnly(from)).inDays;

  /// Makes the clock always return [fixed]. Tests call this in setUp.
  static void useFixed(DateTime fixed) => _source = () => fixed;

  /// Puts the real clock back. Tests call this in tearDown.
  static void useRealClock() => _source = DateTime.now;
}
