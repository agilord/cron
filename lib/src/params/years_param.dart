part of '../../cron.dart';

class _YearsParam extends _CronParam {
  List<int> _years;

  _YearsParam(dynamic years) : super() {
    final now = DateTime.now();
    _years = parseConstraint(years)
        ?.where((x) => x >= now.year && x <= now.year + 100)
        ?.toList();
  }

  @override
  bool shouldTick(DateTime moment) => _years?.contains(moment.year) ?? true;

  @override
  String toString() {
    if (_years == null || _years.isEmpty) return 'Run at any year';
    return 'Run on years $_years';
  }
}
