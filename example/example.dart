import 'package:cron/cron.dart';

void main() {
  print(Schedule.parse('3-5 * * * *').minutes); // [3, 4, 5]

  print(Schedule(hours: 12, minutes: 25, weekdays: [2, 3])
      .toCronString()); // * 25 12 * * 2,3
}
