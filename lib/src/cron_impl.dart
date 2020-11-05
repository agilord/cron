part of '../cron.dart';

const int _millisecondsPerSecond = 1000;

class _Cron implements Cron {
  bool _closed = false;
  Timer _timer;
  final _schedules = <_ScheduledTask>[];

  @override
  ScheduledTask schedule(Schedule schedule, Task task) {
    if (_closed) throw Exception('Closed.');
    final st = _ScheduledTask(schedule, task);
    _schedules.add(st);
    _scheduleNextTick();
    return st;
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
    final now = DateTime.now();
    final isTickMinute = _schedules.any((task) => !task.schedule._hasSeconds);
    final ms = (isTickMinute ? 60 : 1) * _millisecondsPerSecond -
        (now.millisecondsSinceEpoch %
            ((isTickMinute ? 60 : 1) * _millisecondsPerSecond));
    _timer = Timer(Duration(milliseconds: ms), _tick);
  }

  void _tick() {
    _timer = null;
    final now = DateTime.now();
    for (final schedule in _schedules) {
      schedule.tick(now);
    }
    _scheduleNextTick();
  }
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
    if (_closed || schedule.params.any((p) => !p.shouldTick(now))) return;
    _run();
  }

  void _run() {
    if (_closed) return;
    if (_running != null) {
      _overrun = true;
      return;
    }
    _running =
        Future.microtask(() => _task()).then((_) => null, onError: (_) => null);
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
