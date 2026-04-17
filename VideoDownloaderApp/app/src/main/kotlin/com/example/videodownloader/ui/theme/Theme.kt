package com.example.videodownloader.ui.theme

import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.lightColorScheme
import androidx.compose.runtime.Composable

private val LightColorScheme = lightColorScheme(
    primary            = TossBlue,
    onPrimary          = TossWhite,
    primaryContainer   = TossBlueLight,
    onPrimaryContainer = TossBlueDark,
    background         = TossLightGray,
    onBackground       = TossDark,
    surface            = TossWhite,
    onSurface          = TossDark,
    surfaceVariant     = TossLightGray,
    onSurfaceVariant   = TossGray,
    outline            = TossBorder,
    error              = TossRed,
    onError            = TossWhite
)

@Composable
fun VideoDownloaderTheme(content: @Composable () -> Unit) {
    MaterialTheme(
        colorScheme = LightColorScheme,
        typography  = VideoDownloaderTypography,
        content     = content
    )
}
