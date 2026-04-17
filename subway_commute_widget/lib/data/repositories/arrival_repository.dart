import 'package:logger/logger.dart';
import '../../core/constants/commute_config.dart';
import '../../data/api/seoul_subway_api.dart';
import '../../data/static/travel_time_db.dart';
import '../../domain/models/arrival_info_model.dart';

class CalculationTrace {
  const CalculationTrace({
    required this.stationName,
    required this.rawArrivalSeconds,
    required this.updatedAt,
    required this.estimatedArrivalTime,
    required this.travelMinutesFromDb,
    required this.offsetSeconds,
    required this.transferBufferSeconds,
    required this.finalArrivalTime,
    required this.arrivalMessage,
  });

  final String stationName;
  final int rawArrivalSeconds;
  final DateTime updatedAt;
  final DateTime estimatedArrivalTime;  // updatedAt + rawArrivalSeconds
  final int travelMinutesFromDb;         // DB 역간 소요시간
  final int offsetSeconds;               // CommuteConfig.travelTimeOffsetSeconds
  final int transferBufferSeconds;       // CommuteConfig.transferBufferSeconds
  final DateTime finalArrivalTime;       // 실제 하차 예상 시각
  final String arrivalMessage;           // 원본 API 메시지

  @override
  String toString() => '''
[CalculationTrace]
  역명       : $stationName
  API도착잔여  : ${rawArrivalSeconds}초 (${(rawArrivalSeconds / 60).floor()}분 ${rawArrivalSeconds % 60}초)
  기준시접     : $updatedAt
  출발역도쳉  : $estimatedArrivalTime
  DB소요시간  : ${travelMinutesFromDb}분
  Offset    : ${offsetSeconds}초
  환승버퍼   : ${transferBufferSeconds}초
  실제하차예상  : $finalArrivalTime  <-- 카카오와 비교
  원본메시지  : $arrivalMessage
'''.trim();
}

class ArrivalRepository {
  ArrivalRepository(this._api);

  final SeoulSubwayApi _api;
  final _log = Logger(printer: PrettyPrinter(methodCount: 0));

  /// 도착정보 + 하차 예상시각 계산
  Future<(List<ArrivalInfoModel>, CalculationTrace?)> fetchWithCalc({
    required String fromStation,
    required String toStation,
    int? overrideOffsetSeconds,
    int? overrideTransferBufferSeconds,
  }) async {
    _log.i('[Repo] 계산 시작: $fromStation → $toStation');

    final arrivals = await _api.fetchArrivalInfo(fromStation);
    if (arrivals.isEmpty) {
      _log.w('[Repo] 도착정보 없음');
      return (arrivals, null);
    }

    final first = arrivals.first;
    final travelMin =
        TravelTimeDb.getTravelMinutesOrDefault(fromStation, toStation);
    final offsetSec = overrideOffsetSeconds ??
        CommuteConfig.travelTimeOffsetSeconds;
    final bufferSec = overrideTransferBufferSeconds ??
        CommuteConfig.transferBufferSeconds;

    final totalAddedSeconds =
        (travelMin * 60) + offsetSec + bufferSec;
    final finalTime =
        first.estimatedArrivalTime.add(Duration(seconds: totalAddedSeconds));

    final trace = CalculationTrace(
      stationName: fromStation,
      rawArrivalSeconds: first.remainingSeconds,
      updatedAt: first.updatedAt,
      estimatedArrivalTime: first.estimatedArrivalTime,
      travelMinutesFromDb: travelMin,
      offsetSeconds: offsetSec,
      transferBufferSeconds: bufferSec,
      finalArrivalTime: finalTime,
      arrivalMessage: first.arrivalMessage,
    );

    _log.i('[Repo] 계산 결과:\n$trace');
    return (arrivals, trace);
  }
}
