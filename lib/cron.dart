// Copyright (c) 2016, Agilord. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'dart:async';

import 'package:clock/clock.dart';
import 'package:cron/src/job.dart';

import 'src/constraint_parser.dart';
import 'src/job_manager.dart';

export 'src/constraint_parser.dart' show ScheduleParseException;

final _whitespacesRegExp = RegExp('\\s+');

/// A task may return a Future to indicate when it is completed. If it wouldn't
/// complete before [Cron] calls it again, it will be delayed.
typedef Task = FutureOr<dynamic> Function();

/// A cron-like time-based job scheduler.
abstract class Cron {
  /// A cron-like time-based job scheduler.
  factory Cron() => _Cron();

  /// Schedules a [task] running specified by the [schedule].
  ScheduledTask schedule(Schedule schedule, Task task);

  /// Closes the cron instance and doesn't accept new tasks anymore.
  Future close();

  /// Returns `true` if the task with the specified [taskId] is running.
  bool isRunning(String taskId);

  /// Returns the count of the jobs running with the specified [taskId].
  int count(String taskId);
}

/// The cron schedule.
class Schedule {
  /// The seconds a Task should be started.
  final List<int>? seconds;

  /// The minutes a Task should be started.
  final List<int>? minutes;

  /// The hours a Task should be started.
  final List<int>? hours;

  /// The days a Task should be started.
  final List<int>? days;

  /// The months a Task should be started.
  final List<int>? months;

  /// The weekdays a Task should be started.
  final List<int>? weekdays;

  /// Test if this schedule should run at the specified time.
  bool shouldRunAt(DateTime time) {
    if (seconds?.contains(time.second) == false) return false;
    if (minutes?.contains(time.minute) == false) return false;
    if (hours?.contains(time.hour) == false) return false;
    if (days?.contains(time.day) == false) return false;
    if (weekdays?.contains(time.weekday) == false) return false;
    if (months?.contains(time.month) == false) return false;
    return true;
  }

  factory Schedule({
    /// The seconds a Task should be started.
    /// Can be one of `int`, `List<int>` or `String` or `null` (= match all).
    dynamic seconds,

    /// The minutes a Task should be started.
    /// Can be one of `int`, `List<int>` or `String` or `null` (= match all).
    dynamic minutes,

    /// The hours a Task should be started.
    /// Can be one of `int`, `List<int>` or `String` or `null` (= match all).
    dynamic hours,

    /// The days a Task should be started.
    /// Can be one of `int`, `List<int>` or `String` or `null` (= match all).
    dynamic days,

    /// The months a Task should be started.
    /// Can be one of `int`, `List<int>` or `String` or `null` (= match all).
    dynamic months,

    /// The weekdays a Task should be started.
    /// Can be one of `int`, `List<int>` or `String` or `null` (= match all).
    dynamic weekdays,
  }) {
    final parsedSeconds =
        parseConstraint(seconds)?.where((x) => x >= 0 && x <= 59).toList();
    final parsedMinutes =
        parseConstraint(minutes)?.where((x) => x >= 0 && x <= 59).toList();
    final parsedHours =
        parseConstraint(hours)?.where((x) => x >= 0 && x <= 23).toList();
    final parsedDays =
        parseConstraint(days)?.where((x) => x >= 1 && x <= 31).toList();
    final parsedMonths =
        parseConstraint(months)?.where((x) => x >= 1 && x <= 12).toList();
    final parsedWeekdays = parseConstraint(weekdays)
        ?.where((x) => x >= 0 && x <= 7)
        .map((x) => x == 0 ? 7 : x)
        .toSet()
        .toList();
    return Schedule._(parsedSeconds, parsedMinutes, parsedHours, parsedDays,
        parsedMonths, parsedWeekdays);
  }

  /// Parses the cron-formatted text and creates a schedule out of it.
  factory Schedule.parse(String cronFormat) {
    final p = cronFormat
        .split(_whitespacesRegExp)
        .where((p) => p.isNotEmpty)
        .toList();
    assert(p.length == 5 || p.length == 6);
    final parts = [
      if (p.length == 5) null,
      ...p,
    ];
    return Schedule(
      seconds: parts[0],
      minutes: parts[1],
      hours: parts[2],
      days: parts[3],
      months: parts[4],
      weekdays: parts[5],
    );
  }

  Schedule._(this.seconds, this.minutes, this.hours, this.days, this.months,
      this.weekdays);

  bool get _hasSeconds =>
      seconds != null &&
      seconds!.isNotEmpty &&
      (seconds!.length != 1 || !seconds!.contains(0));

  /// Converts the schedule into a cron-formatted string.
  String toCronString({bool hasSecond = false}) {
    return [
      if (hasSecond) _convertToCronString(seconds),
      _convertToCronString(minutes),
      _convertToCronString(hours),
      _convertToCronString(days),
      _convertToCronString(months),
      _convertToCronString(weekdays),
    ].join(' ');
  }

  String _convertToCronString(List<int>? list) {
    if (list == null || list.isEmpty) {
      return '*';
    } else {
      return list.join(',');
    }
  }
}

abstract class ScheduledTask {

  String get id;

  Schedule get schedule;

  Task get task;

  Future cancel();
}

const int _millisecondsPerSecond = 1000;

class _Cron implements Cron {

  _Cron() : _jobManager = JobManager();

  bool _closed = false;
  Timer? _timer;
  final _schedules = <_ScheduledTask>[];
  final JobManager _jobManager;

  @override
  ScheduledTask schedule(Schedule schedule, Task task) {
    if (_closed) throw Exception('Closed.');
    final st = _ScheduledTask(schedule, task);
    _schedules.add(st);
    _scheduleNextTick();
    return st;
  }

  @override
  bool isRunning(String taskId) {
    return _jobManager.isRunning(taskId);
  }

  @override
  int count(String taskId) {
    return _jobManager.count(taskId);
  }

  @override
  Future close() async {
    _closed = true;
    _timer?.cancel();
    _timer = null;
    for (final schedule in _schedules) {
      await schedule.cancel();
    }
  }

  void _scheduleNextTick() {
    if (_closed) return;
    if (_timer != null || _schedules.isEmpty) return;
    final now = clock.now();
    final isTickSeconds = _schedules.any((task) => task.schedule._hasSeconds);
    final ms = (isTickSeconds ? 1 : 60) * _millisecondsPerSecond -
        (now.millisecondsSinceEpoch %
            ((isTickSeconds ? 1 : 60) * _millisecondsPerSecond));
    _timer = Timer(Duration(milliseconds: ms), _tick);
  }

  void _tick() {
    _timer = null;
    final now = clock.now();
    for (final schedule in _schedules) {
      final job = schedule.tick(now);
      if (job != null) {
        _jobManager.start(job, schedule.task);
      }
    }
    _scheduleNextTick();
  }
}

class _ScheduledTask implements ScheduledTask {

  @override
  String get id => '${task.hashCode}';

  @override
  final Schedule schedule;

  @override
  final Task task;

  bool _closed = false;

  /// The datetime a Task last run.
  DateTime lastTime = DateTime(0, 0, 0, 0, 0, 0, 0);

  _ScheduledTask(this.schedule, this.task);

  Job? tick(DateTime now) {
    if (_closed) return null;
    if (!schedule.shouldRunAt(now)) return null;
    if ((schedule.seconds == null || lastTime.second == now.second) &&
        (schedule.minutes == null || lastTime.minute == now.minute) &&
        (schedule.hours == null || lastTime.hour == now.hour) &&
        (schedule.days == null || lastTime.day == now.day) &&
        (schedule.months == null || lastTime.month == now.month) &&
        (schedule.weekdays == null || lastTime.weekday == now.weekday)) {
      return null;
    }
    lastTime = now;
    return Job(taskId: id, id: '$id-${now.millisecondsSinceEpoch}');
  }

  // void _run() {
  //   if (_closed) return;
  //   if (_running != null) {
  //     _overrun = true;
  //     return;
  //   }
  //   _running =
  //       Future.microtask(() => _task()).then((_) => null, onError: (_) => null);
  //   _running!.whenComplete(() {
  //     _running = null;
  //     if (_overrun) {
  //       _overrun = false;
  //       _run();
  //     }
  //   });
  // }

  @override
  Future<void> cancel() async {
    _closed = true;
  }
}
