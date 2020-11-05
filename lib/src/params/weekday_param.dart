part of '../../cron.dart';

class _WeekdayParam extends _CronParam {
  List<int> _weekdays;

  /// If true it means that that this param should fire only on last day of the week
  bool _onLastMonthWeekdayOnly;

  /// Works together with the [_onLastMonthWeekdayOnly] attribute,
  /// so [_onLastMonthWeekdayOnly] must be true and [_onLastWeekDay] should have a value
  /// between 0 and 7
  int _lastWeekDay = 6;

  _WeekdayParam(dynamic weekdays) : super() {
    _onLastMonthWeekdayOnly = false;

    if (weekdays.trim() == 'L') {
      _weekdays = [_lastWeekDay];
    } else if (weekdays is String &&
        weekdays.trim().startsWith(RegExp(r'[0-7]')) &&
        weekdays.endsWith('L')) {
      _onLastMonthWeekdayOnly = true;
      _lastWeekDay = int.tryParse(weekdays.trim()[0]);
    } else {
      _weekdays = parseConstraint(weekdays)
          ?.where((x) => x >= 0 && x <= 7)
          ?.map((x) => x == 0 ? 7 : x)
          ?.toSet()
          ?.toList();
    }
  }

  @override
  bool shouldTick(DateTime moment) {
    /// If `_onLastWeekdayOnly` is true
    /// and the weekday of the moment is the same as the requested last weekday param
    if (_onLastMonthWeekdayOnly && moment.weekday == _lastWeekDay) {
      /// Add a week to the current moment and check if the month is still the same as the moment
      /// if not it means that this is the last weekday of the current moment
      final nextWeekDate = DateTime(moment.year, moment.month, moment.day + 7);
      return nextWeekDate.month != moment.month;
    }
    return _weekdays?.contains(moment.weekday) ?? !_onLastMonthWeekdayOnly;
  }

  @override
  String toString() {
    if (_onLastMonthWeekdayOnly) return 'Run only on week day $_lastWeekDay';
    if (_weekdays == null || _weekdays.isEmpty) {
      return 'Run at any day of the week';
    }
    return 'Run on days of week $_weekdays';
  }
}
