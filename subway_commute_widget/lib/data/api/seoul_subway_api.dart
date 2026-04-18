import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import '../../core/constants/api_constants.dart';
import '../../domain/models/arrival_info_model.dart';

class SeoulSubwayApi {
  SeoulSubwayApi() {
    _dio = Dio(BaseOptions(
      baseUrl: ApiConstants.seoulApiBaseUrl,
      connectTimeout: ApiConstants.connectTimeout,
      receiveTimeout: ApiConstants.receiveTimeout,
    ));
    _dio.interceptors.add(LogInterceptor(
      requestBody: false,
      responseBody: true,
      logPrint: (obj) => _log.d(obj),
    ));
  }

  late final Dio _dio;
  final _log = Logger(printer: PrettyPrinter(methodCount: 0));

  /// 실시간 도착정보 호출
  /// [stationName]: 한글 역명 (예: 부평구청)
  Future<List<ArrivalInfoModel>> fetchArrivalInfo(String stationName) async {
    _log.i('[API] 실시간 도착정보 요청: $stationName');
    final stopwatch = Stopwatch()..start();

    try {
      final response = await _dio.get(
        '/${ApiConstants.seoulApiKey}/json/${ApiConstants.realtimeArrivalPath}/0/10/$stationName',
      );

      stopwatch.stop();
      _log.i('[API] 응답 수신: ${stopwatch.elapsedMilliseconds}ms');

      final data = response.data as Map<String, dynamic>;
      final realtimeList =
          (data['realtimeArrivalList'] as List<dynamic>?) ?? [];

      _log.d('[API] 로우 데이터 수: ${realtimeList.length}개');

      final now = DateTime.now();
      final arrivals = realtimeList.map((item) {
        final map = item as Map<String, dynamic>;
        final barvlDt = int.tryParse(map['barvlDt']?.toString() ?? '0') ?? 0;
        return ArrivalInfoModel(
          trainLineName: map['trainLineNm'] as String? ?? '',
          arrivalMessage: map['arvlMsg2'] as String? ?? '',
          remainingSeconds: barvlDt,
          destinationName: map['bstatnNm'] as String? ?? '',
          updatedAt: now,
          isUpDirection: (map['updnLine'] as String?) == '1',
        );
      }).toList();

      for (final a in arrivals) {
        _log.d('[API] 파싱 결과: $a');
      }

      return arrivals;
    } on DioException catch (e) {
      _log.e('[API] 요청 실패', error: e);
      rethrow;
    }
  }
}
