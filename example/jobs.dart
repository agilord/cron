import 'dart:async';

import 'package:cron/cron.dart';

enum JobAction { run, pause, stop, delete }

enum JobTime {
  hourly(expr: '0 * * * *'),
  daily(expr: '0 0 * * *'),
  weekly(expr: '0 0 * * 0'),
  monthly(expr: '0 0 1 * *'),
  yearly(expr: '0 0 1 1 *'),
  midday12t(expr: '0 12 * * *'),
  midday13t(expr: '0 13 * * * '),
  afternoon15t(expr: '0 15 * * * '),
  afternoon16t(expr: '0 16 * * * '),
  every1mins(expr: '*/1 * * * *'),
  every2mins(expr: '*/2 * * * *'),
  every3mins(expr: '*/3 * * * *'),
  every5mins(expr: '*/5 * * * *'),
  expression(expr: '0 * * * *'),
  ;

  final String expr;
  const JobTime({
    required this.expr,
  });
}

class Job {
  JobTime time;
  JobAction action;
  String name;
  String id;

  Job(
      {required this.action,
      required this.time,
      required this.name,
      required this.id});

  void cancel() {
    action = JobAction.stop;
    print('job closed.');
  }

  Job call() {
    print('begin:${DateTime.now()}');

    Future.delayed(Duration(seconds: 5)).then((value) {
      print('action:$action, name:$name');
      print('__end:${DateTime.now()}');
    });

    return this;
  }
}

void main() {
  final jobName = 'jobTest';
  final jobId = 'job1234';

  final task = Job(
    action: JobAction.run,
    time: JobTime.every1mins,
    name: jobName,
    id: jobId,
  );

  final cron = Cron();
  final schedule = Schedule.parse(task.time.expr)..name = jobId;

  // ignore: implicit_call_tearoffs
  cron.schedule(schedule, task); // append

  print('startup, state:${task.action}, name:${task.name}, ${DateTime.now()}');
  // no.1, runAt, 1mins = 60secs
  // no.2, runAt, 2mins
  Future.delayed(Duration(seconds: 70)).then((value) {
    task.action = JobAction.pause;
    task.name = jobName + task.action.name.toUpperCase();
  });

  // no.3, runAt, 3mins
  Future.delayed(Duration(seconds: 130)).then((value) {
    final idx = cron.indexWhere((e) => e.schedule.name == jobId);
    print('find jobId:$jobId, index:$idx, ${DateTime.now()}');

    if (idx != -1) {
      task.action = JobAction.run;
      task.name = jobName + task.action.name.toUpperCase();
      task.name += '_UPDATE';
      task.time = JobTime.every2mins;

      final sched = Schedule.parse(task.time.expr);
      // ignore: implicit_call_tearoffs
      final st = cron.schedule(sched, task, false); // not append
      cron.updateAt(idx, st);
    }
  });

  // no.4, RunAt, 6mins
  Future.delayed(Duration(minutes: 6)).then((value) {
    final count = cron.count;
    if (count > 0) {
      task.action = JobAction.delete;
      task.name = jobName + task.action.name.toUpperCase();
      task.name += '_DELETE';

      final len1 = cron.count;
      cron.removeAt(0);
      final len2 = cron.count;
      print('remove index:0, length $len1 to $len2. ${DateTime.now()}');
    }
  });

  // no.5, 10mins after close.
  Future.delayed(Duration(minutes: 10)).then((value) {
    print('shutdown. ${DateTime.now()}');
    cron.close().then((value) {
      task.cancel();
    });
  });
}
