# 동영상 → 오디오 변환기

Flutter로 개발된 동영상을 오디오로 변환하는 모바일 앱입니다.

## 주요 기능

- **다양한 동영상 형식 지원**: MP4, AVI, MOV, MKV 등
- **다양한 오디오 출력 형식**: MP3, AAC, WAV, FLAC, OGG
- **비트레이트 조절**: 64kbps ~ 320kbps (MP3/AAC/OGG)
- **변환 진행률 표시**: 실시간 변환 진행 상황 표시
- **파일 관리**: 변환된 파일 목록 보기, 삭제
- **파일 공유**: 변환된 오디오 파일 공유

## 기술 스택

- **Flutter 3.x** - 크로스 플랫폼 UI 프레임워크
- **ffmpeg_kit_flutter** - FFmpeg 기반 미디어 변환
- **file_picker** - 파일 선택
- **permission_handler** - 권한 관리
- **path_provider** - 파일 시스템 접근
- **share_plus** - 파일 공유

## 시작하기

### 요구사항

- Flutter SDK 3.0.0 이상
- Android SDK 24 이상 (Android 7.0+)
- iOS 12.0 이상

### 설치 및 실행

```bash
# 의존성 설치
flutter pub get

# 앱 실행
flutter run
```

### 빌드

```bash
# Android APK 빌드
flutter build apk --release

# iOS 빌드
flutter build ios --release
```

## 앱 사용법

1. 메인 화면에서 **동영상 파일 선택** 버튼을 탭합니다
2. 갤러리나 파일 관리자에서 변환할 동영상을 선택합니다
3. 원하는 **출력 형식** (MP3, AAC 등)을 선택합니다
4. 원하는 **비트레이트**를 선택합니다
5. **오디오로 변환** 버튼을 탭하여 변환을 시작합니다
6. 변환 완료 후 파일을 공유하거나 저장할 수 있습니다

## 스크린샷

| 메인 화면 | 변환 진행 | 파일 목록 |
|-----------|----------|---------|
| 동영상 선택 및 설정 | 실시간 진행률 | 변환된 파일 관리 |

## 라이센스

MIT License
