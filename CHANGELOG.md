# Changelog

## 0.6.2

- Add `JobManager` and `Job` making the `ScheduledTask` a template for the jobs. [#54](https://github.com/agilord/cron/pull/54) by [francescovallone](https://github.com/francescovallone)

## 0.6.1

- Add `isRunning` property to `ScheduledTask` to check if the task is running. [#53](https://github.com/agilord/cron/pull/53) by [francescovallone](https://github.com/francescovallone)

## 0.6.0

- Add `toCronString` function and improve package. [#50](https://github.com/agilord/cron/pull/50) by [mbfakourii](https://github.com/mbfakourii)

## 0.5.1

- Fixed scheduling issue. [#42](https://github.com/agilord/cron/issues/42) by [ccl0326](https://github.com/ccl0326)

## 0.5.0

- Improved time parsing.　[#21](https://github.com/agilord/cron/issues/21) by [myConsciousness](https://github.com/myConsciousness)
- Improved exception that occurred when parsing cron-like string. Currently throws `ScheduleParseException` if parsing fails. [[#29](https://github.com/agilord/cron/issues/29)] by [myConsciousness](https://github.com/myConsciousness)

## 0.4.1

- Fixed weekday check. [#32](https://github.com/agilord/cron/pull/32) by [Langley1996](https://github.com/Langley1996).

## 0.4.0

- Using [clock](https://pub.dev/packages/clock) to allow mocking time (by [pescuma](https://github.com/pescuma)).

## 0.3.2

- Fixed parsing schedules with extra whitespace at the beginning or the end.

## 0.3.1

- Fixed seconds vs minutes ticks issue - #22

## 0.3.0

- Null-safety support (by [bsutton](https://github.com/bsutton)).

## 0.2.4

- Support for `seconds` and 6-part String format.
- `FutureOr<dynamic>` is accepted as a `Task` callback.

## 0.2.3

- Updated code style and using latest pedantic lints.

## 0.2.2

- Schedule returns `ScheduledTask` which allows cancelling a scheduled task.

## 0.2.1

- Fixed a type-cast bug.

## 0.2.0

- Dart 2 support.

## 0.1.0

- Fix issues for Dart 2 compatibility.

## 0.0.2

- Slightly better handling of the async errors.

## 0.0.1

- Initial version.
