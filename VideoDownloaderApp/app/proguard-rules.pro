# youtubedl-android 라이브러리 ProGuard 규칙
-keep class com.yausername.** { *; }
-keep class com.yausername.youtubedl_android.** { *; }

# Kotlin Coroutines
-keepnames class kotlinx.coroutines.internal.MainDispatcherFactory {}
-keepnames class kotlinx.coroutines.CoroutineExceptionHandler {}

# Compose
-keep class androidx.compose.** { *; }
