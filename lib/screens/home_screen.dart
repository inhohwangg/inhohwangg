import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import '../services/converter_service.dart';
import '../widgets/format_selector.dart';
import '../widgets/bitrate_selector.dart';
import '../widgets/conversion_progress.dart';
import 'converted_files_screen.dart';

class HomeScreen extends StatefulWidget {
  final ConverterService converterService;

  const HomeScreen({
    super.key,
    required this.converterService,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  String? _selectedVideoPath;
  String? _selectedVideoName;
  AudioFormat _selectedFormat = AudioFormat.mp3;
  int _selectedBitrate = 192;
  bool _isConverting = false;
  double _progress = 0.0;
  String? _outputPath;
  String? _errorMessage;

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    );
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _pickVideo() async {
    if (Platform.isAndroid || Platform.isIOS) {
      final status = await Permission.storage.request();
      if (status.isDenied) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('저장소 접근 권한이 필요합니다.')),
          );
        }
        return;
      }
    }

    final result = await FilePicker.platform.pickFiles(
      type: FileType.video,
      allowMultiple: false,
    );

    if (result != null && result.files.single.path != null) {
      setState(() {
        _selectedVideoPath = result.files.single.path;
        _selectedVideoName = result.files.single.name;
        _outputPath = null;
        _errorMessage = null;
        _progress = 0.0;
      });
      _fadeController.forward(from: 0);
    }
  }

  Future<void> startConversion() async {
    if (_selectedVideoPath == null) return;

    setState(() {
      _isConverting = true;
      _progress = 0.0;
      _outputPath = null;
      _errorMessage = null;
    });

    final result = await widget.converterService.convertVideoToAudio(
      inputPath: _selectedVideoPath!,
      format: _selectedFormat,
      bitrate: _selectedBitrate,
      onProgress: (progress) {
        if (mounted) {
          setState(() => _progress = progress);
        }
      },
    );

    if (mounted) {
      setState(() {
        _isConverting = false;
        if (result.success) {
          _outputPath = result.outputPath;
          _progress = 1.0;
        } else {
          _errorMessage = result.errorMessage;
        }
      });

      if (result.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('변환이 완료되었습니다!'),
            action: SnackBarAction(
              label: '공유',
              onPressed: () => _shareFile(_outputPath!),
            ),
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  Future<void> _shareFile(String filePath) async {
    await Share.shareXFiles([XFile(filePath)], text: '변환된 오디오 파일');
  }

  String _formatFileSize(String? path) {
    if (path == null) return '';
    try {
      final size = File(path).lengthSync();
      if (size < 1024) return '$size B';
      if (size < 1024 * 1024) return '${(size / 1024).toStringAsFixed(1)} KB';
      return '${(size / (1024 * 1024)).toStringAsFixed(1)} MB';
    } catch (e) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '동영상 → 오디오 변환기',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: colorScheme.primaryContainer,
        foregroundColor: colorScheme.onPrimaryContainer,
        actions: [
          IconButton(
            icon: const Icon(Icons.folder_open),
            tooltip: '변환된 파일 목록',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ConvertedFilesScreen(
                    converterService: widget.converterService,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildVideoPickerCard(colorScheme),
            const SizedBox(height: 20),
            if (_selectedVideoPath != null) ...[
              FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    FormatSelector(
                      selectedFormat: _selectedFormat,
                      onFormatChanged: (format) {
                        setState(() => _selectedFormat = format);
                      },
                    ),
                    const SizedBox(height: 16),
                    BitrateSelector(
                      selectedBitrate: _selectedBitrate,
                      selectedFormat: _selectedFormat,
                      onBitrateChanged: (bitrate) {
                        setState(() => _selectedBitrate = bitrate);
                      },
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ],
            if (_isConverting)
              ConversionProgress(progress: _progress)
            else
              _buildConvertButton(colorScheme),
            if (_outputPath != null) ...[
              const SizedBox(height: 20),
              _buildSuccessCard(colorScheme),
            ],
            if (_errorMessage != null) ...[
              const SizedBox(height: 20),
              _buildErrorCard(colorScheme),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildVideoPickerCard(ColorScheme colorScheme) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: _isConverting ? null : _pickVideo,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Icon(
                _selectedVideoPath != null
                    ? Icons.videocam
                    : Icons.video_library,
                size: 64,
                color: _selectedVideoPath != null
                    ? colorScheme.primary
                    : colorScheme.outline,
              ),
              const SizedBox(height: 12),
              if (_selectedVideoPath != null) ...[
                Text(
                  _selectedVideoName ?? '동영상 선택됨',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.primary,
                      ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '탭하여 다른 파일 선택',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colorScheme.outline,
                      ),
                ),
              ] else ...[
                Text(
                  '동영상 파일 선택',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  'MP4, AVI, MOV, MKV 등 지원',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colorScheme.outline,
                      ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildConvertButton(ColorScheme colorScheme) {
    return FilledButton.icon(
      onPressed: _selectedVideoPath != null ? startConversion : null,
      icon: const Icon(Icons.transform),
      label: const Text(
        '오디오로 변환',
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildSuccessCard(ColorScheme colorScheme) {
    return Card(
      color: colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.check_circle, color: colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  '변환 완료!',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.primary,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              _outputPath!.split('/').last,
              style: Theme.of(context).textTheme.bodyMedium,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              '파일 크기: ${_formatFileSize(_outputPath)}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colorScheme.outline,
                  ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _shareFile(_outputPath!),
                    icon: const Icon(Icons.share),
                    label: const Text('공유'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ConvertedFilesScreen(
                            converterService: widget.converterService,
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.folder_open),
                    label: const Text('파일 목록'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorCard(ColorScheme colorScheme) {
    return Card(
      color: colorScheme.errorContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.error, color: colorScheme.error),
                const SizedBox(width: 8),
                Text(
                  '변환 실패',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.error,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage ?? '알 수 없는 오류가 발생했습니다.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
