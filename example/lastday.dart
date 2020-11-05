import 'package:cron/cron.dart';

void main() async {
  final cron = Cron();

  /// Schedule that will thell the cron to run on Friday of each month at 7AM
  /// You could also use the syntax `0 0 7 * * 5L *`
  final task = cron.schedule(Schedule.parse('0 0 7 ? * 5L *'), () {
    print('Runned at ${DateTime.now()}');
  });

  /// Don't forget to close the task if you don't need it anymore
  /// by running `task.cancel()`
}
