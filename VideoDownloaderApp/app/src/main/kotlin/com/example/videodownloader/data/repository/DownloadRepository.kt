package com.example.videodownloader.data.repository

import android.content.ContentValues
import android.content.Context
import android.media.MediaScannerConnection
import android.net.Uri
import android.os.Build
import android.os.Environment
import android.provider.MediaStore
import androidx.annotation.RequiresApi
import com.yausername.youtubedl_android.YoutubeDL
import com.yausername.youtubedl_android.YoutubeDLRequest
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.suspendCancellableCoroutine
import kotlinx.coroutines.withContext
import java.io.File
import kotlin.coroutines.resume

class DownloadRepository {

    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // 영상 다운로드
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

    /**
     * URL의 영상을 최고화질(1080p+)로 다운로드하고 FFmpeg으로 병합 후 갤러리에 저장.
     *
     * @param onProgress (progress 0f~1f, percent 0~100, 상태 메시지)
     * @return 갤러리에 저장된 파일의 Uri
     */
    suspend fun downloadVideo(
        url: String,
        context: Context,
        onProgress: (progress: Float, percent: Int, message: String) -> Unit
    ): Result<Uri> = withContext(Dispatchers.IO) {
        try {
            val downloadDir = context.getExternalFilesDir(Environment.DIRECTORY_MOVIES)
                ?: context.filesDir
            downloadDir.mkdirs()

            // 다운로드 시작 전 기존 파일 스냅샷 (완료 후 새 파일 감지용)
            val existingPaths = downloadDir.listFiles()
                ?.map { it.absolutePath }?.toSet() ?: emptySet()

            val request = buildDownloadRequest(url, downloadDir)

            onProgress(0f, 0, "다운로드 준비 중...")

            YoutubeDL.getInstance().execute(
                request,
                url.hashCode().toString()   // processId: 취소 시 사용 가능
            ) { progress, _, line ->
                val percent = progress.toInt().coerceIn(0, 100)
                val normalized = (progress / 100f).coerceIn(0f, 1f)
                onProgress(normalized, percent, parseStatusMessage(percent, line))
            }

            // 새로 생성된 파일 탐지
            val downloadedFile = downloadDir.listFiles()
                ?.filter { it.absolutePath !in existingPaths && it.length() > 0 }
                ?.maxByOrNull { it.lastModified() }
                ?: return@withContext Result.failure(
                    Exception("다운로드된 파일을 찾을 수 없습니다.")
                )

            onProgress(1f, 100, "갤러리에 저장 중...")

            val savedUri = saveToGallery(context, downloadedFile)

            // 앱 전용 임시 파일 정리
            downloadedFile.delete()

            savedUri?.let { Result.success(it) }
                ?: Result.failure(Exception("갤러리 저장에 실패했습니다."))

        } catch (e: Exception) {
            Result.failure(e)
        }
    }

    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // yt-dlp 자동 업데이트
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

    /**
     * 유튜브 알고리즘 변경 등으로 다운로드가 실패할 경우 호출.
     * yt-dlp를 최신 Stable 버전으로 자체 패치한다.
     */
    suspend fun updateEngine(context: Context): Result<Unit> = withContext(Dispatchers.IO) {
        try {
            YoutubeDL.getInstance().updateYoutubeDL(
                context,
                YoutubeDL.UpdateChannel._STABLE
            )
            Result.success(Unit)
        } catch (e: Exception) {
            Result.failure(e)
        }
    }

    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // 내부 헬퍼
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

    private fun buildDownloadRequest(url: String, downloadDir: File): YoutubeDLRequest {
        return YoutubeDLRequest(url).apply {
            // 1080p 이상 최고화질 mp4 + m4a 오디오 우선, 순차 폴백
            addOption(
                "-f",
                "bestvideo[height>=1080][ext=mp4]+bestaudio[ext=m4a]" +
                "/bestvideo[ext=mp4]+bestaudio[ext=m4a]" +
                "/bestvideo+bestaudio" +
                "/best"
            )
            // FFmpeg으로 영상+오디오 mp4 컨테이너에 병합
            addOption("--merge-output-format", "mp4")
            // 파일명: 영상 제목.확장자
            addOption("-o", "${downloadDir.absolutePath}/%(title)s.%(ext)s")
            // 재생목록 URL이 입력되어도 단일 영상만 처리
            addOption("--no-playlist")
            addOption("--socket-timeout", "30")
            addOption("--retries", "3")
        }
    }

    private fun parseStatusMessage(percent: Int, line: String): String = when {
        line.contains("[Merger]", ignoreCase = true)   -> "영상과 오디오 병합 중..."
        line.contains("[ffmpeg]", ignoreCase = true)   -> "FFmpeg 처리 중..."
        line.contains("Deleting", ignoreCase = true)   -> "임시 파일 정리 중..."
        percent == 0                                   -> "다운로드 준비 중..."
        percent >= 99                                  -> "마무리 중..."
        else                                           -> "영상 다운로드 중..."
    }

    // ── 갤러리 저장 (API 분기) ───────────────────────────────────

    private suspend fun saveToGallery(context: Context, file: File): Uri? {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            saveToGalleryQ(context, file)
        } else {
            saveToGalleryLegacy(context, file)
        }
    }

    /**
     * Android 10(Q)+ : MediaStore API를 사용하여 갤러리에 저장.
     * IS_PENDING 플래그로 파일 쓰기가 완료될 때까지 다른 앱의 접근을 차단.
     */
    @RequiresApi(Build.VERSION_CODES.Q)
    private fun saveToGalleryQ(context: Context, file: File): Uri? {
        val contentValues = ContentValues().apply {
            put(MediaStore.Video.Media.DISPLAY_NAME, file.name)
            put(MediaStore.Video.Media.MIME_TYPE, "video/mp4")
            put(
                MediaStore.Video.Media.RELATIVE_PATH,
                "${Environment.DIRECTORY_MOVIES}${File.separator}VideoDownloader"
            )
            put(MediaStore.Video.Media.IS_PENDING, 1)
        }

        val resolver = context.contentResolver
        val uri = resolver.insert(MediaStore.Video.Media.EXTERNAL_CONTENT_URI, contentValues)
            ?: return null

        return try {
            resolver.openOutputStream(uri)?.use { out ->
                file.inputStream().use { input -> input.copyTo(out) }
            }
            contentValues.clear()
            contentValues.put(MediaStore.Video.Media.IS_PENDING, 0)
            resolver.update(uri, contentValues, null, null)
            uri
        } catch (e: Exception) {
            resolver.delete(uri, null, null)
            null
        }
    }

    /**
     * Android 9(P) 이하 : 공용 Movies 폴더에 복사 후 MediaScanner로 갤러리 등록.
     * WRITE_EXTERNAL_STORAGE 권한 필요 (AndroidManifest에 maxSdkVersion=28로 선언됨).
     */
    private suspend fun saveToGalleryLegacy(context: Context, file: File): Uri? =
        withContext(Dispatchers.IO) {
            val moviesDir =
                Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_MOVIES)
            val destDir = File(moviesDir, "VideoDownloader").apply { mkdirs() }
            val destFile = File(destDir, file.name)

            try {
                file.copyTo(destFile, overwrite = true)
            } catch (e: Exception) {
                return@withContext null
            }

            // MediaScannerConnection은 비동기이므로 코루틴으로 결과 대기
            suspendCancellableCoroutine { cont ->
                MediaScannerConnection.scanFile(
                    context,
                    arrayOf(destFile.absolutePath),
                    arrayOf("video/mp4")
                ) { _, uri ->
                    cont.resume(uri ?: Uri.fromFile(destFile))
                }
            }
        }
}
