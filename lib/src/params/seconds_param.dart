part of '../../cron.dart';

class _SecondsParam extends _CronParam {
  List<int> _seconds;

  _SecondsParam(dynamic seconds) : super() {
    _seconds =
        parseConstraint(seconds)?.where((x) => x >= 0 && x <= 59)?.toList();
  }

  @override
  bool shouldTick(DateTime moment) => _seconds?.contains(moment.second) ?? true;

  bool get hasSeconds =>
      _seconds != null &&
      _seconds.isNotEmpty &&
      (_seconds.length != 1 || !_seconds.contains(0));

  @override
  String toString() {
    if (_seconds == null || _seconds.isEmpty) return 'Run every second';
    return 'Run on seconds $_seconds';
  }
}
