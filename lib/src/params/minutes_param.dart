part of '../../cron.dart';

class _MinutesParam extends _CronParam {
  List<int> _minutes;

  _MinutesParam(dynamic minutes) : super() {
    _minutes =
        parseConstraint(minutes)?.where((x) => x >= 0 && x <= 59)?.toList();
  }

  @override
  bool shouldTick(DateTime moment) => _minutes?.contains(moment.minute) ?? true;

  @override
  String toString() {
    if (_minutes == null || _minutes.isEmpty) return 'Run every minute';
    return 'Run on minutes $_minutes';
  }
}
