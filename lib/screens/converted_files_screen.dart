import 'dart:io';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path/path.dart' as path;
import '../services/converter_service.dart';

class ConvertedFilesScreen extends StatefulWidget {
  const ConvertedFilesScreen({super.key});

  @override
  State<ConvertedFilesScreen> createState() => _ConvertedFilesScreenState();
}

class _ConvertedFilesScreenState extends State<ConvertedFilesScreen> {
  List<FileSystemEntity> _files = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFiles();
  }

  Future<void> _loadFiles() async {
    setState(() => _isLoading = true);
    final files = await ConverterService.getConvertedFiles();
    if (mounted) {
      setState(() {
        _files = files;
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteFile(String filePath) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('파일 삭제'),
        content: Text('${path.basename(filePath)} 파일을 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('취소'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('삭제'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await ConverterService.deleteFile(filePath);
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('파일이 삭제되었습니다.')),
        );
        _loadFiles();
      }
    }
  }

  String _formatFileSize(FileSystemEntity entity) {
    try {
      final size = (entity as File).lengthSync();
      if (size < 1024) return '$size B';
      if (size < 1024 * 1024) return '${(size / 1024).toStringAsFixed(1)} KB';
      return '${(size / (1024 * 1024)).toStringAsFixed(1)} MB';
    } catch (e) {
      return '';
    }
  }

  String _formatDate(FileSystemEntity entity) {
    try {
      final modified = entity.statSync().modified;
      return '${modified.year}.${modified.month.toString().padLeft(2, '0')}.${modified.day.toString().padLeft(2, '0')} '
          '${modified.hour.toString().padLeft(2, '0')}:${modified.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return '';
    }
  }

  IconData _getFormatIcon(String filePath) {
    final ext = path.extension(filePath).toLowerCase();
    switch (ext) {
      case '.mp3':
        return Icons.audio_file;
      case '.aac':
        return Icons.graphic_eq;
      case '.wav':
        return Icons.waves;
      case '.flac':
        return Icons.high_quality;
      case '.ogg':
        return Icons.music_note;
      default:
        return Icons.audio_file;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('변환된 파일 목록'),
        backgroundColor: colorScheme.primaryContainer,
        foregroundColor: colorScheme.onPrimaryContainer,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadFiles,
            tooltip: '새로고침',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _files.isEmpty
              ? _buildEmptyState(colorScheme)
              : RefreshIndicator(
                  onRefresh: _loadFiles,
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: _files.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final file = _files[index];
                      final fileName = path.basename(file.path);
                      return Card(
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: colorScheme.primaryContainer,
                            child: Icon(
                              _getFormatIcon(file.path),
                              color: colorScheme.primary,
                            ),
                          ),
                          title: Text(
                            fileName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                          subtitle: Text(
                            '${_formatFileSize(file)} • ${_formatDate(file)}',
                            style: TextStyle(
                              fontSize: 12,
                              color: colorScheme.outline,
                            ),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.share),
                                onPressed: () async {
                                  await Share.shareXFiles([XFile(file.path)],
                                      text: '변환된 오디오 파일');
                                },
                                tooltip: '공유',
                              ),
                              IconButton(
                                icon: Icon(Icons.delete_outline,
                                    color: colorScheme.error),
                                onPressed: () => _deleteFile(file.path),
                                tooltip: '삭제',
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }

  Widget _buildEmptyState(ColorScheme colorScheme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.folder_open,
            size: 80,
            color: colorScheme.outline,
          ),
          const SizedBox(height: 16),
          Text(
            '변환된 파일이 없습니다',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: colorScheme.outline,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            '동영상을 변환하면 여기에 표시됩니다',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colorScheme.outline,
                ),
          ),
        ],
      ),
    );
  }
}
