# Cron

Run tasks periodically at fixed times or intervals.

[![pub package](https://img.shields.io/pub/v/cron.svg)](https://pub.dev/packages/cron)

## Usage

A simple usage example:

```dart
import 'package:cron/cron.dart';

void main() {
  final cron = Cron();

  cron.schedule(Schedule.parse('*/3 * * * *'), () async {
    print('every three minutes');
  });

  cron.schedule(Schedule.parse('8-11 * * * *'), () async {
    print('between every 8 and 11 minutes');
  });
}
```

## Cron parser

You can easily create and parse [cron format](https://en.wikipedia.org/wiki/Cron):

```dart
import 'package:cron/cron.dart';

void main() {
  print(Schedule.parse('3-5 * * * *').minutes); // [3, 4, 5]
  
  print(Schedule(hours: 12, minutes: 25, weekdays: [2, 3])
      .toCronString()); // 25 12 * * 2,3
}
```

## Links

- [source code][source]
- contributors: [Agilord][agilord]

[source]: https://github.com/agilord/cron
[agilord]: https://www.agilord.com/
