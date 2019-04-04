// Copyright (c) 2016, Agilord. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'dart:async';

/// A task may return a Future to indicate when it is completed. If it wouldn't
/// complete before [Cron] calls it again, it will be delayed.
typedef Future Task();

/// A cron-like time-based job scheduler.
abstract class Cron {
  /// A cron-like time-based job scheduler.
  factory Cron() => new _Cron();

  /// Schedules a [task] running specified by the [schedule].
  ScheduledTask schedule(Schedule schedule, Task task);

  /// Closes the cron instance and doesn't accept new tasks anymore.
  Future close();
}

/// The cron schedule.
class Schedule {
  /// The minutes a Task should be started.
  final List<int> minutes;

  /// The hours a Task should be started.
  final List<int> hours;

  /// The days a Task should be started.
  final List<int> days;

  /// The months a Task should be started.
  final List<int> months;

  /// The weekdays a Task should be started.
  final List<int> weekdays;

  factory Schedule(
      {

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
      dynamic weekdays}) {
    List<int> parsedMinutes =
        _parseConstraint(minutes)?.where((x) => x >= 0 && x <= 59)?.toList();
    List<int> parsedHours =
        _parseConstraint(hours)?.where((x) => x >= 0 && x <= 59)?.toList();
    List<int> parsedDays =
        _parseConstraint(days)?.where((x) => x >= 1 && x <= 31)?.toList();
    List<int> parsedMonths =
        _parseConstraint(months)?.where((x) => x >= 1 && x <= 12)?.toList();
    List<int> parsedWeekdays = _parseConstraint(weekdays)
        ?.where((x) => x >= 0 && x <= 7)
        ?.map((x) => x == 0 ? 7 : x)
        ?.toSet()
        ?.toList();
    return new Schedule._(
        parsedMinutes, parsedHours, parsedDays, parsedMonths, parsedWeekdays);
  }

  /// Parses the cron-formatted text and creates a schedule out of it.
  factory Schedule.parse(String cronFormat) {
    List<List<int>> p =
        cronFormat.split(new RegExp('\\s+')).map(_parseConstraint).toList();
    assert(p.length == 5);
    return new Schedule._(p[0], p[1], p[2], p[3], p[4]);
  }

  Schedule._(this.minutes, this.hours, this.days, this.months, this.weekdays);
}

abstract class ScheduledTask {
  Schedule get schedule;
  Future cancel();
}

const int _millisecondsPerMinute = 60 * 1000;

class _Cron implements Cron {
  bool _closed = false;
  Timer _timer = null;
  List<_ScheduledTask> _schedules = [];

  @override
  ScheduledTask schedule(Schedule schedule, Task task) {
    if (_closed) throw 'Closed.';
    final st = new _ScheduledTask(schedule, task);
    _schedules.add(st);
    _scheduleNextTick();
    return st;
  }

  @override
  Future close() async {
    _closed = true;
    _timer?.cancel();
    _timer = null;
    for (_ScheduledTask schedule in _schedules) {
      await schedule.cancel();
    }
  }

  void _scheduleNextTick() {
    if (_closed) return;
    if (_timer != null || _schedules.isEmpty) return;
    DateTime now = new DateTime.now();
    int ms = _millisecondsPerMinute -
        (now.millisecondsSinceEpoch % _millisecondsPerMinute);
    _timer = new Timer(new Duration(milliseconds: ms), _tick);
  }

  void _tick() {
    _timer = null;
    DateTime now = new DateTime.now();
    for (_ScheduledTask schedule in _schedules) {
      schedule.tick(now);
    }
    _scheduleNextTick();
  }
}

List<int> _parseConstraint(dynamic constraint) {
  if (constraint == null) return null;
  if (constraint is int) return [constraint];
  if (constraint is List<int>) return constraint;
  if (constraint is String) {
    if (constraint == '*') return null;
    final parts = constraint.split(',');
    if (parts.length > 1) {
      final items =
          parts.map(_parseConstraint).expand((list) => list).toSet().toList();
      items.sort();
      return items;
    }

    int singleValue = int.tryParse(constraint);
    if (singleValue != null) return [singleValue];

    if (constraint.startsWith('*/')) {
      int period = int.tryParse(constraint.substring(2)) ?? -1;
      if (period > 0) {
        return new List.generate(120 ~/ period, (i) => i * period);
      }
    }

    if (constraint.contains('-')) {
      List<String> ranges = constraint.split('-');
      if (ranges.length == 2) {
        int lower = int.tryParse(ranges.first) ?? -1;
        int higher = int.tryParse(ranges.last) ?? -1;
        if (lower <= higher) {
          return new List.generate(higher - lower + 1, (i) => i + lower);
        }
      }
    }
  }
  throw 'Unable to parse: $constraint';
}

class _ScheduledTask implements ScheduledTask {
  @override
  final Schedule schedule;
  final Task _task;

  bool _closed = false;
  Future _running;
  bool _overrun = false;

  _ScheduledTask(this.schedule, this._task);

  void tick(DateTime now) {
    if (_closed) return;
    if (schedule?.minutes?.contains(now.minute) == false) return;
    if (schedule?.hours?.contains(now.hour) == false) return;
    if (schedule?.days?.contains(now.day) == false) return;
    if (schedule?.months?.contains(now.month) == false) return;
    if (schedule?.weekdays?.contains(now.weekday) == false) return;
    _run();
  }

  void _run() {
    if (_closed) return;
    if (_running != null) {
      _overrun = true;
      return;
    }
    _running = new Future.microtask(() => _task())
        .then((_) => null, onError: (_) => null);
    _running.whenComplete(() {
      _running = null;
      if (_overrun) {
        _overrun = false;
        _run();
      }
    });
  }

  @override
  Future cancel() async {
    _closed = true;
    _overrun = false;
    if (_running != null) {
      await _running;
    }
  }
}
