import 'package:cron/cron.dart';
import 'package:cron/src/job.dart';

class JobManager {

  final Map<String, List<Job>> _jobs = {};

  JobManager();

  void start(Job job, Task task) {
    final jobs = _jobs[job.taskId];
    if (jobs != null) {
      jobs.add(job);
    } else {
      _jobs[job.taskId] = [job];
    }
    Future.microtask(() => task()).then((_) {
      _jobs[job.taskId]?.removeWhere((element) => element.id == job.id);
    }, onError: (_) => _);
  }

  bool isRunning(String taskId) {
    return _jobs[taskId]?.isNotEmpty ?? false;
  }

  int count(String taskId) {
    return _jobs[taskId]?.length ?? 0;
  }

}