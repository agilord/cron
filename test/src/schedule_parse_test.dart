import 'package:cron/src/schedule_parse_exception.dart';
import 'package:test/test.dart';

void main() {
  test('Test throw without message', () {
    try {
      throw ScheduleParseException();
    } catch (error) {
      expect(error is ScheduleParseException, isTrue);
      expect(error is FormatException, isTrue);
      expect(error is Exception, isTrue);
    }
  });

  test('Test throw with message', () {
    try {
      throw ScheduleParseException('parse failed');
    } catch (error) {
      expect(error.toString(), 'FormatException: parse failed');
      expect(error is ScheduleParseException, isTrue);
      expect(error is FormatException, isTrue);
      expect(error is Exception, isTrue);
    }
  });
}
