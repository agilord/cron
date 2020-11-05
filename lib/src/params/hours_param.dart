part of '../../cron.dart';

class _HoursParam extends _CronParam {
  List<int> _hours;

  _HoursParam(dynamic hours) : super() {
    _hours = parseConstraint(hours)?.where((x) => x >= 0 && x <= 59)?.toList();
  }

  @override
  bool shouldTick(DateTime moment) => _hours?.contains(moment.hour) ?? true;

  @override
  String toString() {
    if (_hours == null || _hours.isEmpty) return 'Run every hours';
    return 'Run on hours $_hours';
  }
}
