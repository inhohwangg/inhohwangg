package com.example.videodownloader

import android.app.Application
import android.util.Log
import com.yausername.ffmpeg.FFmpeg
import com.yausername.youtubedl_android.YoutubeDL

class VideoDownloaderApplication : Application() {

    override fun onCreate() {
        super.onCreate()
        initLibraries()
    }

    private fun initLibraries() {
        try {
            // 네이티브 라이브러리 및 Python 런타임 초기화
            YoutubeDL.getInstance().init(this)
            FFmpeg.getInstance().init(this)
            Log.d(TAG, "YoutubeDL + FFmpeg 초기화 완료")
        } catch (e: Exception) {
            // 초기화 실패 시 앱이 죽지 않도록 처리
            // 첫 다운로드 시도 때 에러가 발생하면 자동 업데이트가 처리함
            Log.e(TAG, "라이브러리 초기화 실패 — 첫 다운로드 시 자동 복구 시도", e)
        }
    }

    companion object {
        private const val TAG = "VideoDownloaderApp"
    }
}
