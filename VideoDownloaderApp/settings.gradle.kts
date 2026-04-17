pluginManagement {
    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}

dependencyResolutionManagement {
    repositoriesMode.set(RepositoriesMode.FAIL_ON_PROJECT_REPOS)
    repositories {
        google()
        mavenCentral()
        // youtubedl-android 라이브러리 소스
        maven { url = uri("https://jitpack.io") }
    }
}

rootProject.name = "VideoDownloader"
include(":app")
