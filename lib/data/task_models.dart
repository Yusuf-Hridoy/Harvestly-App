import '../shared/logic/app_clock.dart';

/// How often a task comes back after it is done.
enum Repeat {
  none('None'),
  daily('Daily'),
  weekly('Weekly'),
  monthly('Monthly');

  const Repeat(this.label);

  /// The chip text on the task form.
  final String label;

  /// The repeat saved under this name, or None when the name is unknown.
  static Repeat fromName(String? name) {
    for (final Repeat repeat in Repeat.values) {
      if (repeat.name == name) return repeat;
    }
    return Repeat.none;
  }
}

/// How long before the due time the reminder shows.
enum ReminderOffset {
  none('None', null),
  atDue('At due time', Duration.zero),
  hourBefore('1 hour before', Duration(hours: 1)),
  dayBefore('1 day before', Duration(days: 1));

  const ReminderOffset(this.label, this.before);

  /// The chip text on the task form.
  final String label;

  /// How far before the due time the reminder shows, or null for no
  /// reminder.
  final Duration? before;

  /// Whether the task has a reminder at all.
  bool get isOn => before != null;

  /// The reminder saved under this name, or None when the name is unknown.
  static ReminderOffset fromName(String? name) {
    for (final ReminderOffset offset in ReminderOffset.values) {
      if (offset.name == name) return offset;
    }
    return ReminderOffset.none;
  }
}

/// What a task can be linked to.
enum TaskLinkKind {
  field('Fields'),
  group('Animals');

  const TaskLinkKind(this.tag);

  /// The small tag next to the name on the form, "Fields" or "Animals".
  final String tag;

  /// The kind saved under this name, or Fields when the name is unknown.
  static TaskLinkKind fromName(String? name) {
    for (final TaskLinkKind kind in TaskLinkKind.values) {
      if (kind.name == name) return kind;
    }
    return TaskLinkKind.field;
  }
}

/// The field or animal group a task belongs to.
class TaskLink {
  const TaskLink({required this.kind, required this.id});

  factory TaskLink.fromJson(Map<String, dynamic> json) => TaskLink(
    kind: TaskLinkKind.fromName(json['kind'] as String?),
    id: json['id'] as String,
  );

  final TaskLinkKind kind;

  /// The field id or the animal group id.
  final String id;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'kind': kind.name,
    'id': id,
  };

  @override
  bool operator ==(Object other) =>
      other is TaskLink && other.kind == kind && other.id == id;

  @override
  int get hashCode => Object.hash(kind, id);
}

/// Which part of the Tasks list a task shows up in.
enum TaskGroup {
  overdue('Overdue'),
  today('Today'),
  upcoming('Upcoming'),
  done('Done');

  const TaskGroup(this.label);

  /// The heading text, without the count.
  final String label;
}

/// One job on the farm, with a due date, a repeat and a reminder.
class FarmTask {
  const FarmTask({
    required this.id,
    required this.title,
    this.note = '',
    required this.dueAt,
    this.repeat = Repeat.none,
    this.link,
    this.reminder = ReminderOffset.none,
    this.snoozedUntil,
    this.doneAt,
  });

  factory FarmTask.fromJson(Map<String, dynamic> json) => FarmTask(
    id: json['id'] as String,
    title: json['title'] as String,
    note: (json['note'] as String?) ?? '',
    dueAt: DateTime.parse(json['dueAt'] as String),
    repeat: Repeat.fromName(json['repeat'] as String?),
    link: json['link'] == null
        ? null
        : TaskLink.fromJson(json['link'] as Map<String, dynamic>),
    reminder: ReminderOffset.fromName(json['reminder'] as String?),
    snoozedUntil: _date(json['snoozedUntil']),
    doneAt: _date(json['doneAt']),
  );

  static DateTime? _date(Object? value) =>
      value == null ? null : DateTime.parse(value as String);

  final String id;

  /// What to do, for example "Water tomato beds".
  final String title;

  /// An optional note, up to 200 characters. Empty when there is none.
  final String note;

  /// The local date and time it is due, to the minute.
  final DateTime dueAt;

  final Repeat repeat;

  /// The field or animal group this belongs to, or null for a general task.
  final TaskLink? link;

  final ReminderOffset reminder;

  /// When a snoozed reminder should come back, instead of [reminder].
  ///
  /// Set by the Snooze button on the notification, and cleared when the task
  /// is edited or marked done.
  final DateTime? snoozedUntil;

  /// When the task was done, or null while it is still open.
  final DateTime? doneAt;

  /// Whether the task is already done.
  bool get isDone => doneAt != null;

  /// Whether the task is still open.
  bool get isOpen => doneAt == null;

  /// The due date with the time of day cut off.
  DateTime get dueDate => AppClock.dateOnly(dueAt);

  /// Whole days from today to the due date. Negative when it is late.
  int get daysFromToday => AppClock.daysBetween(AppClock.today(), dueDate);

  /// Whether the task repeats, which changes what completing it does.
  bool get repeats => repeat != Repeat.none;

  FarmTask copyWith({
    String? title,
    String? note,
    DateTime? dueAt,
    Repeat? repeat,
    TaskLink? link,
    bool clearLink = false,
    ReminderOffset? reminder,
    DateTime? snoozedUntil,
    bool clearSnooze = false,
    DateTime? doneAt,
    bool clearDone = false,
  }) => FarmTask(
    id: id,
    title: title ?? this.title,
    note: note ?? this.note,
    dueAt: dueAt ?? this.dueAt,
    repeat: repeat ?? this.repeat,
    link: clearLink ? null : (link ?? this.link),
    reminder: reminder ?? this.reminder,
    snoozedUntil: clearSnooze ? null : (snoozedUntil ?? this.snoozedUntil),
    doneAt: clearDone ? null : (doneAt ?? this.doneAt),
  );

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'title': title,
    'note': note,
    'dueAt': dueAt.toIso8601String(),
    'repeat': repeat.name,
    if (link != null) 'link': link!.toJson(),
    'reminder': reminder.name,
    if (snoozedUntil != null) 'snoozedUntil': snoozedUntil!.toIso8601String(),
    if (doneAt != null) 'doneAt': doneAt!.toIso8601String(),
  };
}
