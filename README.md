# A cron-like time-based job scheduler for Dart

Run tasks periodically at fixed times or intervals.

## Usage

A simple usage example:

```dart
import 'package:cron/cron.dart';

main() {
  final cron = Cron();

  cron.schedule(Schedule.parse('*/3 * * * *'), () async {
    print('every three minutes');
  });

  cron.schedule(Schedule.parse('8-11 * * * *'), () async {
    print('between every 8 and 11 minutes');
  });
}
```

## Links

- [source code][source]
- contributors: [Agilord][agilord]

[source]: https://github.com/agilord/cron
[agilord]: https://www.agilord.com/
