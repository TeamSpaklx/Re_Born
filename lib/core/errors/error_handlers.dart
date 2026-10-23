import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_text_styles.dart';
import 'app_error_log.dart';

/// 처리되지 않은 오류를 [log]에 남기고, 화면이 깨졌을 때 빨간 오류 화면 대신 안내를 보여 준다.
/// 앱 시작(`main.dart`)에서 한 번 부른다.
void installErrorHandlers(AppErrorLog log) {
  final previous = FlutterError.onError;
  FlutterError.onError = (details) {
    log.record(details.exception, details.stack, where: 'flutter');
    // 개발 중에는 콘솔에도 평소처럼 보여 준다.
    if (kDebugMode) {
      previous?.call(details);
    }
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    log.record(error, stack, where: 'platform');
    return true;
  };

  // 앱 배포판에서는 위젯 오류가 나도 빨간 화면 대신 안내를 보여 준다.
  if (kReleaseMode) {
    ErrorWidget.builder = (details) => const AppErrorFallback();
  }
}

/// 위젯을 그리다 오류가 났을 때 그 자리에 보여 주는 안내.
class AppErrorFallback extends StatelessWidget {
  const AppErrorFallback({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.light.background,
      alignment: Alignment.center,
      padding: const EdgeInsets.all(24),
      child: Text(
        '화면을 불러오지 못했어요.\n잠시 뒤 다시 시도해 주세요.',
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
        style: AppTextStyles.body.copyWith(
          color: AppColors.light.textSecondary,
          decoration: TextDecoration.none,
        ),
      ),
    );
  }
}
