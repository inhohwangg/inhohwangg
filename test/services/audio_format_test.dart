import 'package:flutter_test/flutter_test.dart';
import 'package:video_audio_converter/services/converter_service.dart';

void main() {
  group('AudioFormat extensions', () {
    group('extension (파일 확장자)', () {
      test('MP3 확장자는 mp3', () {
        expect(AudioFormat.mp3.extension, equals('mp3'));
      });
      test('AAC 확장자는 aac', () {
        expect(AudioFormat.aac.extension, equals('aac'));
      });
      test('WAV 확장자는 wav', () {
        expect(AudioFormat.wav.extension, equals('wav'));
      });
      test('FLAC 확장자는 flac', () {
        expect(AudioFormat.flac.extension, equals('flac'));
      });
      test('OGG 확장자는 ogg', () {
        expect(AudioFormat.ogg.extension, equals('ogg'));
      });
    });

    group('codec (FFmpeg 코덱 이름)', () {
      test('MP3 코덱은 libmp3lame', () {
        expect(AudioFormat.mp3.codec, equals('libmp3lame'));
      });
      test('AAC 코덱은 aac', () {
        expect(AudioFormat.aac.codec, equals('aac'));
      });
      test('WAV 코덱은 pcm_s16le', () {
        expect(AudioFormat.wav.codec, equals('pcm_s16le'));
      });
      test('FLAC 코덱은 flac', () {
        expect(AudioFormat.flac.codec, equals('flac'));
      });
      test('OGG 코덱은 libvorbis', () {
        expect(AudioFormat.ogg.codec, equals('libvorbis'));
      });
    });

    group('displayName (표시 이름)', () {
      test('모든 형식의 표시 이름이 대문자', () {
        expect(AudioFormat.mp3.displayName, equals('MP3'));
        expect(AudioFormat.aac.displayName, equals('AAC'));
        expect(AudioFormat.wav.displayName, equals('WAV'));
        expect(AudioFormat.flac.displayName, equals('FLAC'));
        expect(AudioFormat.ogg.displayName, equals('OGG'));
      });
    });

    group('supportsBitrate (비트레이트 지원 여부)', () {
      test('MP3는 비트레이트 지원', () {
        expect(AudioFormat.mp3.supportsBitrate, isTrue);
      });
      test('AAC는 비트레이트 지원', () {
        expect(AudioFormat.aac.supportsBitrate, isTrue);
      });
      test('OGG는 비트레이트 지원', () {
        expect(AudioFormat.ogg.supportsBitrate, isTrue);
      });
      test('WAV는 비트레이트 미지원 (무손실)', () {
        expect(AudioFormat.wav.supportsBitrate, isFalse);
      });
      test('FLAC는 비트레이트 미지원 (무손실)', () {
        expect(AudioFormat.flac.supportsBitrate, isFalse);
      });
    });

    test('모든 AudioFormat 값이 5개', () {
      expect(AudioFormat.values.length, equals(5));
    });
  });

  group('ConversionResult', () {
    test('성공 결과 생성', () {
      const result = ConversionResult(
        success: true,
        outputPath: '/output/test.mp3',
      );
      expect(result.success, isTrue);
      expect(result.outputPath, equals('/output/test.mp3'));
      expect(result.errorMessage, isNull);
    });

    test('실패 결과 생성', () {
      const result = ConversionResult(
        success: false,
        errorMessage: '변환 실패: 파일을 찾을 수 없습니다',
      );
      expect(result.success, isFalse);
      expect(result.outputPath, isNull);
      expect(result.errorMessage, contains('변환 실패'));
    });

    test('성공 결과에 outputPath 필수', () {
      const result = ConversionResult(success: true, outputPath: '/path/a.mp3');
      expect(result.outputPath, isNotNull);
    });

    test('실패 결과에 errorMessage 필수', () {
      const result = ConversionResult(success: false, errorMessage: '오류');
      expect(result.errorMessage, isNotNull);
    });
  });
}
