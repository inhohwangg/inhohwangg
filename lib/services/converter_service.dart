import 'dart:io';
import 'package:ffmpeg_kit_flutter_full_gpl/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_full_gpl/ffmpeg_kit_config.dart';
import 'package:ffmpeg_kit_flutter_full_gpl/return_code.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

enum AudioFormat { mp3, aac, wav, flac, ogg }

extension AudioFormatExt on AudioFormat {
  String get extension {
    switch (this) {
      case AudioFormat.mp3:
        return 'mp3';
      case AudioFormat.aac:
        return 'aac';
      case AudioFormat.wav:
        return 'wav';
      case AudioFormat.flac:
        return 'flac';
      case AudioFormat.ogg:
        return 'ogg';
    }
  }

  String get codec {
    switch (this) {
      case AudioFormat.mp3:
        return 'libmp3lame';
      case AudioFormat.aac:
        return 'aac';
      case AudioFormat.wav:
        return 'pcm_s16le';
      case AudioFormat.flac:
        return 'flac';
      case AudioFormat.ogg:
        return 'libvorbis';
    }
  }

  String get displayName {
    switch (this) {
      case AudioFormat.mp3:
        return 'MP3';
      case AudioFormat.aac:
        return 'AAC';
      case AudioFormat.wav:
        return 'WAV';
      case AudioFormat.flac:
        return 'FLAC';
      case AudioFormat.ogg:
        return 'OGG';
    }
  }

  bool get supportsBitrate {
    return this != AudioFormat.wav && this != AudioFormat.flac;
  }
}

class ConversionResult {
  final bool success;
  final String? outputPath;
  final String? errorMessage;

  const ConversionResult({
    required this.success,
    this.outputPath,
    this.errorMessage,
  });
}

/// Abstract interface for ConverterService (enables mocking in tests)
abstract class ConverterService {
  Future<ConversionResult> convertVideoToAudio({
    required String inputPath,
    required AudioFormat format,
    required int bitrate,
    void Function(double progress)? onProgress,
  });

  Future<List<FileSystemEntity>> getConvertedFiles();

  Future<bool> deleteFile(String filePath);
}

/// Real implementation using FFmpeg
class ConverterServiceImpl implements ConverterService {
  static bool _callbackRegistered = false;
  static void Function(double)? _progressCallback;

  /// Call once at app startup to register the global statistics callback
  static void initializeCallbacks() {
    if (_callbackRegistered) return;
    _callbackRegistered = true;
    FFmpegKitConfig.enableStatisticsCallback((statistics) {
      final timeInMs = statistics.getTime();
      if (timeInMs > 0 && _progressCallback != null) {
        _progressCallback!(timeInMs.toDouble());
      }
    });
  }

  @override
  Future<ConversionResult> convertVideoToAudio({
    required String inputPath,
    required AudioFormat format,
    required int bitrate,
    void Function(double progress)? onProgress,
  }) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final outputDir = Directory('${directory.path}/converted_audio');
      if (!await outputDir.exists()) {
        await outputDir.create(recursive: true);
      }

      final inputFileName = path.basenameWithoutExtension(inputPath);
      final outputFilePath =
          '${outputDir.path}/${inputFileName}_${DateTime.now().millisecondsSinceEpoch}.${format.extension}';

      // Get video duration for progress calculation
      double? durationMs;
      final probeSession = await FFmpegKit.execute(
          '-i "$inputPath" -v error -show_entries format=duration'
          ' -of default=noprint_wrappers=1:nokey=1');
      final durationOutput = await probeSession.getOutput();
      if (durationOutput != null) {
        final seconds = double.tryParse(durationOutput.trim());
        if (seconds != null) durationMs = seconds * 1000;
      }

      // Register progress callback before session starts
      if (onProgress != null && durationMs != null && durationMs > 0) {
        _progressCallback = (timeInMs) {
          onProgress((timeInMs / durationMs!).clamp(0.0, 1.0));
        };
      }

      String command;
      if (!format.supportsBitrate) {
        command =
            '-i "$inputPath" -vn -acodec ${format.codec} "$outputFilePath"';
      } else {
        command =
            '-i "$inputPath" -vn -acodec ${format.codec} -ab ${bitrate}k "$outputFilePath"';
      }

      final session = await FFmpegKit.execute(command);
      _progressCallback = null;

      final returnCode = await session.getReturnCode();

      if (ReturnCode.isSuccess(returnCode)) {
        onProgress?.call(1.0);
        return ConversionResult(success: true, outputPath: outputFilePath);
      } else {
        final logs = await session.getLogs();
        final errorMsg = logs.map((l) => l.getMessage()).join('\n');
        return ConversionResult(
            success: false, errorMessage: '변환 실패: $errorMsg');
      }
    } catch (e) {
      return ConversionResult(success: false, errorMessage: e.toString());
    }
  }

  @override
  Future<List<FileSystemEntity>> getConvertedFiles() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final outputDir = Directory('${directory.path}/converted_audio');
      if (!await outputDir.exists()) return [];
      return outputDir.listSync().whereType<File>().toList()
        ..sort(
            (a, b) => b.statSync().modified.compareTo(a.statSync().modified));
    } catch (e) {
      return [];
    }
  }

  @override
  Future<bool> deleteFile(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}
