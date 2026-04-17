package com.example.videodownloader

import android.Manifest
import android.app.Application
import android.content.Intent
import android.content.pm.PackageManager
import android.os.Build
import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.rememberLauncherForActivityResult
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.activity.result.contract.ActivityResultContracts
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.platform.LocalContext
import androidx.core.content.ContextCompat
import androidx.lifecycle.ViewModelProvider
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import androidx.lifecycle.viewmodel.compose.viewModel
import com.example.videodownloader.ui.screen.DownloaderScreen
import com.example.videodownloader.ui.theme.VideoDownloaderTheme

class MainActivity : ComponentActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        enableEdgeToEdge()

        // 다른 앱(유튜브, 인스타 등)에서 '공유' 버튼으로 전달된 URL
        val initialUrl = intent?.getStringExtra(Intent.EXTRA_TEXT) ?: ""

        setContent {
            VideoDownloaderTheme {
                val context = LocalContext.current
                val application = context.applicationContext as Application

                // AndroidViewModel 팩토리 명시 (Application 주입 필요)
                val viewModel: DownloaderViewModel = viewModel(
                    factory = ViewModelProvider.AndroidViewModelFactory.getInstance(application)
                )
                val uiState by viewModel.uiState.collectAsStateWithLifecycle()

                // URL 상태: 공유 인텐트 초기값 or 빈 문자열
                var url by remember { mutableStateOf(initialUrl) }

                // ── 권한 목록: API 레벨별 분기 ──────────────────────────────
                //
                //  Android 13+(API 33): READ_MEDIA_VIDEO
                //    → WRITE_EXTERNAL_STORAGE 폐지, 미디어 타입별 세분화
                //
                //  Android 10~12(API 29~32): 권한 불필요
                //    → MediaStore API가 자체적으로 쓰기 허용
                //
                //  Android 9 이하(API ≤ 28): WRITE_EXTERNAL_STORAGE
                //    → 공용 외부 저장소 직접 접근에 필요
                //
                val requiredPermissions: Array<String> = remember {
                    when {
                        Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU ->
                            arrayOf(Manifest.permission.READ_MEDIA_VIDEO)
                        Build.VERSION.SDK_INT <= Build.VERSION_CODES.P ->
                            arrayOf(Manifest.permission.WRITE_EXTERNAL_STORAGE)
                        else -> emptyArray()
                    }
                }

                // 권한 보유 여부 체크
                fun hasAllPermissions() = requiredPermissions.isEmpty() ||
                    requiredPermissions.all { permission ->
                        ContextCompat.checkSelfPermission(context, permission) ==
                            PackageManager.PERMISSION_GRANTED
                    }

                // ── 권한 요청 런처 ────────────────────────────────────────────
                val permissionLauncher = rememberLauncherForActivityResult(
                    ActivityResultContracts.RequestMultiplePermissions()
                ) { result ->
                    val allGranted = result.isEmpty() || result.values.all { it }
                    if (allGranted) {
                        // 권한 획득 → 즉시 다운로드 시작
                        viewModel.startDownload(url)
                    } else {
                        // 거부 → 안내 메시지를 에러 상태로 표시
                        val guide = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                            "설정 > 앱 > 권한 > 미디어에서 허용해 주세요."
                        } else {
                            "설정 > 앱 > 권한 > 저장소에서 허용해 주세요."
                        }
                        viewModel.setError("저장 권한이 거부되었습니다.\n$guide")
                    }
                }

                // ── 다운로드 시작 / 재시도 공통 진입점 ──────────────────────
                //
                // 오류 카드의 '다시 시도' 버튼도 이 람다를 재사용하므로,
                // 권한이 여전히 없으면 다시 요청하고, 있으면 바로 다운로드.
                //
                DownloaderScreen(
                    url = url,
                    onUrlChange = { url = it },
                    uiState = uiState,
                    onDownloadClick = {
                        when {
                            url.isBlank() -> { /* 버튼 비활성화 상태라 도달 불가 */ }
                            hasAllPermissions() -> viewModel.startDownload(url)
                            else -> permissionLauncher.launch(requiredPermissions)
                        }
                    }
                )
            }
        }
    }
}
