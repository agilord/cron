// Copyright (c) 2016, Agilord. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'dart:async';

part 'src/cron_impl.dart';
part 'src/scheduler.dart';

part 'src/params/cron_param.dart';
part 'src/params/days_param.dart';
part 'src/params/hours_param.dart';
part 'src/params/minutes_param.dart';
part 'src/params/months_param.dart';
part 'src/params/seconds_param.dart';
part 'src/params/weekday_param.dart';
part 'src/params/years_param.dart';

/// A task may return a Future to indicate when it is completed. If it wouldn't
/// complete before [Cron] calls it again, it will be delayed.
typedef Task = FutureOr<dynamic> Function();

/// A cron-like time-based job scheduler.
abstract class Cron {
  /// A cron-like time-based job scheduler.
  factory Cron() => _Cron();

  /// Schedules a [task] running specified by the [schedule].
  ScheduledTask schedule(Schedule schedule, Task task);

  /// Closes the cron instance and doesn't accept new tasks anymore.
  Future close();
}
