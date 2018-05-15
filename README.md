# A cron-like time-based job scheduler for Dart 

Run tasks periodically at fixed times or intervals.

## Usage

A simple usage example:

    import 'package:cron/cron.dart';

    main() {
      var cron = new Cron();
      cron.schedule(new Schedule.parse('*/3 * * * *'), () async {
        print('every three minutes');
      });
      cron.schedule(new Schedule.parse('8-11 * * * *'), () async {
        print('between every 8 and 11 minutes');
      });
    }

## Links

- [source code][source]
- contributors: [Agilord][agilord]

[source]: https://github.com/agilord/cron
[agilord]: https://www.agilord.com/
