import 'package:cron/cron.dart';
import 'package:fake_async/fake_async.dart';
import 'package:test/test.dart';

void main() {
  test('Run each 1 min', () {
    fakeAsync((async) {
      final cron = Cron();

      var count = 0;

      cron.schedule(Schedule.parse('* * * * *'), () async {
        count++;
      });

      async.elapse(Duration(minutes: 10));

      expect(count, 10);
    }, initialTime: DateTime(2000, 1, 1, 0, 0, 0, 0, 0));
  });

  test('Run at 12:00', () {
    fakeAsync((async) {
      final cron = Cron();

      var count = 0;

      cron.schedule(Schedule.parse('0 12 * * *'), () async {
        count++;
      });

      async.elapse(Duration(hours: 11, minutes: 59));

      expect(count, 0);

      async.elapse(Duration(minutes: 1));

      expect(count, 1);

      async.elapse(Duration(hours: 23, minutes: 59));

      expect(count, 1);
    }, initialTime: DateTime(2000, 1, 1, 0, 0, 0, 0, 0));
  });

  test('when a Schedule is running, then the "running" value should be [true]', () {
    fakeAsync((async) {
      final cron = Cron();

      var count = 0;

      final schedule = cron.schedule(Schedule.parse('* * * * *'), () async {
        await Future.delayed(Duration(seconds: 10), () {
          count++;
        });
      });

      async.elapse(Duration(minutes: 10));

      expect(cron.isRunning(schedule.id), true);
      async.elapse(Duration(seconds: 10));

      expect(count, 10);
    }, initialTime: DateTime(2000, 1, 1, 0, 0, 0, 0, 0));
  });

  test('should return correct cron format string.', () {
    expect(
      Schedule(hours: 13, minutes: 20, weekdays: [1, 2]).toCronString(),
      '20 13 * * 1,2',
    );
  });
}
