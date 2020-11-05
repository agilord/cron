part of '../cron.dart';

/// The cron schedule.
class Schedule {
  final List<_CronParam> params;

  Schedule(this.params)
      : assert(params != null && params.isNotEmpty && params.length == 7);

  /// Parses the cron-formatted text and creates a schedule out of it.
  factory Schedule.parse(String cronFormat) {
    final p = cronFormat.split(RegExp('\\s+'));

    assert([5, 6, 7].contains(p.length));
    final parts = [
      if (p.length == 5) null,
      ...p,
      if (p.length == 5 || p.length == 6) null,
    ];

    return Schedule([
      _SecondsParam(parts[0]),
      _MinutesParam(parts[1]),
      _HoursParam(parts[2]),
      _DaysParam(parts[3]),
      _MonthsParam(parts[4]),
      _WeekdayParam(parts[5]),
      _YearsParam(parts[6]),
    ]);
  }

  bool get _hasSeconds =>
      params[0] is _SecondsParam && (params[0] as _SecondsParam).hasSeconds;

  @override
  String toString() => params.join('\n');
}

abstract class ScheduledTask {
  Schedule get schedule;
  Future cancel();
}
