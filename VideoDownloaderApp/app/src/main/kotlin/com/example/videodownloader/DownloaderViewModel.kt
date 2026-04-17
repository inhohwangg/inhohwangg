package com.example.videodownloader

import android.app.Application
import androidx.lifecycle.AndroidViewModel
import androidx.lifecycle.viewModelScope
import com.example.videodownloader.data.repository.DownloadRepository
import com.example.videodownloader.ui.screen.DownloaderUiState
import kotlinx.coroutines.delay
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch

/**
 * AndroidViewModel을 사용해 Application Context를 안전하게 보유.
 * (Activity Context는 절대 보관하지 않으므로 메모리 누수 없음)
 */
class DownloaderViewModel(application: Application) : AndroidViewModel(application) {

    private val repository = DownloadRepository()
    private val appContext = application.applicationContext

    private val _uiState = MutableStateFlow<DownloaderUiState>(DownloaderUiState.Idle)
    val uiState: StateFlow<DownloaderUiState> = _uiState.asStateFlow()

    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // 공개 API
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

    /**
     * 다운로드 시작. 실패 시 자동으로 yt-dlp를 업데이트하고 재시도한다.
     * 권한 체크는 호출 전 UI 레이어에서 완료되어야 함.
     */
    fun startDownload(url: String) {
        viewModelScope.launch {
            val result = executeDownload(url)

            result.fold(
                onSuccess = { onDownloadSuccess() },
                onFailure = { error ->
                    // ── 핵심 로직: 에러 발생 → 자동 업데이트 → 재시도 ──────
                    tryUpdateAndRetry(url, error.message)
                }
            )
        }
    }

    /** 오류 카드의 '다시 시도' 버튼에서 직접 재시도할 때 사용 */
    fun retryDownload(url: String) {
        startDownload(url)
    }

    /** 오류 상태에서 입력 화면으로 복귀 */
    fun resetToIdle() {
        _uiState.value = DownloaderUiState.Idle
    }

    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // 내부 로직
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

    private suspend fun executeDownload(url: String): Result<*> {
        _uiState.value = DownloaderUiState.Downloading(0f, 0, "다운로드 준비 중...")

        return repository.downloadVideo(
            url = url,
            context = appContext,
            // StateFlow.value는 스레드 안전 → IO 스레드의 콜백에서 직접 호출 가능
            onProgress = { progress, percent, message ->
                _uiState.value = DownloaderUiState.Downloading(progress, percent, message)
            }
        )
    }

    /**
     * 다운로드 실패 시 자동 복구 흐름:
     * 1) yt-dlp 업데이트 (유튜브 알고리즘 변경 대응)
     * 2) 업데이트 성공 → 자동 재시도
     * 3) 재시도도 실패 → 에러 상태로 전환 (UI에서 수동 재시도 가능)
     */
    private suspend fun tryUpdateAndRetry(url: String, originalError: String?) {
        _uiState.value = DownloaderUiState.Updating("yt-dlp 최신 버전으로 업데이트 중...")

        val updateResult = repository.updateEngine(appContext)

        if (updateResult.isFailure) {
            _uiState.value = DownloaderUiState.Error(
                originalError ?: "다운로드 중 오류가 발생했습니다."
            )
            return
        }

        // 업데이트 성공 → 다운로드 재시도
        _uiState.value = DownloaderUiState.Downloading(
            progress = 0f,
            progressPercent = 0,
            statusMessage = "엔진 업데이트 완료! 다운로드를 재시도합니다..."
        )

        val retryResult = repository.downloadVideo(
            url = url,
            context = appContext,
            onProgress = { progress, percent, message ->
                _uiState.value = DownloaderUiState.Downloading(progress, percent, message)
            }
        )

        retryResult.fold(
            onSuccess = { onDownloadSuccess() },
            onFailure = { retryError ->
                _uiState.value = DownloaderUiState.Error(
                    retryError.message ?: "다운로드에 실패했습니다. URL을 확인해 주세요."
                )
            }
        )
    }

    /** 권한 거부 등 외부 이벤트를 Error 상태로 전달할 때 사용 */
    fun setError(message: String) {
        _uiState.value = DownloaderUiState.Error(message)
    }

    fun resetToIdle() {
        _uiState.value = DownloaderUiState.Idle
    }

    private suspend fun onDownloadSuccess() {
        _uiState.value = DownloaderUiState.Success("갤러리에 저장 완료! 갤러리 앱에서 확인하세요.")
        // 3초 후 입력 화면으로 자동 복귀
        delay(3_000)
        _uiState.value = DownloaderUiState.Idle
    }
}
