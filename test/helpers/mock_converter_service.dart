import 'dart:io';
import 'package:mocktail/mocktail.dart';
import 'package:video_audio_converter/services/converter_service.dart';

class MockConverterService extends Mock implements ConverterService {}

/// 변환 성공을 반환하는 stub 설정
void setupConversionSuccess(
  MockConverterService mock, {
  String outputPath = '/mock/output/test.mp3',
}) {
  when(() => mock.convertVideoToAudio(
        inputPath: any(named: 'inputPath'),
        format: any(named: 'format'),
        bitrate: any(named: 'bitrate'),
        onProgress: any(named: 'onProgress'),
      )).thenAnswer((_) async {
    return ConversionResult(success: true, outputPath: outputPath);
  });
}

/// 변환 실패를 반환하는 stub 설정
void setupConversionFailure(
  MockConverterService mock, {
  String errorMessage = '테스트 변환 실패',
}) {
  when(() => mock.convertVideoToAudio(
        inputPath: any(named: 'inputPath'),
        format: any(named: 'format'),
        bitrate: any(named: 'bitrate'),
        onProgress: any(named: 'onProgress'),
      )).thenAnswer((_) async {
    return ConversionResult(success: false, errorMessage: errorMessage);
  });
}

/// 빈 파일 목록을 반환하는 stub 설정
void setupEmptyFileList(MockConverterService mock) {
  when(() => mock.getConvertedFiles()).thenAnswer((_) async => []);
}

/// 파일 목록을 반환하는 stub 설정
void setupFileList(MockConverterService mock, List<FileSystemEntity> files) {
  when(() => mock.getConvertedFiles()).thenAnswer((_) async => files);
}

/// 파일 삭제 성공 stub 설정
void setupDeleteSuccess(MockConverterService mock) {
  when(() => mock.deleteFile(any())).thenAnswer((_) async => true);
}

/// 파일 삭제 실패 stub 설정
void setupDeleteFailure(MockConverterService mock) {
  when(() => mock.deleteFile(any())).thenAnswer((_) async => false);
}
