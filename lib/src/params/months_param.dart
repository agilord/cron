part of '../../cron.dart';

class _MonthsParam extends _CronParam {
  List<int> _months;

  _MonthsParam(dynamic months) : super() {
    _months =
        parseConstraint(months)?.where((x) => x >= 1 && x <= 12)?.toList();
  }

  @override
  bool shouldTick(DateTime moment) => _months?.contains(moment.month) ?? true;

  @override
  String toString() {
    if (_months == null || _months.isEmpty) return 'Run every month';
    return 'Run on months $_months';
  }
}
