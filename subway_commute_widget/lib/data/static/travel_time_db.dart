/// 역간 이동 소요시간 정적 DB
/// Key: '출발역_도착역', Value: 분
class TravelTimeDb {
  TravelTimeDb._();

  static const Map<String, int> _travelMinutes = {
    // 7호선: 부평구청 → 금천구청 (예시 데이터 - 실제 소요시간으로 수정 필요)
    '부평구청_인장': 3,
    '부평구청_부평': 5,
    '부평구청_부평시청': 7,
    '부평구청_일산': 10,
    '부평구청_어물도': 13,
    '부평구청_마나': 16,
    '부평구청_상동': 19,
    '부평구청_인제육대교': 22,
    '부평구청_부개현': 25,
    '부평구청_침산': 28,
    '부평구청_가라산': 31,
    '부평구청_대림': 34,
    '부평구청_천왕': 40,
    '부평구청_온수': 43,
    '부평구청_간석시장': 46,
    '부평구청_이리': 49,
    '부평구청_도림청': 52,
    '부평구청_금천구청': 55,
    // 역방향 (퇴근)
    '금천구청_부평구청': 55,
  };

  static int? getTravelMinutes(String from, String to) {
    return _travelMinutes['${from}_$to'];
  }

  static int getTravelMinutesOrDefault(String from, String to,
      {int defaultMinutes = 60}) {
    return _travelMinutes['${from}_$to'] ?? defaultMinutes;
  }
}
