# 한국 지하철 - 출퇴근 스마트 위젯

## 구조

```
lib/
├── main.dart
├── core/
│   ├── constants/
│   │   ├── api_constants.dart       # API URL/Key
│   │   └── commute_config.dart      # 시간/구간 전역 설정
│   └── theme/                       # 토스 디자인 시스템
├── data/
│   ├── api/seoul_subway_api.dart    # 서울시 공공 API
│   ├── repositories/               # 도착정보 + 하차시각 계산
│   └── static/travel_time_db.dart  # 역간 소요시간 DB
├── domain/
│   └── models/                     # 불변 데이터 모델
├── features/
│   ├── commute/providers/          # Riverpod 상태관리
│   ├── home/                       # 홈 화면
│   ├── settings/                   # 설정 화면
│   ├── debug/                      # 시간 검증 화면
│   └── widget/                     # 홈화면 위젯 연동
└── shared/widgets/             # 공통 UI 컴포넌트
```

## 프로젝트 실행

```bash
# 1. 의존성 설치
flutter pub get

# 2. 코드 생성 (json_serializable / riverpod_generator)
flutter pub run build_runner build --delete-conflicting-outputs

# 3. 실행
flutter run
```

## API 키 설정

`lib/core/constants/api_constants.dart` 의 `seoulApiKey` 를
[Seoul Open Data Plaza](https://data.seoul.go.kr) 에서 발급받은 키로 교체하세요.

## 시간 오차 조정 방법

1. 앱 우측 상단 `특특` 아이콘 터치 → **시간 검증 디버그** 스크린 진입
2. 카카오 지하철과 하차시각을 나란히 확인
3. 차이만큼 `Offset` 수정 (예: 카카오보다 3분 빠르면 `+180`)
4. 설정 화면에서 저장 → 위젯 자동 반영

## 스위칭 로직

| 시간대 | 모드 | 출발역 | 도착역 |
|---|---|---|---|
| 00:00 ~ 12:59 | 출근 | 부평구청 | 금천구청 |
| 13:00 ~ 23:59 | 퇴근 | 금천구청 | 부평구청 |
