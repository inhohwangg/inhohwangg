// 출퇴근 시간 및 보정값 전역 설정
// 오차 발생 시 이 파일의 offset 값을 직접 수정하여 고속 튜닝
class CommuteConfig {
  CommuteConfig._();

  // 출근/퇴근 분기 시간 (13시 = 780분)
  static const int switchHour = 13;
  static const int switchMinute = 0;

  // 역간 이동 시간 보정 offset (초 단위, 양수 = 늘림, 음수 = 줄임)
  // 카카오 지하철 앙과 비교하면서 조절할 것
  static const int travelTimeOffsetSeconds = 0;

  // 환승 추가 시간 (offset에 포함된 것이 상황에 따라 다름)
  static const int transferBufferSeconds = 0;

  // API 응답 데이터 신뢰도 관련: 만료된 데이터 필터링 기준(분)
  static const int staleDataThresholdMinutes = 2;
}
