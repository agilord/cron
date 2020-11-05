part of '../../cron.dart';

class _DaysParam extends _CronParam {
  List<int> _days;

  /// This will add support for the `L` special char on the cron string
  /// if `true` the [shouldTick] method will ignore the list of days and fire only on the last day of
  /// the given moment
  bool _onLastDayOnly = false;

  _DaysParam(dynamic days) : super() {
    if (days == 'L') {
      _onLastDayOnly = true;
    } else {
      _days = parseConstraint(days)?.where((x) => x >= 1 && x <= 31)?.toList();
    }
  }

  @override
  bool shouldTick(DateTime moment) {
    if (_onLastDayOnly) {
      /// Get the last day of the given moment
      final lastDay = DateTime(moment.year, moment.month + 1, 0).day;

      return lastDay == moment.day;
    }

    return _days?.contains(moment.day) ?? !_onLastDayOnly;
  }

  @override
  String toString() {
    if (_onLastDayOnly) return 'Run only on last day of month';
    if (_days == null || _days.isEmpty) return 'Run everyday';
    return _days.toString();
  }
}
