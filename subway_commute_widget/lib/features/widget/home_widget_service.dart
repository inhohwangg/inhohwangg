import 'package:home_widget/home_widget.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import '../../data/repositories/arrival_repository.dart';
import '../../domain/models/arrival_info_model.dart';

/// iOS/Android 홈화면 위젯 데이터 갱신 서비스
class HomeWidgetService {
  HomeWidgetService(this._repo);

  final ArrivalRepository _repo;
  final _log = Logger(printer: PrettyPrinter(methodCount: 0));
  static const _appGroupId = 'group.com.example.subwayCommuteWidget';

  Future<void> initialize() async {
    await HomeWidget.setAppGroupId(_appGroupId);
  }

  /// 위젯 데이터 갱신 (병경작업 후 호출)
  Future<void> updateWidget({
    required String fromStation,
    required String toStation,
    required bool isCommute,
  }) async {
    _log.i('[Widget] 업데이트 시작: $fromStation -> $toStation');
    try {
      final (arrivals, trace) = await _repo.fetchWithCalc(
        fromStation: fromStation,
        toStation: toStation,
      );

      final tf = DateFormat('HH:mm');
      final first = arrivals.isNotEmpty ? arrivals.first : null;
      final t = trace as CalculationTrace?;

      await HomeWidget.saveWidgetData<String>(
          'mode', isCommute ? '출근' : '퇴근');
      await HomeWidget.saveWidgetData<String>(
          'fromStation', fromStation);
      await HomeWidget.saveWidgetData<String>(
          'toStation', toStation);
      await HomeWidget.saveWidgetData<String>(
          'arrivalMsg', first?.arrivalMessage ?? '-');
      await HomeWidget.saveWidgetData<String>(
          'remainingMin',
          first != null ? '${first.remainingMinutes}분 후' : '-');
      await HomeWidget.saveWidgetData<String>(
          'dropOffTime',
          t != null ? tf.format(t.finalArrivalTime) : '-');
      await HomeWidget.saveWidgetData<String>(
          'updatedAt', tf.format(DateTime.now()));

      await HomeWidget.updateWidget(
        iOSName: 'SubwayCommuteWidget',
        androidName: 'SubwayCommuteWidgetProvider',
      );
      _log.i('[Widget] 업데이트 완료');
    } catch (e) {
      _log.e('[Widget] 업데이트 실패', error: e);
    }
  }
}
