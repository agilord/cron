import 'package:cron/cron.dart';

void main() async {
  final cron = Cron();

  /// Run the task every 30 seconds only on Saturdays during the year of 2020
  /// you could also use `6L` instead of just `L` and specify a different day of the week
  final task = cron.schedule(Schedule.parse('*/30 * * * * * 2020'), () {
    print('Runned at ${DateTime.now()}');
  });

  /// Don't forget to close the task if you don't need it anymore
  /// by running `task.cancel()`
}
