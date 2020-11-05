part of '../../cron.dart';

Map<String, int> _weekdayNameToInt = {
  'SUN': 7,
  'SUNDAY': 7,
  'MON': 1,
  'MONDAY': 1,
  'TUE': 2,
  'TUES': 2,
  'TUESDAY': 2,
  'WED': 3,
  'WEDNESDAY': 3,
  'THU': 4,
  'THURS': 4,
  'THURSDAY': 4,
  'FRI': 5,
  'FRIDAY': 5,
  'SAT': 6,
  'SATURDAY': 6,
};

int _getWeekdayIntFromName(String name) {
  if (_weekdayNameToInt.containsKey(name)) return _weekdayNameToInt[name];
  return null;
}

abstract class _CronParam {
  bool shouldTick(DateTime now);

  /// REturn true if the given value shall be setted as a `null` value
  /// Currently `null`, `* `, `?` and emptyValues will return true;
  static bool isNull(dynamic value) =>
      value == null || value == '*' || value == '' || value == '?';

  List<int> parseConstraint(dynamic constraint) {
    if (isNull(constraint)) return null;

    if (constraint is int) return [constraint];
    if (constraint is List<int>) return constraint;

    if (constraint is String) {
      final parts = constraint.split(',');
      if (parts.length > 1) {
        final items =
            parts.map(parseConstraint).expand((list) => list).toSet().toList();
        items.sort();
        return items;
      }

      final singleValue =
          int.tryParse(constraint) ?? _getWeekdayIntFromName(constraint);
      if (singleValue != null) return [singleValue];

      if (constraint.startsWith('*/')) {
        final period = int.tryParse(constraint.substring(2)) ?? -1;
        if (period > 0) {
          return List.generate(120 ~/ period, (i) => i * period);
        }
      }

      if (constraint.contains('-')) {
        final ranges = constraint.toUpperCase().split('-');
        if (ranges.length == 2) {
          final lower = int.tryParse(ranges.first) ??
              _getWeekdayIntFromName(ranges.first) ??
              -1;

          final higher = int.tryParse(ranges.last) ??
              _getWeekdayIntFromName(ranges.last) ??
              -1;

          if (lower <= higher) {
            return List.generate(higher - lower + 1, (i) => i + lower);
          }
        }
      }
    }
    throw Exception('Unable to parse: $constraint');
  }
}
