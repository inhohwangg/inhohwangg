package com.example.videodownloader.ui.screen

import androidx.compose.animation.AnimatedContent
import androidx.compose.animation.AnimatedVisibility
import androidx.compose.animation.core.tween
import androidx.compose.animation.fadeIn
import androidx.compose.animation.fadeOut
import androidx.compose.animation.slideInVertically
import androidx.compose.animation.slideOutVertically
import androidx.compose.animation.togetherWith
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.systemBarsPadding
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.text.KeyboardActions
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.CheckCircle
import androidx.compose.material.icons.filled.Clear
import androidx.compose.material.icons.filled.ErrorOutline
import androidx.compose.material.icons.filled.FileDownload
import androidx.compose.material.icons.filled.Link
import androidx.compose.material.icons.filled.Refresh
import androidx.compose.material.icons.filled.VideoLibrary
import androidx.compose.material3.Button
import androidx.compose.material3.ButtonDefaults
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.LinearProgressIndicator
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.OutlinedTextField
import androidx.compose.material3.OutlinedTextFieldDefaults
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.shadow
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.LocalClipboardManager
import androidx.compose.ui.platform.LocalFocusManager
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.input.ImeAction
import androidx.compose.ui.text.input.KeyboardType
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.example.videodownloader.ui.theme.TossBlue
import com.example.videodownloader.ui.theme.TossBlueLight
import com.example.videodownloader.ui.theme.TossBorder
import com.example.videodownloader.ui.theme.TossDark
import com.example.videodownloader.ui.theme.TossGray
import com.example.videodownloader.ui.theme.TossGreen
import com.example.videodownloader.ui.theme.TossGreenLight
import com.example.videodownloader.ui.theme.TossLightGray
import com.example.videodownloader.ui.theme.TossRed
import com.example.videodownloader.ui.theme.TossRedLight
import com.example.videodownloader.ui.theme.TossWhite
import com.example.videodownloader.ui.theme.VideoDownloaderTheme

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// UI 상태 정의
// ViewModel(Step 3)이 이 상태를 관리하며 Screen에 전달함
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

sealed interface DownloaderUiState {
    data object Idle : DownloaderUiState

    data class Downloading(
        val progress: Float,          // 0f ~ 1f (CircularProgressIndicator 용)
        val progressPercent: Int,     // 0 ~ 100 (텍스트 표시 용)
        val statusMessage: String = "영상과 오디오를 다운로드 중..."
    ) : DownloaderUiState

    data class Updating(
        val statusMessage: String = "최신 엔진으로 업데이트 중..."
    ) : DownloaderUiState

    data class Success(
        val statusMessage: String = "갤러리에 저장 완료!"
    ) : DownloaderUiState

    data class Error(
        val message: String
    ) : DownloaderUiState
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 메인 Screen Composable
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

@Composable
fun DownloaderScreen(
    url: String,
    onUrlChange: (String) -> Unit,
    uiState: DownloaderUiState,
    onDownloadClick: () -> Unit,
    modifier: Modifier = Modifier
) {
    val isInputEnabled = uiState is DownloaderUiState.Idle
            || uiState is DownloaderUiState.Success
            || uiState is DownloaderUiState.Error

    Box(
        modifier = modifier
            .fillMaxSize()
            .background(TossLightGray)
    ) {
        Column(
            modifier = Modifier
                .fillMaxSize()
                .verticalScroll(rememberScrollState())
                .systemBarsPadding()
                .padding(horizontal = 24.dp)
        ) {
            Spacer(Modifier.height(36.dp))

            HeaderSection()

            Spacer(Modifier.height(32.dp))

            UrlInputCard(
                url = url,
                onUrlChange = onUrlChange,
                enabled = isInputEnabled
            )

            Spacer(Modifier.height(16.dp))

            ActionSection(
                uiState = uiState,
                onDownloadClick = onDownloadClick,
                isUrlValid = url.isNotBlank()
            )

            Spacer(Modifier.height(48.dp))
        }
    }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 헤더 섹션
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

@Composable
private fun HeaderSection() {
    Row(verticalAlignment = Alignment.CenterVertically) {
        // 앱 아이콘 배경 박스
        Box(
            modifier = Modifier
                .size(52.dp)
                .background(TossBlueLight, RoundedCornerShape(16.dp)),
            contentAlignment = Alignment.Center
        ) {
            Icon(
                imageVector = Icons.Default.VideoLibrary,
                contentDescription = null,
                tint = TossBlue,
                modifier = Modifier.size(28.dp)
            )
        }

        Spacer(Modifier.width(16.dp))

        Column {
            Text(
                text = "영상 다운로더",
                style = MaterialTheme.typography.headlineMedium,
                color = TossDark
            )
            Text(
                text = "유튜브, SNS 영상을 내 기기에 저장",
                style = MaterialTheme.typography.bodyMedium,
                color = TossGray
            )
        }
    }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// URL 입력 카드
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

@Composable
private fun UrlInputCard(
    url: String,
    onUrlChange: (String) -> Unit,
    enabled: Boolean
) {
    val clipboardManager = LocalClipboardManager.current
    val focusManager = LocalFocusManager.current

    TossCard {
        Column(modifier = Modifier.padding(20.dp)) {
            Row(verticalAlignment = Alignment.CenterVertically) {
                Icon(
                    imageVector = Icons.Default.Link,
                    contentDescription = null,
                    tint = TossBlue,
                    modifier = Modifier.size(16.dp)
                )
                Spacer(Modifier.width(6.dp))
                Text(
                    text = "영상 URL",
                    style = MaterialTheme.typography.labelMedium,
                    color = TossGray
                )
            }

            Spacer(Modifier.height(12.dp))

            OutlinedTextField(
                value = url,
                onValueChange = onUrlChange,
                enabled = enabled,
                placeholder = {
                    Text(
                        "https://youtube.com/watch?v=...",
                        style = MaterialTheme.typography.bodyMedium,
                        color = TossBorder
                    )
                },
                trailingIcon = {
                    if (url.isNotEmpty()) {
                        IconButton(onClick = { onUrlChange("") }) {
                            Icon(
                                Icons.Default.Clear,
                                contentDescription = "URL 지우기",
                                tint = TossGray,
                                modifier = Modifier.size(20.dp)
                            )
                        }
                    } else {
                        TextButton(
                            onClick = {
                                clipboardManager.getText()?.let { onUrlChange(it.text) }
                            },
                            enabled = enabled
                        ) {
                            Text(
                                "붙여넣기",
                                color = TossBlue,
                                fontSize = 13.sp,
                                fontWeight = FontWeight.SemiBold
                            )
                        }
                    }
                },
                shape = RoundedCornerShape(12.dp),
                colors = OutlinedTextFieldDefaults.colors(
                    focusedBorderColor = TossBlue,
                    unfocusedBorderColor = TossBorder,
                    focusedContainerColor = TossWhite,
                    unfocusedContainerColor = TossWhite,
                    disabledContainerColor = TossLightGray,
                    disabledBorderColor = TossBorder,
                    cursorColor = TossBlue
                ),
                keyboardOptions = KeyboardOptions(
                    keyboardType = KeyboardType.Uri,
                    imeAction = ImeAction.Done
                ),
                keyboardActions = KeyboardActions(
                    onDone = { focusManager.clearFocus() }
                ),
                maxLines = 3,
                modifier = Modifier.fillMaxWidth()
            )

            AnimatedVisibility(visible = url.isBlank()) {
                Column {
                    Spacer(Modifier.height(10.dp))
                    Text(
                        text = "YouTube · Instagram · Twitter(X) · TikTok 지원",
                        style = MaterialTheme.typography.labelMedium,
                        color = TossGray
                    )
                }
            }
        }
    }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 액션 섹션 (버튼 / 진행 표시)
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

@Composable
private fun ActionSection(
    uiState: DownloaderUiState,
    onDownloadClick: () -> Unit,
    isUrlValid: Boolean
) {
    AnimatedContent(
        targetState = uiState,
        transitionSpec = {
            (fadeIn(tween(300)) + slideInVertically { it / 6 }) togetherWith
                    (fadeOut(tween(200)) + slideOutVertically { -it / 6 })
        },
        contentKey = { it::class },
        label = "action_content"
    ) { state ->
        when (state) {
            is DownloaderUiState.Idle -> {
                IdleButton(
                    onClick = onDownloadClick,
                    enabled = isUrlValid
                )
            }
            is DownloaderUiState.Downloading -> DownloadingCard(state)
            is DownloaderUiState.Updating    -> UpdatingCard(state)
            is DownloaderUiState.Success     -> SuccessCard(state)
            is DownloaderUiState.Error       -> ErrorCard(state, onDownloadClick)
        }
    }
}

// ─── 대기 상태: 다운로드 버튼 ────────────────────────────────────

@Composable
private fun IdleButton(onClick: () -> Unit, enabled: Boolean) {
    Button(
        onClick = onClick,
        enabled = enabled,
        modifier = Modifier
            .fillMaxWidth()
            .height(60.dp),
        shape = RoundedCornerShape(16.dp),
        colors = ButtonDefaults.buttonColors(
            containerColor = TossBlue,
            disabledContainerColor = TossBorder,
            contentColor = TossWhite,
            disabledContentColor = TossGray
        )
    ) {
        Icon(
            imageVector = Icons.Default.FileDownload,
            contentDescription = null,
            modifier = Modifier.size(22.dp)
        )
        Spacer(Modifier.width(8.dp))
        Text(
            text = "다운로드",
            fontSize = 17.sp,
            fontWeight = FontWeight.Bold
        )
    }
}

// ─── 다운로드 중: 원형 Progress + % 텍스트 ───────────────────────

@Composable
private fun DownloadingCard(state: DownloaderUiState.Downloading) {
    TossCard {
        Column(
            modifier = Modifier
                .fillMaxWidth()
                .padding(vertical = 28.dp, horizontal = 20.dp),
            horizontalAlignment = Alignment.CenterHorizontally
        ) {
            Box(contentAlignment = Alignment.Center) {
                CircularProgressIndicator(
                    progress = { state.progress },
                    modifier = Modifier.size(88.dp),
                    strokeWidth = 7.dp,
                    trackColor = TossBlueLight,
                    color = TossBlue
                )
                Text(
                    text = "${state.progressPercent}%",
                    fontWeight = FontWeight.Bold,
                    fontSize = 20.sp,
                    color = TossDark
                )
            }

            Spacer(Modifier.height(20.dp))

            Text(
                text = state.statusMessage,
                style = MaterialTheme.typography.bodyMedium,
                color = TossGray,
                textAlign = TextAlign.Center
            )
        }
    }
}

// ─── 업데이트 중: 선형 인디케이터 ────────────────────────────────

@Composable
private fun UpdatingCard(state: DownloaderUiState.Updating) {
    Surface(
        modifier = Modifier.fillMaxWidth(),
        shape = RoundedCornerShape(20.dp),
        color = TossBlueLight
    ) {
        Column(modifier = Modifier.padding(20.dp)) {
            Row(verticalAlignment = Alignment.CenterVertically) {
                CircularProgressIndicator(
                    modifier = Modifier.size(22.dp),
                    strokeWidth = 3.dp,
                    color = TossBlue
                )
                Spacer(Modifier.width(14.dp))
                Column {
                    Text(
                        text = "엔진 자동 업데이트",
                        fontWeight = FontWeight.SemiBold,
                        color = TossBlue,
                        fontSize = 15.sp
                    )
                    Text(
                        text = state.statusMessage,
                        style = MaterialTheme.typography.bodyMedium,
                        color = TossGray
                    )
                }
            }

            Spacer(Modifier.height(14.dp))

            LinearProgressIndicator(
                modifier = Modifier
                    .fillMaxWidth()
                    .height(4.dp),
                color = TossBlue,
                trackColor = TossBlue.copy(alpha = 0.2f)
            )

            Spacer(Modifier.height(10.dp))

            Text(
                text = "yt-dlp 최신 버전으로 업데이트 후 자동으로 다운로드가 재개됩니다.",
                style = MaterialTheme.typography.labelMedium,
                color = TossGray,
                lineHeight = 18.sp
            )
        }
    }
}

// ─── 완료 상태: 녹색 체크 카드 ───────────────────────────────────

@Composable
private fun SuccessCard(state: DownloaderUiState.Success) {
    Surface(
        modifier = Modifier.fillMaxWidth(),
        shape = RoundedCornerShape(20.dp),
        color = TossGreenLight
    ) {
        Row(
            modifier = Modifier.padding(20.dp),
            verticalAlignment = Alignment.CenterVertically
        ) {
            Box(
                modifier = Modifier
                    .size(48.dp)
                    .background(TossGreen.copy(alpha = 0.15f), CircleShape),
                contentAlignment = Alignment.Center
            ) {
                Icon(
                    imageVector = Icons.Default.CheckCircle,
                    contentDescription = null,
                    tint = TossGreen,
                    modifier = Modifier.size(30.dp)
                )
            }

            Spacer(Modifier.width(16.dp))

            Column {
                Text(
                    text = "저장 완료!",
                    fontWeight = FontWeight.Bold,
                    color = TossDark,
                    fontSize = 17.sp
                )
                Text(
                    text = state.statusMessage,
                    style = MaterialTheme.typography.bodyMedium,
                    color = TossGray
                )
            }
        }
    }
}

// ─── 오류 상태: 빨간 경고 카드 + 재시도 버튼 ──────────────────────

@Composable
private fun ErrorCard(
    state: DownloaderUiState.Error,
    onRetry: () -> Unit
) {
    TossCard {
        Column(modifier = Modifier.padding(20.dp)) {
            Row(verticalAlignment = Alignment.CenterVertically) {
                Box(
                    modifier = Modifier
                        .size(40.dp)
                        .background(TossRedLight, CircleShape),
                    contentAlignment = Alignment.Center
                ) {
                    Icon(
                        imageVector = Icons.Default.ErrorOutline,
                        contentDescription = null,
                        tint = TossRed,
                        modifier = Modifier.size(24.dp)
                    )
                }

                Spacer(Modifier.width(12.dp))

                Column {
                    Text(
                        text = "다운로드 실패",
                        fontWeight = FontWeight.SemiBold,
                        color = TossDark,
                        fontSize = 16.sp
                    )
                    Text(
                        text = state.message,
                        style = MaterialTheme.typography.bodyMedium,
                        color = TossGray
                    )
                }
            }

            Spacer(Modifier.height(16.dp))

            Button(
                onClick = onRetry,
                modifier = Modifier
                    .fillMaxWidth()
                    .height(52.dp),
                shape = RoundedCornerShape(14.dp),
                colors = ButtonDefaults.buttonColors(
                    containerColor = TossRed,
                    contentColor = TossWhite
                )
            ) {
                Icon(
                    Icons.Default.Refresh,
                    contentDescription = null,
                    modifier = Modifier.size(18.dp)
                )
                Spacer(Modifier.width(6.dp))
                Text("다시 시도", fontWeight = FontWeight.Bold)
            }
        }
    }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 공통 카드 컴포넌트: 소프트 그림자 + 흰 배경 + 둥근 모서리
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

@Composable
private fun TossCard(
    modifier: Modifier = Modifier,
    content: @Composable () -> Unit
) {
    Surface(
        modifier = modifier
            .fillMaxWidth()
            .shadow(
                elevation = 10.dp,
                shape = RoundedCornerShape(20.dp),
                ambientColor = Color.Black.copy(alpha = 0.06f),
                spotColor = Color.Black.copy(alpha = 0.06f)
            ),
        shape = RoundedCornerShape(20.dp),
        color = TossWhite
    ) {
        content()
    }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 미리보기 (Android Studio Preview)
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

@Preview(showBackground = true, name = "Idle - Empty URL")
@Composable
private fun PreviewIdle() {
    VideoDownloaderTheme {
        DownloaderScreen(
            url = "",
            onUrlChange = {},
            uiState = DownloaderUiState.Idle,
            onDownloadClick = {}
        )
    }
}

@Preview(showBackground = true, name = "Idle - URL Entered")
@Composable
private fun PreviewIdleWithUrl() {
    VideoDownloaderTheme {
        DownloaderScreen(
            url = "https://www.youtube.com/watch?v=dQw4w9WgXcQ",
            onUrlChange = {},
            uiState = DownloaderUiState.Idle,
            onDownloadClick = {}
        )
    }
}

@Preview(showBackground = true, name = "Downloading 47%")
@Composable
private fun PreviewDownloading() {
    VideoDownloaderTheme {
        DownloaderScreen(
            url = "https://www.youtube.com/watch?v=dQw4w9WgXcQ",
            onUrlChange = {},
            uiState = DownloaderUiState.Downloading(
                progress = 0.47f,
                progressPercent = 47,
                statusMessage = "1080p 영상 + 오디오 다운로드 중..."
            ),
            onDownloadClick = {}
        )
    }
}

@Preview(showBackground = true, name = "Updating Engine")
@Composable
private fun PreviewUpdating() {
    VideoDownloaderTheme {
        DownloaderScreen(
            url = "https://www.youtube.com/watch?v=dQw4w9WgXcQ",
            onUrlChange = {},
            uiState = DownloaderUiState.Updating(
                statusMessage = "최신 yt-dlp 버전으로 업데이트 중..."
            ),
            onDownloadClick = {}
        )
    }
}

@Preview(showBackground = true, name = "Success")
@Composable
private fun PreviewSuccess() {
    VideoDownloaderTheme {
        DownloaderScreen(
            url = "https://www.youtube.com/watch?v=dQw4w9WgXcQ",
            onUrlChange = {},
            uiState = DownloaderUiState.Success(
                statusMessage = "갤러리에서 확인하세요!"
            ),
            onDownloadClick = {}
        )
    }
}

@Preview(showBackground = true, name = "Error")
@Composable
private fun PreviewError() {
    VideoDownloaderTheme {
        DownloaderScreen(
            url = "https://www.youtube.com/watch?v=dQw4w9WgXcQ",
            onUrlChange = {},
            uiState = DownloaderUiState.Error(
                message = "네트워크 연결을 확인하거나 다시 시도해 주세요."
            ),
            onDownloadClick = {}
        )
    }
}
