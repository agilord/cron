import 'package:cron/cron.dart';

void main() async {
  final cron = Cron();

  /// Schedule that will thell the cron to run every day from Monday through Friday at 7AM
  /// You could also use the syntax `0 0 7 * * 1-5 *`
  final task = cron.schedule(Schedule.parse('0 0 7 ? * MON-FRI *'), () {
    print('Runned at ${DateTime.now()}');
  });

  /// Don't forget to close the task if you don't need it anymore
  /// by running `task.cancel()`
}
