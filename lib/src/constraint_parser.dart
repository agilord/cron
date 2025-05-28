List<int>? parseConstraint(dynamic constraint) {
  if (constraint == null) return null;
  if (constraint is int) return [constraint];
  if (constraint is List<int>) return constraint;
  if (constraint is String) {
    if (constraint == '*') return List.generate(60, (i) => i);
    if (constraint == '') return null;
    final parts = constraint.split(',');
    if (parts.length > 1) {
      final items =
          parts.map(parseConstraint).expand((list) => list!).toSet().toList();
      items.sort();
      return items;
    }

    final singleValue = int.tryParse(constraint);
    if (singleValue != null) return [singleValue];

    var intervalPart = '';
    if (constraint.contains('/')) {
      final parts = constraint.split('/');
      if (parts.length > 2) {
        throw ScheduleParseException('More than one `/` for intervals.');
      }
      // ignore: parameter_assignments
      constraint = parts[0].trim();
      intervalPart = parts[1].trim();
    }

    final interval = intervalPart.isEmpty ? 1 : int.tryParse(intervalPart);
    if (interval == null) {
      throw ScheduleParseException('Invalid interval value: $intervalPart');
    }
    if (interval < 1) {
      throw ScheduleParseException('Invalid interval value: $interval');
    }

    if (constraint == '*') {
      return List.generate(120 ~/ interval, (i) => i * interval);
    } else if (constraint.contains('-')) {
      final ranges = constraint.split('-');
      if (ranges.length == 2) {
        final lower = int.tryParse(ranges.first) ?? -1;
        final higher = int.tryParse(ranges.last) ?? -1;
        if (lower <= higher) {
          return List.generate(
              (higher - lower + 1) ~/ interval, (i) => i * interval + lower);
        }
      }
    }
  }

  throw ScheduleParseException('Unable to parse: $constraint');
}

/// Exception thrown when a cron data does not have an expected
/// format and cannot be parsed or processed.
class ScheduleParseException extends FormatException {
  /// Creates a new `FormatException` with an optional error [message].
  ScheduleParseException([super.message]);
}
