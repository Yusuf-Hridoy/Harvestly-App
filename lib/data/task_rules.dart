import '../shared/logic/app_clock.dart';
import '../shared/logic/date_text.dart';
import 'task_models.dart';

/// Every date rule for tasks: which group a task falls in, when a repeating
/// task comes back, and when its reminder should show.
///
/// All of it is plain date maths on [AppClock], so a test can fix today and
/// get the same answers on every run.
class TaskRules {
  const TaskRules._();

  /// The word used when a task has no field or animal group.
  static const String generalName = 'General';

  /// Which part of the Tasks list a task belongs in.
  ///
  /// Only the date counts, never the time: a task due at 7:00 AM is still in
  /// Today at 8:00 AM.
  static TaskGroup groupOf(FarmTask task) {
    if (task.isDone) return TaskGroup.done;
    final int days = task.daysFromToday;
    if (days < 0) return TaskGroup.overdue;
    if (days == 0) return TaskGroup.today;
    return TaskGroup.upcoming;
  }

  /// How many days a done task stays in the Done group.
  static const int doneDaysShown = 30;

  /// Whether a done task is recent enough to still show under Done.
  static bool showsUnderDone(FarmTask task) {
    final DateTime? done = task.doneAt;
    if (done == null) return false;
    return AppClock.daysBetween(done, AppClock.today()) <= doneDaysShown;
  }

  /// "Late by 2 days", "Late by 1 day", for an overdue task.
  static String lateText(FarmTask task) {
    final int late = -task.daysFromToday;
    return late == 1 ? 'Late by 1 day' : 'Late by $late days';
  }

  /// The line under a task title on the Tasks list.
  ///
  /// [linkName] is the field or animal group name, or "General".
  static String lineFor(FarmTask task, String linkName) {
    switch (groupOf(task)) {
      case TaskGroup.overdue:
        return '$linkName · ${DateText.weekdayDayMonth(task.dueAt)} · '
            '${lateText(task)}';
      case TaskGroup.today:
        return '$linkName · ${DateText.timeOfDay(task.dueAt)}';
      case TaskGroup.upcoming:
        return '$linkName · ${DateText.weekdayDayMonth(task.dueAt)}';
      case TaskGroup.done:
        return 'Done ${DateText.weekdayDayMonth(task.doneAt ?? task.dueAt)}';
    }
  }

  /// The chip on Task detail: "Today · 5:00 PM", "Fri 27 Nov · 10:00 AM",
  /// "Late by 2 days", or "Done Wed 25 Nov".
  static String dueChipText(FarmTask task) {
    switch (groupOf(task)) {
      case TaskGroup.overdue:
        return lateText(task);
      case TaskGroup.today:
        return 'Today · ${DateText.timeOfDay(task.dueAt)}';
      case TaskGroup.upcoming:
        return '${DateText.weekdayDayMonth(task.dueAt)} · '
            '${DateText.timeOfDay(task.dueAt)}';
      case TaskGroup.done:
        return 'Done ${DateText.weekdayDayMonth(task.doneAt ?? task.dueAt)}';
    }
  }

  /// The Repeat row on Task detail.
  static String repeatText(FarmTask task) {
    switch (task.repeat) {
      case Repeat.none:
        return 'Does not repeat';
      case Repeat.daily:
        return 'Every day';
      case Repeat.weekly:
        return 'Every week, on ${DateText.weekdayShort(task.dueAt)}';
      case Repeat.monthly:
        return 'Every month, on the ${DateText.ordinalDay(task.dueAt.day)}';
    }
  }

  /// The Reminder row on Task detail: "Snoozed until 5:00 PM",
  /// "4:00 PM, 1 hour before", or "None".
  static String reminderText(FarmTask task) {
    final DateTime? snoozed = task.snoozedUntil;
    if (snoozed != null) {
      return 'Snoozed until ${DateText.timeOfDay(snoozed)}';
    }
    if (!task.reminder.isOn) return 'None';
    final DateTime? at = reminderTime(task);
    if (at == null) return 'None';
    return '${DateText.timeOfDay(at)}, ${task.reminder.label.toLowerCase()}';
  }

  /// When the reminder for this task should show, or null when it has none.
  ///
  /// A snooze replaces the reminder time until the task is edited or done.
  static DateTime? reminderTime(FarmTask task) {
    if (task.isDone) return null;
    final DateTime? snoozed = task.snoozedUntil;
    if (snoozed != null) return snoozed;
    final Duration? before = task.reminder.before;
    if (before == null) return null;
    return task.dueAt.subtract(before);
  }

  /// The next due date after [dueAt] for one step of [repeat].
  ///
  /// Monthly keeps the same day of the month, or the last day when the next
  /// month is shorter: 31 Jan becomes 28 Feb, or 29 Feb in a leap year.
  static DateTime stepOnce(DateTime dueAt, Repeat repeat) {
    switch (repeat) {
      case Repeat.none:
        return dueAt;
      case Repeat.daily:
        return dueAt.add(const Duration(days: 1));
      case Repeat.weekly:
        return dueAt.add(const Duration(days: 7));
      case Repeat.monthly:
        return _addOneMonth(dueAt);
    }
  }

  /// The due date of the task that replaces a finished repeating one.
  ///
  /// It steps forward until the new date is today or later, so finishing a
  /// task several periods late still lands on a date the user can act on.
  static DateTime nextDueAt(DateTime dueAt, Repeat repeat) {
    if (repeat == Repeat.none) return dueAt;
    final DateTime today = AppClock.today();
    DateTime next = stepOnce(dueAt, repeat);
    // A daily task finished a year late would otherwise loop forever on a
    // broken clock, so the step count is capped at a very high number.
    int guard = 0;
    while (AppClock.dateOnly(next).isBefore(today) && guard < 10000) {
      next = stepOnce(next, repeat);
      guard++;
    }
    return next;
  }

  /// The same date one month on, clamped to the last day of that month.
  static DateTime _addOneMonth(DateTime when) {
    final int month = when.month == 12 ? 1 : when.month + 1;
    final int year = when.month == 12 ? when.year + 1 : when.year;
    final int lastDay = _daysInMonth(year, month);
    return DateTime(
      year,
      month,
      when.day < lastDay ? when.day : lastDay,
      when.hour,
      when.minute,
    );
  }

  /// How many days the given month has.
  static int _daysInMonth(int year, int month) =>
      DateTime(year, month + 1, 0).day;

  /// Open tasks first by due date and time, then done tasks newest first.
  static List<FarmTask> sorted(List<FarmTask> tasks, TaskGroup group) {
    final List<FarmTask> out = List<FarmTask>.of(tasks);
    if (group == TaskGroup.done) {
      out.sort((FarmTask a, FarmTask b) {
        final DateTime aDone = a.doneAt ?? a.dueAt;
        final DateTime bDone = b.doneAt ?? b.dueAt;
        return bDone.compareTo(aDone);
      });
    } else {
      out.sort((FarmTask a, FarmTask b) => a.dueAt.compareTo(b.dueAt));
    }
    return out;
  }
}
