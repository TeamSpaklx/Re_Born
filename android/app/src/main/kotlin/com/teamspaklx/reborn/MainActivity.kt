package com.teamspaklx.reborn

import android.media.AudioAttributes
import android.os.Build
import android.os.VibrationAttributes
import android.os.VibrationEffect
import android.os.Vibrator
import android.os.VibratorManager
import android.view.HapticFeedbackConstants
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

        // 햅틱. Flutter 기본 HapticFeedback은 View.performHapticFeedback(CLOCK_TICK·VIRTUAL_KEY)을 써서
        // 기기에 따라(특히 삼성) 거의 느껴지지 않는다. 기기 제조사가 맞춰 둔 기본 효과(틱·클릭)를 직접 재생한다.
        // Dart: lib/core/platform/android_haptics.dart
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "reborn/haptics")
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "selection" -> { playHaptic(selection = true); result.success(null) }
                    "tap" -> { playHaptic(selection = false); result.success(null) }
                    else -> result.notImplemented()
                }
            }
    }

    /// [selection]: 선택이 바뀜(가벼운 틱). 아니면 버튼 누름(클릭).
    /// 사용자가 시스템 설정에서 터치 진동을 끄면 따른다(Android 13+는 USAGE_TOUCH가 그 설정을 본다).
    private fun playHaptic(selection: Boolean) {
        val vibrator = vibrator()
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q && vibrator?.hasVibrator() == true) {
            val effect = VibrationEffect.createPredefined(
                if (selection) VibrationEffect.EFFECT_TICK else VibrationEffect.EFFECT_CLICK,
            )
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                vibrator.vibrate(
                    effect,
                    VibrationAttributes.createForUsage(VibrationAttributes.USAGE_TOUCH),
                )
            } else {
                @Suppress("DEPRECATION")
                vibrator.vibrate(
                    effect,
                    AudioAttributes.Builder()
                        .setUsage(AudioAttributes.USAGE_ASSISTANCE_SONIFICATION)
                        .setContentType(AudioAttributes.CONTENT_TYPE_SONIFICATION)
                        .build(),
                )
            }
            return
        }
        // Android 9 이하이거나 진동 장치를 못 찾으면 화면(View)의 햅틱으로.
        window.decorView.performHapticFeedback(
            if (selection) HapticFeedbackConstants.CLOCK_TICK else HapticFeedbackConstants.VIRTUAL_KEY,
        )
    }

    private fun vibrator(): Vibrator? =
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            getSystemService(VibratorManager::class.java)?.defaultVibrator
        } else {
            @Suppress("DEPRECATION")
            getSystemService(Vibrator::class.java)
        }
}
