import 'package:cron/cron.dart';
import 'package:test/test.dart';

import 'package:cron/src/constraint_parser.dart';

void main() {
  group('Constraints', () {
    test('parse fixed constraint', () {
      expect(parseConstraint('12,25'), [12, 25]);
    });

    test('parse star constraint', () {
      expect(parseConstraint('*/14'), [0, 14, 28, 42, 56, 70, 84, 98]);
    });
  });

  group('Schedule.parse', () {
    test('5 parts', () {
      final schedule = Schedule.parse('1 13 */2 3-6 *');
      expect(schedule.seconds, isNull);
      expect(schedule.minutes, [1]);
      expect(schedule.hours, [13]);
      expect(schedule.days,
          [2, 4, 6, 8, 10, 12, 14, 16, 18, 20, 22, 24, 26, 28, 30]);
      expect(schedule.months, [3, 4, 5, 6]);
      expect(schedule.weekdays, isNull);
    });

    test('6 parts', () {
      final schedule = Schedule.parse('1,30-31 1 13 */2 3-6 2,4');
      expect(schedule.seconds, [1, 30, 31]);
      expect(schedule.minutes, [1]);
      expect(schedule.hours, [13]);
      expect(schedule.days,
          [2, 4, 6, 8, 10, 12, 14, 16, 18, 20, 22, 24, 26, 28, 30]);
      expect(schedule.months, [3, 4, 5, 6]);
      expect(schedule.weekdays, [2, 4]);
    });
  });
}
