List<int>? parseConstraint(dynamic constraint) {
  if (constraint == null) return null;
  if (constraint is int) return [constraint];
  if (constraint is List<int>) return constraint;
  if (constraint is String) {
    if (constraint == '*' || constraint == '') return null;
    final parts = constraint.split(',');
    if (parts.length > 1) {
      final items =
          parts.map(parseConstraint).expand((list) => list!).toSet().toList();
      items.sort();
      return items;
    }

    final singleValue = int.tryParse(constraint);
    if (singleValue != null) return [singleValue];

    if (constraint.startsWith('*/')) {
      final period = int.tryParse(constraint.substring(2)) ?? -1;
      if (period > 0) {
        return List.generate(120 ~/ period, (i) => i * period);
      }
    }

    if (constraint.contains('-')) {
      final ranges = constraint.split('-');
      if (ranges.length == 2) {
        final lower = int.tryParse(ranges.first) ?? -1;
        final higher = int.tryParse(ranges.last) ?? -1;
        if (lower <= higher) {
          return List.generate(higher - lower + 1, (i) => i + lower);
        }
      }
    }
  }
  throw Exception('Unable to parse: $constraint');
}
