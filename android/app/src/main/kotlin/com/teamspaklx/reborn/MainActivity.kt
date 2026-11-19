package com.teamspaklx.reborn

import android.os.Build
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

/// local_auth(Face ID·지문·기기 암호)가 FragmentActivity를 요구해서 FlutterFragmentActivity를 쓴다.
class MainActivity : FlutterFragmentActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        // 앱 잠금이 켜져 있으면 최근 앱(앱 전환) 화면에 기록 미리보기를 남기지 않는다(Android 13+).
        // 그보다 낮은 버전은 Flutter 쪽 로고 덮개로 가린다. Dart: lib/core/platform/device_auth_service.dart
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "reborn/app_lock")
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "setRecentsPreviewHidden" -> {
                        val hidden = call.arguments as? Boolean ?: false
                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                            setRecentsScreenshotEnabled(!hidden)
                        }
                        result.success(null)
                    }
                    else -> result.notImplemented()
                }
            }
    }
}
