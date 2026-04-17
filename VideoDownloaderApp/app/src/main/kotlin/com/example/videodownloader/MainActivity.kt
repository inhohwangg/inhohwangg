package com.example.videodownloader

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import com.example.videodownloader.ui.screen.DownloaderScreen
import com.example.videodownloader.ui.screen.DownloaderUiState
import com.example.videodownloader.ui.theme.VideoDownloaderTheme

// Step 2: 순수 UI 확인용 — Step 4에서 ViewModel로 교체
class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        enableEdgeToEdge()

        // 외부 공유 인텐트(SNS 앱 등)에서 받은 URL 처리
        val sharedUrl = intent?.getStringExtra(android.content.Intent.EXTRA_TEXT) ?: ""

        setContent {
            VideoDownloaderTheme {
                var url by remember { mutableStateOf(sharedUrl) }

                DownloaderScreen(
                    url = url,
                    onUrlChange = { url = it },
                    uiState = DownloaderUiState.Idle,  // Step 4에서 ViewModel 상태로 교체
                    onDownloadClick = {
                        // Step 4에서 ViewModel.startDownload() 호출로 교체
                    }
                )
            }
        }
    }
}
