class ApiConstants {
  ApiConstants._();

  // 서울 실시간 지하철 API
  // 공공데이터앤에서 발급받은 키를 .env 또는 flavor로 관리하는 것을 권장
  // 이 파일에는 기본값(placeholder)만 넣어두고 실제 API키는 컴파일 시 주입
  static const String seoulApiBaseUrl =
      'http://swopenAPI.seoul.go.kr/api/subway';
  static const String seoulApiKey = 'YOUR_SEOUL_OPEN_API_KEY';

  // 엔드포인트
  static const String realtimeArrivalPath = 'realtimeStationArrival';

  // Timeout
  static const Duration connectTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 15);
}
